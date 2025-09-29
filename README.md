# Task Management App

Flutter app implementing a collaborative task board (To Do, In Progress, Done) with BLoC and local storage.

## Setup
- Flutter stable SDK
- Run:
```
flutter pub get
flutter run
```

## Tests
```
flutter test
```

## Architecture
- Clean architecture: domain, data, presentation layers
- State management: BLoC
- Local storage: SharedPreferences (offline-ready)

## Features
- Kanban board with drag & drop
- Create/Edit tasks via modal
- Search and filter by priority
- Mock team hook ready (assignee id field)

## Notes
- Time taken: ~2-3 hours
- Assumptions: Using local storage for offline; assignee list mocked; can be swapped with API.
- See code for details.
