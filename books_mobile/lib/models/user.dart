/// Modelo de usuario representando la información devuelta por la API.
/// Compatible con Laravel Sanctum y con la estructura de tu backend.
class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String? emailVerificado;
  final String? token;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    this.emailVerificado,
    this.token,
  });

  /// Crea un usuario desde un JSON recibido de la API.
  factory Usuario.desdeJson(Map<String, dynamic> json, {String? token}) {
    return Usuario(
      id: json["id"],
      nombre: json["name"],
      correo: json["email"],
      emailVerificado: json["email_verified_at"],
      token: token,
    );
  }
}
