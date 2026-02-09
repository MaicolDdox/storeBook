import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../api/bill_service.dart';
import '../../api/shopping_cart_service.dart';
import '../../models/bill.dart';

/// Pantalla de pago simulado.
/// Solicita datos falsos de tarjeta y genera una factura en el backend.
class PagoScreen extends StatefulWidget {
  final int carritoIdReferencia;
  final int total;

  const PagoScreen({
    super.key,
    required this.carritoIdReferencia,
    required this.total,
  });

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  final FacturaService _facturaService = FacturaService();
  final CarritoService _carritoService = CarritoService();

  final TextEditingController numeroTarjetaController = TextEditingController();
  final TextEditingController nombreTitularController = TextEditingController();
  final TextEditingController fechaExpiracionController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  bool _procesandoPago = false;
  Factura? _facturaGenerada;

  bool _validarFormulario() {
    if (numeroTarjetaController.text.isEmpty ||
        nombreTitularController.text.isEmpty ||
        fechaExpiracionController.text.isEmpty ||
        cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor completa todos los campos."),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _procesarPago() async {
    if (!_validarFormulario()) return;

    setState(() {
      _procesandoPago = true;
    });

    final factura =
        await _facturaService.generarFacturaDesdeCarrito(widget.carritoIdReferencia);

    if (factura != null) {
      // Tras generar la factura, vaciamos el carrito en backend para reflejar el pago.
      try {
        await _carritoService.vaciarCarrito();
      } catch (_) {
        // No bloqueamos el flujo si falla limpiar un item.
      }
    }

    if (!mounted) return;

    setState(() {
      _procesandoPago = false;
      _facturaGenerada = factura;
    });

    if (factura == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo generar la factura."),
        ),
      );
      return;
    }

    final resultadoDialogo = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pago exitoso"),
        content: Text(
          "Factura generada con ID ${factura.id}.\nTotal pagado: \$${factura.total}.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Cerramos el dialogo y avisamos al caller que el pago se completo.
              Navigator.of(context).pop(true);
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );

    // Si el dialogo devolvio true, avisamos al carrito que debe recargar (estara vacio).
    if (resultadoDialogo == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    numeroTarjetaController.dispose();
    nombreTitularController.dispose();
    fechaExpiracionController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.total;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pago",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Resumen de pago",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total a pagar: \$${total}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Datos de la tarjeta (simulados)",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _CampoTexto(
              controller: numeroTarjetaController,
              label: "Numero de tarjeta",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _CampoTexto(
              controller: nombreTitularController,
              label: "Nombre del titular",
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CampoTexto(
                    controller: fechaExpiracionController,
                    label: "Fecha expiracion (MM/AA)",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CampoTexto(
                    controller: cvvController,
                    label: "CVV",
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _procesandoPago ? null : _procesarPago,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _procesandoPago
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2.4,
                        ),
                      )
                    : const Text(
                        "Pagar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  const _CampoTexto({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
