/// Serializable state for the draft complaint wizard, returned when leaving
/// [GeneratedComplaintScreen] so the form can be restored (Edit / back).
class DraftComplaintFormData {
  const DraftComplaintFormData({
    required this.currentStep,
    required this.fullName,
    required this.cnic,
    required this.phone,
    required this.email,
    required this.designation,
    required this.workplace,
    required this.address,
    required this.dateOfIncident,
    required this.description,
    required this.evidence,
    required this.witnesses,
    required this.mentalImpact,
    required this.emotionalImpact,
    required this.safetyConcerns,
    required this.reliefSought,
  });

  final int currentStep;
  final String fullName;
  final String cnic;
  final String phone;
  final String email;
  final String designation;
  final String workplace;
  final String address;
  final String dateOfIncident;
  final String description;
  final String evidence;
  final String witnesses;
  final String mentalImpact;
  final String emotionalImpact;
  final String safetyConcerns;
  final List<String> reliefSought;
}
