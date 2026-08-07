import '../models/cdss_models.dart';

class CdssAuditEngine {
  final List<AuditRecord> _auditLogQueue = [];

  List<AuditRecord> get auditLogs => List.unmodifiable(_auditLogQueue);

  void recordAudit({
    required String actionType,
    required String performerId,
    required String performerName,
    required String details,
    String ruleVersion = 'v1.2-BiomedicalRules',
    String pipelineVersion = 'v1.0-DSPPipeline',
  }) {
    final record = AuditRecord(
      auditId: 'AUD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      actionType: actionType,
      performerId: performerId,
      performerName: performerName,
      details: details,
      ruleVersion: ruleVersion,
      pipelineVersion: pipelineVersion,
      timestamp: DateTime.now(),
    );

    _auditLogQueue.add(record);
  }
}
