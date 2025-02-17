import 'package:flutter/material.dart';

class CustomIconButton extends StatefulWidget {
  final VoidCallback? onTap; // Acción al soltar el botón
  final VoidCallback? onTapDown; // Acción al presionar el botón
  final VoidCallback? onTapUp; // Acción al levantar el botón
  final String imagePath; // Ruta de la imagen del botón
  final double size; // Tamaño del botón
  final bool isDisabled; // Condición para deshabilitar el botón

  const CustomIconButton({
    super.key,
    required this.onTap,
    this.onTapDown,
    this.onTapUp,
    required this.imagePath,
    this.size = 40.0, // Valor por defecto para el tamaño
    this.isDisabled = false, // Condición por defecto que no está deshabilitado
  });

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  double scaleFactor = 1.0; // Factor de escala para la animación

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: widget.isDisabled,
      // Deshabilita el botón si isDisabled es true
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            scaleFactor = 0.9; // Escala al presionar
          });
          if (widget.onTapDown != null) {
            widget
                .onTapDown!(); // Llama a la acción de onTapDown si está definida
          }
        },
        onTapUp: (_) {
          setState(() {
            scaleFactor = 1.0; // Regresa a la escala normal al soltar
          });
          if (widget.onTapUp != null) {
            widget.onTapUp!(); // Llama a la acción de onTapUp si está definida
          }
        },
        onTap: widget.onTap, // Llama a la acción de onTap
        child: AnimatedScale(
          scale: scaleFactor,
          duration: const Duration(milliseconds: 100),
          child: Center(
            child: Image.asset(
              widget.imagePath, // Imagen que se pasa al widget
              height: widget.size,
              width: widget.size,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}