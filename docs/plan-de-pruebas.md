# Plan de Pruebas de Software
## Urban Smart Farming (USF)

---

## Tabla de Contenidos

1. [Introducción](#1-introducción)
   - 1.1 [Propósito](#11-propósito)
   - 1.2 [Alcance](#12-alcance)
   - 1.3 [Glosario](#13-glosario)
2. [Formato de Caso de Prueba](#2-formato-de-caso-de-prueba)
3. [Casos de Prueba por Tipo](#3-casos-de-prueba-por-tipo)
   - 3.1 [Pruebas Unitarias (USF-UNIT)](#31-pruebas-unitarias-usf-unit) — USF-UNIT-001 · 002 · 003 · 004
   - 3.2 [Pruebas de Integración (USF-INTG)](#32-pruebas-de-integración-usf-intg) — USF-INTG-001 · 002 · 003
   - 3.3 [Pruebas de Regresión (USF-REGR)](#33-pruebas-de-regresión-usf-regr) — USF-REGR-001 · 002 · 003
   - 3.4 [Pruebas de Humo (USF-SMOK)](#34-pruebas-de-humo-usf-smok) — USF-SMOK-001 · 002 · 003
   - 3.5 [Prueba de Sistema Completo (USF-SIST)](#35-prueba-de-sistema-completo-usf-sist) — USF-SIST-001 · 002 · 003
   - 3.6 [Pruebas de Desempeño (USF-DEMP)](#36-pruebas-de-desempeño-usf-demp) — USF-DEMP-001 · 002
   - 3.7 [Pruebas de Carga (USF-CARG)](#37-pruebas-de-carga-usf-carg) — USF-CARG-001 · 002
   - 3.8 [Pruebas de Stress (USF-STRS)](#38-pruebas-de-stress-usf-strs) — USF-STRS-001 · 002
   - 3.9 [Recuperación y Tolerancia a Fallas (USF-RECV)](#39-recuperación-y-tolerancia-a-fallas-usf-recv) — USF-RECV-001 · 002 · 003
   - 3.10 [Pruebas de GUI (USF-GUII)](#310-pruebas-de-gui-usf-guii) — USF-GUII-001 · 002 · 003
   - 3.11 [Pruebas de Aceptación (USF-ACEP)](#311-pruebas-de-aceptación-usf-acep) — USF-ACEP-001 · 002 · 003
   - 3.12 [Pruebas de Usabilidad (USF-USAB)](#312-pruebas-de-usabilidad-usf-usab) — USF-USAB-001 · 002
   - 3.13 [Pruebas Alfa (USF-ALFA)](#313-pruebas-alfa-usf-alfa) — USF-ALFA-001 · 002
   - 3.14 [Pruebas Beta (USF-BETA)](#314-pruebas-beta-usf-beta) — USF-BETA-001 · 002
4. [Matriz de Trazabilidad](#4-matriz-de-trazabilidad)

---

## 1. Introducción

### 1.1 Propósito

Este documento define el plan de pruebas de software para el sistema Urban Smart Farming (USF). Su objetivo es especificar los tipos de prueba aplicables al proyecto, establecer el formato estándar de casos de prueba del equipo y detallar los casos concretos que se ejecutarán para validar la funcionalidad, rendimiento y calidad del sistema.

### 1.2 Alcance

El plan cubre las pruebas de todas las capas del sistema USF:

- **Frontend:** Aplicación móvil Flutter (Android)
- **Backend:** API REST desarrollada con FastAPI (Python)
- **Base de datos:** Supabase (PostgreSQL + Row Level Security)
- **Mensajería IoT:** Broker MQTT (HiveMQ Cloud)
- **Inteligencia Artificial:** Gemini Vision API (Google)

### 1.3 Glosario

| Término | Definición |
|---------|-----------|
| MQTT | Message Queuing Telemetry Transport — protocolo ligero pub/sub para IoT |
| SensorReading | Tabla Supabase que almacena lecturas de sensores (temperatura, humedad, etc.) |
| CropsBloc | Componente BLoC Flutter que gestiona el estado de cultivos |
| AuthBloc | Componente BLoC Flutter que gestiona autenticación de usuario |
| RLS | Row Level Security — política de seguridad a nivel de fila en Supabase |
| E2E | End-to-End — prueba que cubre el flujo completo desde la UI hasta la base de datos |
| PASS | Resultado de prueba: caso exitoso |
| FAIL | Resultado de prueba: caso fallido |
| BLOQUEADO | La prueba no puede ejecutarse por dependencia externa |

---

## 2. Formato de Caso de Prueba

El equipo utiliza el siguiente formato estándar para todos los casos de prueba. Los campos marcados con `*` se completan antes de ejecutar; los restantes se llenan durante o después de la ejecución.

```
╔══════════════════════════════════════════════════════════════════╗
║  CASO DE PRUEBA — URBAN SMART FARMING                           ║
╠══════════════════════════════════════════════════════════════════╣
║  ID Prueba*        : USF-[TIPO]-[NNN]                           ║
║  Tipo*             : [Tipo de prueba]                            ║
║  Módulo*           : [Componente exacto del proyecto]            ║
║  Nombre*           : [Descripción corta — máx. 60 caracteres]   ║
║  Prioridad*        : ALTA / MEDIA / BAJA                         ║
║  Autor*            : [Nombre del integrante responsable]         ║
║  Fecha*            : [YYYY-MM-DD]                                ║
║  Versión*          : [Commit SHA (7 chars) o tag de build]       ║
╠══════════════════════════════════════════════════════════════════╣
║  Objetivo*         : [Una oración: qué condición se valida]      ║
║  Precondiciones*   : [Lista numerada de condiciones previas]     ║
║  Datos de entrada* : [Valores concretos usados en la prueba]     ║
║  Pasos*            : [Pasos numerados para reproducir la prueba] ║
║  Resultado esperado*: [Comportamiento exacto que se espera]      ║
╠══════════════════════════════════════════════════════════════════╣
║  Resultado real    : [Completar al ejecutar]                     ║
║  Evidencia         : [Ruta a screenshot / extracto de log / CSV] ║
╠══════════════════════════════════════════════════════════════════╣
║  Estado            : [ ] PASS  [ ] FAIL  [ ] BLOQUEADO  [ ] N/A ║
║  Defecto vinculado : [#ID de issue si aplica, o "Ninguno"]       ║
║  Notas             : [Observaciones adicionales]                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## 3. Casos de Prueba por Tipo

---

### 3.1 Pruebas Unitarias (USF-UNIT)

---

**USF-UNIT-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-UNIT-001 |
| **Tipo** | Prueba Unitaria |
| **Módulo** | `frontend/lib/features/auth/presentation/bloc/auth_bloc.dart` |
| **Nombre** | AuthBloc emite AuthAuthenticated tras login exitoso |
| **Prioridad** | ALTA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que `AuthBloc` emite el estado `AuthAuthenticated` cuando `LoginRequested` recibe credenciales válidas mockeadas |
| **Precondiciones** | 1. Dependencias Flutter instaladas (`flutter pub get`). 2. `AuthRepository` mockeado con `mocktail`. |
| **Datos de entrada** | email: `test@usf.com`, password: `Test1234!` |
| **Pasos** | 1. Crear mock de `AuthRepository` que retorna `User` válido. 2. Instanciar `AuthBloc` con el mock. 3. Disparar evento `LoginRequested(email, password)`. 4. Esperar emisiones del bloc. |
| **Resultado esperado** | Secuencia de estados: `[AuthLoading, AuthAuthenticated]` |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Usar `bloc_test` `expect:` para verificar la secuencia exacta |

---

**USF-UNIT-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-UNIT-002 |
| **Tipo** | Prueba Unitaria |
| **Módulo** | `frontend/lib/features/auth/presentation/bloc/auth_bloc.dart` |
| **Nombre** | AuthBloc emite AuthError con credenciales inválidas |
| **Prioridad** | ALTA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que `AuthBloc` emite `AuthError` con mensaje descriptivo cuando el repositorio lanza excepción de autenticación |
| **Precondiciones** | 1. `AuthRepository` mockeado para lanzar `AuthException('Invalid credentials')`. |
| **Datos de entrada** | email: `wrong@usf.com`, password: `wrongpass` |
| **Pasos** | 1. Configurar mock para lanzar excepción. 2. Instanciar `AuthBloc`. 3. Disparar `LoginRequested`. 4. Esperar estados. |
| **Resultado esperado** | Secuencia: `[AuthLoading, AuthError(message: 'Invalid credentials')]` |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-UNIT-003**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-UNIT-003 |
| **Tipo** | Prueba Unitaria |
| **Módulo** | `backend/app/services/mqtt_handler.py` |
| **Nombre** | on_message procesa payload MQTT válido y persiste SensorReading |
| **Prioridad** | ALTA |
| **Autor** | Carolina Ledesma |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que `on_message()` parsea correctamente un payload JSON válido y llama al método de persistencia con los valores correctos |
| **Precondiciones** | 1. Cliente Supabase mockeado con `unittest.mock.patch`. 2. `pytest` instalado. |
| **Datos de entrada** | `{"device_id": "esp32-01", "temperature": 24.5, "humidity": 68.0, "timestamp": "2026-05-11T10:00:00Z"}` |
| **Pasos** | 1. Parchear cliente Supabase. 2. Construir objeto `msg` con el payload. 3. Llamar `on_message(client, userdata, msg)`. 4. Verificar llamada al mock. |
| **Resultado esperado** | `supabase.table('SensorReading').insert()` llamado con `temperature=24.5`, `humidity=68.0`, `device_id='esp32-01'` |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-UNIT-004**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-UNIT-004 |
| **Tipo** | Prueba Unitaria |
| **Módulo** | `frontend/lib/features/crops/presentation/bloc/crops_bloc.dart` |
| **Nombre** | CropsBloc emite CropsLoaded con lista al recibir LoadCrops |
| **Prioridad** | MEDIA |
| **Autor** | Alberto Calderón |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que `CropsBloc` emite `CropsLoaded` con la lista de cultivos cuando `LoadCrops` es disparado y el repositorio retorna datos |
| **Precondiciones** | 1. `CropsRepository` mockeado para retornar lista de 2 cultivos. |
| **Datos de entrada** | Lista mockeada: `[Crop(id:'1', name:'Tomate'), Crop(id:'2', name:'Lechuga')]` |
| **Pasos** | 1. Configurar mock del repositorio. 2. Instanciar `CropsBloc`. 3. Disparar `LoadCrops`. 4. Esperar estados. |
| **Resultado esperado** | Secuencia: `[CropsLoading, CropsLoaded(crops: [Tomate, Lechuga])]` |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.2 Pruebas de Integración (USF-INTG)

---

**USF-INTG-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-INTG-001 |
| **Tipo** | Prueba de Integración |
| **Módulo** | `backend/app/routers/crops.py` + `backend/app/services/crops_service.py` |
| **Nombre** | POST /crops crea cultivo y persiste en Supabase |
| **Prioridad** | ALTA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el endpoint `POST /crops` recibe un body válido, llama a `crops_service`, persiste el registro en Supabase y retorna HTTP 201 con el cultivo creado |
| **Precondiciones** | 1. Backend FastAPI corriendo en `localhost:8000`. 2. Supabase accesible con credenciales de prueba. 3. JWT válido disponible. |
| **Datos de entrada** | `{"name": "Tomate Cherry", "crop_profile_id": "uuid-perfil-tomate", "device_id": "esp32-01"}` |
| **Pasos** | 1. Obtener JWT con credenciales de usuario de prueba. 2. Ejecutar `POST /crops` con body y header `Authorization: Bearer {jwt}`. 3. Verificar respuesta. 4. Consultar Supabase para confirmar registro. |
| **Resultado esperado** | HTTP 201. Body contiene `id`, `name: "Tomate Cherry"`, `created_at`. Registro presente en tabla `Crop` de Supabase. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Limpiar el registro creado al finalizar la prueba |

---

**USF-INTG-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-INTG-002 |
| **Tipo** | Prueba de Integración |
| **Módulo** | `backend/app/services/mqtt_handler.py` → Supabase `SensorReading` |
| **Nombre** | Mensaje MQTT se recibe y persiste como SensorReading |
| **Prioridad** | ALTA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar el flujo completo: publicar un mensaje MQTT → `mqtt_handler.on_message()` lo procesa → registro aparece en `SensorReading` en Supabase |
| **Precondiciones** | 1. Backend corriendo y suscrito al broker MQTT. 2. `mosquitto_pub` o script `paho-mqtt` disponible. 3. Supabase accesible. |
| **Datos de entrada** | Topic: `usf/esp32-01/sensors`. Payload: `{"device_id":"esp32-01","temperature":23.1,"humidity":65.0}` |
| **Pasos** | 1. Publicar mensaje al topic MQTT. 2. Esperar 2 segundos. 3. Consultar `SensorReading` en Supabase filtrando por `device_id='esp32-01'`. |
| **Resultado esperado** | Registro encontrado con `temperature=23.1`, `humidity=65.0`, `device_id='esp32-01'` |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-INTG-003**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-INTG-003 |
| **Tipo** | Prueba de Integración |
| **Módulo** | `backend/app/services/gemini_service.py` → Supabase `VisionAnalysis` |
| **Nombre** | analyze_image llama a Gemini y persiste VisionAnalysis |
| **Prioridad** | ALTA |
| **Autor** | Carolina Ledesma |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que `gemini_service.analyze_image()` envía la imagen a Gemini Vision API, recibe diagnóstico y persiste el resultado en la tabla `VisionAnalysis` |
| **Precondiciones** | 1. API key de Gemini configurada en `.env`. 2. Supabase accesible. 3. Imagen de prueba disponible (hoja con mancha visible). |
| **Datos de entrada** | `crop_id`: UUID de cultivo existente. Imagen: `tests/fixtures/leaf_diseased.jpg` |
| **Pasos** | 1. Llamar `POST /vision/analyze` con `crop_id` y archivo de imagen. 2. Esperar respuesta (<15s). 3. Verificar respuesta HTTP. 4. Consultar `VisionAnalysis` en Supabase. |
| **Resultado esperado** | HTTP 200. Respuesta contiene `diagnosis` (string no vacío) y `confidence`. Registro en `VisionAnalysis` con `crop_id` correcto. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Prueba consume cuota de Gemini API |

---

### 3.3 Pruebas de Regresión (USF-REGR)

---

**USF-REGR-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-REGR-001 |
| **Tipo** | Prueba de Regresión |
| **Módulo** | `backend/app/main.py` |
| **Nombre** | Health check retorna 200 tras merge de rama feature |
| **Prioridad** | ALTA |
| **Autor** | Alberto Calderón |
| **Fecha** | 2026-05-11 |
| **Versión** | [Post-merge] |
| **Objetivo** | Verificar que el endpoint `GET /health` sigue respondiendo HTTP 200 después de cada merge a la rama principal |
| **Precondiciones** | 1. Merge completado en rama `main`. 2. Backend reiniciado. |
| **Datos de entrada** | Ninguno |
| **Pasos** | 1. Ejecutar `GET http://localhost:8000/health`. 2. Verificar código de estado y body. |
| **Resultado esperado** | HTTP 200. Body: `{"status": "ok"}` o similar |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Ejecutar como primera prueba post-merge |

---

**USF-REGR-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-REGR-002 |
| **Tipo** | Prueba de Regresión |
| **Módulo** | `frontend/lib/features/auth/presentation/bloc/auth_bloc.dart` |
| **Nombre** | Flujo de login en app no se rompe tras cambios en otro módulo |
| **Prioridad** | ALTA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | [Post-merge] |
| **Objetivo** | Verificar que el flujo de login completo desde la UI sigue funcionando correctamente tras introducir cambios en módulos no relacionados (p. ej. crops, sensors) |
| **Precondiciones** | 1. App compilada con la versión post-merge. 2. Usuario de prueba registrado en Supabase. |
| **Datos de entrada** | email: `regresion@usf.com`, password: `Regresion1!` |
| **Pasos** | 1. Abrir app en emulador. 2. Ingresar credenciales. 3. Presionar "Iniciar sesión". 4. Verificar navegación al home. |
| **Resultado esperado** | Pantalla Home visible con nombre del usuario. Sin errores en consola. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-REGR-003**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-REGR-003 |
| **Tipo** | Prueba de Regresión |
| **Módulo** | `backend/app/services/gemini_service.py` |
| **Nombre** | Diagnóstico Gemini sigue funcionando tras actualizar dependencias |
| **Prioridad** | MEDIA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | [Post-merge] |
| **Objetivo** | Verificar que `gemini_service.analyze_image()` sigue retornando diagnóstico válido tras actualizaciones de la librería `google-generativeai` |
| **Precondiciones** | 1. Dependencias actualizadas (`pip install -r requirements.txt`). 2. API key válida. |
| **Datos de entrada** | Imagen: `tests/fixtures/leaf_healthy.jpg` |
| **Pasos** | 1. Ejecutar `POST /vision/analyze` con imagen de prueba. 2. Verificar respuesta. |
| **Resultado esperado** | HTTP 200. Campo `diagnosis` no vacío. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.4 Pruebas de Humo (USF-SMOK)

---

**USF-SMOK-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-SMOK-001 |
| **Tipo** | Prueba de Humo |
| **Módulo** | `backend/app/main.py` |
| **Nombre** | Backend FastAPI levanta sin errores |
| **Prioridad** | ALTA |
| **Autor** | Carolina Ledesma |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el servidor FastAPI inicia correctamente, carga todos los routers y está listo para recibir solicitudes |
| **Precondiciones** | 1. Archivo `.env` configurado. 2. Entorno virtual activado. |
| **Datos de entrada** | Comando: `uvicorn app.main:app --reload` |
| **Pasos** | 1. Ejecutar comando de inicio. 2. Observar logs de consola. 3. Ejecutar `GET /health`. |
| **Resultado esperado** | Logs sin errores. Mensaje "Application startup complete". HTTP 200 en `/health`. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | PRERREQUISITO para todas las demás pruebas de backend |

---

**USF-SMOK-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-SMOK-002 |
| **Tipo** | Prueba de Humo |
| **Módulo** | `frontend/lib/main.dart` |
| **Nombre** | App Flutter abre pantalla de login sin crashear |
| **Prioridad** | ALTA |
| **Autor** | Alberto Calderón |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que la app Flutter compila, se instala en el emulador y muestra la pantalla de login sin excepciones |
| **Precondiciones** | 1. Emulador Android iniciado (API 33+). 2. `flutter pub get` ejecutado. |
| **Datos de entrada** | Ninguno |
| **Pasos** | 1. Ejecutar `flutter run`. 2. Esperar carga de la app. 3. Verificar pantalla de login visible. |
| **Resultado esperado** | Pantalla de login visible. Sin errores en la consola de Flutter. Sin pantalla roja de error. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | PRERREQUISITO para todas las pruebas de frontend |

---

**USF-SMOK-003**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-SMOK-003 |
| **Tipo** | Prueba de Humo |
| **Módulo** | `backend/app/main.py` (Swagger UI) |
| **Nombre** | Swagger UI disponible en /docs |
| **Prioridad** | MEDIA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que la documentación interactiva de la API está accesible y lista para facilitar pruebas manuales |
| **Precondiciones** | 1. Backend corriendo (USF-SMOK-001 en PASS). |
| **Datos de entrada** | URL: `http://localhost:8000/docs` |
| **Pasos** | 1. Abrir navegador. 2. Navegar a `http://localhost:8000/docs`. 3. Verificar carga de Swagger UI. |
| **Resultado esperado** | Página Swagger UI visible con todos los routers listados (auth, crops, sensors, vision, actuators). |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.5 Prueba de Sistema Completo (USF-SIST)

---

**USF-SIST-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-SIST-001 |
| **Tipo** | Prueba de Sistema Completo |
| **Módulo** | Sistema completo (Flutter + FastAPI + Supabase + MQTT) |
| **Nombre** | Flujo E2E: registro de usuario → creación de cultivo → lectura de sensor → alerta |
| **Prioridad** | ALTA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar el flujo crítico end-to-end: un nuevo usuario se registra, crea un cultivo, el sensor publica datos, y el sistema genera una alerta cuando los valores superan umbrales |
| **Precondiciones** | 1. Backend, MQTT broker y Supabase disponibles. 2. App en emulador. 3. Script MQTT publicador listo. |
| **Datos de entrada** | Nuevo email: `e2e_test@usf.com`. Cultivo: `Lechuga`. Payload MQTT: `{"temperature":38.0}` (supera umbral) |
| **Pasos** | 1. Registrar nuevo usuario en la app. 2. Crear cultivo "Lechuga" con perfil predefinido. 3. Publicar lectura MQTT con temperatura alta. 4. Esperar 5s. 5. Verificar alerta en la app. 6. Verificar registro en `Alert` en Supabase. |
| **Resultado esperado** | Alerta visible en app con mensaje sobre temperatura. Registro en tabla `Alert` con `crop_id` y `type='temperature_high'`. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Prueba de mayor cobertura del sistema |

---

**USF-SIST-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-SIST-002 |
| **Tipo** | Prueba de Sistema Completo |
| **Módulo** | Sistema completo (Flutter + FastAPI + Gemini + Supabase) |
| **Nombre** | Flujo E2E: captura de imagen → diagnóstico IA → resultado visible en app |
| **Prioridad** | ALTA |
| **Autor** | Carolina Ledesma |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el usuario puede tomar una foto desde la app, el backend la analiza con Gemini Vision y el diagnóstico se muestra correctamente en la interfaz |
| **Precondiciones** | 1. Usuario autenticado. 2. Cultivo creado. 3. API key Gemini válida. |
| **Datos de entrada** | Imagen de hoja con síntomas visibles |
| **Pasos** | 1. Navegar a sección de diagnóstico en la app. 2. Seleccionar o capturar imagen. 3. Enviar para análisis. 4. Esperar resultado. |
| **Resultado esperado** | Diagnóstico mostrado en pantalla (<15s). Texto descriptivo de posible enfermedad o estado de salud. Registro en `VisionAnalysis`. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-SIST-003**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-SIST-003 |
| **Tipo** | Prueba de Sistema Completo |
| **Módulo** | Sistema completo (Flutter + FastAPI + MQTT + Supabase `ActuationEvent`) |
| **Nombre** | Control manual de actuador desde app genera ActuationEvent |
| **Prioridad** | MEDIA |
| **Autor** | Alberto Calderón |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que activar un actuador (riego) desde la app envía el comando MQTT al dispositivo y registra el evento en `ActuationEvent` |
| **Precondiciones** | 1. Usuario autenticado. 2. Dispositivo o simulador MQTT suscrito al topic de actuadores. |
| **Datos de entrada** | Toggle de riego → ON para cultivo `Tomate Cherry` |
| **Pasos** | 1. Navegar a control de actuadores en la app. 2. Activar toggle de riego. 3. Verificar mensaje MQTT publicado. 4. Consultar `ActuationEvent` en Supabase. |
| **Resultado esperado** | Mensaje MQTT publicado al topic correcto. Registro en `ActuationEvent` con `action='riego'`, `state='on'`. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.6 Pruebas de Desempeño (USF-DEMP)

---

**USF-DEMP-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-DEMP-001 |
| **Tipo** | Prueba de Desempeño |
| **Módulo** | `backend/app/services/gemini_service.py` |
| **Nombre** | Latencia de análisis Gemini Vision inferior a 10 segundos |
| **Prioridad** | ALTA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el tiempo de respuesta del endpoint `POST /vision/analyze` no supera 10 segundos en condiciones normales de red |
| **Precondiciones** | 1. Backend corriendo. 2. API key Gemini válida. 3. Conexión a internet estable. |
| **Datos de entrada** | 5 solicitudes consecutivas con imagen de 500KB |
| **Pasos** | 1. Ejecutar colección Postman con 5 iteraciones de `POST /vision/analyze`. 2. Registrar tiempo de cada solicitud. 3. Calcular promedio y máximo. |
| **Resultado esperado** | Tiempo promedio < 8s. Tiempo máximo < 10s. Sin timeouts. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Medición con `time.perf_counter()` en `gemini_service.py` como alternativa |

---

**USF-DEMP-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-DEMP-002 |
| **Tipo** | Prueba de Desempeño |
| **Módulo** | `backend/app/services/mqtt_handler.py` → Supabase |
| **Nombre** | Propagación MQTT a persistencia en Supabase inferior a 500ms |
| **Prioridad** | MEDIA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el tiempo desde la publicación de un mensaje MQTT hasta la aparición del registro en Supabase no supera 500ms |
| **Precondiciones** | 1. Backend suscrito al MQTT broker. 2. Supabase accesible. 3. Script de medición preparado. |
| **Datos de entrada** | 10 mensajes MQTT con timestamp de publicación incluido |
| **Pasos** | 1. Publicar mensaje con `sent_at` en el payload. 2. Sondear Supabase hasta encontrar el registro. 3. Calcular diferencia de tiempo. 4. Repetir 10 veces. |
| **Resultado esperado** | Latencia promedio < 300ms. Latencia máxima < 500ms. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | La latencia incluye red, procesamiento del handler y escritura en Supabase |

---

### 3.7 Pruebas de Carga (USF-CARG)

---

**USF-CARG-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-CARG-001 |
| **Tipo** | Prueba de Carga |
| **Módulo** | `backend/app/services/mqtt_handler.py` |
| **Nombre** | 10 dispositivos MQTT publicando simultáneamente sin pérdida de datos |
| **Prioridad** | MEDIA |
| **Autor** | Carolina Ledesma |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el backend puede procesar mensajes MQTT de 10 dispositivos simultáneos sin pérdida de registros |
| **Precondiciones** | 1. Script multi-publisher `paho-mqtt` preparado con 10 clientes. 2. Supabase accesible. |
| **Datos de entrada** | 10 clientes MQTT, cada uno publica 5 mensajes = 50 mensajes totales |
| **Pasos** | 1. Ejecutar script con 10 publicadores simultáneos. 2. Esperar 30 segundos. 3. Contar registros en `SensorReading` creados en la última sesión. |
| **Resultado esperado** | 50 registros presentes en `SensorReading`. Sin errores en logs del backend. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-CARG-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-CARG-002 |
| **Tipo** | Prueba de Carga |
| **Módulo** | `backend/app/routers/crops.py` |
| **Nombre** | 50 solicitudes concurrentes a GET /crops sin degradación |
| **Prioridad** | MEDIA |
| **Autor** | Alberto Calderón |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el endpoint `GET /crops` maneja 50 solicitudes concurrentes con tiempo de respuesta aceptable |
| **Precondiciones** | 1. Backend corriendo. 2. `locust` instalado. 3. Al menos 5 cultivos en la base de datos. |
| **Datos de entrada** | 50 usuarios virtuales, ramp-up de 10s, duración 60s |
| **Pasos** | 1. Configurar `locustfile.py` con tarea `GET /crops`. 2. Ejecutar `locust -u 50 -r 10 --run-time 60s`. 3. Revisar reporte. |
| **Resultado esperado** | P95 de tiempo de respuesta < 2000ms. 0% de errores. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.8 Pruebas de Stress (USF-STRS)

---

**USF-STRS-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-STRS-001 |
| **Tipo** | Prueba de Stress |
| **Módulo** | `backend/app/services/mqtt_handler.py` |
| **Nombre** | 100 mensajes MQTT en 5 segundos no colapsa el backend |
| **Prioridad** | MEDIA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el backend se mantiene estable (sin crash ni memory leak) ante una ráfaga de 100 mensajes MQTT en 5 segundos |
| **Precondiciones** | 1. Backend corriendo. 2. Script de publicación masiva preparado. |
| **Datos de entrada** | 100 mensajes publicados en 5s (20 msg/s) desde 1 cliente |
| **Pasos** | 1. Ejecutar script de publicación masiva. 2. Monitorear CPU y memoria del proceso backend. 3. Al finalizar, verificar logs. 4. Ejecutar `GET /health` para confirmar backend responde. |
| **Resultado esperado** | Backend sigue respondiendo tras el burst. Sin crash. Log puede mostrar advertencias pero no excepciones críticas. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Pueden perderse algunos mensajes; lo crítico es que el proceso sobreviva |

---

**USF-STRS-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-STRS-002 |
| **Tipo** | Prueba de Stress |
| **Módulo** | `backend/app/services/gemini_service.py` |
| **Nombre** | Caída de Gemini API retorna HTTP 503 con degradación elegante |
| **Prioridad** | ALTA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que cuando Gemini API no está disponible, el backend retorna HTTP 503 con mensaje claro en lugar de crashear o colgar |
| **Precondiciones** | 1. API key de Gemini inválida o vacía configurada temporalmente. |
| **Datos de entrada** | `GEMINI_API_KEY=""` en `.env`. Solicitud a `POST /vision/analyze`. |
| **Pasos** | 1. Configurar API key inválida. 2. Reiniciar backend. 3. Ejecutar `POST /vision/analyze` con imagen. 4. Verificar respuesta. |
| **Resultado esperado** | HTTP 503. Body con mensaje de error: `{"detail": "Servicio de análisis no disponible temporalmente"}`. Sin excepción no manejada en logs. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Restaurar API key válida al finalizar |

---

### 3.9 Recuperación y Tolerancia a Fallas (USF-RECV)

---

**USF-RECV-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-RECV-001 |
| **Tipo** | Recuperación y Tolerancia a Fallas |
| **Módulo** | `backend/app/services/mqtt_handler.py` |
| **Nombre** | JSON malformado en MQTT es rechazado sin crashear el handler |
| **Prioridad** | ALTA |
| **Autor** | Carolina Ledesma |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que `on_message()` maneja correctamente un payload MQTT con JSON malformado sin lanzar excepción no controlada |
| **Precondiciones** | 1. Backend corriendo y suscrito al broker. |
| **Datos de entrada** | Payload MQTT inválido: `{temperatura: 24.5, "humidity": 68}` (clave sin comillas) |
| **Pasos** | 1. Publicar payload malformado al topic MQTT. 2. Verificar logs del backend. 3. Verificar que no se creó registro en `SensorReading`. 4. Publicar mensaje válido posterior. |
| **Resultado esperado** | Log de advertencia: "Payload MQTT inválido, descartado". Sin registro en Supabase para el mensaje malformado. Mensaje válido posterior procesado correctamente. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-RECV-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-RECV-002 |
| **Tipo** | Recuperación y Tolerancia a Fallas |
| **Módulo** | `backend/app/core/security.py` |
| **Nombre** | JWT expirado retorna HTTP 401 con mensaje claro |
| **Prioridad** | ALTA |
| **Autor** | Alberto Calderón |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que cualquier endpoint protegido retorna HTTP 401 con mensaje apropiado cuando el JWT del header `Authorization` está expirado |
| **Precondiciones** | 1. JWT expirado generado (o modificar `exp` del token). |
| **Datos de entrada** | Header: `Authorization: Bearer {jwt_expirado}` en `GET /crops` |
| **Pasos** | 1. Obtener JWT y modificar la fecha de expiración a pasado. 2. Ejecutar `GET /crops` con el JWT expirado. 3. Verificar respuesta. |
| **Resultado esperado** | HTTP 401. Body: `{"detail": "Token expirado o inválido"}` |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-RECV-003**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-RECV-003 |
| **Tipo** | Recuperación y Tolerancia a Fallas |
| **Módulo** | `backend/app/services/mqtt_handler.py` |
| **Nombre** | Payload MQTT con campos faltantes es descartado con log de advertencia |
| **Prioridad** | MEDIA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que cuando el payload MQTT omite campos requeridos (como `device_id`), el handler lo descarta sin intentar persistir datos incompletos |
| **Precondiciones** | 1. Backend suscrito al broker MQTT. |
| **Datos de entrada** | `{"temperature": 22.0}` (falta `device_id` y `humidity`) |
| **Pasos** | 1. Publicar payload incompleto. 2. Verificar logs. 3. Verificar Supabase. |
| **Resultado esperado** | Log de advertencia indicando campos faltantes. Sin inserción en `SensorReading`. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.10 Pruebas de GUI (USF-GUII)

---

**USF-GUII-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-GUII-001 |
| **Tipo** | Prueba de GUI |
| **Módulo** | Frontend — pantalla de registro / login |
| **Nombre** | Formulario de login valida campos vacíos y muestra errores |
| **Prioridad** | ALTA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el formulario de login muestra mensajes de error apropiados cuando se intenta enviar con campos vacíos |
| **Precondiciones** | 1. App abierta en pantalla de login. |
| **Datos de entrada** | Campos email y password vacíos |
| **Pasos** | 1. No ingresar nada en los campos. 2. Presionar "Iniciar sesión". 3. Observar mensajes de validación. |
| **Resultado esperado** | Mensajes de error visibles bajo cada campo: "El email es requerido", "La contraseña es requerida". Sin navegación ni solicitud al backend. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-GUII-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-GUII-002 |
| **Tipo** | Prueba de GUI |
| **Módulo** | Frontend — componente SensorGauge |
| **Nombre** | SensorGauge muestra color correcto según nivel de alerta |
| **Prioridad** | ALTA |
| **Autor** | Carolina Ledesma |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el widget SensorGauge cambia de color (verde/amarillo/rojo) según si el valor está dentro, cerca o fuera del rango óptimo del cultivo |
| **Precondiciones** | 1. Cultivo con perfil de temperatura creado (óptimo: 18-28°C). 2. Datos de sensor cargados. |
| **Datos de entrada** | Tres lecturas: 22°C (normal), 30°C (advertencia), 40°C (crítico) |
| **Pasos** | 1. Navegar al dashboard del cultivo. 2. Observar color del gauge con temperatura 22°C. 3. Simular lectura de 30°C y observar. 4. Simular 40°C y observar. |
| **Resultado esperado** | 22°C: gauge verde. 30°C: gauge amarillo. 40°C: gauge rojo. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Puede requerir modificar datos en Supabase para simular lecturas |

---

**USF-GUII-003**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-GUII-003 |
| **Tipo** | Prueba de GUI |
| **Módulo** | Frontend — wizard de creación de cultivo |
| **Nombre** | Wizard de 4 pasos navega correctamente y valida cada paso |
| **Prioridad** | MEDIA |
| **Autor** | Alberto Calderón |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el wizard de creación de cultivo permite navegar entre los 4 pasos, valida los campos de cada uno antes de avanzar y completa la creación |
| **Precondiciones** | 1. Usuario autenticado. 2. Al menos un perfil de cultivo disponible. |
| **Datos de entrada** | Nombre: "Menta", Perfil: "Hierbas aromáticas", Dispositivo: "esp32-01", Ubicación: "Balcón" |
| **Pasos** | 1. Navegar a "Nuevo cultivo". 2. Completar paso 1 (nombre) y presionar "Siguiente". 3. Completar paso 2 (perfil). 4. Completar paso 3 (dispositivo). 5. Completar paso 4 (ubicación). 6. Presionar "Crear". |
| **Resultado esperado** | Navegación fluida entre 4 pasos. Indicador de progreso actualizado. Botón "Siguiente" deshabilitado si campo vacío. Cultivo creado al finalizar. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.11 Pruebas de Aceptación (USF-ACEP)

---

**USF-ACEP-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-ACEP-001 |
| **Tipo** | Prueba de Aceptación |
| **Módulo** | CU-01: Registrar usuario |
| **Nombre** | CU-01 — Usuario completa registro exitosamente |
| **Prioridad** | ALTA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que el caso de uso CU-01 (Registrar usuario) cumple todos los criterios de aceptación definidos en la especificación |
| **Precondiciones** | 1. App abierta. 2. Email de prueba no registrado previamente. |
| **Datos de entrada** | email: `nuevo@usf.com`, password: `NuevoUser1!`, nombre: "Carlos Perez" |
| **Pasos** | 1. Seleccionar "Crear cuenta". 2. Ingresar datos. 3. Confirmar registro. 4. Verificar email de confirmación (si aplica). 5. Iniciar sesión con las nuevas credenciales. |
| **Resultado esperado** | Usuario registrado exitosamente. Puede iniciar sesión. Perfil visible en la app. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Evaluador/profesor como observador |

---

**USF-ACEP-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-ACEP-002 |
| **Tipo** | Prueba de Aceptación |
| **Módulo** | CU-07: Solicitar diagnóstico con IA |
| **Nombre** | CU-07 — Diagnóstico IA retorna recomendación comprensible |
| **Prioridad** | ALTA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que CU-07 cumple el criterio de aceptación: el usuario recibe un diagnóstico en lenguaje natural comprensible dentro de los 15 segundos |
| **Precondiciones** | 1. Usuario autenticado. 2. Cultivo activo. 3. Gemini API disponible. |
| **Datos de entrada** | Foto real o de fixture con hoja enferma |
| **Pasos** | 1. Ir a la sección de diagnóstico. 2. Cargar imagen. 3. Solicitar análisis. 4. Medir tiempo de respuesta. 5. Leer diagnóstico mostrado. |
| **Resultado esperado** | Diagnóstico visible en menos de 15s. Texto en español. Incluye posible causa y recomendación de acción. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

**USF-ACEP-003**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-ACEP-003 |
| **Tipo** | Prueba de Aceptación |
| **Módulo** | CU-11: Recibir y gestionar alertas |
| **Nombre** | CU-11 — Sistema genera alerta automática por umbral superado |
| **Prioridad** | ALTA |
| **Autor** | Carolina Ledesma |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que CU-11 cumple el criterio de aceptación: el sistema genera y muestra una alerta automáticamente cuando un sensor supera el umbral del perfil de cultivo |
| **Precondiciones** | 1. Cultivo con perfil que define umbrales. 2. Backend procesando MQTT. |
| **Datos de entrada** | Temperatura: 42°C (umbral máximo del perfil: 32°C) |
| **Pasos** | 1. Publicar lectura MQTT con temperatura 42°C. 2. Esperar hasta 10s. 3. Verificar sección de alertas en la app. |
| **Resultado esperado** | Alerta visible en la app con descripción del umbral superado y timestamp. Registro en tabla `Alert`. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.12 Pruebas de Usabilidad (USF-USAB)

---

**USF-USAB-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-USAB-001 |
| **Tipo** | Prueba de Usabilidad |
| **Módulo** | Frontend — flujo de onboarding completo |
| **Nombre** | Usuario sin experiencia técnica completa onboarding en menos de 5 minutos |
| **Prioridad** | MEDIA |
| **Autor** | Alberto Calderón |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Medir el tiempo que tarda un usuario sin experiencia técnica en registrarse y crear su primer cultivo desde cero |
| **Precondiciones** | 1. Usuario participante reclutado (no del equipo de desarrollo). 2. App instalada en dispositivo físico. |
| **Datos de entrada** | Sin instrucciones previas al usuario. Solo indicar: "Regístrate y crea tu primer cultivo" |
| **Pasos** | 1. Entregar dispositivo al usuario. 2. Cronometrar desde que abre la app hasta que el cultivo queda creado. 3. Observar sin intervenir. 4. Anotar puntos de fricción. |
| **Resultado esperado** | Tarea completada en menos de 5 minutos. Usuario no necesita asistencia del equipo. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Anotar verbatim comentarios del usuario |

---

**USF-USAB-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-USAB-002 |
| **Tipo** | Prueba de Usabilidad |
| **Módulo** | Frontend — dashboard de sensor |
| **Nombre** | Usuario interpreta correctamente el estado del cultivo en el gauge |
| **Prioridad** | MEDIA |
| **Autor** | Julián Alva |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que un usuario no técnico puede interpretar correctamente el estado del cultivo (bueno/advertencia/crítico) al ver el SensorGauge sin explicación previa |
| **Precondiciones** | 1. Dashboard visible con gauge en color rojo (temperatura 40°C). |
| **Datos de entrada** | Pantalla del dashboard con gauge en estado crítico (rojo) |
| **Pasos** | 1. Mostrar pantalla al usuario. 2. Preguntar: "¿Cómo está el cultivo según lo que ves?". 3. Anotar respuesta. |
| **Resultado esperado** | Usuario indica que "algo está mal" o "hay un problema" o "la temperatura está alta" sin necesidad de guía. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Probar con 3 usuarios distintos y promediar |

---

### 3.13 Pruebas Alfa (USF-ALFA)

---

**USF-ALFA-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-ALFA-001 |
| **Tipo** | Prueba Alfa |
| **Módulo** | Sistema completo |
| **Nombre** | Sesión interna del equipo: recorrido completo de todas las funcionalidades |
| **Prioridad** | ALTA |
| **Autor** | Equipo USF |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | El equipo completo ejecuta un recorrido guiado por todas las funcionalidades antes de la entrega, identificando defectos no detectados anteriormente |
| **Precondiciones** | 1. Versión integrada estable en rama `main`. 2. Todos los integrantes presentes. |
| **Datos de entrada** | Datos de prueba reales (no fixtures) |
| **Pasos** | 1. Registro y login. 2. Creación de cultivo. 3. Visualización de sensores en tiempo real. 4. Diagnóstico IA con foto. 5. Control de actuadores. 6. Verificación de alertas. 7. Cierre de sesión. |
| **Resultado esperado** | Flujo completo sin bloqueos críticos. Defectos menores registrados en el sistema de seguimiento. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Duración estimada: 1-2 horas |

---

**USF-ALFA-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-ALFA-002 |
| **Tipo** | Prueba Alfa |
| **Módulo** | Frontend — compatibilidad Android |
| **Nombre** | App funciona correctamente en Android 10 y Android 13 |
| **Prioridad** | MEDIA |
| **Autor** | Ximena Pérez |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que la app Flutter no presenta errores de compatibilidad en las versiones Android mínima y objetivo del proyecto |
| **Precondiciones** | 1. Emulador Android API 29 (Android 10) disponible. 2. Emulador o dispositivo API 33 (Android 13) disponible. |
| **Datos de entrada** | APK de versión actual |
| **Pasos** | 1. Instalar APK en Android 10. 2. Ejecutar flujo login → dashboard. 3. Repetir en Android 13. |
| **Resultado esperado** | App funciona en ambas versiones. Sin errores de permisos no gestionados. UI correctamente renderizada. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | |

---

### 3.14 Pruebas Beta (USF-BETA)

---

**USF-BETA-001**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-BETA-001 |
| **Tipo** | Prueba Beta |
| **Módulo** | Sistema completo |
| **Nombre** | Usuarios externos usan la app de forma autónoma durante 48 horas |
| **Prioridad** | MEDIA |
| **Autor** | Equipo USF |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Detectar defectos de usabilidad, crashes y comportamientos inesperados que no emergen en pruebas controladas, mediante uso real no supervisado |
| **Precondiciones** | 1. Mínimo 3 usuarios externos reclutados. 2. APK instalado en sus dispositivos. 3. Canal de reporte de problemas establecido (formulario o grupo de chat). |
| **Datos de entrada** | Instrucciones básicas de uso. Sin guía de pasos específicos. |
| **Pasos** | 1. Distribuir APK y credenciales de prueba. 2. Indicar que usen la app con libertad durante 48h. 3. Solicitar que reporten cualquier problema. 4. Recopilar reportes al finalizar. |
| **Resultado esperado** | Menos de 3 defectos de severidad MEDIA reportados. Sin crashes con pérdida de datos. |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Periodo de prueba: 48h continuas antes de la fecha de entrega |

---

**USF-BETA-002**

| Campo | Valor |
|-------|-------|
| **ID Prueba** | USF-BETA-002 |
| **Tipo** | Prueba Beta |
| **Módulo** | Frontend — sistema de alertas |
| **Nombre** | Usuarios externos comprenden y reaccionan a las alertas automáticas |
| **Prioridad** | MEDIA |
| **Autor** | Equipo USF |
| **Fecha** | 2026-05-11 |
| **Versión** | d0effe4 |
| **Objetivo** | Verificar que las alertas generadas automáticamente son lo suficientemente claras para que un usuario externo entienda qué acción tomar |
| **Precondiciones** | 1. Usuarios beta activos en la app. 2. Al menos una alerta generada durante el periodo de 48h. |
| **Datos de entrada** | Alerta real generada por umbral superado durante uso normal |
| **Pasos** | 1. Después del periodo de 48h, preguntar a cada usuario: "Si viste una alerta en la app, ¿qué hiciste o qué hubieras hecho?". 2. Registrar respuestas. |
| **Resultado esperado** | Al menos 2 de 3 usuarios describen una acción correcta en respuesta a la alerta (revisar la planta, ajustar riego, etc.). |
| **Resultado real** | |
| **Evidencia** | |
| **Estado** | [ ] PASS   [ ] FAIL   [ ] BLOQUEADO   [ ] N/A |
| **Defecto vinculado** | Ninguno |
| **Notas** | Entrevista post-prueba de 5 minutos por usuario |

---

## 4. Matriz de Trazabilidad

| Caso de Uso | UNIT | INTG | REGR | SMOK | SIST | DEMP | CARG | STRS | RECV | GUII | ACEP | USAB | ALFA | BETA |
|-------------|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|:----:|
| CU-01 Registrar usuario | ✓ | | ✓ | ✓ | | | | | | ✓ | ✓ | ✓ | ✓ | ✓ |
| CU-02 Iniciar sesión | ✓ | | ✓ | ✓ | | | | | ✓ | ✓ | | ✓ | ✓ | |
| CU-03 Crear cultivo | ✓ | ✓ | | | ✓ | | | | | ✓ | | ✓ | ✓ | ✓ |
| CU-04 Ver dashboard de cultivo | | | | | ✓ | | | | | ✓ | | ✓ | ✓ | ✓ |
| CU-05 Recibir datos de sensores | ✓ | ✓ | | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | | | ✓ | |
| CU-06 Ver historial de lecturas | | ✓ | ✓ | | | ✓ | ✓ | | | | | | ✓ | ✓ |
| CU-07 Solicitar diagnóstico IA | ✓ | ✓ | ✓ | | ✓ | ✓ | | ✓ | | | ✓ | | ✓ | |
| CU-08 Ver resultados de diagnóstico | | | | | ✓ | | | | | ✓ | | ✓ | ✓ | ✓ |
| CU-09 Controlar actuadores | | ✓ | | | ✓ | | | | | ✓ | | | ✓ | ✓ |
| CU-10 Ver estado de actuadores | | | | | ✓ | | | | | ✓ | | ✓ | ✓ | ✓ |
| CU-11 Recibir y gestionar alertas | | ✓ | ✓ | | ✓ | | | | ✓ | ✓ | ✓ | | ✓ | ✓ |
| CU-12 Configurar perfil de cultivo | ✓ | ✓ | | | | | | | | ✓ | | | ✓ | |
| CU-13 Cerrar sesión | ✓ | | ✓ | | | | | | ✓ | | | | ✓ | |

---

*Documento generado: 2026-05-11 | Urban Smart Farming — Equipo de Desarrollo*
