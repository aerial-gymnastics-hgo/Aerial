/**
 * Cloud Functions de Aerial Gymnastics Pachuca (proyecto aerial-temporal).
 *
 * registerStudent: crea la cuenta de una alumna con el Admin SDK para que
 * la sesión del admin que la registra NO se vea afectada (Tarea 5 de la
 * auditoría: el cliente llamaba createUserWithEmailAndPassword y deslogueaba
 * al admin).
 */

import {setGlobalOptions} from "firebase-functions";
import {onCall, HttpsError} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore, Timestamp, FieldValue} from "firebase-admin/firestore";

initializeApp();

setGlobalOptions({maxInstances: 10});

const ALLOWED_ROLES = ["admin", "caja"];

interface RegisterStudentData {
  email?: string;
  password?: string;
  name?: string;
  groupId?: string;
  birthDate?: string; // ISO-8601, ej. "2015-06-12"
  phone?: string;
  parentName?: string;
  parentPhone?: string;
  parentEmail?: string;
  photoUrl?: string;
}

/**
 * Genera una contraseña temporal aleatoria para la cuenta nueva.
 * La familia puede cambiarla después vía "Olvidé mi contraseña".
 * @return {string} contraseña de 12 caracteres.
 */
function generateTempPassword(): string {
  const chars =
    "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!#$%";
  let out = "";
  for (let i = 0; i < 12; i++) {
    out += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return out;
}

export const registerStudent = onCall(
  {
    memory: "256MiB",
    timeoutSeconds: 30,
    maxInstances: 10,
  },
  async (request) => {
    // 1. Autenticación: solo usuarios logueados pueden llamar
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Debes iniciar sesión para registrar alumnas.",
      );
    }

    const db = getFirestore();
    const auth = getAuth();

    // 2. Autorización: el rol se lee de users/{uid}, igual que en
    //    firestore.rules
    const callerDoc = await db
      .collection("users")
      .doc(request.auth.uid)
      .get();
    const callerRole = callerDoc.data()?.role;
    if (!callerDoc.exists || !ALLOWED_ROLES.includes(callerRole)) {
      throw new HttpsError(
        "permission-denied",
        "Solo admin o caja pueden registrar alumnas.",
      );
    }

    // 3. Validación de entrada
    const data = (request.data ?? {}) as RegisterStudentData;
    const email = (data.email ?? "").trim().toLowerCase();
    const name = (data.name ?? "").trim();
    const groupId = (data.groupId ?? "").trim();

    if (!email || !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
      throw new HttpsError(
        "invalid-argument",
        "El email de la alumna es obligatorio y debe ser válido.",
      );
    }
    if (!name) {
      throw new HttpsError(
        "invalid-argument",
        "El nombre de la alumna es obligatorio.",
      );
    }
    if (!groupId) {
      throw new HttpsError(
        "invalid-argument",
        "El grupo de la alumna es obligatorio.",
      );
    }

    let birthDate: Timestamp | null = null;
    if (data.birthDate) {
      const parsed = new Date(data.birthDate);
      if (isNaN(parsed.getTime())) {
        throw new HttpsError(
          "invalid-argument",
          "birthDate debe ser una fecha ISO válida (ej. 2015-06-12).",
        );
      }
      birthDate = Timestamp.fromDate(parsed);
    }

    const password = data.password && data.password.length >= 6 ?
      data.password :
      generateTempPassword();

    // 4. Crear el usuario en Firebase Auth con el Admin SDK.
    //    Esto NO toca la sesión del cliente: el admin sigue logueado.
    let uid: string;
    try {
      const userRecord = await auth.createUser({
        email: email,
        password: password,
        displayName: name,
      });
      uid = userRecord.uid;
    } catch (err) {
      const code = (err as {code?: string}).code ?? "";
      if (code === "auth/email-already-exists") {
        throw new HttpsError(
          "already-exists",
          `Ya existe una cuenta con el email ${email}.`,
        );
      }
      if (code === "auth/invalid-password") {
        throw new HttpsError(
          "invalid-argument",
          "La contraseña debe tener al menos 6 caracteres.",
        );
      }
      logger.error("registerStudent: fallo creando usuario en Auth", err);
      throw new HttpsError(
        "internal",
        "No se pudo crear la cuenta en Firebase Auth.",
      );
    }

    // 5. Escribir el perfil en Firestore. Si falla, rollback del Auth user
    //    para no dejar cuentas huérfanas sin documento.
    try {
      await db.collection("users").doc(uid).set({
        uid: uid,
        email: email,
        name: name,
        groupId: groupId,
        // La app lee 'group' y 'guardian*' (_userFromFirestore); se
        // escriben espejados para compatibilidad con las pantallas
        // existentes.
        group: groupId,
        birthDate: birthDate,
        phone: data.phone ?? null,
        role: "student",
        createdAt: FieldValue.serverTimestamp(),
        parentName: data.parentName ?? null,
        parentPhone: data.parentPhone ?? null,
        parentEmail: data.parentEmail ?? null,
        guardianName: data.parentName ?? null,
        guardianPhone: data.parentPhone ?? null,
        guardianEmail: data.parentEmail ?? null,
        photoUrl: data.photoUrl ?? null,
        active: true,
        registeredBy: request.auth.uid,
      });
    } catch (err) {
      logger.error(
        "registerStudent: fallo escribiendo users/" + uid +
        ", haciendo rollback de Auth",
        err,
      );
      try {
        await auth.deleteUser(uid);
      } catch (rollbackErr) {
        logger.error(
          "registerStudent: rollback de Auth falló para " + uid,
          rollbackErr,
        );
      }
      throw new HttpsError(
        "internal",
        "No se pudo guardar el perfil de la alumna. Intenta de nuevo.",
      );
    }

    logger.info(
      `registerStudent: alumna ${name} (${uid}) registrada por ` +
      `${request.auth.uid} en grupo ${groupId}`,
    );

    return {
      success: true,
      uid: uid,
      email: email,
      message: `Alumna ${name} registrada correctamente.`,
    };
  },
);
