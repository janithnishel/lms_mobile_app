// lib/models/paper_intro_details.dart

import 'package:flutter/material.dart';
import 'package:lms_app/models/exam_paper_model.dart'; // Core Model එක Import කරයි

// ----------------------------------------------------------------------
// DetailCardModel (Reusable Component for Instructions)
// ----------------------------------------------------------------------
class DetailCardModel {
  final Color boxColor;
  final Color contentColor;
  final IconData icon;
  final String title;
  final String value;

  const DetailCardModel({
    required this.boxColor,
    required this.contentColor,
    required this.icon,
    required this.title,
    required this.value,
  });
}

// ----------------------------------------------------------------------
// PaperIntroDetails (Instructions Screen UI Display Model)
// ----------------------------------------------------------------------
class PaperIntroDetailsModel {
  final String paperId;
  final String paperTitle;
  final String? paperDescription;
  final int timeLimitMinutes;
  final List<DetailCardModel> detailCards;

  const PaperIntroDetailsModel({
    required this.paperId,
    required this.paperTitle,
    this.paperDescription,
    required this.timeLimitMinutes,
    required this.detailCards,
  });

  // Mapping Factory: ExamPaperModel එකෙන් Instructions Screen Data සාදයි
  factory PaperIntroDetailsModel.fromExamPaper(ExamPaperModel paper) {
    String formatDate(DateTime date) {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    final List<DetailCardModel> cards = [
      DetailCardModel(
        boxColor: const Color(0xFFEFF6FF),
        contentColor: const Color(0xFF2563EB),
        icon: Icons.subject_outlined,
        title: "Total Questions",
        value: "${paper.totalQuestions} Questions",
      ),
      DetailCardModel(
        boxColor: const Color(0xFFECFDF5),
        contentColor: const Color(0xFF059669),
        icon: Icons.timer,
        title: "Time Limit",
        value: "${paper.timeLimitMinutes} mins",
      ),
      DetailCardModel(
        boxColor: const Color(0xFFFFF7ED),
        contentColor: const Color(0xFFF97316),
        icon: Icons.calendar_today_outlined,
        title: "Due Date",
        value: formatDate(paper.deadline),
      ),
    ];

    return PaperIntroDetailsModel(
      paperId: paper.id,
      paperTitle: paper.title,
      paperDescription: paper.description,
      timeLimitMinutes: paper.timeLimitMinutes,
      detailCards: cards,
    );
  }
}