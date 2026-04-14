class Notifications {
  final String id;
  final String title;
  final String body;
  final String refugioId;
  final String date;

  Notifications({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.refugioId,
  });

  factory Notifications.fromMap(String id, Map<dynamic, dynamic> json) {
    return Notifications(
      id: id,
      refugioId: json['refugioId'],
      title: json['title'],
      body: json['body'],
      date: json['date'],
    );
  }
}
