import 'package:flutter/material.dart';
import '../catalogo/catalogo_screen.dart';
import '../carrito/carrito_screen.dart';
import '../pagos/pago_screen.dart';
import '../home/home_screen.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _index = 0;

  final List<Widget> _pantallas = const [
    HomeScreen(),        // saludo + perfil
    CatalogoScreen(),    // catálogo REAL
    CarritoScreen(),     // carrito
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Catálogo",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Carrito",
          ),
        ],
      ),
    );
  }
}
