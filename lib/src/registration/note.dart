class Note {
  String userId;
  String text;
  DateTime date;

  Note({
    required this.userId,
    required this.text,
    required this.date,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      userId: json['userId'],
      text: json['text'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
      'date': date.toIso8601String(),
    };
  }
}