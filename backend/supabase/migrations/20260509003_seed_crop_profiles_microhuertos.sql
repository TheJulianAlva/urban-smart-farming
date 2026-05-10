-- Migration: seed_crop_profiles_microhuertos
-- Applied: 2026-05-09
-- Inserts 10 predefined crop profiles based on docs/microhuertos_urbanos.md.
-- creator_id = NULL marks system-wide predefined profiles.
--
-- Column mapping from the agronomic document:
--   min_moisture / max_moisture → Humedad relativa del aire (%)
--   ideal_temperature           → Punto medio del rango funcional (°C)
--   min_light_percentage        → Lux mínimo / 100,000 lux × 100  (%)
--                                 (referencia: pleno sol exterior ≈ 100,000 lux)

INSERT INTO public."CropProfile"
  (id, creator_id, profile_name, min_moisture, max_moisture, ideal_temperature, min_light_percentage)
VALUES
  -- ── CULTIVOS ──────────────────────────────────────────────
  -- Lechuga: HR 60-80%, T 7-24°C, luz mín 10,000 lux → 10%
  (gen_random_uuid(), NULL, 'Lechuga',             60, 80, 15.5, 10.0),

  -- Tomate cherry: HR 60-80%, T 15-30°C, luz mín 20,000 lux → 20%
  (gen_random_uuid(), NULL, 'Tomate cherry',       60, 80, 22.5, 20.0),

  -- Albahaca: HR 50-70%, T 15-30°C, luz mín 15,000 lux → 15%
  (gen_random_uuid(), NULL, 'Albahaca',            50, 70, 22.5, 15.0),

  -- Espinaca: HR 60-80%, T 5-20°C, luz mín 10,000 lux → 10%
  (gen_random_uuid(), NULL, 'Espinaca',            60, 80, 12.5, 10.0),

  -- Rábano: HR 60-80%, T 5-20°C, luz mín 10,000 lux → 10%
  (gen_random_uuid(), NULL, 'Rábano',              60, 80, 12.5, 10.0),

  -- ── FLORES / PLANTAS COMPAÑERAS ───────────────────────────
  -- Tagete (Cempasúchil): HR 40-70%, T 10-35°C, luz mín 20,000 lux → 20%
  (gen_random_uuid(), NULL, 'Tagete',              40, 70, 22.5, 20.0),

  -- Caléndula: HR 40-65%, T -3 a 28°C, luz mín 15,000 lux → 15%
  (gen_random_uuid(), NULL, 'Caléndula',           40, 65, 12.5, 15.0),

  -- Lavanda: HR 30-60%, T -10 a 30°C, luz mín 20,000 lux → 20%
  (gen_random_uuid(), NULL, 'Lavanda',             30, 60, 10.0, 20.0),

  -- Pensamiento: HR 50-75%, T -5 a 18°C, luz mín 10,000 lux → 10%
  (gen_random_uuid(), NULL, 'Pensamiento',         50, 75,  6.5, 10.0),

  -- Alegría de la casa: HR 55-80%, T 13-24°C, luz mín 5,000 lux → 5%
  (gen_random_uuid(), NULL, 'Alegría de la casa',  55, 80, 18.5,  5.0)

ON CONFLICT DO NOTHING;
