# Checklist de Limpieza de Base de Datos Provisional

Este checklist asegura una transición limpia a la base de datos de producción sin dejar rastro de los datos de prueba, manteniendo la integridad de la configuración.

## 1. Backup de Configuración (Opcional pero recomendado)
- [ ] Exportar Reglas de Seguridad actuales a un archivo local.
- [ ] Documentar Índices Compuestos creados manualmente.

## 2. Limpieza de Colecciones (Datos de Prueba)
- [ ] Eliminar todos los documentos de la colección `users` (excepto los administradores si ya fueron creados en Auth).
- [ ] Eliminar colección `students` (obsoleta tras la unificación).
- [ ] Eliminar colección `coaches` (obsoleta tras la unificación).
- [ ] Eliminar colección `announcements`.
- [ ] Eliminar colección `events`.
- [ ] Eliminar colección `assignments`.
- [ ] Eliminar colección `rotations`.
- [ ] Eliminar colección `attendance`.
- [ ] Eliminar colección `achievements`.
- [ ] Eliminar colección `trials`.
- [ ] Eliminar colección `metrics` (o resetear el documento `general`).

## 3. Verificación de Reglas de Seguridad
- [ ] Asegurar que no existan reglas basadas en colecciones eliminadas (`students`, `coaches`).
- [ ] Validar que la regla de `users` permita lectura/escritura basada en el nuevo esquema unificado.

## 4. Gestión de Índices
- [ ] Eliminar índices compuestos que ya no se usen (ej: aquellos que apuntaban a la colección `students`).
- [ ] Verificar que existan los índices necesarios para las nuevas queries (ej: `users` con filtro `role` y ordenamiento).

## 5. Cloud Functions / Triggers
- [ ] Desactivar triggers temporales de desarrollo.
- [ ] Limpiar logs de funciones para iniciar monitoreo de producción desde cero.
- [ ] Verificar que las funciones de envío de notificaciones apunten a la colección `users` correcta.

## 6. Firebase Auth
- [ ] Eliminar usuarios de prueba en la consola de Firebase Authentication para evitar conflictos de email.
