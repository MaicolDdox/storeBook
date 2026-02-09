# books_mobile

Flutter mobile client for StoreBook.

## API configuration

By default:
- Android emulator uses `http://10.0.2.2:8000/api`
- iOS/macOS/Windows/Linux use `http://127.0.0.1:8000/api`

You can override the API URL at runtime:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

Use this override when running on a physical device.
