# Revalia Obscura

Revalia Obscura is a point-and-click adventure game built with Flutter and
Flame.

## Requirements

- Flutter stable with Dart 3.5 or newer
- A configured Flutter target: Chrome, Windows, Android, Linux, macOS, or iOS
- Platform toolchains required by the target you intend to build

Check the local setup:

```powershell
flutter doctor
flutter devices
```

## Install Dependencies

From the repository root:

```powershell
flutter pub get
```

After changing dependencies or generated asset declarations, regenerate the
Flutter asset references:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Generated asset paths are written to `lib/gen/assets.gen.dart`.

## Run

List available devices:

```powershell
flutter devices
```

Run the web version in Chrome:

```powershell
flutter run -d chrome
```

Run the Windows desktop version:

```powershell
flutter run -d windows
```

Run on another connected device:

```powershell
flutter run -d <device-id>
```

## Analyze and Test

Run static analysis:

```powershell
flutter analyze
```

Run automated tests:

```powershell
flutter test
```

Note: `test/widget_test.dart` is currently the obsolete Flutter counter
template and must be replaced before the test suite can pass.

## Build

Create a production web build:

```powershell
flutter build web --release
```

The output is written to `build/web/`.

Create a Windows release build:

```powershell
flutter build windows --release
```

The output is written under `build/windows/x64/runner/Release/`.

Common additional targets:

```powershell
flutter build apk --release
flutter build appbundle --release
flutter build linux --release
flutter build macos --release
flutter build ios --release
```

The required platform toolchain must be installed for each target.

## Clean Rebuild

Use this when dependencies or generated output become inconsistent:

```powershell
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Web Packaging for itch.io

Build the web release first:

```powershell
flutter build web --release
```

The repository includes `publish_itch.py`, which adjusts the generated
`build/web/index.html` base path and uploads `build/web/` with Butler. Install
the Python dependencies and place `butler.exe` in the repository root:

```powershell
python -m pip install requests pyyaml
$env:ITCH_API_KEY = '<itch-api-key>'
python publish_itch.py
```

Rotate any credential that was previously committed before using the
publishing helper.

For a manual upload, remove the generated `<base href="/">` line from
`build/web/index.html`, then upload the contents of `build/web/` as an HTML5
game.

## Project Layout

- `lib/main.dart`: Flutter and Flame entry point
- `lib/revalia_obs.dart`: game boot, asset preload, camera, and world switching
- `lib/gamefsm/`: menu, loading, gameplay, score, and end-state routing
- `lib/game/states/game/`: point-and-click gameplay entities and action flow
- `lib/utils/`: shared image, audio, dialogue, UI, and translation helpers
- `resources/`: images, fonts, audio, shaders, and translations
