import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  const ElevatedButtonWidget({
    super.key,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final double width;
  final double height;
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        label: Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        icon: Icon(icon),
      ),
    );
  }
}