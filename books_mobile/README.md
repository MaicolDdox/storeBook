# books_mobile

Flutter mobile client for StoreBook.

## API configuration

Default compile-time base URL:
- `http://192.168.20.55:8000`

Flutter derives API prefix automatically:
- `${apiBaseUrl}/api`

You can override the API URL at runtime:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Use host-only URLs (no `/api` suffix) for overrides.
