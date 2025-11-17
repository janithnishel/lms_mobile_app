// lib/models/exam_paper_card_model.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms_app/models/exam_paper_model.dart'; // Core Model එක Import කරයි

// -------------------------------------------------------------------------
// ExamPaperCardModel - UI Display Model (Assignments Card)
// -------------------------------------------------------------------------
class ExamPaperCardModel {
  final String id; 
  final String title;
  final String description;
  final int totalQuestions;
  final int timeLimitMinutes; 
  final String dueDateDisplay; 
  final String timeLeftDisplay; 
  final Color timeLeftColor; 
  final bool isAvailableToStart; 
  final bool isCompleted; 
  final String? studentScorePercentage; 
  final String? studentStatus; 

  const ExamPaperCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.totalQuestions,
    required this.timeLimitMinutes,
    required this.dueDateDisplay,
    required this.timeLeftDisplay,
    required this.timeLeftColor,
    required this.isAvailableToStart,
    required this.isCompleted,
    this.studentScorePercentage,
    this.studentStatus,
  });

  factory ExamPaperCardModel.fromApiPaper(
    ExamPaperModel paper, 
    Map<String, dynamic>? studentAttempt, 
  ) {
    // 1. Status Calculations 
    final bool isCompleted = studentAttempt?['status'] == 'submitted';
    final bool isStarted = studentAttempt?['status'] == 'started';
    final String status = studentAttempt?['status'] as String? ?? 'not_started';
    final String? score = studentAttempt?['scorePercentage'] as String?;
    
    final bool isOverdue = paper.deadline.isBefore(DateTime.now()) && !isCompleted;
    final bool isAvailableForAction = !isCompleted && !isOverdue; 

    // 2. Date & Time Calculations
    final String dueDateDisplay = DateFormat('dd MMM yyyy').format(paper.deadline);
    
    String timeLeftDisplay;
    Color timeLeftColor;
    
    if (isCompleted) {
        timeLeftDisplay = 'Completed';
        timeLeftColor = Colors.green;
    } else if (isOverdue) {
        timeLeftDisplay = 'Overdue';
        timeLeftColor = Colors.red;
    } else {
        final Duration remaining = paper.deadline.difference(DateTime.now());
        
        if (remaining.inDays > 1) {
            timeLeftDisplay = '${remaining.inDays} Days Left';
            timeLeftColor = Colors.blue;
        } else if (remaining.inHours > 1) {
            timeLeftDisplay = '${remaining.inHours} Hours Left';
            timeLeftColor = Colors.orange;
        } else {
            timeLeftDisplay = 'Less than 1 Hour!';
            timeLeftColor = Colors.red;
        }
    }

    // 3. Return the Final Display Model
    return ExamPaperCardModel(
      id: paper.id,
      title: paper.title,
      description: paper.description ?? 'No description provided.',
      totalQuestions: paper.totalQuestions,
      timeLimitMinutes: paper.timeLimitMinutes,
      
      dueDateDisplay: dueDateDisplay,
      timeLeftDisplay: timeLeftDisplay,
      timeLeftColor: timeLeftColor,
      
      isAvailableToStart: isAvailableForAction || isStarted,
      isCompleted: isCompleted,
      
      studentScorePercentage: score,
      studentStatus: status,
    );
  }
}