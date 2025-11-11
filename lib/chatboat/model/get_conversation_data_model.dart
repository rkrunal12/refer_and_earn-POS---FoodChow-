import 'dart:math';

class GetConversationDataModel {
  final String? id;
  final String? userId =
      "user_${Random().nextDouble().toString().substring(2, 12)}";
  final String? userQuestion;
  final String? agentAnswer;
  final String? message;
  final String? userQuestionFromResponse;
  final String? agentAnswerFromResponse;

  GetConversationDataModel({
    this.userQuestion,
    this.agentAnswer,
    this.message,
    this.agentAnswerFromResponse,
    this.userQuestionFromResponse,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_question': userQuestion,
      'agent_answer': agentAnswer,
    };
  }

  factory GetConversationDataModel.fromJson(Map<String, dynamic> json) {
    return GetConversationDataModel(
      message: json["message"],
      id: json["conversation"]["id"],
      agentAnswerFromResponse: json["conversation"]["agent_answer"],
      userQuestionFromResponse: json["conversation"]["user_question"],
    );
  }
}
