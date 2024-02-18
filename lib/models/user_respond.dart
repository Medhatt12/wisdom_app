class UserResponse {
  final String questionId;
  final dynamic response;

  UserResponse({required this.questionId, required this.response});

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'response': response,
    };
  }
}
