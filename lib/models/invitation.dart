class Invitation {
  final String id;
  final String invitationCode;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isUsed;

  const Invitation({
    required this.id,
    required this.invitationCode,
    required this.createdAt,
    required this.expiresAt,
    required this.isUsed,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
        id: json['id'] as String,
        invitationCode: json['invitationCode'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String),
        isUsed: json['isUsed'] as bool,
      );
}
