import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed; 
  // Correction: Make Widget nullable (as Widget?).
  final Widget? child; 

  const PrimaryButton({
    Key? key,
    required this.onPressed,
    this.child, // required ඉවත් කර ඇත
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, 
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      // child එක null නම්, හිස් SizedBox එකක් දමන්න.
      child: child ?? const SizedBox(), 
    );
  }
}