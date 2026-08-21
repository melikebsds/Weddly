import '../models/invitation.dart';
import 'api_client.dart';

class JoinResult {
  final String weddingSpaceId;
  final String weddingSpaceName;

  const JoinResult({required this.weddingSpaceId, required this.weddingSpaceName});

  factory JoinResult.fromJson(Map<String, dynamic> json) => JoinResult(
        weddingSpaceId: json['weddingSpaceId'] as String,
        weddingSpaceName: json['weddingSpaceName'] as String,
      );
}

class InvitationApiService {
  InvitationApiService(this._client);

  final ApiClient _client;

  Future<Invitation> create(String weddingSpaceId) async {
    final json = await _client.post('/wedding-spaces/$weddingSpaceId/invitations');
    return Invitation.fromJson(json);
  }

  Future<JoinResult> join(String invitationCode) async {
    final json = await _client.post('/invitations/join', {'invitationCode': invitationCode});
    return JoinResult.fromJson(json);
  }
}
