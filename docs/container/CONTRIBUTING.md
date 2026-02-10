# Contributing

## Scope
This repository contains three applications and shared API documentation:
- `BackendApi/` (Laravel 12 API)
- `frontend/` (Vue 3 web)
- `books_mobile/` (Flutter mobile)

## Workflow
1. Create a feature branch from `main`.
2. Keep changes focused and atomic.
3. Use English naming in code, comments, and documentation.
4. Do not introduce emojis in code, commits, or docs.

## Quality Checks
Run checks relevant to your changes before opening a PR.

Backend (`BackendApi`):
```bash
composer install
php artisan test
./vendor/bin/pint
```

Frontend (`frontend`):
```bash
npm install
npm run lint
npm run build
```

Mobile (`books_mobile`):
```bash
flutter pub get
flutter analyze
```

## Pull Request Guidelines
- Describe what changed and why.
- Include setup or migration notes if behavior changed.
- Add screenshots for UI updates when helpful.
- Link related issues or tasks.
