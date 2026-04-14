# 🌱 Urban Smart Farming

> Intelligent Urban Agriculture Platform integrating IoT, Automation, Data Analytics, and Computer Vision to optimize crop growth in real-time.

![Java](https://img.shields.io/badge/Java-17%2B-ED8B00?style=for-the-badge&logo=openjdk)
![SQL](https://img.shields.io/badge/SQL-Relational-003B57?style=for-the-badge&logo=postgresql)
![Architecture](https://img.shields.io/badge/Architecture-Layered%20%26%20Modular-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-In%20Development-orange?style=for-the-badge)

## 📖 About the Project

**Urban Smart Farming** is a smart agriculture management system designed for urban farmers who want to monitor, control, and automate their crops using technology. The objective is to optimize plant growth, reduce resource waste, and enable data-driven decision-making.

### ✨ Key Features

* 🌡 **Environmental Monitoring:** Real-time tracking of humidity, temperature, and light levels.
* 🤖 **Automation Engine:** Rule-based system (e.g., *IF Humidity < 30% THEN Activate Irrigation*).
* 📷 **Computer Vision:** Plant health analysis through image processing.
* 📊 **Analytics Dashboard:** Visualization of historical data and crop performance insights.
* 🔔 **Intelligent Notifications:** Alert system for critical environmental changes.

---

## 🏛️ System Architecture

The system is organized into modular components following **SOLID** principles and a **Layered Architecture** to ensure scalability and maintainability.

### Main Modules
1.  **Access & Profile Management:** Handles user security, registration, and plant catalog management.
2.  **Monitoring & Notifications:** Processes sensor data in real-time and manages alert generation.
3.  **Control & Automation:** Evaluates rules and manages manual or automatic actuator commands.
4.  **Analytics:** Provides trend visualization and image analysis using computer vision.

### System Actors
* 👤 **User (Primary):** Configures profiles, monitors conditions, and controls devices.
* 📡 **Sensors/Actuators (Secondary):** Hardware devices providing data and executing commands.
* 🔔 **Notification System (Secondary):** External services for delivering email or push alerts.

---

## 🛠️ Tech Stack

* **Backend:** Java 17+ (Spring Boot recommended).
* **Database:** SQL (MySQL 8+ / PostgreSQL 14+).
* **IoT Communication:** Integration for sensor and actuator data processing.
* **Computer Vision:** Specialized module for image-based plant health assessment.
* **Build Tool:** Maven 3.8+.

---

## 📂 Project Structure

```text
urban-smart-farming/
├── src/
│   ├── controllers/    # API Endpoints / UI Logic
│   ├── services/       # Business Logic & Rules
│   ├── models/         # Data Entities
│   ├── repositories/   # Data Access Layer (SQL)
│   ├── automation/     # Rule Evaluation Engine
│   └── config/         # System Configuration
├── database/           # schema.sql and migrations
├── docs/               # Use cases and diagrams
├── assets/             # Images and static resources
└── README.md
```

## 🚀 Installation & Setup

### 1. Prerequisites
* **Java JDK:** Version 17 or higher.
* **Database:** MySQL 8+ or PostgreSQL 14+.
* **Maven:** Version 3.8+.

### 2. Configuration
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/TheJulianAlva/urban-smart-farming.git
    cd urban-smart-farming
    ```
2.  **Database Setup:**
    * Create a database: `CREATE DATABASE urban_smart_farming;`
    * Run `database/schema.sql` to set up tables.
3.  **Update Credentials:**
    Modify `src/main/resources/application.properties` with your database info:
    ```properties
    spring.datasource.url=jdbc:mysql://localhost:3306/urban_smart_farming
    spring.datasource.username=root
    spring.datasource.password=yourpassword
    ```

### 3. Execution
```bash
mvn clean install
mvn spring-boot:run
📈 Future Improvements
🌎 Mobile Application: Cross-platform app for on-the-go monitoring.

☁️ Cloud Deployment: Migration to AWS or Azure for global accessibility.

🧠 AI Analysis: Predictive crop health analysis using Machine Learning.

📡 MQTT Integration: Optimized protocol for IoT device communication.


👩‍💻 Authors
Urban Smart Farming – Software Engineering Project
*   **[TheJulianAlva](https://github.com/TheJulianAlva)** - *Julián Alva*
*   **[Ximenakdsk](https://github.com/Ximenakdsk)** - *Ximena Hernández*
