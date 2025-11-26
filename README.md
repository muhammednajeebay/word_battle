# 🎮 Realtime Word-Battle Arena

A fast, realtime multiplayer **drawing & word-guessing game** built with **Flutter + Firebase** — engineered with clean architecture, realtime state sync, server-validated gameplay, and fully deployable on **Web + Mobile**.

This repo is structured as a **portfolio-grade production project**, with full docs, testing, CI/CD, and a system blueprint.

---

## 🚀 Features

* ⚡ Realtime multiplayer (Firestore listeners)
* ✏ Drawing + word guessing gameplay
* 🔐 Server-validated guesses (Cloud Functions)
* 👥 Matchmaking lobby
* 🏆 Global leaderboard
* 🎨 Rive/Lottie animations
* 📈 Analytics + Crashlytics
* 🌐 Deployable to GitHub Pages or Firebase Hosting

---

## 🏛 Architecture Overview

```
presentation/  → Flutter UI + BLoC
   domain/     → Pure Dart game engine (rules, scoring, entities)
   data/       → Firebase repo implementations (Firestore, Functions)
   core/       → Shared widgets, utils, error handling
```

Key principles:

* **Clean Architecture** (Domain-Driven)
* **Repository Pattern**
* **BLoC State Management**
* **DI using GetIt**
* **Firebase as backend, not tied to UI**

---

## 🔨 Tech Stack

### Frontend

* Flutter (Web/Mobile)
* flutter_bloc
* get_it
* equatable
* rive / lottie
* shared_preferences

### Backend (Firebase)

* Firestore (game state)
* Firebase Auth (players)
* Cloud Functions (server logic)
* Cloud Storage (optional drawings)
* Firebase Hosting or GitHub Pages
* Analytics + Crashlytics

---

## 📁 Project Structure

```plaintext
lib/
├── app/
├── core/
├── features/
│   ├── auth/
│   ├── matchmaking/
│   ├── gameplay/
│   └── leaderboard/
└── main.dart
```

Cleanly divided by feature for scale and maintainability.

---

## 📘 Documentation

This repository includes full engineering documentation:

### 🔹 [detailed_blueprint.md](./detailed_blueprint.md)

Full system architecture, Firebase rules, models, CI, diagrams.

### 🔹 [plan_and_implementation.md](./plan_and_implementation.md)

High-level plan + detailed implementation steps.

### 🔹 [phase_plan.md](./phase_plan.md)

Step-by-step sprint-style breakdown.

These documents together form the **official documentation** for the game.

---

## 🏗 Installation & Setup

### 1. Clone

```bash
git clone https://github.com/<your_user>/word_battle.git
cd word_battle
```

### 2. Install packages

```bash
flutter pub get
```

### 3. Configure Firebase

```bash
flutterfire configure
```

This generates `firebase_options.dart`.

### 4. Run locally

```bash
flutter run -d chrome
```

---

## 🌐 Web Deployment

### ✔ Option 1 — GitHub Pages (recommended)

Build Web:

```bash
flutter build web --release
```

Deploy via GitHub Actions or manual push to `gh-pages`.

### ✔ Option 2 — Firebase Hosting

```bash
firebase deploy --only hosting
```

---

## 🧪 Testing

```bash
flutter test
```

Tests cover:

* Domain logic
* Match lifecycle
* Widget flows
* Integration tests (Emulator)

---

## 🔧 CI/CD

GitHub Actions pipeline:

* `flutter analyze`
* `flutter test`
* Build Web
* Deploy to `gh-pages`

---

## 🛣 Roadmap

* [ ] Local MVP (v0.1.0)
* [ ] Realtime Multiplayer (v0.2.0)
* [ ] Hosting + CI/CD (v0.3.0)
* [ ] Full Polish + Case Study (v1.0.0)
* [ ] Multi-player expansion (v1.1.0)

<!-- ---

## 📸 Screenshots / Demo GIF

*(Add screenshots or GIF once UI is ready)* -->

---

## 🤝 Contributing

PRs, issues, and discussions are welcome.

---

## 📜 License

MIT License

---

Enjoy the project! If you're using this as a portfolio piece, link the hosted demo and the blueprint documents to show your engineering depth.
