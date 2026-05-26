class Notifications {
  final String id;
  final String title;
  final String body;
  final String refugioId;
  final String type;
  final String targetId;
  final String date;

  Notifications({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.refugioId,
    required this.type,
    required this.targetId,
  });

  factory Notifications.fromMap(String id, Map<dynamic, dynamic> json) {
    return Notifications(
      id: id,
      type: json['type'],
      refugioId: json['refugioId'],
      title: json['title'],
      body: json['body'],
      date: json['date'],
      targetId: json['targetId'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'refugioId': refugioId,
      'date': date,
      'type': type,
      'targetId': targetId,
    };
  }
}
