<p align="center">
    <a href="https://github.com/MaicolDdox" target="_blank">
      <img src="docs/assets/app_icon.png" width="260" alt="StoreBook Logo">
    </a>
</p>

[![GitHub](https://img.shields.io/badge/GitHub-MaicolDdox-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/MaicolDdox)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/maicol-duvan-gasca-rodas-4483923a4/?trk=public-profile-join-page)
[![Instagram](https://img.shields.io/badge/Instagram-@maicolddox__-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/maicolddox_?utm_source=qr&igsh=cTV6enRlMW05bjY3)
[![Discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discordapp.com/users/1425631850453270543)
[![Facebook](https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white)](https://www.facebook.com/profile.php?id=61586710675179&sk=about_contact_and_basic_info)

<div align="center">
  <h1>StoreBook</h1>
  <p>Virtual library and online bookstore with an admin panel to manage catalog and operations, and a client flow to browse books, manage cart, and place orders. Includes a Vue web app, a Flutter mobile app, and a Laravel 12 API.</p>
</div>

---

## Monorepo Overview

- `BackendApi/`: Laravel 12 REST API (Sanctum auth, roles, policies, admin metrics, catalog, cart, orders).
- `frontend/`: Vue 3 web application (Vite + Tailwind) with admin and client modules.
- `books_mobile/`: Flutter mobile application for client and admin flows.
- `docs/`: Repository documentation assets only (`docs/assets/*`).
- `openapi.yaml`: OpenAPI 3.1 specification for endpoints, authentication, and schemas.

## Requirements

- PHP `8.2+` (recommended `8.3`)
- Composer `2.x`
- Node.js `20+`
- npm `10+` (or pnpm if preferred)
- Flutter SDK (stable) with Dart `3.x`
- Android Studio (for emulator, SDK tools, APK installation)
- MySQL or compatible database for Laravel

Network note for APK testing on a physical phone:
- Phone and development PC must be on the same Wi-Fi.
- Use a LAN API URL such as `http://<LAN_IP>:8000` instead of `localhost` or `127.0.0.1`.

## Backend Setup (`BackendApi`)

```bash
cd BackendApi
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
```

Set environment values in `.env` before running:
- `APP_URL=http://<LAN_IP_OR_HOST>:8000`
- Database credentials (`DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`)
- CORS allowed origins for web clients

Run backend server for LAN access:

```bash
php artisan serve --host 0.0.0.0 --port 8000
```

Roles and auth notes:
- A default admin user is created by seeders.
- New registered users are assigned `client` role automatically.

Troubleshooting:
- If web calls fail, verify CORS configuration in `BackendApi/config/cors.php`.
- If phone calls fail, allow inbound TCP port `8000` in Windows Firewall.

## Vue Frontend Setup (`frontend`)

```bash
cd frontend
npm install
```

Create or update `.env` values:
- `VITE_API_BASE_URL=http://<API_HOST>:8000/api`
- `VITE_API_ORIGIN=http://<API_HOST>:8000`

Run and build:

```bash
npm run dev
npm run build
```

Auth behavior:
- Vue stores Sanctum bearer token and attaches it through Axios interceptors.
- `/admin` requires authenticated user with `admin` role.
- `/app` is the client area.

Testing admin vs client:
- Sign in with seeded admin account to access admin dashboard and CRUD flows.
- Register a new user to validate client-only access and role restrictions.

## Flutter Mobile Setup (`books_mobile`)

```bash
cd books_mobile
flutter pub get
```

Run app with configurable API base URL:

```bash
flutter run --dart-define=API_BASE_URL=http://<LAN_IP>:8000
```

Build release APK:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://<LAN_IP>:8000
```

APK output:
- `books_mobile/build/app/outputs/flutter-apk/app-release.apk`

Install on Android:
- Transfer `app-release.apk` to the phone and install it.
- Ensure Android allows installing apps from your file source.

HTTP note:
- If running HTTP (not HTTPS), Android network security/cleartext settings must allow your development host.

## End-to-End System Test

1. Start backend API (`php artisan serve --host 0.0.0.0 --port 8000`).
2. Start Vue web app (`npm run dev` in `frontend`).
3. Start Flutter app (`flutter run ...`) or install generated APK.
4. Register/login as client and validate catalog, cart, checkout, and order history.
5. Login as admin and validate categories, books, types/genres, orders, and dashboard charts.
6. Confirm image uploads and cover rendering in both web and mobile clients.

## API Documentation (`openapi.yaml`)

`openapi.yaml` is an OpenAPI 3.1 specification that documents:
- Endpoint paths and operations
- Authentication requirements (Bearer token)
- Request/response schemas and common envelopes

Server host guidance:
- `servers.url` uses a host variable in `openapi.yaml`.
- Set `host` depending on runtime:
  - `localhost` or `127.0.0.1` for local web
  - `10.0.2.2` for Android emulator
  - `<LAN_IP>` for physical device testing

How to use:
- Swagger UI (local): load `openapi.yaml` in a local Swagger UI instance.
- VS Code: use Swagger/OpenAPI preview extensions to render the spec directly.
- Postman or Insomnia: import `openapi.yaml` as an API definition.

## Keep `docs/` Clean

- `docs/` contains only assets in `docs/assets/`.
- Documentation files are centralized at the repository root to avoid duplicate README files.
- Main logo path for repository documentation is `docs/assets/app_icon.png`.

## Repository Naming Note

The canonical backend folder in this repository is `BackendApi/`.
If older references mention `BaackendApi`, treat it as a typo and use `BackendApi/` in scripts, docs, and commands.
