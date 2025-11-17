import 'package:flutter/material.dart';
import 'dart:io';

class IDCardUpload extends StatelessWidget {
  final String label;
  final String? imagePath; // Path of the selected image file
  final VoidCallback
  onTap; // Function that handles the tap event (for selecting image)
  final VoidCallback?
  onRemove; // NEW: Function to remove the selected image (clear state)

  const IDCardUpload({
    Key? key,
    required this.label,
    required this.onTap,
    this.imagePath,
    this.onRemove, // Added to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  // Checking if a selected image file exists
  final hasImage = imagePath != null && imagePath!.isNotEmpty;
  // Fixed height for displayed image to avoid unbounded layout issues
  final double imageHeight = 140.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with Icon
        Row(
          children: [
            const Icon(
              Icons.badge_outlined,
              size: 18,
              color: Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Upload Area (InkWell to handle tap)
        // Allow tapping even when an image exists so user can replace the image.
        // Use the small 'X' button to remove the current image.
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
    // When an image is present we give the container a fixed height
    // so that StackFit.expand doesn't receive unbounded (infinite)
    // height constraints when the parent is inside a scrollable.
    padding: hasImage ? const EdgeInsets.all(8) : const EdgeInsets.all(40),
    height: hasImage ? imageHeight : null,
    constraints: hasImage ? null : const BoxConstraints(minHeight: 150),
            decoration: BoxDecoration(
              color: hasImage ? Colors.white : const Color(0xFFF9FAFB),
              border: Border.all(
                color: hasImage
                    ? const Color(0xFF10B981) // Green Border if image exists
                    : const Color(0xFFE5E7EB),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: hasImage
                ? Stack(
                    // Use Stack to place the remove button on top of the image
                    fit: StackFit.expand,
                    children: [
                      // 1. The Image itself
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: double.infinity,
                          height: imageHeight,
                          child: Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Text(
                                'Image Loading Error',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 2. Remove Button (only visible if onRemove callback is provided)
                      if (onRemove != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: InkWell(
                            onTap:
                                onRemove, // This callback will clear the imagePath in the parent widget
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Color(
                                  0xFFEF4444,
                                ), // Red color for removal
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Column(
                    // Default Upload UI
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.upload_file,
                          color: Color(0xFF10B981),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Click to select ID Card Image',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PNG, JPG up to 5MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
