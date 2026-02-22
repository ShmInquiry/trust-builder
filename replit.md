# Flutter Sandbox

## Overview
A Flutter web application imported from GitHub. The app displays a simple Material Design interface with an app bar and profile image.

## Project Architecture
- **Framework**: Flutter 3.32.0 with Dart 3.8.0
- **Platform**: Web (compiled from Flutter)
- **Build**: `flutter build web --release` compiles Dart to JavaScript
- **Server**: Custom Dart HTTP server (`serve_web.dart`) serves the built web files on port 5000

## Project Structure
- `lib/main.dart` - Main Flutter application entry point
- `pubspec.yaml` - Flutter/Dart package configuration
- `serve_web.dart` - Dart HTTP server for serving built web files
- `web/` - Web platform template (index.html, manifest, icons)
- `build/web/` - Compiled web output (generated, not committed)
- `assets/images/` - Application image assets
- `android/` - Android platform files (not used for web)
- `ios/` - iOS platform files (not used for web)

## Running the App
The workflow builds and serves the Flutter web app:
1. `flutter build web --release` - Compiles Dart to JavaScript
2. `dart run serve_web.dart` - Serves compiled files on port 5000

## Recent Changes
- 2026-02-22: Updated SDK constraint from `>=2.0.0-dev.68.0 <3.0.0` to `>=3.0.0 <4.0.0`
- 2026-02-22: Updated cupertino_icons from `^0.1.2` to `^1.0.8`
- 2026-02-22: Added Flutter web platform support
- 2026-02-22: Created `serve_web.dart` for serving the web build on port 5000
