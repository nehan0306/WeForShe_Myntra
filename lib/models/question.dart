class Question {
  final String question;
  final List<String> options;
  List<String> selectedOptions;

  Question({required this.question, required this.options, List<String>? selectedOptions})
      : selectedOptions = selectedOptions ?? [];

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      selectedOptions: [],
    );
  }
}
