class PatientModel {
  final String id;
  final String mrn;
  final String name;
  final String dob;
  final String gender;
  final String lastTestDate;
  final String protocol;
  final String status;
  final double p100Latency;
  final double p100Amplitude;

  PatientModel({
    required this.id,
    required this.mrn,
    required this.name,
    required this.dob,
    required this.gender,
    required this.lastTestDate,
    required this.protocol,
    required this.status,
    required this.p100Latency,
    required this.p100Amplitude,
  });
}
