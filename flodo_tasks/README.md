Flodo AI Task Management App

A fully functional, visually polished Task Management application built for the Flodo AI Take-Home Assignment. This repository contains both the Flutter frontend and the Python FastAPI backend.

🎯 Track & Stretch Goal Selection

Selected Track: Track A (The Full-Stack Builder)

Frontend: Flutter & Dart

Backend: Python (FastAPI) & SQLite

Why: To demonstrate end-to-end capabilities, full-stack architecture, and seamless API integration as required by the job role.

Selected Stretch Goal: Goal 1 (Debounced Autocomplete Search)

Implementation: The main task list features a search bar that waits 300ms after the user stops typing before triggering an API call to the backend. It also visually highlights the matching text within the task titles.

✨ Core Features Implemented

Complete CRUD: Create, Read, Update, and Delete tasks via the FastAPI backend.

Artificial Delay: A simulated 2-second delay on Task Creation and Updates. The UI implements a proper loading state and disables the "Save" button to prevent double submissions.

Draft Preservation: Uses SharedPreferences and WidgetsBindingObserver. If the user minimizes the app or swipes back while creating a task, their typed text is saved locally and restored upon return.

"Blocked By" UI Rule: Tasks blocked by incomplete tasks are visually distinct (lowered opacity with a red lock icon and warning text).

Search & Filter: Search tasks by title (debounced) and filter by Status (To-Do, In Progress, Done).

🚀 Setup & Installation Instructions

This project requires both the Python backend and the Flutter frontend to be running simultaneously.

1. Backend Setup (Python / FastAPI)

Ensure you have Python 3.9+ installed.

Open a terminal and navigate to the backend directory (or wherever you saved main.py).

Install the required dependencies:

pip install fastapi uvicorn sqlalchemy pydantic


Start the FastAPI server:

uvicorn main:app --reload


The backend will now be running at http://127.0.0.1:8000. You can view the automatic API documentation at http://127.0.0.1:8000/docs.

2. Frontend Setup (Flutter)

Ensure you have the Flutter SDK installed and configured.

Open a new terminal and navigate to the flodo_tasks directory.

Install the Flutter dependencies:

flutter pub get


Important Note on Emulators: * If you are running the app on an iOS Simulator, macOS, or Web, the API base URL is correctly set to http://127.0.0.1:8000/tasks/.

If you are running the app on an Android Emulator, you must ensure the baseUrl in lib/services/api_service.dart is using http://10.0.2.2:8000/tasks/ (the code dynamically handles this for you using Platform.isAndroid).

Run the app:

flutter run


🤖 AI Usage Report

In accordance with the assignment guidelines, here is a transparent report of my AI tool usage (Gemini) during development:

Helpful Prompts Used:

"I have this Flutter task app assignment. Based on the job description that requires Python, which Track should I choose and what is the best stretch goal to show production readiness?" (Helped finalize the architecture and track selection).

"Generate a Riverpod StateNotifier that handles an AsyncValue list of Tasks, integrates with my FastAPI service, and properly manages the 2-second loading state without freezing the UI."

"How can I detect if a Flutter app is minimized while a user is typing in a form so I can save it to SharedPreferences?" (Provided the WidgetsBindingObserver lifecycle implementation).

Hallucinations & Fixes:

The Issue: While generating the state management layer, I accidentally pasted the Riverpod TaskProvider code directly into the task_model.dart file. The AI's context window mixed up the data class and the provider, resulting in severe Undefined class 'Task' errors across the codebase.

The Fix: I prompted the AI to analyze the specific line errors in my IDE screenshot. It correctly identified the structural mix-up. I fixed it by isolating the Task JSON serialization class into its own lib/models/task_model.dart file, and moving the Riverpod logic strictly into lib/providers/task_provider.dart, immediately resolving all typing errors.

🎥 1-Minute Demo Video

Click here to view the 1-Minute Demo Video

(Note: The video demonstrates core CRUD, the Drafts lifecycle handling, the 2-second delay safeguard, and the Debounced search stretch goal).