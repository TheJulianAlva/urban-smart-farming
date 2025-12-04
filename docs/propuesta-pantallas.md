# GUÍA DE DISEÑO DE INTERFAZ Y EXPERIENCIA DE USUARIO (UX/UI)
# PROYECTO: URBAN SMART FARMING
# PLATAFORMA: FLUTTER (MÓVIL)

---

## 1. PANTALLA DE INICIO (SPLASH & AUTH)
**Objetivo:** Permitir el acceso seguro y personalizado al sistema.
---

## 2. PANTALLA PRINCIPAL: "MI JARDÍN" (DASHBOARD)
**Objetivo:** Vista rápida del estado general de todos los cultivos.

### Estructura (Layout):
- **App Bar Superior:**
  - Saludo: "Hola, [Nombre Usuario]".
  - Icono Acción: Campana de Notificaciones (Con badge rojo si hay alertas activas).
- **Cuerpo (Body):**
  - **Resumen de Estado:** Tarjeta superior que cambia de color.
    - *Verde:* "Tus cultivos están excelentes".
    - *Naranja:* "1 Cultivo requiere atención".
  - **Grilla de Cultivos:** Lista scrolleable de tarjetas (Cards).
    - Cada tarjeta muestra: Icono de la planta, Nombre (ej. "Tomates"), Ubicación (ej. "Terraza").
    - **Badges de Estado:** Pequeños iconos sobre la tarjeta que se iluminan si falta agua (Gota) o luz (Sol).
- **Botón Flotante (FAB):** Icono grande [+] en la esquina inferior derecha para [AGREGAR CULTIVO].
- **Barra de Navegación Inferior (Bottom Nav):**
  1. Mi Jardín (Activo).
  2. Diagnóstico IA.
  3. Perfiles/Ajustes.

### Funciones:
- **Toque en Tarjeta:** Navega a la Pantalla 3 (Detalle del Cultivo).
- **Toque en FAB (+):** Navega a la Pantalla 4 (Wizard de Creación).

---

## 3. PANTALLA DE DETALLE DEL CULTIVO (CENTRO DE CONTROL)
**Objetivo:** Monitoreo detallado y control de hardware (Manual/Automático).

### Estructura (Tab View):
Esta pantalla se divide en 3 pestañas superiores para no saturar al usuario.

#### Pestaña A: MONITOR (Vista por defecto)
- **Visualización de Datos:** 3 Gráficos Circulares (Radial Gauges).
  1. **Humedad del Suelo:** Muestra % actual. Fondo verde si está dentro del umbral del perfil, rojo si está fuera.
  2. **Temperatura:** Muestra °C.
  3. **Luz:** Muestra %.
- **Estado de Conexión:** Indicador pequeño "Hardware: Conectado/Desconectado".

#### Pestaña B: CONTROL (Interacción Hardware)
- **Modo de Operación:** Switch principal "Modo Automático".
  - *Si está ON:* Los controles manuales se bloquean (gris). Texto: "El sistema gestiona el riego según el perfil".
  - *Si está OFF:* Se habilitan los controles manuales.
- **Controles Manuales:**
  - **Riego:** Botón grande [REGAR AHORA] (presionar para activar bomba, soltar para apagar o toggle ON/OFF).
  - **Iluminación:** Slider (deslizador) de 0% a 100% de intensidad o Switch ON/OFF.
  - **Ventilación (Opcional):** Switch ON/OFF.

#### Pestaña C: HISTORIAL
- **Gráfica Lineal:** Muestra la evolución de humedad/temperatura de los últimos 7 días.

---

## 4. PANTALLA: ASISTENTE DE NUEVO CULTIVO (WIZARD)
**Objetivo:** Registrar un cultivo, asignar hardware y definir perfil.

### Pasos del Wizard:
1.  **Datos Básicos:**
    - Input: Nombre del cultivo (ej. "Albahaca Cocina").
    - Input: Ubicación.
    - Selección de Icono/Avatar.
2.  **Vincular Hardware:**
    - Lista desplegable: Muestra dispositivos disponibles y no asignados.
    - Botón: [ESCANEAR NUEVO HARDWARE] (si aplica QR o búsqueda Bluetooth).
3.  **Configuración de Perfil (La clave de la adaptabilidad):**
    - **Opción A: "Soy Principiante" (Recomendado)**
      - Lista de Perfiles Predefinidos (Base de Datos): Tomates, Lechugas, Cactus, Flores.
      - Al seleccionar uno, muestra: "Este perfil mantendrá la humedad al 60%".
    - **Opción B: "Soy Experto"**
      - Formulario manual: Definir Umbral Mínimo Humedad, Umbral Máximo Temperatura, Horas de luz.
4.  **Resumen y Guardar:** Muestra todos los datos para confirmación.

---

## 5. PANTALLA: DIAGNÓSTICO CON IA
**Objetivo:** Detectar plagas o enfermedades visualmente.

### Interfaz:
- **Vista de Cámara:** Ocupa el 80% de la pantalla.
- **Botones de Acción:**
  - [CAPTURAR FOTO]: Botón circular central.
  - [GALERÍA]: Icono para subir foto existente.
- **Flujo de Respuesta:**
  - Al tomar la foto, mostrar animación "Analizando...".
  - **Pop-up de Resultados (Bottom Sheet):**
    - Imagen recortada.
    - Resultado: "Saludable (98%)" o "Alerta: Hojas Amarillas / Deficiencia de Nitrógeno (85%)".
    - **Acción Sugerida:** Texto breve recomendando qué hacer (ej. "Aumentar frecuencia de fertilizante").

---

## 6. PANTALLA: GESTIÓN Y AJUSTES
**Objetivo:** Gestión integral de hardware y perfiles personalizados.

### Secciones (Lista de Opciones):
- **Mis Perfiles de Cultivo:**
  - Lista de los perfiles creados o guardados.
  - Al tocar uno: Opción de [EDITAR UMBRALES] o [ELIMINAR].
- **Gestión de Hardware:**
  - Lista de sensores/actuadores registrados.
  - Estado actual (En línea / Fuera de línea).
  - Opción para [DESVINCULAR] o [ACTUALIZAR FIRMWARE] (futuro).
- **Cuenta:**
  - Cerrar Sesión.

---

## CONSIDERACIONES DE UX (Experiencia de Usuario)
1.  **Feedback Visual:** Cada vez que el usuario active un actuador (luz/agua), la app debe mostrar un indicador de carga "Enviando orden..." y luego una confirmación "Riego Activado" para asegurar que el hardware respondió.
2.  **Alertas:** Si la app está cerrada y un sensor detecta valores críticos, debe llegar una **Notificación Push** nativa: "¡Alerta! Tu cultivo 'Tomates' tiene la humedad crítica (10%)". Al tocarla, abre directamente la Pantalla 3.
3.  **Tema:** Usar un tema claro (Light Mode) con acentos verdes para evocar naturaleza, limpieza y tecnología.
