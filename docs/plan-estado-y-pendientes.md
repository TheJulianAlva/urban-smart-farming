# Plan de estado y pendientes — Urban Smart Farming

> Actualizado el 2026-05-17. Estado verificado contra código fuente y Supabase.

---

## 1. Visión general del proyecto

App móvil Flutter para monitoreo y control de cultivos urbanos inteligentes.

| Capa | Tecnología |
|---|---|
| Frontend | Flutter + Clean Architecture + BLoC |
| Backend | FastAPI (Python), corriendo en IP local |
| Base de datos / Auth | Supabase (PostgreSQL) |
| IoT | MQTT via HiveMQ Cloud (TLS) |
| IA | Google Gemini Vision API (gemini-2.5-flash) |

---

## 2. Estado actual verificado

### 2.1 Base de datos (Supabase — proyecto `ubojiqlbmwqwbofrxkea`)

| Tabla | Columnas relevantes | RLS | Políticas |
|---|---|---|---|
| `User` | id, full_name, email | ✅ ON | SELECT y UPDATE propios |
| `CropProfile` | id, creator_id, profile_name, min_moisture, max_moisture, ideal_temperature, min_light_percentage | ✅ ON | SELECT perfiles propios + predefinidos (creator_id IS NULL); ALL propios |
| `Crop` | id, user_id, profile_id, custom_name, location, health_status, planting_date, icon_storage_url | ✅ ON | SELECT/INSERT/UPDATE/DELETE propios |
| `Device` | id, crop_id, mac_address, last_heartbeat | ✅ ON | ALL via join con Crop |
| `SensorReading` | id, device_id, avg_soil_moisture, avg_temperature, avg_light, recorded_at | ✅ ON | SELECT via join Device→Crop (user_id) |
| `ActuationEvent` | id, device_id, crop_id, actuator_type, triggered_by, duration_seconds, started_at, action | ✅ ON | SELECT via join Device→Crop (user_id) |
| `VisionAnalysis` | id, crop_id, diagnosis, suggested_treatment, confidence_percentage, analysis_date | ✅ ON | SELECT via crop_id |
| `Alert` | id, user_id, device_id, alert_type, message, is_resolved, notification_sent, notification_channel, created_at, resolved_at | ✅ ON | ALL propios |

**Seed data aplicado:** 10 perfiles predefinidos con `creator_id = NULL`:
Lechuga, Tomate cherry, Albahaca, Espinaca, Rábano, Tagete, Caléndula, Lavanda, Pensamiento, Alegría de la casa.

---

### 2.2 Backend (FastAPI)

Todos los routers están registrados en `main.py` y todos los servicios implementados.

| Componente | Estado |
|---|---|
| `routers/users.py` + `routers/vision.py` | ✅ Registrado y funcional |
| `routers/crops.py` | ✅ Registrado — GET list, GET by id, POST create, DELETE |
| `routers/devices.py` | ✅ Registrado — POST /register, GET list, DELETE |
| `routers/alerts.py` | ✅ Registrado — GET list, PATCH /{id}/resolve |
| `routers/history.py` | ✅ Registrado — GET /latest, GET / (con rango day/week/month) |
| `routers/actuators.py` | ✅ Registrado — POST /{device_id}/actuate |
| `services/crops_service.py` | ✅ Existe — CRUD completo |
| `services/devices_service.py` | ✅ Existe — registro, listado, eliminación con validación MAC única |
| `services/alerts_service.py` | ✅ Existe — listado y resolución |
| `services/history_service.py` | ✅ Existe — lecturas históricas y última lectura |
| `services/actuators_service.py` | ✅ Existe — MQTT publish + ActuationEvent + gestión de alertas |
| `services/gemini_service.py` | ✅ `_USE_MOCK = False` — Gemini Vision API real activa |
| `services/mqtt_handler.py` | ✅ Lookup correcto Device→Crop→CropProfile; inserts completos (user_id, crop_id, action) |

---

### 2.3 Frontend (Flutter)

| Feature | UI | Datos |
|---|---|---|
| Auth (login/registro) | ✅ Completo | ✅ Real (Supabase Auth) |
| CropListScreen + navegación | ✅ Completo | ✅ Real (Supabase directo) |
| Wizard de creación de cultivos | ✅ Completo | ✅ Real (POST /api/v1/crops con profile_id UUID) |
| DashboardScreen (3 métricas: temp, humedad, luz) | ✅ Completo | ✅ Real (GET /api/v1/sensor-readings/latest) |
| ControlScreen (bomba + LED) | ✅ Completo | ✅ Real (POST /api/v1/devices/{id}/actuate) |
| AiDiagnosisScreen | ✅ Completo | ✅ Real (Gemini Vision) |
| AnalyticsScreen (3 gráficos: temp, humedad, luz) | ✅ Completo | ✅ Real (GET /api/v1/sensor-readings?range=) |
| SettingsScreen | ✅ Completo | — |
| CropsBloc.deleteCrop | ✅ UI | ✅ Real (DELETE /api/v1/crops/{id}) |

**Configuración:**
- `AppConfig.backendBaseUrl` usa `String.fromEnvironment('BACKEND_URL', defaultValue: 'http://192.168.68.110:8000')` — configurable por `--dart-define` en builds.

---

## 3. Pendientes / deuda técnica

Las 7 fases del plan original están **completas**. Lo que sigue son mejoras identificadas durante la implementación:

### 3.1 Pot data sigue siendo mock

`CropRepositoryImpl.getUserCrops()` construye cada `CropEntity` con un `MockPotFactory.createMockPot()` hardcodeado. Los datos reales del hardware están en la tabla `Device`. La migración requiere:
- Cambiar la query de `Crop` para hacer JOIN con `Device`
- Mapear `Device` → `PotEntity`
- Eliminar `mock_pot_factory.dart`

### 3.2 `updateCrop()` no implementado en backend

`CropRepositoryImpl.updateCrop()` devuelve la entidad sin cambios. No hay UI que lo llame actualmente. Pendiente si se necesita editar nombre/ubicación/perfil de cultivos existentes.

### 3.3 No hay pantallas para Devices ni Alerts en Flutter

El backend tiene endpoints completos para dispositivos (`/api/v1/devices`) y alertas (`/api/v1/alerts`), pero el frontend no tiene screens para:
- Registrar un dispositivo físico desde la app (actualmente solo vía API directa)
- Ver y resolver alertas activas

### 3.4 Sistema de notificaciones push no implementado

La tabla `Alert` tiene columnas `notification_sent` y `notification_channel`, pero no hay lógica para enviar push notifications (FCM/APNs). El campo `notification_sent` queda siempre en `false`.

### 3.5 8 warnings en `flutter analyze`

Ninguno es error de compilación. Están en archivos no tocados por el plan principal:

| Archivo | Warning |
|---|---|
| `crop_repository_impl.dart:62` | `unnecessary_cast` |
| `control_screen.dart:306` | `prefer_typing_uninitialized_variables` |
| `control_screen.dart:361` | `unnecessary_brace_in_string_interps` |
| `crop_list_screen.dart:374` | `deprecated_member_use` (withOpacity → withValues) |
| `wizard_step_2_hardware.dart:200,201,214,215` | `deprecated_member_use` (Radio groupValue/onChanged → RadioGroup) |

---

## 4. Orden sugerido para los pendientes

```
3.1 Pot real (Device → PotEntity)        — impacto visual inmediato
3.3 DevicesScreen + AlertsScreen          — funcionalidad nueva completa
3.2 updateCrop()                          — baja prioridad (sin UI)
3.4 Push notifications                    — requiere setup FCM/APNs
3.5 Limpiar warnings de analyze           — cosmético
```

---

## 5. Verificación de sistema completo

Para confirmar end-to-end con hardware real:

1. `uvicorn app.main:app --reload` arranca sin errores; `GET /docs` muestra los 12 endpoints activos.
2. Registrar un dispositivo vía `POST /api/v1/devices/register` con `crop_id` y `mac_address`.
3. El dispositivo publica telemetría MQTT en `usf/telemetria/{mac}` → aparece fila en `SensorReading`.
4. Dashboard Tab → muestra datos reales de temperatura, humedad y luz.
5. Control Tab → toggle bomba → aparece fila en `ActuationEvent` con `action='on'`.
6. Analytics Tab → SegmentedButton día/semana/mes → gráficos con histórico real.
7. Wizard de creación → cultivo aparece en tabla `Crop` con `profile_id` correcto (UUID de CropProfile).
8. Swipe delete en lista → fila eliminada de `Crop`.
9. AiDiagnosis Tab → subir foto → respuesta real de Gemini Vision (no mock hardcodeado).
10. Telemetría con `moisture < min_moisture` → fila en `Alert` con `user_id`, `device_id` y fila en `ActuationEvent` con `action='on'`.
