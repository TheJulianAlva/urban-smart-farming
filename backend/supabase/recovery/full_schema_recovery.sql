-- ============================================================
-- SCRIPT DE RECUPERACIÓN COMPLETO — Urban Smart Farming
-- ============================================================
-- Uso: Ejecutar en un proyecto Supabase limpio (vacío) para
--      reconstruir toda la base de datos desde cero.
--
-- Requisito previo: el proyecto debe tener habilitada la extensión
--   pgcrypto (disponible por defecto en Supabase).
--
-- Orden de ejecución: único archivo, ejecutar completo.
-- Versión del esquema: refleja el estado aplicado al 2026-05-09.
-- ============================================================


-- ============================================================
-- PASO 1: TABLAS
-- ============================================================

-- 1.1 User (sincronizada con auth.users mediante trigger)
CREATE TABLE IF NOT EXISTS public."User" (
  id          UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT        NOT NULL DEFAULT '',
  email       TEXT        NOT NULL DEFAULT '',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 1.2 CropProfile (perfiles de plantas; creator_id NULL = predefinido del sistema)
CREATE TABLE IF NOT EXISTS public."CropProfile" (
  id                   UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id           UUID            REFERENCES public."User"(id) ON DELETE SET NULL,
  profile_name         VARCHAR         NOT NULL,
  min_moisture         DOUBLE PRECISION NOT NULL,
  max_moisture         DOUBLE PRECISION NOT NULL,
  ideal_temperature    DOUBLE PRECISION,
  min_light_percentage DOUBLE PRECISION,
  created_at           TIMESTAMPTZ     DEFAULT now(),
  updated_at           TIMESTAMPTZ     DEFAULT now()
);

-- 1.3 Crop
CREATE TABLE IF NOT EXISTS public."Crop" (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        NOT NULL REFERENCES public."User"(id) ON DELETE CASCADE,
  profile_id       UUID        REFERENCES public."CropProfile"(id) ON DELETE SET NULL,
  custom_name      VARCHAR     NOT NULL,
  icon_storage_url VARCHAR,
  planting_date    DATE,
  health_status    VARCHAR     DEFAULT 'healthy',
  location         TEXT        NOT NULL DEFAULT '',
  created_at       TIMESTAMPTZ DEFAULT now(),
  updated_at       TIMESTAMPTZ DEFAULT now()
);

-- 1.4 Device (un dispositivo IoT por cultivo; relación 1:1 con Crop)
CREATE TABLE IF NOT EXISTS public."Device" (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_id        UUID        UNIQUE REFERENCES public."Crop"(id) ON DELETE SET NULL,
  mac_address    VARCHAR     NOT NULL UNIQUE,
  last_heartbeat TIMESTAMPTZ
);

-- 1.5 SensorReading
CREATE TABLE IF NOT EXISTS public."SensorReading" (
  id               BIGSERIAL   PRIMARY KEY,
  device_id        UUID        NOT NULL REFERENCES public."Device"(id) ON DELETE CASCADE,
  avg_soil_moisture DOUBLE PRECISION,
  avg_temperature  DOUBLE PRECISION,
  avg_light        DOUBLE PRECISION,
  recorded_at      TIMESTAMPTZ DEFAULT now()
);

-- 1.6 ActuationEvent
CREATE TABLE IF NOT EXISTS public."ActuationEvent" (
  id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id      UUID        NOT NULL REFERENCES public."Device"(id) ON DELETE CASCADE,
  crop_id        UUID        REFERENCES public."Crop"(id) ON DELETE SET NULL,
  actuator_type  VARCHAR     CHECK (actuator_type IN ('pump', 'light')),
  action         VARCHAR(3)  CHECK (action IN ('on', 'off')),
  triggered_by   VARCHAR     CHECK (triggered_by IN ('manual', 'automatic', 'scheduled')),
  duration_seconds INTEGER,
  started_at     TIMESTAMPTZ DEFAULT now()
);

-- 1.7 VisionAnalysis
CREATE TABLE IF NOT EXISTS public."VisionAnalysis" (
  id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  crop_id               UUID        REFERENCES public."Crop"(id) ON DELETE CASCADE,
  diagnosis             TEXT,
  suggested_treatment   TEXT,
  confidence_percentage DOUBLE PRECISION,
  analysis_date         TIMESTAMPTZ DEFAULT now()
);

-- 1.8 Alert
CREATE TABLE IF NOT EXISTS public."Alert" (
  id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID        NOT NULL REFERENCES public."User"(id) ON DELETE CASCADE,
  device_id            UUID        REFERENCES public."Device"(id) ON DELETE SET NULL,
  alert_type           VARCHAR,
  message              TEXT,
  is_resolved          BOOLEAN     DEFAULT false,
  notification_sent    BOOLEAN     DEFAULT false,
  notification_channel VARCHAR     CHECK (notification_channel IN ('push', 'email', 'both')),
  created_at           TIMESTAMPTZ DEFAULT now(),
  resolved_at          TIMESTAMPTZ
);


-- ============================================================
-- PASO 2: TRIGGER — sincronizar auth.users → public.User
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public."User" (id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.email, '')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ============================================================
-- PASO 3: ROW LEVEL SECURITY
-- ============================================================

-- 3.1 User
ALTER TABLE public."User" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users: select own" ON public."User" FOR SELECT USING (auth.uid() = id);
CREATE POLICY "users: update own" ON public."User" FOR UPDATE USING (auth.uid() = id);

-- 3.2 CropProfile
ALTER TABLE public."CropProfile" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "cropprofile: select predefined or own"
  ON public."CropProfile" FOR SELECT
  USING (creator_id IS NULL OR creator_id = auth.uid());
CREATE POLICY "cropprofile: insert own"
  ON public."CropProfile" FOR INSERT
  WITH CHECK (creator_id = auth.uid());
CREATE POLICY "cropprofile: update own"
  ON public."CropProfile" FOR UPDATE
  USING (creator_id = auth.uid());
CREATE POLICY "cropprofile: delete own"
  ON public."CropProfile" FOR DELETE
  USING (creator_id = auth.uid());

-- 3.3 Crop
ALTER TABLE public."Crop" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "crops: select own" ON public."Crop" FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "crops: insert own" ON public."Crop" FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "crops: update own" ON public."Crop" FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "crops: delete own" ON public."Crop" FOR DELETE USING (auth.uid() = user_id);

-- 3.4 Device (propiedad se infiere a través de Crop)
ALTER TABLE public."Device" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "User sees own devices"
  ON public."Device" FOR ALL
  USING (
    crop_id IN (SELECT id FROM public."Crop" WHERE user_id = auth.uid())
  );

-- 3.5 SensorReading
ALTER TABLE public."SensorReading" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "sensorreading: select own"
  ON public."SensorReading" FOR SELECT
  USING (
    device_id IN (
      SELECT d.id FROM public."Device" d
      JOIN public."Crop" c ON c.id = d.crop_id
      WHERE c.user_id = auth.uid()
    )
  );
CREATE POLICY "sensorreading: insert own"
  ON public."SensorReading" FOR INSERT
  WITH CHECK (
    device_id IN (
      SELECT d.id FROM public."Device" d
      JOIN public."Crop" c ON c.id = d.crop_id
      WHERE c.user_id = auth.uid()
    )
  );

-- 3.6 ActuationEvent
ALTER TABLE public."ActuationEvent" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "actuationevent: select own"
  ON public."ActuationEvent" FOR SELECT
  USING (
    device_id IN (
      SELECT d.id FROM public."Device" d
      JOIN public."Crop" c ON c.id = d.crop_id
      WHERE c.user_id = auth.uid()
    )
  );
CREATE POLICY "actuationevent: insert own"
  ON public."ActuationEvent" FOR INSERT
  WITH CHECK (
    device_id IN (
      SELECT d.id FROM public."Device" d
      JOIN public."Crop" c ON c.id = d.crop_id
      WHERE c.user_id = auth.uid()
    )
  );

-- 3.7 VisionAnalysis
ALTER TABLE public."VisionAnalysis" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "visionanalysis: select own"
  ON public."VisionAnalysis" FOR SELECT
  USING (crop_id IN (SELECT id FROM public."Crop" WHERE user_id = auth.uid()));
CREATE POLICY "visionanalysis: insert own"
  ON public."VisionAnalysis" FOR INSERT
  WITH CHECK (crop_id IN (SELECT id FROM public."Crop" WHERE user_id = auth.uid()));

-- 3.8 Alert
ALTER TABLE public."Alert" ENABLE ROW LEVEL SECURITY;
CREATE POLICY "User sees own alerts"
  ON public."Alert" FOR ALL
  USING (auth.uid() = user_id);


-- ============================================================
-- PASO 4: SEED — Perfiles predefinidos de cultivos
-- ============================================================
-- Fuente: docs/microhuertos_urbanos.md
-- min_light_percentage = lux_mínimo / 100,000 × 100

INSERT INTO public."CropProfile"
  (id, creator_id, profile_name, min_moisture, max_moisture, ideal_temperature, min_light_percentage)
VALUES
  (gen_random_uuid(), NULL, 'Lechuga',             60, 80, 15.5, 10.0),
  (gen_random_uuid(), NULL, 'Tomate cherry',       60, 80, 22.5, 20.0),
  (gen_random_uuid(), NULL, 'Albahaca',            50, 70, 22.5, 15.0),
  (gen_random_uuid(), NULL, 'Espinaca',            60, 80, 12.5, 10.0),
  (gen_random_uuid(), NULL, 'Rábano',              60, 80, 12.5, 10.0),
  (gen_random_uuid(), NULL, 'Tagete',              40, 70, 22.5, 20.0),
  (gen_random_uuid(), NULL, 'Caléndula',           40, 65, 12.5, 15.0),
  (gen_random_uuid(), NULL, 'Lavanda',             30, 60, 10.0, 20.0),
  (gen_random_uuid(), NULL, 'Pensamiento',         50, 75,  6.5, 10.0),
  (gen_random_uuid(), NULL, 'Alegría de la casa',  55, 80, 18.5,  5.0)
ON CONFLICT DO NOTHING;
