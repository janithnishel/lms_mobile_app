import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_app/logic/structure_paper/structure_paper_cubit.dart';
import 'package:lms_app/logic/structure_paper/structure_paper_state.dart';
import 'package:lms_app/core/repositories/structure_paper_repository.dart';

class StructurePaperScreen extends StatefulWidget {
  final String? paperId;
  final Map<String, dynamic> paperData;

  const StructurePaperScreen({
    Key? key,
    this.paperId,
    required this.paperData,
  }) : super(key: key);

  @override
  State<StructurePaperScreen> createState() => _StructurePaperScreenState();
}

class _StructurePaperScreenState extends State<StructurePaperScreen> {
  String? _selectedFileUrl;
  String? _selectedFileName;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final paperId = widget.paperId ?? widget.paperData['paperId'] as String?;

    if (paperId == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Paper ID not provided')),
      );
    }

    return BlocProvider(
      create: (context) => StructurePaperCubit(
        paperId: paperId,
        repository: RepositoryProvider.of<StructurePaperRepository>(context),
      ),
      child: BlocConsumer<StructurePaperCubit, StructurePaperState>(
        listener: (context, state) {
          if (state is StructurePaperSubmissionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Answer submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(); // Go back to assignments screen
          } else if (state is StructurePaperFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isSubmitting = false;
            });
          }
        },
        builder: (context, state) {
          if (state is StructurePaperLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is StructurePaperLoaded) {
            return _buildLoadedContent(context, state);
          } else if (state is StructurePaperSubmissionLoading) {
            return _buildLoadedContent(context, state);
          } else if (state is StructurePaperFailure) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.error),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StructurePaperCubit>().retryLoad();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Scaffold(body: Center(child: Text('Unknown state')));
        },
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, dynamic state) {
    final paper = state is StructurePaperLoaded ? state.paper : null;
    if (paper == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          paper.title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back to Papers'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Info Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.article,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paper.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              paper.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.calendar_today,
                        'Due: ${paper.deadline?.toString().split(' ')[0] ?? 'No deadline'}'
                      ),
                      if (paper.timeLimitMinutes != null) ...[
                        const SizedBox(width: 12),
                        _buildInfoChip(Icons.timer, '${paper.timeLimitMinutes} Mins'),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            if (paper.hasSubmitted) ...[
              // Already Submitted Message
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'You have already submitted this paper.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You can review your answers or contact your teacher for feedback.',
                      style: TextStyle(color: Color(0xFF059669)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Instructions Card
              _buildCard(
                icon: Icons.info_outline,
                iconColor: const Color(0xFF2563EB),
                title: 'Instructions',
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Download the paper PDF below, answer all questions, and upload your completed answer sheet as a single PDF file. Make sure all pages are clearly visible.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              // Download Paper Card
              _buildCard(
                icon: Icons.file_download,
                iconColor: const Color(0xFF10B981),
                title: 'Download Paper',
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Click the button to download the paper PDF.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<StructurePaperCubit>().downloadPaper();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Downloading paper...')),
                          );
                        },
                        icon: const Icon(Icons.download, size: 20),
                        label: const Text(
                          'Download PDF',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Upload Answer Card
              _buildCard(
                icon: Icons.upload_file,
                iconColor: const Color(0xFFEF4444),
                title: 'Upload Your Answer',
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    if (_selectedFileUrl == null) ...[
                      const Text(
                        'Please select your completed answer sheet.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select Answer File',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'PDF files only, Max 10MB',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFileName ?? 'Selected file',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFileUrl = null;
                                  _selectedFileName = null;
                                });
                              },
                              icon: const Icon(Icons.close, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () async {
                          if (_selectedFileUrl == null) {
                            await _pickAnswerFile(context);
                          } else {
                            await _submitAnswer(context);
                          }
                        },
                        icon: _selectedFileUrl == null
                            ? const Icon(Icons.file_present, size: 20)
                            : (_isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white),
                                  )
                                : const Icon(Icons.send, size: 20)),
                        label: Text(
                          _selectedFileUrl == null
                              ? 'Choose File'
                              : (_isSubmitting ? 'Submitting...' : 'Submit Answer'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedFileUrl != null
                              ? const Color(0xFF2563EB)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _selectedFileUrl != null ? 2 : 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAnswerFile(BuildContext context) async {
    // TODO: Implement actual file picker
    // For demo, simulate file selection
    setState(() {
      _selectedFileUrl = 'mock_file_url.pdf';
      _selectedFileName = 'answer_sheet.pdf';
    });
  }

  Future<void> _submitAnswer(BuildContext context) async {
    if (_selectedFileUrl != null) {
      setState(() {
        _isSubmitting = true;
      });
      context.read<StructurePaperCubit>().submitAnswerFile(_selectedFileUrl!);
    }
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
