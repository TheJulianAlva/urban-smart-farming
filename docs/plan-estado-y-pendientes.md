# Plan de estado y pendientes — Urban Smart Farming

> Generado el 2026-05-09. Refleja el estado real verificado: código fuente + base de datos Supabase consultada vía MCP.

---

## 1. Visión general del proyecto

App móvil Flutter para monitoreo y control de cultivos urbanos inteligentes.

| Capa | Tecnología |
|---|---|
| Frontend | Flutter + Clean Architecture + BLoC |
| Backend | FastAPI (Python), corriendo en IP local |
| Base de datos / Auth | Supabase (PostgreSQL) |
| IoT | MQTT via HiveMQ Cloud (TLS) |
| IA | Google Gemini Vision API |

---

## 2. Estado actual verificado

### 2.1 Base de datos (Supabase — proyecto `ubojiqlbmwqwbofrxkea`)

**8 migraciones ya aplicadas.** Todas las tablas existen y están vacías (0 filas).

| Tabla | Columnas relevantes | RLS | Políticas |
|---|---|---|---|
| `User` | id, full_name, email | ✅ ON | SELECT y UPDATE propios |
| `CropProfile` | id, creator_id, profile_name, min_moisture, max_moisture, ideal_temperature, min_light_percentage | ❌ **OFF** | Ninguna |
| `Crop` | id, user_id, profile_id, custom_name, location, health_status, planting_date, icon_storage_url | ✅ ON | SELECT/INSERT/UPDATE/DELETE propios |
| `Device` | id, crop_id, mac_address, last_heartbeat | ✅ ON | ALL via join con Crop |
| `SensorReading` | id, device_id, avg_soil_moisture, avg_temperature, avg_light, recorded_at | ✅ ON | **Sin políticas** |
| `ActuationEvent` | id, device_id, crop_id, actuator_type, triggered_by, duration_seconds, started_at | ✅ ON | **Sin políticas** |
| `VisionAnalysis` | id, crop_id, diagnosis, suggested_treatment, confidence_percentage, analysis_date | ✅ ON | **Sin políticas** |
| `Alert` | id, user_id, device_id, alert_type, message, is_resolved, notification_sent, notification_channel, created_at, resolved_at | ✅ ON | ALL propios |

**Problemas detectados en el esquema:**

1. `SensorReading` **no tiene columna `ph`** — el frontend la espera.
2. `ActuationEvent` **no tiene columna `action`** (on/off) — imposible saber el estado del actuador.
3. `CropProfile` tiene **RLS desactivado** — cualquier usuario autenticado puede leer/modificar todos los perfiles. ⚠️ Riesgo de seguridad.
4. `SensorReading`, `ActuationEvent`, `VisionAnalysis` tienen RLS activado **pero sin políticas** — ningún usuario puede leer ni escribir en estas tablas desde el cliente Flutter. El backend las accede vía `service_role` (bypass RLS), por eso funciona.
5. `CropProfile` tiene **0 filas** — no hay perfiles de plantas predefinidos cargados.
6. `Device` no tiene `user_id` propio — la propiedad se infiere vía `crop_id → Crop.user_id`.

---

### 2.2 Backend (FastAPI)

| Componente | Estado |
|---|---|
| Core (config, JWT, MQTT, Supabase) | ✅ Completo |
| `services/gemini_service.py` | ✅ Existe — `_USE_MOCK = True` (mock activo) |
| `services/actuators_service.py` | ✅ Existe |
| `services/mqtt_handler.py` | ✅ Existe |
| `routers/users.py` | ✅ Registrado en `main.py` |
| `routers/vision.py` | ✅ Registrado en `main.py` |
| `routers/crops.py` | ✅ Existe — **NO registrado** en `main.py` |
| `routers/devices.py` | ✅ Existe — **NO registrado** en `main.py` |
| `routers/alerts.py` | ✅ Existe — **NO registrado** en `main.py` |
| `routers/history.py` | ✅ Existe — **NO registrado** en `main.py` |
| `routers/actuators.py` | ✅ Existe — **NO registrado** en `main.py` |
| `services/crops_service.py` | ❌ No existe |
| `services/devices_service.py` | ❌ No existe |
| `services/alerts_service.py` | ❌ No existe |
| `services/history_service.py` | ❌ No existe |

---

### 2.3 Frontend (Flutter)

| Feature | UI | Datos |
|---|---|---|
| Auth (login/registro) | ✅ Completo | ✅ Real (Supabase Auth) |
| CropListScreen + navegación | ✅ Completo | ✅ Real (Supabase directo) |
| Wizard de creación de cultivos | ✅ Completo | ❌ `createCrop` es mock |
| DashboardScreen (4 métricas) | ✅ Completo | ❌ Datos simulados con `Random()` |
| ControlScreen (bomba + LED) | ✅ Completo | ❌ Sin repositorio, estado en memoria |
| AiDiagnosisScreen | ✅ Completo | ✅ Real (llama al backend) |
| AnalyticsScreen | ❌ Placeholder "Coming soon" | ❌ No existe |
| SettingsScreen | ✅ Completo | — |
| CropsBloc.deleteCrop | ✅ UI | ❌ Mock |

---

## 3. Estado final esperado

1. Backend con todos los endpoints activos y servicios implementados.
2. Esquema de BD corregido (columnas faltantes, RLS completo, seed data).
3. Dashboard y Control conectados al backend real.
4. AnalyticsScreen implementada con gráficos históricos.
5. `createCrop` y `deleteCrop` llaman al backend real.
6. Gemini Vision en modo real.

---

## 4. Tareas pendientes priorizadas

### FASE 1 — Correcciones de base de datos

> Sin esto, las fases siguientes fallarán.

**1.1 Agregar columnas faltantes** (nueva migración SQL)

```sql
-- Agregar action a ActuationEvent
ALTER TABLE public."ActuationEvent" ADD COLUMN IF NOT EXISTS action VARCHAR CHECK (action IN ('on', 'off'));
```

> **Decisión sobre pH:** La columna `ph` **no existe** en `SensorReading` ni en el backend. En lugar de agregarla, se elimina la referencia a pH del frontend (ver Fase 6.2).

**1.2 Activar RLS y agregar políticas a tablas sin protección**

```sql
-- CropProfile: habilitar RLS
ALTER TABLE public."CropProfile" ENABLE ROW LEVEL SECURITY;

-- CropProfile: todos ven perfiles predefinidos (creator_id = null), solo ven los propios si son custom
CREATE POLICY "anyone reads predefined profiles"
  ON public."CropProfile" FOR SELECT
  USING (creator_id IS NULL OR creator_id = auth.uid());

CREATE POLICY "user manages own profiles"
  ON public."CropProfile" FOR ALL
  USING (creator_id = auth.uid());

-- SensorReading: el usuario ve las lecturas de sus devices
CREATE POLICY "user reads own sensor readings"
  ON public."SensorReading" FOR SELECT
  USING (device_id IN (
    SELECT d.id FROM public."Device" d
    JOIN public."Crop" c ON c.id = d.crop_id
    WHERE c.user_id = auth.uid()
  ));

-- ActuationEvent: igual que SensorReading
CREATE POLICY "user reads own actuation events"
  ON public."ActuationEvent" FOR SELECT
  USING (device_id IN (
    SELECT d.id FROM public."Device" d
    JOIN public."Crop" c ON c.id = d.crop_id
    WHERE c.user_id = auth.uid()
  ));

-- VisionAnalysis: el usuario ve sus análisis
CREATE POLICY "user reads own vision analysis"
  ON public."VisionAnalysis" FOR SELECT
  USING (crop_id IN (
    SELECT id FROM public."Crop" WHERE user_id = auth.uid()
  ));
```

**1.3 Cargar seed data de CropProfile**

Insertar ~10 perfiles predefinidos con `creator_id = NULL`:
tomate, lechuga, albahaca, menta, fresa, pimiento, pepino, cilantro, espinaca, zanahoria.
Cada uno con `min_moisture`, `max_moisture`, `ideal_temperature`, `min_light_percentage`.

---

### FASE 2 — Backend: servicios y registro de routers

> Las fases 3–5 dependen de que el backend esté activo.

**2.1** Crear `backend/app/services/crops_service.py`
- `list_crops(user)` → SELECT Crop + JOIN CropProfile WHERE user_id = user["sub"]
- `create_crop(data, user)` → INSERT
- `get_crop(crop_id, user)` → SELECT WHERE id = crop_id AND user_id = user["sub"]
- `delete_crop(crop_id, user)` → DELETE

**2.2** Crear `backend/app/services/devices_service.py`
- `register_device(data, user)` → verificar MAC único, INSERT Device vinculado al crop del usuario
- `list_devices(user)` → SELECT Device via join con Crop WHERE user_id = user["sub"]
- `delete_device(device_id, user)` → DELETE verificando propiedad

**2.3** Crear `backend/app/services/alerts_service.py`
- `list_alerts(user)` → SELECT WHERE user_id = user["sub"] AND is_resolved = False
- `resolve_alert(alert_id, user)` → UPDATE SET is_resolved=True, resolved_at=now()

**2.4** Crear `backend/app/services/history_service.py`
- `get_sensor_readings(crop_id, range, user)` → busca Device del crop, filtra SensorReading por rango de fecha (day/week/month)
- `get_latest_reading(crop_id, user)` → SELECT ORDER BY recorded_at DESC LIMIT 1 para Dashboard en tiempo real

**2.5** Agregar endpoint DELETE en `backend/app/routers/crops.py`
```python
@router.delete("/{crop_id}", status_code=204)
async def delete_crop(crop_id: UUID, user: dict = Depends(get_current_user)):
    await crops_service.delete_crop(crop_id, user)
```

**2.6** Agregar endpoint de última lectura en `backend/app/routers/history.py`
```python
# GET /api/v1/sensor-readings/latest?crop_id={id}
# Devuelve: {temperature, humidity, light, ph, recorded_at}
```

**2.7** Modificar `backend/app/main.py` — registrar los 5 routers pendientes:
```python
from app.routers import crops, devices, alerts, history, actuators
app.include_router(crops.router)
app.include_router(devices.router)
app.include_router(alerts.router)
app.include_router(history.router)
app.include_router(actuators.router)
```
> Nota: `actuators` y `devices` comparten prefix `/api/v1/devices`. Verificar que los paths no colisionen (`/register`, `/{id}` vs `/{id}/actuate`).

---

### FASE 3 — Frontend: conectar Dashboard al backend

**3.1** Crear `frontend/lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart`
- `getSensorReadings(cropId)` → GET `/api/v1/sensor-readings/latest?crop_id={cropId}`
  - Header: `Authorization: Bearer {Supabase.instance.client.auth.currentSession?.accessToken}`
  - Mapear `{avg_temperature, avg_soil_moisture, avg_light, ph}` → `SensorReadingEntity`
- `getActuatorStatuses(cropId)` → consultar Supabase: Device del crop → último ActuationEvent por tipo

**3.2** Reemplazar datos mock en `frontend/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`
- Eliminar `Random()` y delays simulados
- Manejar caso "cultivo sin Device" → `Left(NoDeviceFailure())`

**3.3** Registrar `DashboardRemoteDataSource` en `frontend/lib/core/di/di_container.dart`

---

### FASE 4 — Frontend: conectar Control al backend

**4.1** Crear `frontend/lib/features/control/data/`
- `datasources/control_remote_datasource.dart` → POST `/api/v1/devices/{deviceId}/actuate`
  - Body: `{actuator_type: "pump"|"light", action: "on"|"off", duration_seconds?}`
- `repositories/control_repository_impl.dart`:
  - Obtener `device_id` del crop via Supabase (Device WHERE crop_id = cropId)
  - Llamar datasource
  - Registrar en DI como `registerFactoryParam` (necesita `cropId`)

**4.2** Modificar `frontend/lib/features/control/presentation/bloc/control_bloc.dart`
- Inyectar `ControlRepository` como dependencia
- `_onTogglePump` y `_onToggleLight` deben llamar al repositorio antes de actualizar estado local
- Agregar estado `ControlNoDevice` para cultivos sin hardware

**4.3** Modificar `ControlScreen` para obtener el BLoC del DI con `cropId`

---

### FASE 5 — Frontend: implementar AnalyticsScreen

**5.1** Crear `frontend/lib/features/analytics/` completo:
- `domain/entities/sensor_history_entity.dart` — lista de puntos `{DateTime timestamp, double value}`
- `domain/repositories/analytics_repository.dart`
- `domain/usecases/get_sensor_history_use_case.dart`
- `data/repositories/analytics_repository_impl.dart` → GET `/api/v1/sensor-readings?crop_id={id}&range={range}`
- `presentation/bloc/analytics_bloc.dart`
  - Eventos: `LoadAnalyticsData(cropId, range)`, `ChangeRange(range)`
  - Estados: `AnalyticsLoading`, `AnalyticsLoaded`, `AnalyticsError`, `AnalyticsEmpty`

**5.2** Implementar `frontend/lib/features/analytics/presentation/pages/analytics_screen.dart`
- `SegmentedButton` para rango: día / semana / mes
- 4 `LineChart` de `fl_chart` (temperatura, humedad, luz, pH) — `fl_chart ^0.68.0` ya instalado
- `FlSpot(x, y)` donde x = índice temporal, y = valor del sensor
- Estado vacío amigable cuando no hay lecturas

**5.3** Registrar en `di_container.dart`

---

### FASE 6 — Frontend: createCrop/deleteCrop reales + eliminar pH

**6.1** Modificar `frontend/lib/features/crops/data/repositories/crop_repository_impl.dart`
- `createCrop(data)` → POST `/api/v1/crops` con JWT en header
- `deleteCrop(cropId)` → DELETE `/api/v1/crops/{id}` con JWT

**6.2** Eliminar referencias a `ph` del frontend — `ph` no existe en la BD ni en el backend
- `frontend/lib/features/dashboard/domain/entities/sensor_reading_entity.dart` — eliminar campo `ph`
- `frontend/lib/features/dashboard/data/models/sensor_reading_model.dart` — eliminar campo `ph`
- `frontend/lib/features/dashboard/presentation/pages/dashboard_screen.dart` — eliminar la `MetricCard` de pH
- `frontend/lib/features/analytics/` (al crearse en Fase 5) — no incluir gráfico de pH

---

### FASE 7 — Polish y seguridad

**7.1** Activar Gemini real: cambiar `_USE_MOCK = False` en `backend/app/services/gemini_service.py`

**7.2** Configuración de URL por entorno: reemplazar `http://192.168.68.110:8000` hardcodeado en `AppConfig` usando `--dart-define=BACKEND_URL=...` en el build

**7.3** Revisar `mqtt_handler.py`: usa `"alert_type"` como clave SQL; verificar que coincide con el nombre de columna real en la tabla `Alert` (`alert_type` ✅ correcto según el esquema)

---

## 5. Orden de ejecución

```
Fase 1 (BD: columnas, RLS, seed)
    ↓
Fase 2 (Backend: servicios + routers)
    ↓
Fases 3 y 4 en paralelo (Dashboard real + Control real)
    ↓
Fase 5 y 6 en paralelo (Analytics + createCrop/delete real)
    ↓
Fase 7 (polish)
```

---

## 6. Archivos críticos a tocar

| Archivo | Acción |
|---|---|
| `backend/app/main.py` | Registrar 5 routers |
| `backend/app/services/crops_service.py` | Crear |
| `backend/app/services/devices_service.py` | Crear |
| `backend/app/services/alerts_service.py` | Crear |
| `backend/app/services/history_service.py` | Crear |
| `backend/app/routers/crops.py` | Agregar DELETE |
| `backend/app/routers/history.py` | Agregar `/latest` |
| `backend/app/services/gemini_service.py` | `_USE_MOCK = False` |
| `frontend/lib/features/dashboard/data/` | Crear datasource, reemplazar mock |
| `frontend/lib/features/control/data/` | Crear datasource y repositorio |
| `frontend/lib/features/control/presentation/bloc/control_bloc.dart` | Inyectar repositorio |
| `frontend/lib/features/analytics/` | Crear módulo completo |
| `frontend/lib/features/crops/data/repositories/crop_repository_impl.dart` | Reemplazar mock |
| `frontend/lib/core/di/di_container.dart` | Registrar nuevas dependencias |

---

## 7. Verificación al completar

1. `uvicorn app.main:app --reload` arranca sin errores; `/docs` muestra todos los endpoints.
2. Supabase dashboard: CropProfile tiene filas de seed, ph y action columnas existen.
3. Dashboard Tab → datos reales (o mensaje "sin dispositivo" si no hay hardware).
4. Control Tab → toggle bomba → aparece fila en tabla `ActuationEvent` en Supabase.
5. Analytics Tab → gráficos con datos históricos (o estado vacío si no hay lecturas).
6. Wizard de creación → cultivo aparece en tabla `Crop` de Supabase.
