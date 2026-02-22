# Trust OS

## Overview
Trust OS is a Flutter mobile/web app for building and tracking interpersonal trust within teams, based on Stephen Covey's principles. Features include a Trust Score (Emotional Bank Account), active request tracking with urgency-based color coding, a network node map, roster view, alerts, and profile/settings management.

## Project Architecture
- **Framework**: Flutter 3.32.0 with Dart 3.8.0
- **Platform**: Web (compiled from Flutter, designed as mobile-first)
- **Build**: `flutter build web --release` compiles Dart to JavaScript
- **Server**: Custom Dart HTTP server (`serve_web.dart`) serves the built web files on port 5000
- **Design System**: Custom theme with blue/white color scheme (AppTheme)
- **State**: Currently using local mock data; prepared for backend integration

## Project Structure
```
lib/
  main.dart              - App entry point (TrustOSApp)
  theme/
    app_theme.dart       - Colors, typography, component themes
  models/
    request_model.dart   - Request/expectation data model
    alert_model.dart     - Alert/notification data model
    network_node_model.dart - Network peer node model
  services/
    mock_data.dart       - Mock data for all screens
    local_storage_service.dart - SharedPreferences wrapper for user auth
  screens/
    login_screen.dart    - Email/password login with validation
    register_screen.dart - Account registration with validation (username, email, password)
    verify_email_screen.dart - 6-digit email verification
    main_shell.dart      - Main app shell with bottom nav + drawer + logo
    home_screen.dart     - Dashboard: Trust Score, Covey quote, active requests
    network_screen.dart  - Interactive network node map with zoom/pan
    roster_screen.dart   - List view of network peers
    alerts_screen.dart   - Filterable alerts (All/Requests/System)
    settings_screen.dart - Profile editing, privacy toggles, app settings
    request_detail_screen.dart - Full request detail view with back navigation
  widgets/
    request_card.dart    - Tappable request card with status dot and navigation
```

## Navigation Flow
- Login Screen -> Main Shell (validates against stored credentials)
- Register Screen -> stores user in local storage -> Verify Email -> Main Shell
- Main Shell: Bottom nav (Home, Network, Roster, Alerts) + Hamburger drawer menu
- Drawer: Navigate to tabs or Profile & Settings screen
- Home -> Tap request card -> Request Detail Screen -> Back button returns to Home

## Running the App
The workflow builds and serves the Flutter web app:
1. `flutter build web --release` - Compiles Dart to JavaScript
2. `dart run serve_web.dart` - Serves compiled files on port 5000

## Key Design Decisions
- Mobile-first design matching Figma wireframes in wireframe-design-mockups/
- Single Scaffold pattern with MainShell managing AppBar and Drawer for all tabs
- InteractiveViewer for network map zoom/pan
- Color-coded request statuses: Blue (Fair), Yellow (Stalled), Red (Critical)
- Trust Score badge in Home AppBar showing EB points and health status

## Dependencies
- `shared_preferences` - Local storage for user authentication credentials

## Recent Changes
- 2026-02-22: Phase 1 complete - Added form validation, local storage auth, logo, detail screen
- 2026-02-22: Login validation (email regex, password required, error banners)
- 2026-02-22: Signup validation (username 3+ chars, email format, password 8+ with number)
- 2026-02-22: LocalStorageService saves/validates user credentials via SharedPreferences
- 2026-02-22: App logo added to Home screen AppBar header
- 2026-02-22: RequestDetailScreen with full info, peer list, action buttons, back nav
- 2026-02-22: Request cards now tappable, navigating to detail screen
- 2026-02-22: Built complete Trust OS app with all core screens
- 2026-02-22: Drawer menu and bottom navigation wired up
