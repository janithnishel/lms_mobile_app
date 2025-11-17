import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final String? Function(String?)? validator;

  // Custom State/Validation Props
  final String? errorText;
  final String? successText;

  // 🔑 NEW: Property for a separate, custom validation indicator (like Username status)
  final String? customIndicatorText;
  final Color? customIndicatorColor; // Color for the custom indicator

  final String? strengthIndicator;
  final Color? strengthColor;
  final bool showSuccess;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.validator,
    this.errorText,
    this.successText,

    // 🔑 NEW: Add new properties to the constructor
    this.customIndicatorText,
    this.customIndicatorColor,

    this.strengthIndicator,
    this.strengthColor,
    this.showSuccess = false,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final bool isObscured = widget.isPassword && _obscureText;

    // --- Determine Border Color ---
    Color borderColor = const Color(0xFFE5E7EB);
    Color focusedColor = const Color(0xFF10B981);

    // Priority 1: Custom Indicator Color (for fields like Username)
    if (widget.customIndicatorText != null &&
        widget.customIndicatorColor != null) {
      focusedColor = widget.customIndicatorColor!;
      borderColor = widget.customIndicatorColor!;
    }
    // Priority 2: Password Strength Color
    else if (widget.strengthIndicator != null) {
      focusedColor = widget.strengthColor ?? focusedColor;
    }

    // Priority 3: Error state (Highest priority, overrides everything)
    if (widget.errorText != null) {
      borderColor = const Color(0xFFEF4444); // Red 500
      focusedColor = const Color(0xFFEF4444);
    }
    // Priority 4: Default Success
    else if (widget.showSuccess) {
      borderColor = const Color(0xFF10B981);
      focusedColor = const Color(0xFF10B981);
    }

    // --- Suffix Icon Logic ---
    Widget? buildSuffixIcon() {
      List<Widget> icons = [];

      // 1. Password Visibility Toggle
      if (widget.isPassword) {
        icons.add(
          IconButton(
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        );
      }

      // 2. Custom Suffix Icon
      if (widget.suffixIcon != null) {
        icons.insert(0, widget.suffixIcon!);
      }

      // 3. Success Checkmark (only if default showSuccess is true AND NO custom indicator text)
      if (widget.showSuccess &&
          widget.errorText == null &&
          !widget.isPassword &&
          widget.suffixIcon == null &&
          widget.customIndicatorText == null) {
        icons.add(const Icon(Icons.check_circle, color: Color(0xFF10B981)));
      }

      if (icons.isEmpty) return null;

      if (icons.length > 1) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(mainAxisSize: MainAxisSize.min, children: icons),
        );
      }

      return icons.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Label Section ---
        Row(
          children: [
            Icon(
              widget.icon,
              size: 18,
              // Icon color logic updated to use customIndicatorColor
              color: widget.errorText != null
                  ? focusedColor
                  : (widget.customIndicatorColor ??
                        widget.strengthColor ??
                        focusedColor),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // --- Input Field ---
        TextFormField(
          controller: widget.controller,
          obscureText: isObscured,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: const TextStyle(fontSize: 15, color: Color(0xFF374151)),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),

            suffixIcon: buildSuffixIcon(),

            // --- Borders ---
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: focusedColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
          ),
        ),

        // --- Custom Error/Success/Strength Indicators ---

        // 1. Error Message (Highest priority)
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 4),
              Text(
                widget.errorText!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ],

        // 2. Custom Indicator (Only show if NO error and NO default success text exists)
        if (widget.errorText == null &&
            widget.customIndicatorText != null &&
            widget.successText == null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                widget.customIndicatorText!.toLowerCase().contains('available')
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                size: 16,
                color:
                    widget.customIndicatorColor ??
                    const Color(0xFF10B981), // Use provided color
              ),
              const SizedBox(width: 4),
              Text(
                widget.customIndicatorText!,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.customIndicatorColor ?? const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],

        // 3. General Success text (Only show if NO error OR custom indicator exists)
        if (widget.errorText == null &&
            widget.successText != null &&
            widget.customIndicatorText == null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 4),
              Text(
                widget.successText!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF10B981)),
              ),
            ],
          ),
        ],

        // 4. Password Strength Indicator
        if (widget.strengthIndicator != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.strengthColor ?? focusedColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.strengthIndicator!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.strengthColor ?? focusedColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
