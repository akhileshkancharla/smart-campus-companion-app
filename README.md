# Campus · Smart Campus Companion

A responsive Flutter student companion inspired by modular campus portals. Plum and teal styling, spacious cards, desktop sidebar navigation, and mobile bottom navigation.

## Features

- Dashboard with date-aware next class and unread / saved notice counts
- Announcements with search, category filters, bookmarks, read state and full details
- Seven-day timetable with current-class highlighting and weekend empty states
- Searchable faculty directory, department filters, office hours, email copying and email app launch
- Campus facilities, hours and student guidance
- Light / dark theme and editable preferred name
- Device-local persistence for preferences, bookmarks and read notices
- Responsive layouts for mobile and desktop

## Run

Install Flutter with Dart 3.13.2 or compatible Dart 3.x, then:

```sh
flutter pub get
flutter run -d chrome
```

For Android, start an emulator or attach a device and use `flutter run`. iOS builds require macOS and Xcode. Desktop builds require the relevant platform toolchain.

## Validate and build

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Deploy the contents of `build/web` to a static host. For a repository subpath, build with `flutter build web --base-href /YOUR_REPOSITORY/`.

## Project structure

`lib/main.dart` contains the application shell, screens and local interaction state. `lib/data.dart` contains typed sample content and visual constants. `test/widget_test.dart` covers navigation, filtering, persistence, responsive layout and profile editing.

## Demo data and production integration

This is a complete local frontend demo, not an official college portal. All notices, faculty identities, facilities, schedules and example.edu contacts are illustrative. Replace them with verified college content before real use. No authentication or live backend is included. There are no push notifications; the bell opens announcements and its badge reflects locally unread notices.

The sample academic profile is Computer Science, semester 3, section A. The name is editable; changing departments or enrolling real students requires an institutional data source. Local preferences are not encrypted and should not contain confidential data. Web persistence is specific to the browser and origin.

Before production, connect an authenticated institutional API, provide staff publishing workflows, enforce student access on the server, and configure real notification delivery if needed. Replacing data with a live source also requires loading, retry and offline states.

## GitHub

Commit source, tests, platform folders, pubspec.yaml and pubspec.lock. Keep generated build outputs and local SDK settings excluded using the Flutter .gitignore. Review college content and branding permissions before publishing. No license is selected; choose one before offering reuse rights.
