import 'package:flutter/material.dart';

class ExplanationExpansionTile extends StatelessWidget {
  final String? explanation;
  final String? visualExplanationUrl;

  const ExplanationExpansionTile({
    super.key,
    this.explanation,
    this.visualExplanationUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasExplanation = explanation != null && explanation!.isNotEmpty;
    final hasVisual =
        visualExplanationUrl != null && visualExplanationUrl!.isNotEmpty;

    // If no explanation data, hide the entire widget
    if (!hasExplanation && !hasVisual) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // Custom header design
          title: const Row(
            children: [
              Icon(Icons.menu_book, color: Color(0xFFE65100), size: 20),
              SizedBox(width: 10),
              Text(
                'Detailed Explanation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE65100), // Deep Orange
                ),
              ),
            ],
          ),
          subtitle: const Text(
            'Click to see the detailed explanation',
            style: TextStyle(fontSize: 12, color: Color(0xFFE65100)),
          ),

          children: [
            const Divider(height: 1, color: Color(0xFFE65100)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Explanation
                  if (hasExplanation) ...[
                    const Text(
                      'Explanation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      explanation!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    if (hasVisual) const SizedBox(height: 16),
                  ],

                  // Visual Explanation (Image)
                  // ... (Previous code remains the same)

                  // Visual Explanation (Image)
                  if (hasVisual) ...[
                    const Text(
                      'Visual Explanation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          visualExplanationUrl!,
                          height: 150,
                          fit: BoxFit.contain,
                          // 🛑 FIX START: Changed cumulativeProgress to cumulativeBytesLoaded
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          // 🛑 FIX END
                          errorBuilder: (context, error, stackTrace) =>
                              const Text(
                                'Image failed to load or URL is invalid.',
                              ),
                        ),
                      ),
                    ),
                  ],

                  // ... (Remaining code remains the same)
                  const SizedBox(height: 16),

                  // Footer info text
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This explanation helps you understand the reasoning behind the correct answer.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
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
}
