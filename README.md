# 🌱 Urban Smart Farming

> Intelligent Urban Agriculture Platform integrating IoT, Automation, Data Analytics, and Computer Vision to optimize crop growth in real-time.

![Python](https://img.shields.io/badge/Python-3.13-blue?style=for-the-badge&logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase)
![Architecture](https://img.shields.io/badge/Architecture-Modular-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-In%20Development-orange?style=for-the-badge)

## About

**Urban Smart Farming** is a smart agriculture management system designed for urban farmers who want to monitor, control, and automate their crops using technology. The objective is to optimize plant growth, reduce resource waste, and enable data-driven decision-making.

### Key Features

* **Environmental Monitoring:** Real-time tracking of humidity, temperature, and light levels.
* **Automation Engine:** Rule-based system for IoT actuation.
* **Computer Vision:** Plant health analysis through image processing.
* **Analytics Dashboard:** Visualization of historical data and crop performance insights.
* **Intelligent Notifications:** Alert system for critical environmental changes.

---

## 🏛️ System Architecture

The system is organized into modular components following a **Client-Server Architecture** to ensure scalability and maintainability.

### Main Components
1.  **Backend (API):** Built with Python, FastAPI, and Supabase. Handles business logic, database operations, sensor data ingestion, and automation rules.
2.  **Frontend (Web/Mobile App):** User interface for monitoring conditions, controlling devices, and configuring profiles.
3.  **Database & Auth:** Supabase provides PostgreSQL for data storage, real-time subscriptions, and authentication.

### System Actors
* 👤 **User (Primary):** Configures profiles, monitors conditions, and controls devices.
* 📡 **Sensors/Actuators (Secondary):** Hardware devices providing data and executing commands.
* 🔔 **Notification System (Secondary):** Services for delivering alerts.

---

## 🛠️ Tech Stack

* **Backend:** Python 3.13+, FastAPI
* **Database & Auth:** Supabase (PostgreSQL)
* **IoT Communication:** Integration for sensor and actuator data processing.
* **Computer Vision:** Specialized module for image-based plant health assessment.

---

## 📂 Project Structure

```text
urban-smart-farming/
├── backend/            # Python/FastAPI Backend Services
├── frontend/           # User Interface Application
├── docs/               # Documentation and guidelines
└── README.md
```

## Installation & Setup

For detailed installation instructions, please refer to the specific documentation inside each module:

* **[Backend Configuration & Setup](./backend/README.md)**: Instructions on setting up the Python virtual environment, FastAPI server, and installing dependencies.
* **Frontend Configuration & Setup**: *(Check the `./frontend` directory for frontend setup instructions)*.

---

## Future Improvements

* **Mobile Application**: Cross-platform app for on-the-go monitoring.
* **Cloud Deployment**: Expanding from local/Supabase to a full cloud infrastructure setup.
* **AI Analysis**: Predictive crop health analysis using Machine Learning.

