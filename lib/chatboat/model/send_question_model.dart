class SendQuestionModel {
  static final String agentId = "68df6c4b3d1052916ddbccdd";
  final String? question;
  final int? topK = 3;
  final String? answer;

  SendQuestionModel({this.question, this.answer});

  // Convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {'agent_id': agentId, 'question': question, 'top_k': topK};
  }

  factory SendQuestionModel.fromJson(Map<String, dynamic> json) {
    return SendQuestionModel(answer: json["answer"]);
  }
}
