# Detailed Blueprint — Realtime Word‑Battle Arena

This document is an actionable, engineer‑grade blueprint for building, testing, deploying, and maintaining the Realtime Word‑Battle Arena. It expands the earlier plan into precise technical tasks, schemas, CI/CD, security, testing matrices, instrumentation, and project management artifacts you can use immediately.

---

## 1. Executive Summary

* Build a one‑on‑one realtime word/drawing guessing game using Flutter (presentation) and Firebase (backend).
* Deliverables: playable MVP (mobile+web), published demo, production‑grade README + case study.
* Primary goals: clean architecture, testability, realtime robustness, production polish.

---

## 2. Tech Stack

* Frontend: Flutter (stable channel)
* State management: flutter_bloc (BLoC + Cubit)
* Dependency injection: get_it
* Backend: Firebase (Firestore, Authentication, Cloud Functions, Cloud Storage, Firebase Hosting)
* Analytics & Monitoring: Firebase Analytics, Crashlytics
* CI/CD: GitHub Actions
* Testing: flutter_test, integration_test, mocktail
* Optional: Rive (animations), Lottie (fallback), audioplayers (SFX)

---

## 3. High‑Level Components

1. **Auth Service** — anonymous + Google Sign‑in
2. **Matchmaking Service** — creates/join matches, lobby management
3. **Game Engine (Domain)** — turn logic, scoring, timer, validations
4. **Realtime Sync (Data)** — Firestore stores + streams for match state
5. **Drawing Service** — canvas ingestion and compression, optional image storage
6. **Leaderboard Service** — global top scores
7. **Cloud Functions** — server validation, word generation, leaderboard updates
8. **Frontend UI** — Home, Lobby, Gameplay, Results, Leaderboard, Profile
9. **CI/CD Pipeline** — lint, analyze, test, build, deploy web
10. **Telemetry** — analytics events & Crashlytics

---

## 4. Project Directory (recommended)

```
word_battle/
├── android/
├── ios/
├── lib/
│   ├── app/
│   ├── core/
│   ├── features/
│   │   ├── auth/
│   │   ├── matchmaking/
│   │   ├── gameplay/
│   │   └── leaderboard/
│   └── main.dart
├── functions/        # Cloud Functions (TypeScript)
├── firebase/
│   ├── firestore.rules
│   └── storage.rules
├── test/
├── .github/
└── README.md
```

---

## 5. Data Schemas (detailed)

### users collection

```
/users/{userId}
  username: string
  avatarUrl?: string
  createdAt: timestamp
  bestScore: number
  gamesPlayed: number
```

### matches collection

```
/matches/{matchId}
  id: string
  hostId: string
  hostName: string
  opponentId?: string
  opponentName?: string
  status: string // waiting|started|finished|cancelled
  round: number
  createdAt: timestamp
  currentTurn: string // userId
  wordToken: string // generated token or id; do NOT store plaintext if client-readable
  wordHash?: string // optional hashed value
  roundDuration: int // seconds per round
```

### state subcollection

```
/matches/{matchId}/state/{stateId}
  timer: int
  currentWordId: string
  guesses: [ { playerId: string, guess: string, correct: bool, ts: timestamp } ]
  drawingData?: string // compressed strokes or storageUrl
```

### leaderboard collection

```
/leaderboard/{userId}
  userId
  username
  score
  lastUpdated: timestamp
```

Notes:

* Use server timestamps for ordering.
* Prefer compact fields for frequent writes.

---

## 6. Cloud Functions API & Contracts

All server‑side functions are callable or HTTP endpoints with auth checks.

### functions.generateWord (callable)

**Input:** { packId?: string }
**Output:** { wordId: string, token: string }
**Purpose:** Returns a word token or id instead of plaintext. Cloud function stores answer mapping for server validation during match.

### functions.validateGuess (callable)

**Input:** { matchId, guess }
**Auth:** required
**Behavior:** Compares guess against server‑stored word (use hash or direct check), returns `{ correct: bool, points: int }` and writes guess entry to match state.

### functions.updateLeaderboard (trigger)

**Trigger:** onWrite to `/matches/{matchId}` when status == 'finished'
**Behavior:** Compute winner and update leaderboard atomically to avoid race conditions.

Security and rate limiting:

* Enforce per‑user rate limits (e.g., 10 guesses/sec) via function logic and Firestore rules where possible.

---

## 7. Firestore Security Rules (production ready starter)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }

    match /matches/{matchId} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && (resource.data.hostId == request.auth.uid || resource.data.opponentId == request.auth.uid || resource.data.status == 'waiting');
      allow update: if request.auth != null && (request.auth.uid == resource.data.hostId || request.auth.uid == resource.data.opponentId);
    }

    match /matches/{matchId}/state/{stateId} {
      allow read: if request.auth != null && (get(/databases/$(database)/documents/matches/$(matchId)).data.hostId == request.auth.uid || get(/databases/$(database)/documents/matches/$(matchId)).data.opponentId == request.auth.uid);
      allow write: if request.auth != null && (request.auth.uid == get(/databases/$(database)/documents/matches/$(matchId)).data.hostId || request.auth.uid == get(/databases/$(database)/documents/matches/$(matchId)).data.opponentId);
    }

    match /leaderboard/{doc} {
      allow read: if true;
      allow write: if false; // Cloud Functions only
    }
  }
}
```

---

## 8. Game Engine — Rules & Pseudocode

**Round flow (single round)**

1. Server generates `wordToken` and assigns to match.
2. Server sets `currentTurn = hostId` (or randomized).
3. Timer starts (server timestamp + roundDuration).
4. During round, clients can submit guesses via `validateGuess` function.
5. On correct guess: award points, mark round finished, record winner.
6. After round, next round or match end logic triggers.

**Scoring rules (example)**

* First correct guess: 100 points
* Each subsequent correct guess (if multi‑player): 50 points
* Time bonus: remainingSeconds * 2
* Wrong guess: -5 points (optional)

**Pseudocode: validateGuess**

```
function validateGuess(matchId, userId, guess) {
  word = getWordForMatch(matchId) // server side
  if (isSimilar(guess, word)) {
    points = calculatePoints(matchId)
    writeGuessToState(matchId, userId, guess, true)
    if (match not finished) markRoundFinished
    return {correct: true, points}
  } else {
    writeGuessToState(matchId, userId, guess, false)
    return {correct: false}
  }
}
```

Use fuzzy matching carefully — prefer exact match trimmed/lowercase for MVP. Add fuzzy later.

---

## 9. UI/UX Guidelines (senior level)

* Responsive layouts for mobile & web. Test breakpoints: 360, 720, 1024, 1366.
* Use `RepaintBoundary` around canvas and heavy animated widgets.
* Local optimistic UI for guesses, but rely on server message to confirm.
* Micro‑interactions: small success confetti, subtle haptics on mobile.
* Accessibility: screen reader labels for buttons, enough color contrast, scalable fonts.

---

## 10. Performance Considerations

* Batch stroke data: rather than submit every point, compress strokes into packets every 200ms or when stroke ends.
* Avoid large arrays in Firestore documents — store recent N guesses only and archive older ones if required.
* Use `withConverter` to map Firestore documents to DTOs to reduce mapping bugs.
* Profile with Dart DevTools and test builds in release mode for realistic metrics.

---

## 11. Testing Matrix

| Layer        | Type        |                   Tools | Targets                               |
| ------------ | ----------- | ----------------------: | ------------------------------------- |
| Domain       | Unit        | flutter_test + mocktail | scoring, timer, turn logic            |
| Data         | Integration |      Firestore emulator | repos read/write flows                |
| Presentation | Widget      |            flutter_test | UI flows for match start/guess/result |
| E2E          | Integration |        integration_test | end‑to‑end match flow on emulator     |
| Security     | Rules       |       firebase emulator | rules coverage tests                  |

Write tests before major features (TDD where it helps critical logic). Use emulator for Firestore and Functions tests.

---

## 12. CI/CD Details

**Workflow steps**

1. checkout
2. setup flutter
3. flutter pub get
4. analyzer
5. unit + widget tests
6. build web
7. deploy web to Firebase Hosting (only from `main` with secret)

**Secrets needed**

* FIREBASE_TOKEN (for firebase deploy)
* GOOGLE_SERVICES_JSON / PLIST for mobile builds (store in secrets manager if building mobile in CI)

**PR checks**

* Lint & analyze must pass
* Unit tests coverage threshold (e.g., 70%)

---

## 13. Release Checklist (pre‑launch)

* [ ] Crashlytics integrated
* [ ] Analytics events instrumented
* [ ] Performance profiled on target devices
* [ ] Security rules tested in emulator
* [ ] Cloud Functions tested and deployed
* [ ] Privacy policy and terms (if collecting analytics)
* [ ] Demo video recorded (30–60s)
* [ ] README + Case Study written

---

## 14. Branching & Git Strategy

* `main` — production ready, always green
* `dev` — integration branch for weekly merges
* feature branches: `feat/<short-desc>`
* bugfix: `fix/<short-desc>`
* release: `release/v0.1.0`

**PR template** (short)

```
### Summary
What changed and why.

### How to test
- steps to reproduce

### Checklist
- [ ] Tests added
- [ ] Lint passed
- [ ] Docs updated
```

Commit message convention: `type(scope): short description` (e.g., `feat(gameplay): implement submitGuess usecase`)

---

## 15. Metrics & Monitoring (KPIs)

* Daily active users (DAU)
* Matches started / completed
* Average match duration
* Guess accuracy rate
* Crash rate (Crashes per DAU)
* Retention (D1, D7)

Use Firebase Analytics and export to BigQuery later if deeper analysis needed.

---

## 16. Risk Register & Mitigations

1. **Cheating (clients seeing answer)** — mitigation: server-side validation, do not store plaintext word in readable document, use tokens.
2. **Realtime glitches / race conditions** — mitigation: Cloud Functions for critical transitions, use transactions when updating shared counters.
3. **Firestore cost explosion** — mitigation: limit write frequency (batch strokes, compress data), set retention/archival policies, monitor billing alerts.
4. **Performance on web** — mitigation: test and optimize canvas code, use lightweight libraries, lazy load assets.

---

## 17. Accessibility, i18n & Localization

* Extract user‑facing strings to `intl` (ARB) files.
* Support RTL later if needed.
* Provide a setting for font scaling and a screen‑reader friendly mode.

---

## 18. Art & Assets

* Minimal polished theme: 2 primary colors, 2 accent colors, neutral background.
* Provide avatars (placeholder + upload to Storage), or generate identicons.
* Keep SFX under 100KB each for web performance.

---

## 19. Legal & Privacy Notes

* If collecting analytics, add a privacy notice in app and portfolio page.
* Avoid storing personal data unnecessarily.

---

## 20. README Template (detailed)

Include:

* Project description
* Architecture summary
* Setup steps (Firebase emulator recommended)
* Run commands
* Testing commands
* Deployment instructions
* Contribution guidelines
* License

---

## 21. Immediate 10‑step Implementation Plan (concrete tasks)

1. Initialize repo, add `analysis_options.yaml`, `pubspec.yaml`, and CI workflow stub.
2. Setup GetIt DI and register basic services (Auth stub, repos interfaces).
3. Implement domain models: Player, Match, GameState, Guess.
4. Implement scoring usecase + unit tests.
5. Build simple local gameplay UI (canvas or text‑based guessing) that uses domain engine locally.
6. Add Auth (anonymous) and basic profile screen.
7. Wire matchmaking flow locally (create/join local match objects).
8. Write Firestore DTOs and repository skeletons (no wiring yet).
9. Create Cloud Functions project and implement `generateWord` skeleton.
10. Draft README and record 30s demo GIF of local gameplay.

Complete these in small commits with clear PRs.

---

## 22. Long Term Ideas (for portfolio growth)

* Publish a `word_battle_engine` pub package that extracts the domain game engine for reuse.
* Add AI opponent using serverless inference or client heuristics for offline play.
* Integrate social sharing (recorded clip or share final score screenshot)

---

## 23. Next Offerings from me

I can instantly scaffold any of the following for you (pick one):

* Full code skeleton (Flutter) with working local multiplayer demo
* Cloud Functions stubs (TypeScript) + deploy script
* GitHub Actions workflow for CI + deploy
* A one‑page architecture diagram (SVG)

Tell me which to generate and I’ll scaffold it now.
