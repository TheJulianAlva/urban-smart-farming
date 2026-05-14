# Tipos de Pruebas de Software — Investigación General

---

## Índice

1. [Pruebas Unitarias](#1-pruebas-unitarias)
2. [Pruebas de Integración](#2-pruebas-de-integración)
3. [Prueba de Regresión](#3-prueba-de-regresión)
4. [Prueba de Humo (Smoke Testing)](#4-prueba-de-humo-smoke-testing)
5. [Prueba de Sistema Completo](#5-prueba-de-sistema-completo)
6. [Prueba de Desempeño](#6-prueba-de-desempeño)
7. [Prueba de Carga](#7-prueba-de-carga)
8. [Pruebas de Estrés](#8-pruebas-de-estrés)
9. [Pruebas de Volumen](#9-pruebas-de-volumen)
10. [Pruebas de Recuperación y Tolerancia a Fallas](#10-pruebas-de-recuperación-y-tolerancia-a-fallas)
11. [Pruebas de GUI](#11-pruebas-de-gui)
12. [Pruebas de Configuración](#12-pruebas-de-configuración)
13. [Pruebas de Estilo](#13-pruebas-de-estilo)
14. [Pruebas de Instalación](#14-pruebas-de-instalación)
15. [Pruebas de Aceptación](#15-pruebas-de-aceptación)
16. [Pruebas de Documentación y Procedimiento](#16-pruebas-de-documentación-y-procedimiento)
17. [Prueba de Usabilidad](#17-prueba-de-usabilidad)
18. [Prueba de Campo](#18-prueba-de-campo)
19. [Prueba Alfa](#19-prueba-alfa)
20. [Prueba Beta](#20-prueba-beta)
- [Conclusión](#conclusión)
- [Fuentes](#fuentes)

---

## 1. Pruebas Unitarias

Las pruebas unitarias verifican el comportamiento correcto de la unidad más pequeña de código comprobable de forma aislada: generalmente una función, método o clase.

**Objetivo:** detectar defectos en la lógica interna de cada componente antes de integrarlo con el resto del sistema.

**Características principales:**
* Se ejecutan de forma automatizada y repetida durante el ciclo de desarrollo (integración continua).
* El código de prueba es independiente de dependencias externas; se usan dobles de prueba (mocks, stubs) cuando es necesario.
* Siguen el patrón AAA: *Arrange* (preparar), *Act* (ejecutar), *Assert* (verificar).
* Son la base de la pirámide de pruebas propuesta por Mike Cohn, por ser las más rápidas y económicas de ejecutar.

**Herramientas comunes:** JUnit (Java), pytest (Python), Jest (JavaScript), Flutter Test (Dart).

---

## 2. Pruebas de Integración

Las pruebas de integración evalúan la interacción entre dos o más módulos o componentes que han sido verificados individualmente, comprobando que se comunican y colaboran correctamente.

**Objetivo:** detectar errores en las interfaces entre componentes: contratos de API incorrectos, incompatibilidades de datos o fallos de comunicación.

**Características principales:**
* Pueden aplicarse de forma incremental (enfoque *big-bang*, *top-down* o *bottom-up*).
* Requieren un entorno más cercano al de producción que las pruebas unitarias.
* Cubren capas como base de datos, servicios REST, colas de mensajes y sistemas externos.
* Su costo de mantenimiento es mayor que el de las pruebas unitarias debido a las dependencias involucradas.

**Herramientas comunes:** Postman/Newman, REST Assured, Spring Boot Test, Supertest.

---

## 3. Prueba de Regresión

Las pruebas de regresión verifican que los cambios recientes en el código (correcciones, nuevas funcionalidades, refactorizaciones) no hayan introducido defectos en las partes del sistema que ya funcionaban correctamente.

**Objetivo:** garantizar la estabilidad del software existente ante modificaciones continuas.

**Características principales:**
* Se ejecutan después de cada cambio significativo o entrega.
* Idealmente automatizadas para reducir el tiempo de retroalimentación.
* El conjunto de pruebas de regresión crece con el tiempo; se requiere priorización y selección estratégica.
* Son críticas en entornos ágiles con entregas frecuentes.

**Herramientas comunes:** Selenium, Cypress, TestNG, cualquier framework de automatización con suite acumulativa.

---

## 4. Prueba de Humo (Smoke Testing)

La prueba de humo es un conjunto mínimo de casos de prueba que verifican las funcionalidades más críticas del sistema, ejecutadas como primera validación después de un nuevo build o despliegue.

**Objetivo:** determinar rápidamente si el build es lo suficientemente estable para ser sometido a pruebas más exhaustivas.

**Características principales:**
* No es exhaustiva; cubre el "camino feliz" de las funciones principales.
* Su duración es breve (minutos), por lo que se integra fácilmente en pipelines de CI/CD.
* Un fallo en las pruebas de humo detiene el pipeline e impide pruebas posteriores, ahorrando recursos.
* Recibe su nombre de la práctica en hardware de encender un circuito por primera vez para verificar que no produce humo.

**Herramientas comunes:** scripts de automatización integrados en Jenkins, GitHub Actions, GitLab CI.

---

## 5. Prueba de Sistema Completo

Las pruebas de sistema evalúan el software integrado en su totalidad, verificando que cumple los requisitos funcionales y no funcionales especificados.

**Objetivo:** validar el comportamiento del sistema como un producto terminado antes de su entrega al cliente o usuarios finales.

**Características principales:**
* Se realizan en un entorno que simula fielmente el de producción.
* Cubren todos los requisitos del sistema: funcionales, de rendimiento, de seguridad y de interfaz.
* Corresponden al nivel más alto de prueba antes de la aceptación formal.
* Son ejecutadas habitualmente por un equipo de QA independiente del equipo de desarrollo.

**Referencia estándar:** IEEE 829 — *Standard for Software Test Documentation* define la documentación necesaria para este nivel.

---

## 6. Prueba de Desempeño

Las pruebas de desempeño miden la velocidad, la capacidad de respuesta, la estabilidad y el uso de recursos del sistema bajo condiciones determinadas de carga.

**Objetivo:** identificar cuellos de botella y garantizar que el sistema cumple los requisitos de rendimiento definidos (tiempo de respuesta, throughput, uso de CPU/memoria).

**Características principales:**
* Se planifican a partir de métricas concretas: p. ej., "el 95 % de las solicitudes deben resolverse en menos de 2 segundos bajo 500 usuarios concurrentes".
* Incluyen monitoreo detallado de recursos del servidor durante la ejecución.
* Son la categoría padre de las pruebas de carga, estrés y volumen.
* Los resultados se comparan contra líneas base (*baselines*) establecidas.

**Herramientas comunes:** Apache JMeter, Gatling, k6, Locust.

---

## 7. Prueba de Carga

Las pruebas de carga simulan el número esperado de usuarios o transacciones simultáneas para verificar que el sistema mantiene su rendimiento dentro de los límites aceptables.

**Objetivo:** confirmar que el sistema soporta el volumen de trabajo previsto en condiciones normales y pico de uso.

**Características principales:**
* Define un nivel de carga objetivo (usuarios concurrentes, solicitudes por segundo) basado en proyecciones reales.
* Mide tiempos de respuesta, tasas de error y uso de recursos conforme la carga aumenta gradualmente.
* Permite identificar el punto de saturación del sistema antes del despliegue en producción.
* Se distingue de la prueba de estrés en que no supera los límites esperados del sistema.

**Herramientas comunes:** Apache JMeter, k6, Locust, Artillery.

---

## 8. Pruebas de Estrés

Las pruebas de estrés llevan el sistema más allá de sus límites operativos normales para observar su comportamiento bajo condiciones extremas y determinar su punto de quiebre.

**Objetivo:** conocer cómo falla el sistema (de forma controlada o catastrófica) cuando se superan sus recursos o capacidad máxima, y verificar su capacidad de recuperación.

**Características principales:**
* La carga se incrementa progresivamente hasta que el sistema falla o degrada su rendimiento de forma significativa.
* Permiten identificar fugas de memoria, deadlocks y condiciones de carrera que solo aparecen bajo presión extrema.
* Evalúan si el sistema falla de manera segura (*graceful degradation*).
* Son especialmente importantes en sistemas de misión crítica o de alta disponibilidad.

**Herramientas comunes:** Apache JMeter, Gatling, Chaos Monkey (Netflix), k6.

---

## 9. Pruebas de Volumen

Las pruebas de volumen evalúan el comportamiento del sistema cuando procesa grandes cantidades de datos, verificando que no se degradan el rendimiento ni la integridad de la información.

**Objetivo:** determinar si el sistema maneja correctamente volúmenes masivos de datos almacenados o procesados, sin errores de truncamiento, pérdida de registros o degradación excesiva.

**Características principales:**
* Se enfocan en la cantidad de datos (registros en base de datos, tamaño de archivos), no necesariamente en usuarios concurrentes.
* Revelan problemas de paginación, índices ineficientes, límites de campos de datos y desbordamientos.
* Son críticas en sistemas con bases de datos de gran escala o procesamiento batch.
* Complementan las pruebas de carga desde la perspectiva de los datos.

**Herramientas comunes:** scripts de generación de datos (Faker, Datafaker), JMeter con JDBC.

---

## 10. Pruebas de Recuperación y Tolerancia a Fallas

Estas pruebas verifican la capacidad del sistema para recuperarse correctamente ante fallos de hardware, software, red u otros eventos inesperados.

**Objetivo:** garantizar que el sistema puede restaurar su funcionamiento normal en un tiempo aceptable (*Recovery Time Objective*, RTO) y sin pérdida de datos más allá de lo permitido (*Recovery Point Objective*, RPO).

**Características principales:**
* Simulan condiciones de fallo reales: cortes de energía, pérdida de conexión de red, caídas de base de datos, fallos de disco.
* Verifican mecanismos de failover, replicación, backups y reinicio automático.
* Son obligatorias en sistemas con requisitos de alta disponibilidad (SLAs de 99.9 % o superior).
* Se relacionan con las pruebas de resiliencia (*chaos engineering*).

**Herramientas comunes:** Chaos Monkey, Gremlin, scripts de simulación de fallo personalizados.

---

## 11. Pruebas de GUI

Las pruebas de interfaz gráfica de usuario (GUI) verifican que los elementos visuales del sistema funcionan correctamente y presentan la información de la forma esperada.

**Objetivo:** asegurar que los controles, formularios, navegación, mensajes y flujos de la interfaz se comportan conforme a las especificaciones de diseño.

**Características principales:**
* Incluyen verificación de elementos: botones, menús, campos de texto, tablas, modales y notificaciones.
* Pueden ejecutarse de forma manual o automatizada mediante herramientas de automatización de UI.
* Son sensibles a cambios de diseño, por lo que requieren mantenimiento frecuente en entornos ágiles.
* Se complementan con pruebas de usabilidad para garantizar tanto funcionalidad como experiencia de usuario.

**Herramientas comunes:** Selenium WebDriver, Cypress, Playwright, Appium (móvil), Flutter Driver.

---

## 12. Pruebas de Configuración

Las pruebas de configuración verifican que el sistema funciona correctamente bajo distintas combinaciones de hardware, software, sistemas operativos, navegadores o ajustes de configuración.

**Objetivo:** garantizar la compatibilidad del sistema con los diferentes entornos en los que será desplegado o utilizado.

**Características principales:**
* Cubren variaciones como versiones de sistema operativo, resoluciones de pantalla, navegadores web, bases de datos y configuraciones de red.
* Son especialmente relevantes en software multiplataforma o de distribución amplia.
* Se organizan mediante matrices de compatibilidad que definen las combinaciones prioritarias a probar.
* Pueden ejecutarse en paralelo mediante virtualización o plataformas de prueba en la nube.

**Herramientas comunes:** BrowserStack, Sauce Labs, AWS Device Farm, Docker para entornos aislados.

---

## 13. Pruebas de Estilo

Las pruebas de estilo, también conocidas como pruebas de conformidad de código (*linting* o *static analysis*), verifican que el código fuente cumple los estándares de codificación, guías de estilo y convenciones definidas por el equipo o la organización.

**Objetivo:** mantener la coherencia, legibilidad y mantenibilidad del código, reduciendo la deuda técnica.

**Características principales:**
* No ejecutan el programa; analizan el código fuente de forma estática.
* Detectan problemas como variables no utilizadas, convenciones de nomenclatura incorrectas, complejidad ciclomática excesiva y posibles errores lógicos.
* Se integran en el pipeline de CI para bloquear merges que no cumplan los estándares.
* Complementan las revisiones de código (code review) humanas.

**Herramientas comunes:** ESLint (JavaScript), Pylint/Flake8 (Python), Dart Analyzer (Flutter), SonarQube.

---

## 14. Pruebas de Instalación

Las pruebas de instalación verifican que el proceso de instalación, actualización y desinstalación del software se realiza correctamente en los entornos objetivo.

**Objetivo:** garantizar que el usuario o administrador puede instalar el producto sin errores y que el sistema queda en un estado funcional tras el proceso.

**Características principales:**
* Cubren escenarios de instalación limpia, actualización desde versiones anteriores y desinstalación completa.
* Verifican que los archivos, dependencias, permisos y configuraciones se establecen correctamente.
* Son especialmente importantes en software distribuido como aplicaciones de escritorio, móviles o microservicios con despliegue automatizado.
* En el contexto moderno incluyen también la validación de contenedores Docker, scripts de IaC (Terraform, Ansible) y pipelines de despliegue.

**Herramientas comunes:** Inno Setup (Windows), scripts de CI/CD, Docker Compose, Helm (Kubernetes).

---

## 15. Pruebas de Aceptación

Las pruebas de aceptación validan que el sistema cumple los criterios de aceptación definidos por el cliente o usuario, determinando si está listo para ser entregado o puesto en producción.

**Objetivo:** obtener la aprobación formal del cliente o usuario final de que el sistema satisface sus necesidades y requisitos de negocio.

**Características principales:**
* Existen dos variantes principales: Pruebas de Aceptación del Usuario (UAT) y Pruebas de Aceptación Operacional (OAT).
* Se basan directamente en los criterios de aceptación definidos en las historias de usuario o especificaciones de requisitos.
* Las ejecuta el cliente, el usuario final o un representante designado, no el equipo de desarrollo.
* En metodologías ágiles se expresan mediante el enfoque BDD (*Behavior-Driven Development*) con herramientas como Cucumber o SpecFlow.

**Referencia estándar:** ISO/IEC/IEEE 29119 — *Software and Systems Engineering — Software Testing*.

---

## 16. Pruebas de Documentación y Procedimiento

Las pruebas de documentación verifican que la documentación del sistema (manuales de usuario, guías de instalación, procedimientos operativos) es correcta, completa y coherente con el comportamiento real del software.

**Objetivo:** garantizar que los usuarios y administradores pueden operar el sistema correctamente siguiendo la documentación provista.

**Características principales:**
* Incluyen la ejecución literal de los pasos descritos en manuales y guías para verificar su exactitud.
* Detectan discrepancias entre el comportamiento documentado y el real del sistema.
* Son especialmente críticas en sistemas regulados (médicos, financieros, aeronáuticos) donde la documentación tiene valor legal.
* Se actualizan junto con el software para evitar documentación obsoleta.

**Estándar de referencia:** IEEE 1063 — *Standard for Software User Documentation*.

---

## 17. Prueba de Usabilidad

Las pruebas de usabilidad evalúan la facilidad con que los usuarios reales pueden aprender a usar el sistema, completar sus tareas y obtener satisfacción en la experiencia de uso.

**Objetivo:** identificar problemas de diseño de interacción que dificultan el uso eficiente e intuitivo del sistema.

**Características principales:**
* Se realizan con usuarios representativos del público objetivo bajo condiciones controladas o en entorno real.
* Miden métricas como tasa de éxito en tareas, tiempo de compleción, número de errores y satisfacción subjetiva (escala SUS, NPS).
* Los resultados se traducen en mejoras de diseño de interfaz y flujos de navegación.
* Son fundamentales en el diseño centrado en el usuario (UCD) y en metodologías como Design Thinking.

**Estándar de referencia:** ISO 9241-11:2018 — *Ergonomics of Human-System Interaction — Usability: Definitions and Concepts*.

---

## 18. Prueba de Campo

Las pruebas de campo se realizan en el entorno real de operación del usuario final, con datos y condiciones auténticas, una vez que el sistema ha superado las pruebas en entornos controlados.

**Objetivo:** descubrir defectos que solo se manifiestan bajo condiciones reales de uso: variaciones ambientales, datos no anticipados, integración con sistemas legacy o comportamiento humano impredecible.

**Características principales:**
* Se llevan a cabo con usuarios reales en su lugar de trabajo habitual.
* Permiten detectar problemas de compatibilidad, rendimiento y usabilidad no reproducibles en laboratorio.
* Los resultados se recopilan mediante observación directa, registros de uso (logs) y encuestas.
* Son previas o complementarias a la entrega definitiva del sistema.

---

## 19. Prueba Alfa

La prueba alfa es una forma de prueba de aceptación realizada internamente por el equipo de desarrollo o por un grupo seleccionado de usuarios internos, antes de que el producto sea distribuido externamente.

**Objetivo:** identificar los defectos restantes y recopilar retroalimentación sobre el comportamiento general del sistema en condiciones cercanas a las reales, con el respaldo del equipo técnico disponible.

**Características principales:**
* Se ejecuta en el sitio del desarrollador, generalmente con usuarios internos o clientes de confianza.
* El equipo de desarrollo observa el uso y registra los problemas encontrados.
* Precede siempre a la prueba beta; constituye la última etapa de validación interna.
* Es especialmente común en productos de software de consumo masivo (videojuegos, aplicaciones móviles, sistemas operativos).

---

## 20. Prueba Beta

La prueba beta es la distribución del producto a un conjunto limitado de usuarios externos reales para que lo utilicen en sus propios entornos antes del lanzamiento oficial.

**Objetivo:** obtener retroalimentación auténtica de usuarios reales bajo una variedad de condiciones y entornos que el equipo de desarrollo no puede reproducir internamente.

**Características principales:**
* Los usuarios beta usan el producto en condiciones reales sin supervisión directa del desarrollador.
* Los defectos se reportan a través de canales establecidos (formularios, herramientas de reporte de bugs).
* Puede ser abierta (cualquier usuario puede registrarse) o cerrada (grupo seleccionado por invitación).
* La retroalimentación obtenida informa las correcciones finales antes del lanzamiento general (*General Availability*, GA).

---

## Conclusión

Las 20 categorías de prueba descritas en este documento no son excluyentes entre sí; por el contrario, conforman un ecosistema complementario que cubre el ciclo de vida del software desde su unidad más pequeña hasta su comportamiento en manos de usuarios reales. Las pruebas unitarias y de integración establecen la base de confianza en el código; las pruebas de rendimiento (carga, estrés, volumen) garantizan la resiliencia bajo condiciones adversas; las pruebas de GUI, usabilidad y campo aseguran la experiencia del usuario final; y las pruebas alfa y beta cierran el ciclo con validación en el mundo real.

Una estrategia de calidad madura no selecciona un único tipo de prueba, sino que combina los niveles adecuados según el riesgo, el presupuesto y el contexto del proyecto. La automatización progresiva —comenzando por las pruebas unitarias y extendiendo hacia las de integración y regresión— es la práctica que mejor equilibra velocidad de entrega y calidad del producto en entornos de desarrollo ágil. En proyectos como Urban Smart Farming, donde convergen hardware IoT, servicios en la nube y aplicaciones móviles, la cobertura de pruebas de integración, campo y sistema completo resulta especialmente crítica para garantizar la fiabilidad del sistema en entornos reales de cultivo.

---

## Fuentes

Las siguientes referencias son documentos estándar, libros académicos reconocidos y recursos técnicos verificables:

**Estándares internacionales**
* IEEE Std 829-2008. *IEEE Standard for Software and System Test Documentation*. IEEE. https://standards.ieee.org/ieee/829/3787/
* ISO/IEC/IEEE 29119-1:2022. *Software and Systems Engineering — Software Testing — Part 1: General Concepts*. ISO. https://www.iso.org/standard/81291.html
* ISO 9241-11:2018. *Ergonomics of Human-System Interaction — Part 11: Usability: Definitions and Concepts*. ISO. https://www.iso.org/standard/63500.html
* IEEE Std 1063-2001. *IEEE Standard for Software User Documentation*. IEEE. https://standards.ieee.org/ieee/1063/1638/

**Recursos técnicos**
* ISTQB. (2023). *Certified Tester Foundation Level Syllabus v4.0*. International Software Testing Qualifications Board. https://www.istqb.org/certifications/certified-tester-foundation-level
* ISTQB Glossary of Testing Terms. https://glossary.istqb.org/
* Ministry of Testing. *Types of Software Testing*. https://www.ministryoftesting.com/
* Google Testing Blog. https://testing.googleblog.com/
* Martin Fowler. *TestPyramid* (artículo técnico). https://martinfowler.com/bliki/TestPyramid.html
* Martin Fowler. *BlueGreenDeployment / SmokeTest* (artículo técnico). https://martinfowler.com/bliki/SmokeTest.html
