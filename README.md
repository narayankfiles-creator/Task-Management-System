# Flodo AI - Task Management System

A modern, full-stack task management application built with **Flutter** and **Python Flask**, featuring an intelligent task management experience across all platforms.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- **Cross-Platform Support**: Deploy on iOS, Android, Windows, macOS, Linux, and Web
- **Task Management**: Create, edit, and manage tasks with ease
- **Draft Support**: Save tasks as drafts before publishing
- **State Management**: Efficient state management using Provider pattern
- **RESTful API**: Robust Python Flask backend with SQLite database
- **Real-time Sync**: Seamless synchronization between frontend and backend
- **Responsive UI**: Beautiful, intuitive user interface with Material Design

## 🛠️ Tech Stack

### Frontend
- **Flutter** - UI framework for cross-platform development
- **Dart** - Programming language
- **Provider** - State management solution
- **HTTP** - Network requests

### Backend
- **Python 3.10+** - Server-side programming
- **Flask** - Web framework
- **SQLite** - Database

### Platforms
- ✅ iOS (via Xcode)
- ✅ Android (via Gradle)
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

## 📁 Project Structure

```
Flodo AI/
├── Backend/
│   ├── main.py                 # Flask API server
│   └── tasks.db               # SQLite database
│
└── flodo_tasks/               # Flutter application
    ├── lib/
    │   ├── main.dart          # App entry point
    │   ├── models/
    │   │   └── task_model.dart
    │   ├── providers/
    │   │   └── task_provider.dart
    │   ├── screens/
    │   │   ├── task_list_screen.dart
    │   │   └── create_task_screen.dart
    │   └── services/
    │       ├── api_service.dart
    │       └── draft_service.dart
    ├── android/               # Android configuration
    ├── ios/                   # iOS configuration
    ├── windows/               # Windows configuration
    ├── macos/                 # macOS configuration
    ├── linux/                 # Linux configuration
    ├── web/                   # Web configuration
    ├── pubspec.yaml           # Flutter dependencies
    └── test/                  # Unit tests
```

## 🚀 Quick Start

### Prerequisites
- Flutter 3.0+ ([Download](https://flutter.dev/docs/get-started/install))
- Python 3.10+ ([Download](https://www.python.org/downloads/))
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/narayankfiles-creator/Task-Management-System.git
   cd Flodo\ AI
   ```

2. **Setup Backend**
   ```bash
   cd Backend
   python -m venv venv
   
   # Activate virtual environment
   # On Windows:
   venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   
   # Install dependencies (if requirements.txt exists)
   # pip install -r requirements.txt
   
   # Run Flask server
   python main.py
   ```
   The API server will run on `http://localhost:5000`

3. **Setup Flutter App**
   ```bash
   cd flodo_tasks
   flutter pub get
   ```

4. **Run the Application**
   
   **For Development:**
   ```bash
   flutter run
   ```
   
   **For Android:**
   ```bash
   flutter run -d android
   ```
   
   **For iOS:**
   ```bash
   flutter run -d ios
   ```
   
   **For Web:**
   ```bash
   flutter run -d chrome
   ```
   
   **For Desktop (Windows/macOS/Linux):**
   ```bash
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

## 📱 Usage

### Creating a Task
1. Tap the "Create Task" button
2. Fill in task details
3. Choose to save as draft or publish immediately
4. Task syncs with backend API

### Managing Tasks
- View all tasks in the task list
- Edit existing tasks
- Delete completed tasks
- Toggle task completion status

## 🔌 API Endpoints

The Backend Flask API provides the following endpoints:

```
GET    /api/tasks              # Get all tasks
POST   /api/tasks              # Create new task
GET    /api/tasks/<id>         # Get task by ID
PUT    /api/tasks/<id>         # Update task
DELETE /api/tasks/<id>         # Delete task
GET    /api/drafts             # Get draft tasks
```

### Task Model
```dart
class Task {
  int? id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt;
}
```

## 🔧 Development

### Architecture
- **Clean Architecture**: Separation of concerns with models, services, and providers
- **State Management**: Provider pattern for efficient state handling
- **API Integration**: RESTful API calls via `api_service.dart`
- **Local Storage**: Draft tasks via `draft_service.dart`

### Building

**Android APK:**
```bash
flutter build apk --release
```

**iOS IPA:**
```bash
flutter build ios --release
```

**Web Build:**
```bash
flutter build web --release
```

**Desktop:**
```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## 🧪 Testing

Run unit tests:
```bash
flutter test
```

## 📝 Git Workflow

This project follows conventional commits:
- `chore:` - Setup and configuration
- `feat:` - New features
- `build:` - Build system changes
- `test:` - Testing additions

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Narayan Kshirsagar**
- GitHub: [@narayankfiles-creator](https://github.com/narayankfiles-creator)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community contributions and feedback
- All contributors who helped with this project

## 📞 Support

For support, email support@flodo.ai or open an issue on GitHub.

---

**Happy Task Managing! 🎉**

**Last Updated:** March 27, 2026
