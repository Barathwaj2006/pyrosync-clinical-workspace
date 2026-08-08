import '../models/cdss_models.dart';

class DoctorReviewEngine {
  DoctorReview initializeReview({
    required String reportId,
    required String doctorId,
    required String doctorName,
    required String initialNotes,
  }) {
    return DoctorReview(
      reportId: reportId,
      doctorId: doctorId,
      doctorName: doctorName,
      state: DoctorReviewState.underReview,
      doctorNotes: initialNotes,
    );
  }

  DoctorReview updateDoctorNotes(DoctorReview currentReview, String newNotes) {
    return DoctorReview(
      reportId: currentReview.reportId,
      doctorId: currentReview.doctorId,
      doctorName: currentReview.doctorName,
      state: DoctorReviewState.edited,
      doctorNotes: newNotes,
    );
  }

  FinalReport approveAndLockReport({
    required DraftReport draftReport,
    required DoctorReview doctorReview,
  }) {
    final approvedReview = DoctorReview(
      reportId: doctorReview.reportId,
      doctorId: doctorReview.doctorId,
      doctorName: doctorReview.doctorName,
      state: DoctorReviewState.locked,
      doctorNotes: doctorReview.doctorNotes,
      approvalTimestamp: DateTime.now(),
    );

    final signatureData = '${draftReport.id}_${doctorReview.doctorId}_${approvedReview.approvalTimestamp?.toIso8601String()}';
    final signatureHash = 'SIG-SHA256-${signatureData.hashCode.abs().toRadixString(16).toUpperCase()}';

    return FinalReport(
      reportId: draftReport.id,
      draftReport: draftReport,
      doctorReview: approvedReview,
      isLocked: true,
      digitalSignatureHash: signatureHash,
    );
  }
}
