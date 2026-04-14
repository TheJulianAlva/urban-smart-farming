# Configuración del Backend - Urban Smart Farming

Bienvenido al Backend de USF. Sigue estos pasos para instalar tu entorno de desarrollo local y empezar a codificar.

## Prerequisitos
Antes de comenzar, asegúrate de tener instalado en tu computadora:
- **Python 3.13.x** — [Descargar aquí](https://www.python.org/downloads/release/python-3130/)

> **¿Cómo verifico mi versión?** Abre una terminal y ejecuta: `python --version`
> Debes ver `Python 3.13.x`. Si tienes una versión más antigua, descarga e instala la indicada arriba.

## Pasos para Arrancar

### 1. Entrar al directorio
Si estás en la raíz del proyecto, debes entrar a la carpeta del backend en tu terminal:
```powershell
cd backend
```

### 2. Crear tu Entorno Virtual
Esto aislará las versiones de tu código de tu sistema operativo general.
```powershell
python -m venv .venv
```
*(Sistema Mac/Linux: usa `python3` en lugar de `python`)*

### 3. Activar el Entorno Virtual
Debes activarlo **cada vez** que vayas a trabajar en el backend o a instalar algo nuevo. Sabrás que está activo cuando veas un prefijo verde que dice `(.venv)` a la izquierda de tu terminal.

**En Windows (PowerShell):**
```powershell
.\.venv\Scripts\Activate
```
> **Nota de Seguridad de Windows:** Si te salta un error de "Ejecución de scripts deshabilitada", debes correr el siguiente comando por única vez como administrador de tu PC y luego volver a intentar el paso 3:
> `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

**En Mac/Linux:**
```bash
source .venv/bin/activate
```

### 4. Instalar el "Contrato" de Dependencias
Asegurándote de que el entorno esté activado (`.venv`), ejecuta el archivo maestra:
```powershell
pip install -r requirements.txt
```
Esto descargará FastAPI, Supabase y más, dejándote exactamente en la misma versión tecnológica que todo el equipo.

### 5. Prueba de Vida (Opcional)
Para probar que todo funciona, levanta el servidor de la API:
```powershell
uvicorn app.main:app --reload
```
Abre en tu navegador `http://127.0.0.1:8000/docs` para ver tu interfaz de pruebas.
