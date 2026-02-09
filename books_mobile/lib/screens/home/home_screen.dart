import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/api_service.dart';
import '../../models/user.dart';

/// Pantalla principal del usuario.
/// Esta pantalla funciona como la sección "Inicio" dentro del NavigationMenu.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Usuario? usuario;
  bool cargandoUsuario = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  /// Obtiene el usuario autenticado desde la API (/me).
  Future<void> _cargarUsuario() async {
    final api = ApiService();
    final datos = await api.obtenerUsuarioActual();

    setState(() {
      if (datos != null) {
        usuario = Usuario.desdeJson(datos);
      }
      cargandoUsuario = false;
    });
  }

  /// Cierra sesión y regresa al login.
  Future<void> _logout() async {
    final api = ApiService();
    await api.logout();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: Text(
          cargandoUsuario ? "Cargando..." : "Hola, ${usuario?.nombre}",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == "logout") _logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "logout",
                child: Text(
                  "Cerrar sesión",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Colors.blueAccent,
                  size: 28,
                ),
              ),
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenido a Books Store",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              "Explora nuestro catálogo, agrega libros al carrito y realiza tus compras fácilmente.",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¿Qué deseas hacer hoy?",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _opcionRapida(
                        icono: Icons.book,
                        titulo: "Ver catálogo",
                        onTap: () {
                          // Cambia al TAB 1 (Catálogo)
                          Navigator.pushNamed(context, "/home");
                        },
                      ),
                      _opcionRapida(
                        icono: Icons.shopping_cart,
                        titulo: "Ver carrito",
                        onTap: () {
                          Navigator.pushNamed(context, "/home");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcionRapida({
    required IconData icono,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blueAccent.withOpacity(0.15),
            child: Icon(
              icono,
              color: Colors.blueAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
