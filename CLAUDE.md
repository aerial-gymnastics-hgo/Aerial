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
- `ReceiptCaptureService` y `ExcelExportService` usan `dart:io` — no funcionan en web; tratar su uso como opcional con try/catch.

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
- [x] **Tarea 8** — Limpieza de código muerto: eliminados FABs "Fix Colors" y "Migrar" + métodos _executeMigration, _createAllSlots, _get*Slots, _updateCoachColors de `admin_role_builder.dart`; eliminados todos los prints de debug de `schedule_grid_view.dart` y _debugDirectQuery de `admin_dashboard.dart`; eliminados 23 scripts de parcheo de la raíz y 2 archivos de backup. Total: -594 líneas de código muerto.

### Pendiente
- [ ] **Tarea 4** — Reportes de adeudos y cumpleaños usan datos simulados (`id.contains('a')`, `name.length % 12`). Reemplazar con consultas reales a Firestore.
- [ ] **Tarea 5** — Registro de alumnas llama `createUserWithEmailAndPassword` desde el cliente → desloguea al admin. Mover a Firebase Function o flujo separado.
- [ ] **Tarea 6** — Colecciones `evaluations` y `achievements` no tienen ningún writer en la app. Implementar pantallas de captura.
- [ ] **Tarea 7** — Reglas de Firestore no están en el repo (`firestore.rules`). Crear y versionar.
- [ ] **Tarea 9** — `rotation_sabana_screen.dart` ignora tap en celda vacía (`if (slot == null) return`). Limpiar.
- [ ] **Tarea 10** — `ExcelExportService` usa `dart:io`; en web falla silenciosamente. Migrar a `universal_html` / descarga por bytes.
- [ ] **Tarea 11** — `admin_objectives_editor.dart` guarda claves de grupo capitalizadas; las consultas usan minúsculas → mismatch. Normalizar.
- [ ] **Tarea 12** — `trial_class_registration_form.dart` lee `trial_class_requests` sin auth → expone conteo de solicitudes a usuarios anónimos. Mover lógica al backend.
