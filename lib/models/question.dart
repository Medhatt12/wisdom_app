class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String>? options;
  final String? skill;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.skill,
  });

  // Add the copyWith method
  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<String>? options,
    String? skill,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      skill: skill ?? this.skill,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      type: _parseQuestionType(json['type'] as String),
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      skill: json['skill'] as String?,
    );
  }

  static QuestionType _parseQuestionType(String type) {
    switch (type) {
      case 'MCQ':
        return QuestionType.MCQ;
      case 'SCALE':
        return QuestionType.SCALE;
      case 'TEXT_FIELD':
        return QuestionType.TEXT_FIELD;
      default:
        throw Exception('Unknown question type: $type');
    }
  }
}

enum QuestionType { MCQ, SCALE, TEXT_FIELD }
