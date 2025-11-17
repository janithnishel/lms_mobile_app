import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  // Correction: Make Widget nullable (as Widget?).
  final Widget? child;

  const SecondaryButton({
    Key? key,
    required this.onPressed,
    this.child, // required ඉවත් කර ඇත
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // child එක null නම්, හිස් SizedBox එකක් දමන්න.
      child: child ?? const SizedBox(),
    );
  }
}