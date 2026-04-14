import 'package:flutter/material.dart';

class ItemNotification extends StatefulWidget {
  final Icon icon;
  final String notificationTitle;
  final String notificationBody;
  final String notificationTime;
  final FontWeight textWeight;
  const ItemNotification({
    super.key,
    required this.icon,
    required this.notificationTitle,
    required this.notificationBody,
    required this.notificationTime,
    required this.textWeight,
  });

  @override
  State<ItemNotification> createState() => _ItemNotificationState();
}

class _ItemNotificationState extends State<ItemNotification> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.icon,
      title: Text(
        widget.notificationTitle,
        style: TextStyle(fontWeight: widget.textWeight),
      ),
      subtitle: Text(widget.notificationBody),
      trailing: Text(
        widget.notificationTime.substring(0, 10),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
