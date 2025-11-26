# Realtime Word‑Battle Arena

A realtime multiplayer **drawing & word‑guessing game** built with **Flutter** and **Firebase**, designed as a production‑grade demonstration of clean architecture, scalable state management, and realtime sync on both mobile and web.

This project highlights robust engineering practices: domain‑driven structure, repository abstraction, server‑validated gameplay, animations, CI/CD, and a full technical blueprint that documents the entire system design.

---

## 🎮 Overview

The **Realtime Word‑Battle Arena** enables two players to compete in a fast‑paced guessing battle:

* One player draws or hints a word.
* The other player guesses in realtime.
* Firebase manages matchmaking, game state syncing, scoring, and leaderboard updates.
* Cloud Functions ensure secure, server‑validated gameplay.

This project is built as a **portfolio‑level showcase** of:

* Clean Architecture
* Flutter + Firebase integration
* Realtime multiplayer flows
* Scalable state management with BLoC
* Cross‑platform deployment (Web + Mobile)

---

## 🚀 Tech Stack

### **Frontend (Flutter)**

* Flutter (stable)
* flutter_bloc (state management)
* get_it (dependency injection)
* equatable (value equality)
* rxdart (advanced streams)
* Rive / Lottie (animations)
* shared_preferences (local storage)

### **Backend (Firebase)**

* Firebase Auth (Anonymous / Google Sign‑in)
* Firestore (realtime match + game state)
* Cloud Functions (server‑validated gameplay logic)
* Cloud Storage (optional canvas or assets)
* Firebase Hosting (or GitHub Pages for web)
* Emulator Suite (local development)
* Firebase Analytics + Crashlytics

---

## 🏛 Architecture

This project adopts a clean, layered architecture to ensure scalability and maintainability:

### **1. Presentation Layer**

* Flutter widgets + UI
* BLoC/Cubit for state handling

### **2. Domain Layer (pure Dart)**

* Entities: Player, Match, GameState, Guess
* Usecases: createMatch, joinMatch, validateGuess, submitGuess, endMatch
* Repository interfaces only (no Firebase logic here)

### **3. Data Layer**

* Firebase implementations of repository interfaces
* DTOs for Firestore serialization
* Cloud Function calls using callable functions

### **4. Infrastructure Layer**

* DI setup (GetIt)
* Utilities, error handling, logging

This strict separation makes the game engine testable, reusable, and flexible for future features like 4‑player mode or offline AI opponents.

---

## 🧩 Core Features

### ✔ Local MVP (Phase 1)

* One‑device or local-network match simulation
* Drawing canvas / guess input
* Timer + scoring implemented locally
* Local leaderboard

### ✔ Realtime Firebase Integration (Phase 2)

* Firestore-based matchmaking
* Realtime game state listeners
* Cloud Functions for secure guess validation
* Server‑generated words to prevent cheating
* Persistent leaderboard

### ✔ Production Polish (Phase 3)

* Rive/Lottie animations
* SFX and theme system
* Responsive UI for web + mobile
* Analytics + Crashlytics
* CI/CD with GitHub Actions
* Hosted Web Build

### ✔ Optional Extensions (Phase 4)

* 4‑Player battles
* Chat/emotes during match
* Friend invites
* Custom word packs
* Monetization simulation

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

This modular structure allows each feature to grow independently.

---

## 🔥 Firebase Cloud Functions

Cloud Functions enforce secure gameplay:

* `generateWord` → server‑generated word tokens
* `validateGuess` → server‑validated guessing
* `updateLeaderboard` → safe scoreboard updates

This ensures fairness, prevents tampering, and keeps the game authoritative.

---

## 📊 Firestore Structure

```
/users/{userId}
/matches/{matchId}
/matches/{matchId}/state/{stateId}
/leaderboard/{userId}
```

Data design optimized for low latency, low cost, and predictable reads/writes.

---

## 🧪 Testing Strategy

### Unit Tests

* Domain logic: scoring, timer, match cycle
* Repository interfaces mocked via mocktail

### Widget Tests

* Match creation/join flow
* Guess submission flow

### Integration Tests

* Full match simulation using Firebase Emulator

### CI Enforcement

GitHub Actions runs:

* `flutter analyze`
* `flutter test`
* web build + optional deploy

---

## 🌐 Web Hosting

You can host the web build in two ways:

### **1. GitHub Pages (recommended for portfolio)**

* Build Flutter web → deploy via GitHub Actions
* Firebase backend works normally; just add domain to Authorized Domains

### **2. Firebase Hosting**

* Full rewrite support
* Built‑in CDN + HTTPS

This project can run seamlessly on both.

---

## 📘 Phases Summary

This project follows a structured development plan (detailed in `phase_plan.md`).

### **Phase 0 — Setup**

Repo structure, DI, CI stub, documentation.

### **Phase 1 — Local MVP**

Core game engine + local gameplay.

### **Phase 2 — Firebase Realtime**

Matchmaking, state sync, Cloud Functions.

### **Phase 3 — Polish & Deploy**

Animations, SFX, performance, CI/CD, hosting.

### **Phase 4 — Extensions**

Scaling to multi‑player, chat, custom packs.

---

## 📂 Full System Blueprint

A complete architectural blueprint is included in:

* **`detailed_blueprint.md`** → architecture, models, rules, CI/CD
* **`plan_and_implementation.md`** → full execution plan
* **`phase_plan.md`** → sprint-style roadmap

These documents contain:

* Data schemas
* Cloud Functions contracts
* Firestore security rules
* CI/CD pipeline setup
* Testing matrix
* Performance checklist

They collectively form the **technical documentation** for the entire project.

---

## 📝 Roadmap

* [ ] Release v0.1.0 — Local MVP
* [ ] Release v0.2.0 — Realtime Multiplayer
* [ ] Release v0.3.0 — Hosted Web Build
* [ ] Release v1.0.0 — Full Polish + Analytics + Case Study

---

## 🤝 Contributing

Open to PRs, improvements, and architecture discussions.

---

## 📜 License

MIT License unless otherwise specified.

---

## 🙌 Acknowledgements

Thanks to the Flutter & Firebase communities for powerful tooling and open-source documentation.

---

For setup instructions, see the project root README, and check the blueprint files for deeper architectural guides.
