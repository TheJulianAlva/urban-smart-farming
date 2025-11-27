# ESPECIFICACIÓN DE REQUISITOS DE SOFTWARE: URBAN SMART FARMING

## 1. VISIÓN GENERAL DEL PROYECTO
**Urban Smart Farming** es un sistema integral de agricultura urbana inteligente diseñado para democratizar el acceso a la tecnología agrícola. El sistema permite a usuarios con o sin experiencia cultivar alimentos en casa mediante la automatización del monitoreo y control de variables ambientales.

El núcleo del sistema es una **Aplicación Móvil (desarrollada en Flutter)** que actúa como interfaz de mando, conectándose con un prototipo de hardware (IoT) y servicios para gestionar el ciclo de vida de las plantas.

---

## 2. OBJETIVOS DEL SISTEMA
1.  **Automatización:** Monitorear variables críticas (humedad, temperatura, luz) y actuar sobre ellas (riego, iluminación) sin intervención humana constante.
2.  **Diagnóstico Inteligente:** Utilizar Visión por Computadora para detectar plagas o deficiencias nutricionales mediante fotos tomadas con el móvil.
3.  **Gestión Centralizada:** Permitir la administración de múltiples perfiles de cultivo y dispositivos desde una única app.
4.  **Notificaciones Proactivas:** Alertar al usuario en tiempo real sobre condiciones anómalas que requieran atención inmediata.

---

## 3. ACTORES DEL SISTEMA

| Actor | Tipo | Descripción |
| :--- | :--- | :--- |
| **Usuario** | Primario | El agricultor urbano. Interactúa con la App (Flutter) para configurar, supervisar y controlar los cultivos. |
| **Sensores/Actuadores** | Secundario | Hardware físico (IoT). Envía datos brutos de telemetría y recibe comandos de acción (encender bomba/luz). |
| **Sistema de Notificaciones** | Secundario | Servicio externo (Push/Email) encargado de entregar las alertas generadas por el sistema. |

---

## 4. DETALLE DE FUNCIONALIDADES Y CASOS DE USO (Prioridad V2)

### MÓDULO A: GESTIÓN DE ACCESO Y PERFILES

**CU-01: Registrarse en Sistema**
* **Objetivo:** Onboarding de nuevos usuarios.
* **Datos:** Nombre, email, contraseña.
* **Validaciones:** Formato de email, robustez de contraseña, unicidad de cuenta.
* **Flujo:** Registro -> Validación -> Creación de cuenta -> Redirección a Login.

**CU-02: Iniciar Sesión**
* **Objetivo:** Autenticación segura para acceder a datos privados.
* **Mecanismo:** Email y contraseña.
* **Reglas:** Bloqueo temporal tras 3 intentos fallidos. Gestión de sesiones activas.

**CU-03: Gestionar Perfil de Cultivo**
* **Concepto:** Un "Perfil" representa una zona de cultivo o maceta específica (ej. "Lechugas Balcón").
* **Acciones:** Crear, Ver, Editar, Eliminar (CRUD).
* **Datos del Perfil:** Nombre, tipo de planta (vinculado al Catálogo), ubicación.
* **Regla de Negocio:** No permitir nombres duplicados para un mismo usuario.

**CU-04: Administrar Dispositivos**
* **Objetivo:** Vincular el mundo físico con el lógico.
* **Flujo:** El usuario ingresa un ID único de dispositivo (Sensor o Actuador) y lo asocia a un Perfil de Cultivo específico.
* **Validación:** Verificar que el ID del dispositivo no esté asociado ya a otro usuario.

---

### MÓDULO B: MONITOREO Y NOTIFICACIÓN (CORE)

**CU-05: Visualizar Dashboard (Pantalla Principal de la App)**
* **Interfaz:** Medidores visuales (gauges), indicadores de estado y gráficos en tiempo real.
* **Datos:** Humedad, temperatura, luminosidad actuales. Estado de conexión de sensores (Online/Offline).
* **Frecuencia:** Actualización automática a intervalos regulares.

**CU-06: Recibir Datos de Sensores (Backend/Lógica)**
* **Descripción:** Proceso de fondo que ingesta la telemetría enviada por el hardware.
* **Lógica de Negocio:**
    1. Recibe paquete de datos -> Decodifica ID.
    2. Busca el Perfil de Cultivo asociado.
    3. Compara valores recibidos vs. Umbrales Óptimos (del Catálogo).
    4. **Trigger 1:** Si valor fuera de rango -> Invoca *CU-07 (Notificar Alerta)*.
    5. **Trigger 2:** Guarda dato en BD -> Invoca *CU-08 (Registrar Historial)*.
    6. **Trigger 3:** Evalúa reglas automáticas -> Si cumple condición, dispara actuador (ver *CU-11*).

**CU-07: Notificar Alerta**
* **Disparador:** Anomalías detectadas en CU-06 o problemas detectados en CU-09.
* **Acción:** Envía Push Notification o Email (ej. "Alerta: Humedad crítica 18% en 'Tomates'").
* **Control:** Evitar spam (no enviar la misma alerta repetidamente en corto tiempo).

**CU-08: Registrar en Historial**
* **Objetivo:** Persistencia de datos para análisis futuro. Almacena series temporales de telemetría.

**CU-09: Analizar Imagen de Planta (Visión Computacional)**
* **Flujo:**
    1. Usuario toma foto o selecciona de galería.
    2. Envío a módulo de IA/CV.
    3. Retorno de diagnóstico: "Saludable", "Posible Plaga", "Deficiencia: Nitrógeno" + % de confianza.
* **Integración:** Si se detecta problema grave, dispara *CU-07 (Notificar Alerta)*.

---

### MÓDULO C: CONTROL Y AUTOMATIZACIÓN

**CU-10: Controlar Actuador Manualmente**
* **Interfaz:** Botones tipo "Toggle" en la App (ON/OFF) para bombas de riego o luces.
* **Acción:** Envía comando inmediato al hardware.
* **Feedback:** La UI debe reflejar si el hardware confirmó la recepción del comando o si hubo error.

**CU-11: Gestionar Reglas Automáticas**
* **Objetivo:** Programación lógica "IF-THEN" para autonomía del cultivo.
* **Constructor de Reglas:** Interfaz que permita crear frases lógicas:
    * *SI* [Sensor Humedad] < [30%] *ENTONCES* [Activar Bomba] por [5 min].
* **Validación:** Evitar reglas contradictorias (ej. encender y apagar al mismo tiempo).

---

### MÓDULO D: ANALÍTICA Y CONFIGURACIÓN

**CU-12: Consultar Historial y Analíticas**
* **Interfaz:** Gráficos interactivos de líneas/barras.
* **Filtros:** Por Perfil de Cultivo y por Rango de Fechas (Semana, Mes).
* **Métricas:** Promedios, máximos, mínimos, consumo de recursos.

**CU-13: Gestionar Catálogo de Plantas**
* **Concepto:** Base de conocimiento de "Plantillas" con parámetros ideales predefinidos.
* **Uso:** Al crear un perfil, el usuario selecciona "Tomate Cherry" y el sistema carga automáticamente: Temp (20-28°C), Humedad (50-65%).
* **Gestión:** Capacidad de añadir nuevas plantillas personalizadas.

---

## 5. REQUERIMIENTOS NO FUNCIONALES CLAVE (Para Flutter)

1.  **Adaptabilidad:** Diseño Responsive que funcione bien en diferentes tamaños de pantalla móvil.

## CONSIDERACIONES PARA DESARROLLO

1. Uso de las dependencias de Flutter (Mock Up):
    * Flutter Bloc
    * GoRouter
    * getIt
    * dartz
    * equatable

2. Ser claro en la arquitectura de la app, en la forma en que se implementan los patrones de diseño y en la sintaxis de redacción, colocar nombres de variables, funciones y metodos descriptivos y completos.



# GUÍA DE DISEÑO DE INTERFAZ Y NAVEGACIÓN (FLUTTER)

## ESTRUCTURA GENERAL DE NAVEGACIÓN
El sistema utiliza una arquitectura simplificada para mejorar la experiencia de usuario (UX). Se basa en un flujo de **Autenticación Única** seguido de una estructura principal controlada por un **BottomNavigationBar** persistente.

### Mapa de Navegación Simplificado (6 Pantallas Clave)
1.  **S-01: Autenticación** (Login/Registro unificados).
2.  **S-02: Dashboard** (Home - BottomNav Index 0).
3.  **S-03: Control y Automatización** (BottomNav Index 1).
4.  **S-04: Historial y Analíticas** (BottomNav Index 2).
5.  **S-05: Alertas y Diagnóstico** (BottomNav Index 3).
6.  **S-06: Ajustes y Configuración** (Accesible desde Dashboard).

---

# DETALLE DE PANTALLAS A DESARROLLAR

### 1. PANTALLA DE ACCESO (S-01)
**Propósito:** Punto de entrada único a la aplicación.
**Widget Sugerido:** `Scaffold` con un `DefaultTabController`.

* **Estructura:**
    * Logo del Proyecto en la parte superior.
    * **TabBar** con dos pestañas: "Iniciar Sesión" y "Registrarse".
    * **Tab 1 (Login):** Campos de Email y Contraseña. Botón "Entrar".
    * **Tab 2 (Registro):** Campos Nombre, Email, Password, Confirmar Password. Botón "Registrar".
* **Comportamiento:** Al autenticar con éxito, navegar usando `Navigator.pushReplacement` hacia la estructura principal (MainScreen).

---

### 2. ESTRUCTURA PRINCIPAL (SCAFFOLD PADRE)
Esta no es una pantalla en sí, sino el contenedor que gestiona la navegación inferior.
**Widget:** `Scaffold` con `BottomNavigationBar`.
**Items del Menú:**
1.  Icono Home (Dashboard).
2.  Icono Switches/Control (Automatización).
3.  Icono Gráfica (Historial).
4.  Icono Notificación/Cámara (Alertas).

---

### 3. S-02: DASHBOARD / MONITOREO (HOME)
**Propósito:** Visualización rápida del estado del cultivo activo.

* **AppBar:** Título del cultivo actual y **Action Icon** (engranaje) para ir a Ajustes (S-06).
* **Sección Métricas (Grid/Cards):**
    * Tarjetas visuales para Temperatura, Humedad, Luz y PH.
    * **Indicadores Visuales:** El color de la tarjeta o icono debe cambiar según el estado (Verde = Óptimo, Amarillo = Precaución, Rojo = Peligro).
* **Sección Resumen Actuadores:**
    * Indicadores pequeños (Chips o Iconos) que muestren si el Riego o la Luz están encendidos en ese momento.

---

### 4. S-03: CONTROL Y AUTOMATIZACIÓN
**Propósito:** Control manual de dispositivos y gestión de reglas lógicas.

* **Sección 1: Control Manual (Cabecera):**
    * Lista de `SwitchListTile` para activar/desactivar actuadores inmediatamente (Bomba de Agua, Luces LED, Ventilación).
* **Sección 2: Reglas Automáticas (Cuerpo):**
    * `ListView` mostrando las reglas activas (ej. "Si Humedad < 50% -> Riego ON 5 min").
    * Cada item debe permitir Editar o Eliminar (Swipe to dismiss).
* **Acción Flotante:**
    * `FloatingActionButton` (+) para abrir un Modal/Dialogo de creación de nueva regla.

---

### 5. S-04: HISTORIAL Y ANALÍTICAS
**Propósito:** Análisis de tendencias a lo largo del tiempo.

* **Filtros Superiores:**
    * Dropdown para seleccionar el Sensor (Temp, Humedad, Luz).
    * Selector de Rango de Fecha (Chips: "Hoy", "Semana", "Mes").
* **Área de Gráfica:**
    * Widget de gráfico de líneas (ej. usando `fl_chart`). Eje X = Tiempo, Eje Y = Valor.
* **Resumen Estadístico:**
    * Fila de datos mostrando Máximo, Mínimo y Promedio del periodo seleccionado.

---

### 6. S-05: ALERTAS Y DIAGNÓSTICO
**Propósito:** Centralizar notificaciones y la funcionalidad de Visión por Computadora.
**Widget Sugerido:** `TabBar` superior dentro de esta pantalla.

* **Pestaña 1: Notificaciones:**
    * `ListView` con tarjetas de alertas pasadas (ej. "Bomba falló - hace 2 horas").
    * Diferenciar urgencia por colores o iconos.
* **Pestaña 2: Diagnóstico IA (CU-09):** (No implementar en MockUp)
    * Botón grande "Tomar Foto" (Cámara) o "Subir Imagen" (Galería).
    * Contenedor para previsualizar la imagen seleccionada.
    * Botón "Analizar Planta".
    * **Resultado:** Tarjeta que aparece tras el análisis mostrando el diagnóstico (ej. "Deficiencia de Nitrógeno") y el % de confianza.

---

### 7. S-06: AJUSTES Y CONFIGURACIÓN (PANTALLA SECUNDARIA)
**Propósito:** Gestión administrativa. No está en el BottomNav, se accede desde el Dashboard.

* **Lista de Opciones (Settings UI):**
    * **Sección Cultivos:**
        * "Ver mis Perfiles de Cultivo" (Navega a lista CRUD).
        * "Añadir Nuevo Perfil".
        * "Asociar Dispositivos" (Vincular ID de hardware a perfil).
    * **Sección Catálogo:**
        * "Gestión de Plantillas de Plantas" (Ver/Crear presets de temperatura y humedad).
    * **Sección Cuenta:**
        * Cambiar Contraseña.
        * Cerrar Sesión (Logout).