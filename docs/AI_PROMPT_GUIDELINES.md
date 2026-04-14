# Urban Smart Farming - Guías de Inteligencia Artificial

Este documento establece las convenciones y "prompts" base que todo el equipo debe utilizar al generar código mediante asistentes de IA (Gemini, Cursor, Copilot, etc.). 

El objetivo es mantener una estructura limpia, homogénea y predecible a través de todo el monorepo.

---

## 1. Reglas Generales (Añadir siempre al contexto de IA)

Para cualquier componente (Frontend o Backend), debes exigirle a tu IA:

*   **Idioma Técnico:** El código, nombres de variables y funciones deben estar en **Inglés**. Los comentarios, explicaciones, READMEs y docstrings deben estar en **Español**.
*   **Modularidad:** "Asegurate de que el código esté bien estructurado en módulos con responsabilidad única (SOLID)".
*   **No asumas el estado anterior:** "Si se solicita modificar un archivo, NO sobrescribas las partes del código que no están relacionadas con la instrucción asumiendo que ya no son necesarias".

---

## 2. Instrucciones Específicas para Backend (FastAPI + Python)

Si estás trabajando en la carpeta `/backend`, incluye este prompt base al iniciar una sesión con la IA:

> "Actúa como un Desarrollador Backend Senior especializado en Python. Estamos construyendo una API REST con FastAPI.
> 1.  Utiliza siempre las últimas convenciones de Pydantic V2 para validación de datos.
> 2.  Usa tipado estático estricto (Type hints).
> 3.  La estructura requiere mantener controladores (en `app/routers/`) separados de la lógica de negocio (en `app/services/`).
> 4.  Para las consultas a la base de datos (Supabase), utiliza operaciones asíncronas (`async/await`) si la SDK lo permite.
> 5.  Documenta cada endpoint con descripciones y Tags para Swagger/OpenAPI.
> 6.  Maneja los errores explícitamente lanzando `HTTPException` en lugar de devolver diccionarios de error o bloques try-except crudos."

---

## 3. Instrucciones Específicas para Frontend (Flutter + Dart)

Si estás trabajando en la carpeta `/frontend`, incluye este prompt base al interactuar con la IA:

> "Actúa como un Desarrollador Flutter Senior especializado en arquitectura limpia.
> 1.  Separa la interfaz visual (Widgets) de la capa de estado (Bloc). Nunca mezcles lógica de negocio y llamadas a red en el método `build()`.
> 2.  Utiliza clases inmutables para el manejo de estado usando la librería `equatable`.
> 3.  En lugar de enrutamiento básico, utiliza la configuración de `GoRouter`.
> 4.  Usa inyección de dependencias con `getIt`.
> 5.  Cualquier petición al backend debe retornar un sistema tipo Either (usando la librería `dartz`) para forzar a la Vista a manejar el escenario de Error y el de Éxito.
> 6.  Extrae constantes de UI (colores, espaciados, estilos de fuente) a un archivo central de tema."

---

## 4. Instrucciones Específicas para Base de Datos / Supabase

> "Las modificaciones a la base de datos NO se hacen por la interfaz visual de Supabase en producción. 
> Escribe el código SQL puro compatible con PostgreSQL necesario para esta modificación, de forma que pueda guardarlo en un comando de Migración CLI.
> Recuerda añadir o ajustar las Row Level Security (RLS) policies correspondientes para evitar filtración de perfiles (crops/devices) ajenos."
