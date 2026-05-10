# Base de datos — Urban Smart Farming

Proyecto Supabase: `ubojiqlbmwqwbofrxkea`

---

## Estructura de directorios

```
backend/supabase/
├── migrations/          # Migraciones incrementales
│   └── 20260509003_seed_crop_profiles_microhuertos.sql
└── recovery/
    └── full_schema_recovery.sql   # Reconstruye toda la BD desde cero
```

---

## Esquema de tablas

### `User`
Sincronizada con `auth.users` mediante el trigger `on_auth_user_created`. Cada vez que un usuario se registra en Supabase Auth, se crea automáticamente una fila en esta tabla.

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID (PK) | FK → auth.users |
| full_name | TEXT | |
| email | TEXT | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

---

### `CropProfile`
Perfiles de plantas con umbrales de sensores. `creator_id = NULL` indica un perfil predefinido del sistema (visible para todos los usuarios).

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID (PK) | |
| creator_id | UUID | FK → User; NULL = perfil del sistema |
| profile_name | VARCHAR | Ej: "Lechuga", "Tomate cherry" |
| min_moisture | FLOAT | Humedad relativa mínima del aire (%) |
| max_moisture | FLOAT | Humedad relativa máxima del aire (%) |
| ideal_temperature | FLOAT | Temperatura ideal de crecimiento (°C) |
| min_light_percentage | FLOAT | Luz mínima como % de pleno sol (lux/100,000×100) |

**Perfiles predefinidos cargados:**

| Planta | min_moisture | max_moisture | ideal_temp (°C) | min_light (%) |
|---|:---:|:---:|:---:|:---:|
| Lechuga | 60 | 80 | 15.5 | 10 |
| Tomate cherry | 60 | 80 | 22.5 | 20 |
| Albahaca | 50 | 70 | 22.5 | 15 |
| Espinaca | 60 | 80 | 12.5 | 10 |
| Rábano | 60 | 80 | 12.5 | 10 |
| Tagete | 40 | 70 | 22.5 | 20 |
| Caléndula | 40 | 65 | 12.5 | 15 |
| Lavanda | 30 | 60 | 10.0 | 20 |
| Pensamiento | 50 | 75 | 6.5 | 10 |
| Alegría de la casa | 55 | 80 | 18.5 | 5 |

Fuente de los umbrales: [`docs/microhuertos_urbanos.md`](../../docs/microhuertos_urbanos.md)

---

### `Crop`
Un cultivo activo de un usuario.

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID | FK → User |
| profile_id | UUID | FK → CropProfile |
| custom_name | VARCHAR | Nombre libre del usuario |
| icon_storage_url | VARCHAR | URL de imagen en Supabase Storage |
| planting_date | DATE | |
| health_status | VARCHAR | `'healthy'` por defecto |
| location | TEXT | Ubicación textual libre |

---

### `Device`
Dispositivo IoT (ESP32/similar) asociado a un cultivo. Relación 1:1 con `Crop`.

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID (PK) | |
| crop_id | UUID (UNIQUE) | FK → Crop; un dispositivo por cultivo |
| mac_address | VARCHAR (UNIQUE) | Identificador físico del hardware |
| last_heartbeat | TIMESTAMPTZ | Última conexión MQTT |

> **Nota:** `Device` no tiene `user_id` propio. La propiedad se resuelve mediante `Device.crop_id → Crop.user_id`.

---

### `SensorReading`
Lecturas de sensores enviadas por el dispositivo vía MQTT.

| Columna | Tipo | Notas |
|---|---|---|
| id | BIGSERIAL (PK) | |
| device_id | UUID | FK → Device |
| avg_soil_moisture | FLOAT | Humedad del suelo promediada (%) |
| avg_temperature | FLOAT | Temperatura ambiente (°C) |
| avg_light | FLOAT | Luz (lux) |
| recorded_at | TIMESTAMPTZ | |

> **pH no existe** en esta tabla ni en el backend. Las referencias a `ph` en el frontend deben eliminarse (ver Fase 6.2 del plan).

---

### `ActuationEvent`
Registro de cada acción de actuador (bomba de agua, LED).

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID (PK) | |
| device_id | UUID | FK → Device |
| crop_id | UUID | FK → Crop |
| actuator_type | VARCHAR | `'pump'` o `'light'` |
| action | VARCHAR(3) | `'on'` o `'off'` ← **agregado en migración 20260509001** |
| triggered_by | VARCHAR | `'manual'`, `'automatic'`, `'scheduled'` |
| duration_seconds | INT | |
| started_at | TIMESTAMPTZ | |

---

### `VisionAnalysis`
Resultado del análisis de imagen con Gemini Vision.

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID (PK) | |
| crop_id | UUID | FK → Crop |
| diagnosis | TEXT | |
| suggested_treatment | TEXT | |
| confidence_percentage | FLOAT | |
| analysis_date | TIMESTAMPTZ | |

---

### `Alert`
Alertas generadas por el backend (MQTT handler) o manualmente.

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID (PK) | |
| user_id | UUID | FK → User |
| device_id | UUID | FK → Device |
| alert_type | VARCHAR | Tipo de alerta libre |
| message | TEXT | |
| is_resolved | BOOLEAN | `false` por defecto |
| notification_sent | BOOLEAN | |
| notification_channel | VARCHAR | `'push'`, `'email'`, `'both'` |
| created_at | TIMESTAMPTZ | |
| resolved_at | TIMESTAMPTZ | |

---

## Row Level Security (RLS)

| Tabla | RLS | Políticas activas |
|---|:---:|---|
| User | ✅ | SELECT y UPDATE propios |
| CropProfile | ✅ | SELECT predefinidos + propios; INSERT/UPDATE/DELETE propios |
| Crop | ✅ | SELECT/INSERT/UPDATE/DELETE propios |
| Device | ✅ | ALL via join con Crop |
| SensorReading | ✅ | SELECT e INSERT via Device → Crop → user_id |
| ActuationEvent | ✅ | SELECT e INSERT via Device → Crop → user_id |
| VisionAnalysis | ✅ | SELECT e INSERT via Crop → user_id |
| Alert | ✅ | ALL propios (user_id) |

> El backend usa la clave `service_role` (bypass RLS) para todas las escrituras IoT (MQTT). Las políticas de INSERT en `SensorReading` y `ActuationEvent` están disponibles si el frontend necesita acceso directo en el futuro.

---

## Recuperación completa

Para reconstruir toda la BD en un proyecto Supabase limpio:

```sql
-- Ejecutar en el SQL Editor de Supabase (una sola vez, proyecto vacío):
\i backend/supabase/recovery/full_schema_recovery.sql
```

O pegar el contenido directamente en el SQL Editor del dashboard de Supabase.

---

## Migraciones históricas (anteriores al 2026-05-09)

Aplicadas al momento de la primera integración con Supabase:

| Versión | Nombre |
|---|---|
| 20260414045126 | 01_create_tables |
| 20260414045135 | 02_enable_rls |
| 20260414045142 | 03_seed_crop_profile |
| 20260415183112 | recreate_user_table_with_auth_id |
| 20260415183119 | trigger_sync_auth_to_user_table |
| 20260415183129 | rls_user_table |
| 20260415183136 | rls_crop_table |
| 20260415184452 | add_location_to_crop |
