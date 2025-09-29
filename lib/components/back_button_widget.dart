import 'package:flutter/material.dart';

/// Botón de regreso circular estandarizado para toda la app
/// Diseño consistente: círculo gris oscuro con flecha blanca
class StandardBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const StandardBackButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C), // GRIS OSCURO LANDGO TRAVEL
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 18,
        ),
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}
