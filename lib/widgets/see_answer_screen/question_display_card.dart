import 'package:flutter/material.dart';
import 'package:lms_app/widgets/see_answer_screen/answer_option.dart';

class QuestionDisplayCard extends StatelessWidget {
  final int questionIndex;
  final String questionText;
  final String? imageUrl;
  final List<dynamic> options;
  final int correctAnswerIndex;
  final int userAnswerIndex;
  final String? explanation;
  final String? visualExplanationUrl;

  const QuestionDisplayCard({
    super.key,
    required this.questionIndex,
    required this.questionText,
    this.imageUrl,
    this.explanation,
    this.visualExplanationUrl,
    required this.options,
    required this.correctAnswerIndex,
    required this.userAnswerIndex,
  });

  // ⚠️ IMPORTANT: Set your server's base URL here!
  static final String _imageBaseUrl = 'http://10.0.2.2:5000';

  // Normalize image paths returned by the server (same logic as quiz screen)
  // Handles cases where the API returns:
  // - absolute URLs (http...)
  // - "/api/uploads/..." (already correct)
  // - "/uploads/..." (replace -> "/api/uploads/...")
  // - "/paper-options/..." or "/explanations/..." (prefix with "/api/uploads")
  // - relative paths without leading slash
  String _normalizeImageUrl(String raw) {
    if (raw.isEmpty) return '';
    // Already absolute
    if (raw.startsWith('http')) return raw;

    String path = raw;

    if (path.startsWith('/api/uploads')) {
      return '$_imageBaseUrl$path';
    }

    if (path.startsWith('/uploads')) {
      // Replace leading /uploads with /api/uploads
      path = path.replaceFirst('/uploads', '/api/uploads');
      return '$_imageBaseUrl$path';
    }

    // If path starts with '/' but not /uploads or /api/uploads -> prefix /api/uploads
    if (path.startsWith('/')) {
      return '$_imageBaseUrl/api/uploads$path';
    }

    // No leading slash -> assume it's a relative path under uploads
    return '$_imageBaseUrl/api/uploads/$path';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${questionIndex + 1}', // Dynamic Question Number
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Question ${questionIndex + 1}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                // Explanation indicator for current question
                if (explanation != null && explanation!.isNotEmpty || visualExplanationUrl != null && visualExplanationUrl!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 14,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Has Explanation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Question Text
            Text(
              questionText, // Dynamic Question Text
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              // Question Image (Same logic as quiz screen)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Builder(builder: (context) {
                  // Use the same normalization logic as quiz screen
                  final String finalImageUrl = _normalizeImageUrl(imageUrl!);

                  if (finalImageUrl.isNotEmpty) {
                    print('DEBUG: Loading question image in see answers -> $finalImageUrl');
                  }

                  return Image.network(
                    finalImageUrl,
                    height: 150, // Reduced from 200 to 150 for better screen usage
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              'Image Error: ${error.toString()}',
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'URL: $finalImageUrl',
                              style: const TextStyle(color: Colors.black54, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),

            // Answer Options List
            ...options.asMap().entries.map((entry) {
              int index = entry.key;
              String optionText = entry.value as String;
              String label = String.fromCharCode('A'.codeUnitAt(0) + index);

              final bool isCorrect = index == correctAnswerIndex;
              // User answer is only highlighted as 'isUserAnswer' if it is NOT the correct answer
              final bool isUserAnswer = index == userAnswerIndex && index != correctAnswerIndex;

              return Column(
                children: [
                  AnswerOption(
                    label: label,
                    text: optionText,
                    isCorrect: isCorrect,
                    isUserAnswer: isUserAnswer,
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
