# Trust OS

## Overview
Trust OS is a Flutter mobile/web app for building and tracking interpersonal trust within teams, based on Stephen Covey's principles. Features include a Trust Score (Emotional Bank Account), active request tracking with urgency-based color coding, a network node map, roster view, alerts, and profile/settings management.

## Project Architecture
- **Frontend**: Flutter 3.32.0 with Dart 3.8.0, compiled to web
- **Backend**: Rust (actix-web 4 + sqlx 0.7) REST API on port 3001
- **Database**: PostgreSQL (Neon-backed via Replit)
- **Server**: Custom Dart HTTP server (`serve_web.dart`) on port 5000 with API proxy to backend
- **Design System**: Custom theme with blue/white color scheme (AppTheme)
- **Auth**: Token-based authentication (bcrypt password hashing, session tokens)
- **State**: Real data from PostgreSQL via Rust REST API

## Project Structure
```
lib/
  main.dart              - App entry point (TrustOSApp)
  theme/
    app_theme.dart       - Colors, typography, component themes
  models/
    request_model.dart   - Request/expectation data model (with fromJson)
    alert_model.dart     - Alert/notification data model (with fromJson)
    network_node_model.dart - Network peer node model (with fromJson)
  services/
    api_service.dart     - Singleton API client (auth, requests, trust, network, alerts)
    notification_service.dart - Notification preferences & web notification delivery
    notification_service_web.dart - Web Notifications API bridge (dart:js_interop)
    mock_data.dart       - Covey quotes (static content)
    local_storage_service.dart - SharedPreferences wrapper for session persistence
  screens/
    login_screen.dart    - Email/password login via API
    register_screen.dart - Account registration via API
    verify_email_screen.dart - 6-digit email verification (future use)
    main_shell.dart      - Main app shell with bottom nav + drawer + trust score
    home_screen.dart     - Dashboard: Trust Score, Covey quote, active requests from API
    network_screen.dart  - Interactive network node map from API data
    roster_screen.dart   - List view of network peers from API
    alerts_screen.dart   - Filterable alerts from API (All/Requests/System)
    notifications_screen.dart - Notification settings: enable/disable, task filters, time picker, test
    settings_screen.dart - Profile editing, privacy toggles, app settings
    configure_screen.dart - App configuration: privacy toggles, dark mode, notifications toggle
    personal_info_screen.dart - Profile editing: name, email, title/department
    reports_screen.dart  - Trust reports: score summary, request breakdown, network size
    request_detail_screen.dart - Full request detail view with back navigation
  widgets/
    request_card.dart    - Tappable request card with status dot and navigation

backend/
  Cargo.toml             - Rust dependencies
  src/
    main.rs              - Server entry point, route configuration
    models.rs            - Database models, API request/response types
    db.rs                - Table creation, demo data seeding
    auth.rs              - Register, login, session management
    requests.rs          - CRUD for trust requests
    trust.rs             - Trust score computation, network peers
    alerts.rs            - Alert listing, mark-as-read
```

## API Endpoints
- POST `/api/auth/register` - Create account (username, email, password)
- POST `/api/auth/login` - Login (email, password) -> token + user
- GET `/api/auth/me` - Current user info (requires Bearer token)
- GET `/api/requests` - List user's requests (sorted by urgency)
- POST `/api/requests` - Create new request
- GET `/api/requests/{id}` - Get request detail
- PUT `/api/requests/{id}/status` - Update request status
- GET `/api/trust-score` - Get user's trust score
- POST `/api/trust-score/recalculate` - Recalculate trust score
- GET `/api/network` - List network peers
- GET `/api/alerts` - List alerts (optional ?filter=request|system)
- PUT `/api/alerts/{id}/read` - Mark alert as read

## Navigation Flow
- Login Screen -> API auth -> Main Shell
- Register Screen -> API register -> Main Shell
- Main Shell: Bottom nav (Home, Network, Roster, Alerts) + Hamburger drawer menu
- Drawer: Navigate to tabs (Home, Network, Roster, Alerts), Configure, Personal Info, Reports, Notifications, or Sign Out
- Home -> Tap request card -> Request Detail Screen -> Back button returns to Home

## Running the App
Two workflows run simultaneously:
1. **Rust Backend**: `cargo build && cargo run` on port 3001 (API server)
2. **Flutter Web App**: `flutter build web --release --pwa-strategy=none && dart run serve_web.dart` on port 5000

The Dart web server proxies `/api/*` requests to the Rust backend on port 3001.

## Demo Account
- Email: demo@trustos.app
- Password: demo1234

## Key Design Decisions
- Mobile-first design matching Figma wireframes
- Single Scaffold pattern with MainShell managing AppBar and Drawer for all tabs
- InteractiveViewer for network map zoom/pan
- Color-coded request statuses: Blue (Fair), Yellow (Stalled), Red (Critical)
- Trust Score badge in Home AppBar showing EB points and health status
- API proxy pattern: Dart server on port 5000 forwards /api/* to Rust on 3001
- Trust score computation: weighted algorithm (completed +20, stalled -15, critical -30, interactions +1.5, peers +10)

## Dependencies
### Flutter
- `http` - HTTP client for API calls
- `shared_preferences` - Local storage for session & notification preferences
- `flutter_local_notifications` - Notification support (web uses Web Notifications API)
- `cupertino_icons` - iOS-style icons

### Rust Backend
- `actix-web` + `actix-cors` - HTTP server with CORS
- `sqlx` - Async PostgreSQL driver
- `bcrypt` - Password hashing
- `uuid` + `chrono` - ID generation and timestamps
- `serde` + `serde_json` - JSON serialization
- `regex` - Email validation

## Evidence Screenshots
- `module-2-wireframe-design-mockups/login_screen_evidence.png` - Login screen with form validation
- `module-2-wireframe-design-mockups/signup_screen_evidence.png` - Signup/register screen with validation
- `module-2-wireframe-design-mockups/home-screen-evidence.png` - Home dashboard with trust score, requests
- `module-2-wireframe-design-mockups/evidence-detail-navigation.jpg` - Navigation evidence

## Recent Changes
- 2026-03-01: Added Configure, Personal Info, and Reports screens to drawer menu
- 2026-03-01: Drawer menu now has: Home, Network, Roster, Alerts | Configure, Personal Info, Reports, Notifications, Sign Out
- 2026-02-25: Added NotificationsScreen with enable/disable toggle, task type filters, time picker, test notification button
- 2026-02-25: Created NotificationService with Web Notifications API support and SharedPreferences persistence
- 2026-02-25: Added "Notifications" item to drawer menu in MainShell
- 2026-02-25: Disabled PWA service worker (--pwa-strategy=none) to prevent caching issues
- 2026-02-23: Added local storage (SharedPreferences) for persisting user session and details
- 2026-02-23: ApiService now saves/restores session to/from local storage on login/register/logout
- 2026-02-23: Created module-2-wireframe-design-mockups/ folder with evidence screenshots
- 2026-02-23: Added CreateRequestScreen with title, description, urgency picker, and peer assignment
- 2026-02-23: FAB and "Clarify Expectations" button on Home screen navigate to create request form
- 2026-02-23: Backend supports initial status on request creation (fair/stalled/critical)
- 2026-02-22: Phase 2 complete - Rust backend with full REST API
- 2026-02-22: API proxy in serve_web.dart forwards /api/* to Rust backend
- 2026-02-22: Created ApiService singleton for Flutter API integration
- 2026-02-22: Updated all models with fromJson factory constructors
- 2026-02-22: Wired all screens (login, register, home, network, roster, alerts, settings) to API
- 2026-02-22: Added sign-out functionality in drawer menu
- 2026-02-22: Trust score fetched from API and displayed dynamically
- 2026-02-22: Pull-to-refresh on home, roster, and alerts screens
- 2026-02-22: Demo data seeded automatically on backend startup
