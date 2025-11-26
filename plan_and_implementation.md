# Realtime Word‑Battle Arena — Plan & Implementation

This document is a **detailed implementation plan** and technical blueprint for the *Realtime Word‑Battle Arena* game built with **Flutter** and **Firebase**. It covers architecture, data models, Firebase structure and rules, core code examples, CI/CD, testing strategy, assets, performance considerations, and a step‑by‑step implementation checklist you can follow to build a production‑quality game and portfolio piece.

---

## Table of Contents

1. Project Goals
2. High‑level Architecture
3. Repository Structure
4. Feature Phases & Deliverables
5. Data Model & Firebase Structure
6. Firebase Rules & Cloud Functions (skeleton)
7. Domain Layer: Entities, Usecases & Repositories
8. Data Layer: DTOs & Firebase Repos
9. Presentation Layer: BLoC/Cubit Patterns
10. Key Screens & UI Flow
11. Sample Code Snippets
12. Testing Strategy
13. CI/CD (GitHub Actions) Boilerplate
14. Performance & Optimization Checklist
15. Assets, Animations & Sound
16. Analytics & Telemetry
17. Polishing, Publishing & Portfolio Advice
18. Next Steps & Prioritized Implementation Checklist

---

## 1. Project Goals

* Build a one‑on‑one, realtime multiplayer word/drawing guessing game using Flutter and Firebase.
* Demonstrate clean architecture: UI decoupled from domain logic.
* Showcase realtime sync, matchmaking, disconnect handling, and scoreboard.
* Implement a reusable game engine (domain + rules) that can be repurposed for other games.
* Publish a live demo (Web + Mobile) and write a case study describing design choices and tradeoffs.

---

## 2. High‑level Architecture

* **Presentation (Flutter UI)** — Widgets, Pages, BLoCs/Cubits, Animation Widgets.
* **Domain (Pure Dart)** — Entities, Value Objects, Use Cases, Game Rules, Game Engine.
* **Data (Implementation)** — Firebase Repositories (Firestore/Realtime DB, Storage), DTOs, Cloud Functions.
* **Infrastructure** — DI (GetIt), Logging, Network retry policy, Local cache.

All network/DB calls go through repository interfaces in the domain layer so you can swap Firebase for a mock or other backend for tests.

---

## 3. Repository Structure (detailed)

```
word_battle/
├── lib/
│   ├── app/
│   │   ├── config/
│   │   ├── di/
│   │   └── router/
│   ├── core/
│   │   ├── errors/
│   │   ├── utils/
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/
│   │   ├── matchmaking/
│   │   ├── gameplay/
│   │   └── leaderboard/
│   └── main.dart
├── test/
├── .github/workflows/
├── firebase/
└── README.md
```

Notes: keep `domain/` and `data/` inside each feature for modularity (e.g., `features/gameplay/domain/...`).

---

## 4. Feature Phases & Deliverables

### Phase 1: MVP

* Auth (anonymous/Google) + basic profile.
* One‑on‑one match using local word list (no backend realtime sync yet).
* Drawing canvas (optional) and guess input UI.
* Timer and scoring rules implemented in domain layer.
* Local persistence of top scores (shared_preferences).

### Phase 2: Realtime + Firebase

* Move match state to Firestore or Realtime Database with real‑time listeners.
* Implement matchmaking lobby and match creation/join flows.
* Leaderboard backed by Firestore.
* Cloud Functions: server‑side turn validation & word generation.

### Phase 3: Polish & Scale

* Rive/Lottie animations and SFX.
* Cross‑platform polish (mobile + web responsive UI).
* Analytics events and performance monitoring.

### Phase 4: Extend

* 2–4 player matches.
* Chat/emotes and friend invites.
* Custom word packs and monetization simulation.

---

## 5. Data Model & Firebase Structure

### Firestore (recommended) structure — top level collections

```
/users/{userId}
  username
  avatarUrl
  bestScore
  createdAt

/matches/{matchId}
  hostId
  hostName
  opponentId (nullable)
  status: waiting|started|finished|cancelled
  round
  createdAt
  currentTurn: userId
  currentWordHash (optional)

/matches/{matchId}/state/{stateId}
  timer
  currentWord (encrypted/hashed or server-generated token)
  guesses: [ { playerId, guessText, correct, timestamp } ]
  drawingData (if using vector/serialized strokes) or drawingUrl (Storage)

/leaderboard/{playerId}
  username
  score
  updatedAt
```

**Design decisions:**

* Use **Firestore** with real-time listeners for moderate realtime use. If you require ultra-low latency for position-sync style games, Realtime Database is more suited—but for turn-based guessing Firestore is fine.
* Store drawing strokes as compressed JSON blobs in Firestore (small games) or as images in Cloud Storage (if heavy) and keep reference in match state.
* Avoid storing plaintext answer in client‑readable fields. Store hashed or use Cloud Functions to validate answers.

---

## 6. Firebase Rules & Cloud Functions (skeleton)

### Firestore Security Rules (starter)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }

    match /matches/{matchId} {
      allow read: if true; // consider limiting to players
      allow create: if request.auth != null;
      allow update: if request.auth != null && (request.auth.uid == resource.data.hostId || request.auth.uid == resource.data.opponentId);
    }

    match /matches/{matchId}/state/{stateId} {
      allow read, write: if request.auth != null && (request.auth.uid == get(/databases/$(database)/documents/matches/$(matchId)).data.hostId || request.auth.uid == get(/databases/$(database)/documents/matches/$(matchId)).data.opponentId);
    }

    match /leaderboard/{doc} {
      allow read: if true;
      allow write: if false; // only Cloud Functions write
    }
  }
}
```

**Cloud Functions (TypeScript / Node)**

* `validateGuess` — trigger: HTTP callable or Firestore trigger. Verifies guess against word, applies scoring, and writes result to match state.
* `generateWord` — returns a new random word or pack; used to avoid exposing answers to clients.
* `updateLeaderboard` — triggered on match finished to update top scores safely.

Skeleton `functions/src/index.ts` (pseudo):

```ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

export const validateGuess = functions.https.onCall(async (data, context) => {
  // data: { matchId, guess }
  // Auth check, fetch match state, compare hashed answer, record guess
});

export const generateWord = functions.https.onCall(async (data, context) => {
  // return a word token or id, do NOT send word plaintext to client
});
```

**Why Cloud Functions?**

* Keeps critical validations server‑side to prevent cheating.
* Centralized leaderboard updates to avoid race conditions.

---

## 7. Domain Layer: Entities, Usecases & Repositories

### Key Entities (Dart)

* `Player` — id, username, avatarUrl
* `Match` — id, hostId, opponentId, status, round
* `GameState` — matchId, currentTurn, timer, guesses
* `Guess` — playerId, text, correct, timestamp

### Example Usecases

* `CreateMatch(host)`
* `JoinMatch(matchId, player)`
* `SubmitGuess(matchId, player, guess)`
* `NextTurn(matchId)`
* `EndMatch(matchId)`

### Repositories (interfaces)

* `IMatchRepository` — createMatch, joinMatch, watchMatch, updateMatch
* `IGameplayRepository` — submitGuess, watchGameState
* `ILeaderboardRepository` — saveScore, watchTopScores

All usecases only depend on these interfaces. Implementations live in data layer.

---

## 8. Data Layer: DTOs & Firebase Repositories

Provide implementations:

* `FirestoreMatchRepository implements IMatchRepository`
* `FirestoreGameplayRepository implements IGameplayRepository`
* `FirestoreLeaderboardRepository implements ILeaderboardRepository`

DTO example `match_dto.dart`:

```dart
class MatchDto {
  final String id;
  final String hostId;
  final String? opponentId;
  final String status;
  final int round;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => { ... };
  factory MatchDto.fromMap(Map<String,dynamic> map) => ...;
}
```

**Implementation notes**

* Use converters and `withConverter` when using Firestore with typed models.
* Use streams for `watchMatch` and expose domain models via mapping functions.
* Keep all Firebase-specific code inside `data/` folder to ease testing/mocking.

---

## 9. Presentation Layer: BLoC/Cubit Patterns

Suggested BLoCs/Cubits:

* `AuthCubit` — user auth state
* `MatchmakingCubit` — finding/joining matches, lobby state
* `GameSessionBloc` — the heavy one: handles timer, incoming realtime events, submitGuess flow, show results
* `LeaderboardCubit` — fetch top scores

### Example `GameSessionCubit` responsibilities

* Subscribe to `gameplayRepository.watchGameState(matchId)`
* Start/stop local timer (server authoritative but display local countdown)
* Provide methods: `submitGuess(String guess)`, `sendDrawingStroke(Stroke)`, `leaveMatch()`
* Emit states: `GameLoading`, `GameActive(GameState)`, `RoundResult`, `GameEnded`

**State synchronization guidance**

* Treat server state as source of truth. Client performs optimistic UI updates, but reconciles on next server message.
* Use server timestamps for ordering.

---

## 10. Key Screens & UI Flow

1. **Splash / Onboarding** — quick app intro, permissions (microphone if voice drawing?), analytics opt‑in
2. **Auth / Profile** — anonymous or Google Sign‑in
3. **Home** — Play Now, Leaderboard, Settings
4. **Matchmaking Lobby** — find opponent, show ready/accept UI
5. **Gameplay** — central canvas / guess pane, timer, score
6. **Results Screen** — per round and match summary
7. **Leaderboard** — global top players

UX decisions

* Use subtle haptics for mobile wins/loses
* Maintain consistent theme across screens; add micro‑interactions (button presses, correct guess) to improve polish

---

## 11. Sample Code Snippets

### DI (GetIt) setup (app/di/injection.dart)

```dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Repos
  getIt.registerLazySingleton<IMatchRepository>(() => FirestoreMatchRepository());
  getIt.registerLazySingleton<IGameplayRepository>(() => FirestoreGameplayRepository());
  // Usecases
  getIt.registerFactory(() => CreateMatchUsecase(getIt()));
  // Cubits / Blocs
  getIt.registerFactory(() => MatchmakingCubit(getIt()));
}
```

### Game Entity (domain/entities/player.dart)

```dart
class Player {
  final String id;
  final String username;
  final String? avatarUrl;

  Player({ required this.id, required this.username, this.avatarUrl });
}
```

### GameplayRepository interface

```dart
abstract class IGameplayRepository {
  Future<void> submitGuess(String matchId, String guess, String playerId);
  Stream<GameState> watchGameState(String matchId);
}
```

### GameSessionCubit (skeleton)

```dart
class GameSessionCubit extends Cubit<GameSessionState> {
  final IGameplayRepository _gameplayRepository;
  StreamSubscription?<GameState>? _sub;

  GameSessionCubit(this._gameplayRepository) : super(GameSessionInitial());

  Future<void> start(String matchId) async {
    emit(GameSessionLoading());
    _sub = _gameplayRepository.watchGameState(matchId).listen((gs) {
      emit(GameSessionActive(gs));
    });
  }

  Future<void> submitGuess(String matchId, String guess, String playerId) async {
    try {
      await _gameplayRepository.submitGuess(matchId, guess, playerId);
    } catch (e) {
      emit(GameSessionError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
```

---

## 12. Testing Strategy

### Unit tests

* Pure domain logic (scoring rules, timer expiry, guess validation): fast, deterministic
* Use `mockito` or `mocktail` to mock repositories

### Widget tests

* Test key UI flows: launching match, submitting a guess, showing round result
* Use `pumpWidget` and test `GameSessionCubit` state changes

### Integration tests

* Use `flutter_driver` or `integration_test` to run end‑to‑end flows on an emulator
* Include tests for reconnection scenarios (simulate network loss)

**Test examples:**

* `test/domain/scoring_test.dart` — verify point distribution for correct/incorrect guesses
* `test/widget/gameplay_flow_test.dart` — simulate a correct guess and expect UI to show success animation

---

## 13. CI/CD (GitHub Actions) Boilerplate

`.github/workflows/flutter.yml` (skeleton)

```yaml
name: Flutter CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Run analyzer
        run: flutter analyze
      - name: Run tests
        run: flutter test --coverage
      - name: Build web
        run: flutter build web --release
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: web-build
          path: build/web
```

**Notes**: Add secrets for Firebase deploy if you intend to deploy web builds via CI.

---

## 14. Performance & Optimization Checklist

* Use `RepaintBoundary` for canvas widgets and heavy animated areas.
* Avoid rebuilding the whole screen on every state change — granular BLoCs/Cubits.
* Compress images and use WebP where possible for web builds.
* Throttle draws and stroke submissions to Firestore; batch small stroke packets.
* Use a debounced local timer UI and trust server for authoritative state.
* Profile with DevTools: check frame rendering times and memory usage.

---

## 15. Assets, Animations & Sound

* Prefer vector animations (Rive) for crisp animations cross‑platform; fallback Lottie for web if needed.
* Keep SFX short and minimal (correct guess, wrong guess, round end, match win)
* Store large media assets in Cloud Storage and load lazily.

---

## 16. Analytics & Telemetry

* Track custom events:

  * `match_started` {matchId, hostId}
  * `guess_submitted` {matchId, playerId, correct}
  * `match_ended` {matchId, winnerId, duration}
  * `player_retention` {userId, sessionCount}
* Use Firebase Analytics for cross‑platform aggregation.
* Use Crashlytics for crash monitoring.

---

## 17. Polishing, Publishing & Portfolio Advice

* Add a **case study** page to your portfolio: include architecture diagrams, challenges, screenshots, and a link to the live demo and GitHub repo.
* Record a 30–60 second demo video and embed it in the project page.
* In README, include a short architecture summary, commands to run the project locally, and a development roadmap.
* Add badges (build status, license, platform) to README and add GitHub Projects or Issues to show planned work and progress.

---

## 18. Next Steps & Prioritized Implementation Checklist

(Use this checklist to drive incremental commits and PRs.)

### Setup & MVP

* [ ] Initialize Flutter project with feature folders
* [ ] Add GetIt and basic DI
* [ ] Implement domain models and scoring usecases
* [ ] Implement drawing canvas & guess UI locally
* [ ] Implement Auth (Google / Anonymous)
* [ ] Implement local match flow (no backend) and a local leaderboard
* [ ] Write unit tests for scoring and timer
* [ ] Prepare README and basic screenshots

### Realtime & Firebase

* [ ] Setup Firebase project + Firestore
* [ ] Implement Firestore repositories and real‑time listeners
* [ ] Implement Cloud Functions: generateWord, validateGuess, updateLeaderboard
* [ ] Add Firestore security rules and test them
* [ ] Replace local matchmaking with Firestore matchmaking
* [ ] Add tests for repository implementations (mock Firestore or use emulator)

### Polish & Deploy

* [ ] Integrate Rive/Lottie animations
* [ ] Add sound effects & background music (optional toggle in settings)
* [ ] Setup GitHub Actions for analysis/tests/build
* [ ] Deploy web build to Firebase Hosting
* [ ] Create portfolio case study & demo video

---

## Appendix A: Helpful Packages

* `flutter_bloc` / `bloc` — predictable state management
* `get_it` — dependency injection
* `cloud_firestore`, `firebase_auth`, `firebase_functions`, `firebase_storage` — Firebase SDKs
* `rxdart` — advanced stream utilities (optional)
* `flutter_riverpod` (alternative to bloc) — if you prefer provider-based approach
* `painter` or `flutter_canvas` — drawing helpers (evaluate performance)
* `mocktail` or `mockito` — testing
* `rive` / `lottie` — animations

---

## Appendix B: Example README (brief)

```
# Realtime Word Battle Arena

Realtime multiplayer drawing & guessing game built with Flutter & Firebase.

## Features
- One-on-one matches
- Realtime gameplay with Firestore
- Leaderboard
- Animations with Rive

## Run locally
1. flutter pub get
2. Copy `firebase/firebase_config_example.dart` to `lib/firebase_config.dart` and add your project config
3. flutter run -d chrome

## Project structure
(Short summary)

## Contributing
Open issues, PRs welcome.
```

---

If you want, I can now:

* Generate the **full code skeleton** for the repo (boilerplate files + minimal working example) as a GitHub‑ready project.
* Create **Cloud Functions** stubs in TypeScript.
* Produce **detailed README** and a one‑page architecture diagram (SVG/PNG).

Tell me which of the above to produce next and I’ll scaffold it for you.
