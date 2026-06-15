# Aerial Gymnastics – Contexto Maestro

## Proyecto
App Flutter web para gimnasio Aerial Gymnastics Pachuca.
- **URL**: aerialgymnasticspachuca.netlify.app (Netlify)
- **Firebase**: proyecto `aerial-temporal` (Auth, Firestore, Storage)
- **Escala**: 156 alumnas, 10 grupos, 9 coaches
- **Roles**: Admin, Coach, Caja, Alumna, Padre

## Reglas críticas (nunca romper)
- **NUNCA modificar `user_model.dart` directamente.**
- **Todos los writes a Firestore deben ir por `FirestoreService`** (`lib/services/firestore_service.dart`).
- `ReceiptCaptureService` es un stub sin-op en web (devuelve null). `ExcelExportService.downloadReport()` usa `dart:html` Blob en web y `share_plus` en nativo.

## Arquitectura clave
- Flujo de pagos correcto: `PaymentDialog` → `PaymentService.registerPayment` → Firestore colección `payments` con campos `paidAt`, `folio` (formato `AER-YYYY-NNNNN`), `registeredBy`.
- Colecciones Firestore: `users`, `payments`, `rotations`, `events`, `announcements`, `groups`, `mesocycles`, `achievements`, `attendance`, `trial_class_requests`, `evaluations`.
- Tema: dark glassmorphism, Material Design 3, locale español.
- Imágenes de perfil: usar siempre `getProfileImageProvider(photoUrl)` de `lib/utils/image_helper.dart`.

## Estado de la auditoría (2026-06-09)

### Resuelto
- [x] **Tarea 1** — Backdoor en `auth_service.dart` eliminado (commit `0d9af27`).
- [x] **Tarea 2** — Cobros de Caja y Admin unificados sobre `PaymentDialog` + `PaymentService` (commit `dfaf61b`). `payment_dialog.dart` robusto en web (preview de recibo en try/catch separado).
- [x] **Tarea 3** — Avisos unificados: `_showAddAnnouncementDialog` ahora usa `FirestoreService.instance.saveEvent(SystemEvent(..., type:'announcement'))` → escribe a `events`. Añadido chip "🤸 Alumnas" (targetRole:'student'). Eliminado import `announcement_model.dart`.
- [x] **Tarea 6** — Asistencia consistente sin duplicados: saveAttendance usa ID determinista {studentId}_{yyyy-MM-dd} con SetOptions(merge:true) en lugar de .add(); parámetro groupId agregado; getAttendanceStats cuenta días con 'late' en lugar de minutos; widget AttendanceButton unificado (lib/widgets/attendance_button.dart) con ciclo: sin marcar→present→late→absent→sin marcar, borra doc al volver a sin marcar; ciclos en coach_dashboard.dart y coach_session_screen.dart ahora idénticos.
- [x] **Tarea 8** — Limpieza de código muerto: eliminados FABs "Fix Colors" y "Migrar" + métodos _executeMigration, _createAllSlots, _get*Slots, _updateCoachColors de `admin_role_builder.dart`; eliminados todos los prints de debug de `schedule_grid_view.dart` y _debugDirectQuery de `admin_dashboard.dart`; eliminados 23 scripts de parcheo de la raíz y 2 archivos de backup. Total: -594 líneas de código muerto.

- [x] **Tarea 9** — ExcelExportService refactorizado: `generateBytes()` → `Uint8List`; `downloadReport()` usa `dart:html` Blob+anchor en web y `share_plus XFile.fromData` en nativo. `ReceiptCaptureService` reemplazado por stub sin-op (eliminados `screenshot` y `path_provider` de pubspec). `flutter build web` pasa limpio.
- [x] **Analytics** — `admin_analytics_screen.dart` corregido: campo `paidAt` en pagos, `timestamp` en asistencia; `hasError` muestra error en pantalla.

- [x] **Tarea 7** — `firestore.rules` creado y versionado. Reglas basadas en rol leído de `users/{uid}.role` en Firestore. `firebase.json` actualizado para deploy con Firebase CLI (`firebase deploy --only firestore:rules`).

- [x] **Tarea 4** — Reportes con datos reales: nuevo `FirestoreService.getStudentIdsPaidThisMonth()` (una query por rango de `paidAt` del mes, filtro de concepto "Mensualidad" en cliente). Deudora = sin pago de mensualidad este mes; monto = `monthlyFee` de la alumna o del grupo (`getGroupInfo`). Cumpleaños usa `birthDate` real (filtra por mes, excluye nulls, ordena por día). Aplicado en `admin_reports_hub.dart`, `pdf_service.dart` (`generateDebtorsPdf` ahora recibe `Map<String,double>` de montos) y `admin_payment_entry_screen.dart` (refresca al cerrar PaymentDialog).

### Pendiente
- [ ] **Tarea 5** — Registro de alumnas llama `createUserWithEmailAndPassword` desde el cliente → desloguea al admin. Mover a Firebase Function o flujo separado.
- [ ] **Tarea 10** — Colecciones `evaluations` y `achievements` no tienen ningún writer en la app. Implementar pantallas de captura.
- [ ] **Tarea 11** — `admin_objectives_editor.dart` guarda claves de grupo capitalizadas; las consultas usan minúsculas → mismatch. Normalizar.
- [ ] **Tarea 12** — `trial_class_registration_form.dart` lee `trial_class_requests` sin auth → expone conteo de solicitudes a usuarios anónimos. Mover lógica al backend.
