# Plan de Rollback (Reversión de Migración)

En caso de que la inyección de datos reales cause fallos críticos o inconsistencias, siga estos pasos para restaurar la operatividad del sistema.

## Escenario A: Fallo durante la inyección (Datos corruptos)
1. **Identificación**: La app muestra pantallas blancas o errores de "TypeError" al leer campos.
2. **Acción Inmediata**: Detener el script de inyección.
3. **Limpieza**: Ejecutar un script de borrado masivo en las colecciones afectadas (puedes usar el Firebase CLI: `firebase firestore:delete --all-collections`).
4. **Restauración**: Re-inyectar el `sample_data.json` original de desarrollo para mantener la app funcional mientras se depura el set de datos reales.

## Escenario B: Inconsistencia de Roles (Usuarios no pueden entrar)
1. **Verificación**: Comprobar en Firestore si los UIDs coinciden con los de Firebase Authentication.
2. **Corrección Manual**: Si el error es en un usuario específico (ej: el admin), corregir el campo `role` directamente en la consola de Firebase.
3. **Rollback Auth**: Si se crearon cuentas de Auth masivamente de forma errónea, eliminarlas y re-crearlas usando el `RegistrationService` que ya validamos.

## Escenario C: Fallo de Reglas de Seguridad
1. **Síntoma**: Errores de "Permission Denied" en la consola de la app.
2. **Acción**: Restaurar el archivo de reglas `firestore.rules` que se respaldó antes de iniciar la migración.

## Puntos de Control de No-Retorno
- Antes de borrar los datos provisionales, asegúrese de tener el archivo `sample_data.json` a la mano.
- No borre usuarios de Firebase Authentication hasta confirmar que la inyección en Firestore ha fallado irremediablemente y requiere un reinicio total.
