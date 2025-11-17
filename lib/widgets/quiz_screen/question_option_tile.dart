import 'package:flutter/material.dart';

class QuestionOptionTile extends StatelessWidget {
  final Map<String, dynamic> option;
  final String optionLabel; // The label (A, B, C, etc.)
  final bool isSelected;
  final void Function(String) onTap;
  
  // Base URL passed from QuestionScreen
  final String imageBaseUrl; 

  const QuestionOptionTile({
    Key? key,
    required this.option,
    required this.optionLabel, 
    required this.isSelected,
    required this.onTap,
    // Base URL එක Constructor එකට එකතු කිරීම
    required this.imageBaseUrl, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String optionId = option['id'] as String;
    final String optionDisplayText =
        option['optionText'] as String? ?? 'Option Text Missing';

    final String? optionImageUrl = option['optionImageUrl'] as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onTap(optionId),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Radio Button UI ---
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: isSelected ? Colors.blue : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12), 

              // --- 2. Option Label (A, B, C) ---
              Text(
                optionLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.blue : Colors.black87,
                ),
              ),
              const SizedBox(width: 12),

              // --- 3. Option Content (Image and Text) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼️ Option Image Display Logic
                    if (optionImageUrl != null && optionImageUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            // Normalize server-returned paths on the client so the
                            // app works even if the backend returns:
                            // "/paper-options/...", "/uploads/..." or already
                            // correct "/api/uploads/..." paths.
                            () {
                              final raw = optionImageUrl;
                              if (raw.startsWith('http')) return raw;
                              if (raw.startsWith('/api/uploads')) return '$imageBaseUrl$raw';
                              if (raw.startsWith('/uploads')) return '$imageBaseUrl' + raw.replaceFirst('/uploads', '/api/uploads');
                              if (raw.startsWith('/')) return '$imageBaseUrl/api/uploads$raw';
                              return '$imageBaseUrl/api/uploads/$raw';
                            }(),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            height: 120, 
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Text(
                                      'Image Error',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // 📝 Option Text
                    Text(
                      optionDisplayText,
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected ? Colors.black87 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}