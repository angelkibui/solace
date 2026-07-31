# Solace

Solace is a privacy-first Flutter mobile application that helps people in
Rwanda find licensed mental-health professionals, reserve sessions, and manage
their care through an anonymous alias. The current implementation uses Firebase
Authentication, Cloud Firestore, BLoC/Cubit state management, and a
feature-oriented clean architecture.

Repository: <https://github.com/angelkibui/solace>

## Implemented functionality

- Privacy-focused onboarding with a generated alias and concern selection.
- Email/password and Google authentication, email verification, password reset,
  persisted authentication, and logout.
- Searchable therapist directory with specialty, language, gender, and price
  filters, responsive cards, profile details, refresh, empty, loading, and error
  states.
- Four-step appointment booking with date, time, session type, notes, review,
  confirmation, rescheduling, cancellation, deletion, and upcoming/history tabs.
- MTN MoMo and Airtel Money checkout presentation with validation, success
  feedback, Firestore transaction history, and appointment confirmation. The
  academic build simulates provider approval; it does not connect to a live
  mobile-money gateway or move funds.
- SharedPreferences-backed onboarding, theme, notification, and language
  values.
- Owner-scoped Firestore security rules for users, appointments, and
  transactions.

## Architecture

Feature code is separated into data and presentation layers. Models and
repositories own serialization and Firebase access; BLoCs/Cubits own state and
business decisions; pages render state and dispatch events.

```text
lib/
├── core/
│   ├── bloc/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
└── features/
    ├── auth/
    ├── onboarding/
    ├── therapists/
    │   ├── data/{models,repositories}/
    │   └── presentation/{bloc,pages}/
    ├── appointments/
    │   ├── data/{models,repositories}/
    │   └── presentation/{bloc,pages}/
    └── payments/
        ├── data/{models,repositories}/
        └── presentation/{bloc,pages}/
```

The implemented Firestore structure is documented in [docs/erd.md](docs/erd.md).

## Setup

Prerequisites:

- Flutter with a Dart SDK compatible with `>=3.3.0 <4.0.0`.
- Android Studio/Android SDK or Xcode for a mobile build.
- Firebase CLI and FlutterFire CLI.
- Google Cloud CLI when running the optional seed script.
- Access to the Firebase project `solace-rwanda`.

```bash
git clone git@github.com:angelkibui/solace.git
cd solace
flutter pub get
flutterfire configure --project=solace-rwanda --platforms=android,ios
flutter analyze
flutter test
flutter run
```

Run the application on an Android/iOS emulator or a physical phone. The course
does not accept web or desktop builds.

Authentication providers must be enabled in Firebase Console:

1. Enable Email/Password and Google in Authentication > Sign-in method.
2. Add Android SHA-1/SHA-256 fingerprints before testing Google sign-in.
3. Add test accounts or configure the OAuth consent screen as required.

## Firestore setup

Deploy the versioned rules and indexes:

```bash
firebase use solace-rwanda
firebase deploy --only firestore:rules,firestore:indexes
```

`tool/therapists_seed.json` contains six deterministic fictional therapist
profiles for demonstration. `tool/seed_therapists.mjs` writes them by stable
document ID and can be run repeatedly without creating duplicates:

```bash
FIREBASE_ACCESS_TOKEN="$(gcloud auth print-access-token)" \
  node tool/seed_therapists.mjs solace-rwanda
```

The token is read only from the process environment and is never written to the
repository.

## Security rules

- `users/{uid}` is readable and writable only by that authenticated user.
- `therapists` is readable by authenticated users and writable only by an
  account with an `admin` custom claim.
- `appointments` can be created only for the signed-in user. They can be read by
  the owner or assigned therapist and changed only by the owner; ownership,
  assigned therapist, and amount cannot be reassigned during an update.
- `transactions` can be created, read, changed, and deleted only by their owner.
  Ownership, appointment, reference, and amount are immutable after creation.

These rules are in [firestore.rules](firestore.rules). They intentionally avoid
the broad `allow read, write: if request.auth != null` pattern.

## Quality checks

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build apk --debug
```

Tests cover validators, authentication state, therapist loading/filtering,
responsive directory rendering, appointment creation/deletion and booking
navigation, payment validation/state/history, and checkout responsiveness.

## Known limitations and future work

- Mobile-money authorization is simulated for the academic prototype. A
  production version requires an approved provider integration, server-side
  verification, webhook handling, and a compliance review.
- Community Circles, real-time chat, secure audio calling, maps, and the complete
  profile/settings interface are owned by other team workstreams and must be
  integrated before the final release.
- Seed profiles are fictional demonstration data and must be replaced with
  verified professionals before any public pilot.
- Production releases require separate Android/iOS signing, Crashlytics,
  accessibility review, and end-to-end testing on physical devices.
