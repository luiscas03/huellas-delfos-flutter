# Huellas del FOS (Flutter)

Proyecto Flutter con 13 pantallas replicadas desde las capturas. Incluye arquitectura feature‑first, navegación con `go_router`, configuración de conexión, offline‑first + sync, multimedia (imágenes, audio y firma) y wakelock.

## Configuración de conexión

Editar desde la app en `Configuración / Conexiones`:
- `baseUrl` (obligatorio)
- `timeout` (segundos)
- `headers` personalizados
- `auth` (None / Bearer Token / ApiKey Header) + valor

Los valores se guardan con:
- `shared_preferences` para opciones no sensibles
- `flutter_secure_storage` para tokens/keys

### Endpoints

No se inventaron URLs. Debes completar las rutas reales en:
- `lib/core/network/api_paths.dart`

## Supabase (Lovable)

Completa tus credenciales en:
- `lib/core/network/supabase_config.dart`

Campos:
- `url`
- `anonKey`

Notas:
- El payload en `ClosureScreen` ya usa `profiles`/`visitors` si existen.

## Offline + Sync

- Si no hay internet, el registro se guarda localmente y queda como **Pendiente de sincronizar**.
- Cuando vuelva internet, se sincroniza automáticamente al detectar conectividad.
- La cola se maneja en la tabla `pending_sync` (SQLite).

Rutas de archivos locales:
```
/records/{localId}/images/
/records/{localId}/audios/
/records/{localId}/signature/
```

## Audio (formato requerido)

Se graba en `.m4a` con AAC:
- Sample rate: 48000 Hz
- Mono
- Bitrate: 32 kbps
- CBR

Nota: algunos dispositivos no soportan bit depth 32 para AAC. Se prioriza AAC + 48kHz + mono + 32kbps + CBR.

## Permisos

- Cámara
- Micrófono
- Almacenamiento

Si el permiso se niega, la app muestra explicación y botón **Ir a ajustes**.

## Cómo ejecutar

```
flutter pub get
flutter run
```

## Cómo probar offline/sync

1. Activa modo avión.
2. En la app, completa el flujo hasta **Confirmar y Finalizar**.
3. Aparecerá como **pendiente de sincronizar**.
4. Desactiva modo avión: la sync se ejecuta automáticamente.
