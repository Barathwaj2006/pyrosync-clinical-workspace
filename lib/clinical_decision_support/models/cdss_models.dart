import 'dart:core';

enum RuleSeverity { pass, warning, fail }

enum ReportTemplateType { doctorReport, patientReport, researchReport, hospitalReport }

enum DoctorReviewState { draft, underReview, edited, approved, locked }

class ClinicalEvidence {
  final String metricName;
  final double value;
  final String unit;
  final String sourceModule;
  final double confidenceScore;
  final DateTime timestamp;

  ClinicalEvidence({
    required this.metricName,
    required this.value,
    required this.unit,
    required this.sourceModule,
    required this.confidenceScore,
    required this.timestamp,
  });
}

class Explanation {
  final String why;
  final String generatingModule;
  final List<ClinicalEvidence> supportingEvidence;
  final String triggeredThreshold;
  final String suggestedDoctorAction;

  Explanation({
    required this.why,
    required this.generatingModule,
    required this.supportingEvidence,
    required this.triggeredThreshold,
    required this.suggestedDoctorAction,
  });
}

class Recommendation {
  final String id;
  final String title;
  final String description;
  final RuleSeverity severity;
  final String suggestedAction;
  final Explanation explanation;

  Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.suggestedAction,
    required this.explanation,
  });
}

class ConfidenceReport {
  final double signalQualityConfidence;
  final double featureExtractionConfidence;
  final double artifactDetectionConfidence;
  final double peakDetectionConfidence;
  final double overallRecordingConfidence;
  final double overallReportConfidence;

  ConfidenceReport({
    required this.signalQualityConfidence,
    required this.featureExtractionConfidence,
    required this.artifactDetectionConfidence,
    required this.peakDetectionConfidence,
    required this.overallRecordingConfidence,
    required this.overallReportConfidence,
  });
}

class DraftReport {
  final String id;
  final ReportTemplateType templateType;
  final String title;
  final String patientId;
  final String patientName;
  final String contentBody;
  final List<Recommendation> cdssRecommendations;
  final ConfidenceReport confidenceReport;
  final DateTime generatedTimestamp;

  DraftReport({
    required this.id,
    required this.templateType,
    required this.title,
    required this.patientId,
    required this.patientName,
    required this.contentBody,
    required this.cdssRecommendations,
    required this.confidenceReport,
    required this.generatedTimestamp,
  });
}

class DoctorReview {
  final String reportId;
  final String doctorId;
  final String doctorName;
  final DoctorReviewState state;
  final String doctorNotes;
  final DateTime? approvalTimestamp;

  DoctorReview({
    required this.reportId,
    required this.doctorId,
    required this.doctorName,
    required this.state,
    required this.doctorNotes,
    this.approvalTimestamp,
  });
}

class FinalReport {
  final String reportId;
  final DraftReport draftReport;
  final DoctorReview doctorReview;
  final bool isLocked;
  final String digitalSignatureHash;

  FinalReport({
    required this.reportId,
    required this.draftReport,
    required this.doctorReview,
    required this.isLocked,
    required this.digitalSignatureHash,
  });
}

class AuditRecord {
  final String auditId;
  final String actionType;
  final String performerId;
  final String performerName;
  final String details;
  final String ruleVersion;
  final String pipelineVersion;
  final DateTime timestamp;

  AuditRecord({
    required this.auditId,
    required this.actionType,
    required this.performerId,
    required this.performerName,
    required this.details,
    required this.ruleVersion,
    required this.pipelineVersion,
    required this.timestamp,
  });
}
