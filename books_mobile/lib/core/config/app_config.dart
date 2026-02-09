class AppConfig {
  /// Cambia esta constante dependiendo del dispositivo donde estes probando.
  ///
  /// Para Flutter Desktop (Windows)
  static const String apiBaseUrl = "http://127.0.0.1:8000/api";

  /// Para Android Emulator
  // static const String apiBaseUrl = "http://10.0.2.2:8000/api";

  /// Para celular fisico
  // static const String apiBaseUrl = "http://192.168.X.X:8000/api";

  /// Host base sin el sufijo /api para construir rutas publicas (ej. imagenes).
  static String get baseHost {
    final uri = Uri.parse(apiBaseUrl);
    final host = "${uri.scheme}://${uri.host}${uri.hasPort ? ":${uri.port}" : ""}";
    return host;
  }

  /// El backend solo envia la ruta relativa de la imagen (ej. books/portada.jpg).
  /// Este helper compone la URL completa apuntando a /storage para que Flutter la pueda mostrar.
  static String? buildImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    final path = relativePath.startsWith("/") ? relativePath.substring(1) : relativePath;

    final lower = relativePath.toLowerCase();
    if (lower.startsWith("http://") || lower.startsWith("https://")) {
      return relativePath;
    }

    return "$baseHost/storage/$path";
  }
}
