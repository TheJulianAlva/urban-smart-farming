# Urban Smart Farming

Una aplicación móvil inteligente para gestión de cultivos urbanos, desarrollada con Flutter.

## 📋 Requisitos Previos

Antes de poder ejecutar y probar este proyecto, asegúrate de tener instalado lo siguiente:

### 1. Flutter SDK
- **Versión requerida**: Flutter SDK 3.7.2 o superior
- **Descarga**: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- **Verificación**: 
  ```bash
  flutter --version
  ```

### 2. Dart SDK
- **Versión requerida**: Dart 3.7.2 o superior (incluido con Flutter)
- **Verificación**:
  ```bash
  dart --version
  ```

### 3. Editor de Código
Elige uno de los siguientes:
- **Visual Studio Code** con las extensiones:
  - Flutter
  - Dart
- **Android Studio** con los plugins:
  - Flutter
  - Dart

### 4. Herramientas Específicas por Plataforma

#### Para Android:
- **Android Studio** o **Android SDK**
- **Java Development Kit (JDK)** 17 o superior
- **Emulador Android** o dispositivo físico con modo desarrollador activado
- **Verificación**:
  ```bash
  flutter doctor --android-licenses
  ```

### 5. Git
- **Descarga**: [https://git-scm.com/downloads](https://git-scm.com/downloads)
- **Verificación**:
  ```bash
  git --version
  ```

## 🚀 Configuración del Proyecto

### 1. Clonar el Repositorio
```bash
git clone https://github.com/TheJulianAlva/urban-smart-farming.git
cd urban-smart-farming
```

### 2. Verificar la Instalación de Flutter
```bash
flutter doctor
```
Asegúrate de que todos los componentes necesarios estén marcados con ✓. Resuelve cualquier problema indicado por el comando.

### 3. Instalar Dependencias
```bash
flutter pub get
```

Esto instalará todas las dependencias del proyecto listadas en `pubspec.yaml`, incluyendo:
- `flutter_bloc` (^8.1.3) - Gestión de estado
- `go_router` (^13.0.0) - Navegación
- `get_it` (^7.6.4) - Inyección de dependencias
- `dartz` (^0.10.1) - Programación funcional
- `equatable` (^2.0.5) - Comparación de objetos
- `fl_chart` (^0.68.0) - Gráficos
- `intl` (^0.19.0) - Internacionalización

## 🏃‍♂️ Ejecutar el Proyecto

### Opción 1: Usando VS Code
1. Abre el proyecto en VS Code
2. Presiona `F5` o usa el menú `Run > Start Debugging`
3. Selecciona el dispositivo de destino en la barra de estado

### Opción 2: Usando Android Studio
1. Abre el proyecto en Android Studio
2. Selecciona el dispositivo de destino en la barra superior
3. Haz clic en el botón ▶️ (Run)

## 📱 Dispositivos Recomendados para Pruebas

### Android:
- **Emulador**: Pixel 5 API 33 (Android 13) o superior
- **Resolución mínima**: 1080x2340

### iOS:
- **Simulador**: iPhone 14 o superior
- **iOS**: 14.0 o superior

## 🏗️ Estructura del Proyecto

El proyecto sigue los principios de Clean Architecture:

```
lib/
├── core/              # Utilidades compartidas
├── features/          # Funcionalidades por módulos
│   ├── auth/          # Autenticación
│   │   ├── data/      # Repositorios y fuentes de datos
│   │   ├── domain/    # Entidades y casos de uso
│   │   └── presentation/ # UI y gestión de estado
│   └── dashboard/     # Panel de control
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart          # Punto de entrada
```

## ⚠️ Solución de Problemas Comunes

### Error: "Flutter SDK not found"
```bash
# Asegúrate de que Flutter esté en el PATH
export PATH="$PATH:`pwd`/flutter/bin"  # Linux/macOS
# o configura el PATH en Windows
```

### Error: "Gradle build failed" (Android)
```bash
# Limpia el build
flutter clean
flutter pub get
```

### Error: "CocoaPods not installed" (iOS)
```bash
sudo gem install cocoapods
cd ios
pod install
```

### Problemas de rendimiento en desarrollo
```bash
# Ejecutar en modo release (más rápido)
flutter run --release
```

## 📄 Licencia

Este proyecto está bajo la licencia especificada en el archivo LICENSE.

## 🤝 Contribuir

Si deseas contribuir al proyecto:
1. Haz un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📧 Contacto

Para preguntas o soporte, contacta con el equipo de desarrollo.
