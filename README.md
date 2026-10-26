WashWait MVP 🧺

WashWait is a Minimum Viable Product (MVP) built to solve a common hostel problem: walking down to the laundry room only to find all washing machines occupied.

This Flutter application demonstrates a real-time, global queueing system that tracks machine availability, manages a virtual waitlist, and handles time-based state transitions.

🚀 Features

Live Machine Status: Visually distinguishes between available (green) and in-use (red) machines.

Global Virtual Queue: Implements a First-In-First-Out (FIFO) global waitlist rather than machine-specific queues, optimizing machine utilization.

Automated Cycle Timers: Tracks active wash cycles and automatically frees up machines when the timer expires.

State Management: Utilizes Flutter's local state Timer and setState for immediate UI rendering and prototype demonstration.

🛠️ Tech Stack

Frontend: Flutter & Dart

Architecture Concept: Designed to support a future transition to a WebSockets/Firebase Firestore backend for distributed real-time synchronization.

⚙️ How to Run Locally

Ensure you have the Flutter SDK installed.

Clone this repository:

git clone https://github.com/YOUR_USERNAME/washwait.git


Navigate to the project directory:

cd washwait


Fetch dependencies:

flutter pub get


Run the app on an emulator or connected device:

flutter run


Note: For demonstration purposes, the active wash cycle timer in this MVP is hardcoded to 2 minutes instead of 45 minutes.

🧠 System Design Choices (Track B Notes)

If discussing this project in a system design context:

Why a Global Queue? Hardcoding a student to a specific machine's queue creates bottlenecks if a machine finishes but isn't emptied. A global queue assigns the person at the front of the line to the very next available machine.

Scaling to Production: To deploy this campus-wide, the local List<Machine> state would be replaced with a NoSQL database (like Firestore) or a backend (FastAPI + PostgreSQL) using WebSockets to push status alerts to students' phones without draining battery via REST polling.
