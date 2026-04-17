import 'package:admin_patitas/models/notifications_show.dart';
import 'package:admin_patitas/services/notification_service.dart';
import 'package:admin_patitas/utils/preferences_service.dart';
import 'package:admin_patitas/widgets/item_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificacionScreen extends StatefulWidget {
  const NotificacionScreen({super.key});

  @override
  State<NotificacionScreen> createState() => _NotificacionScreenState();
}

class _NotificacionScreenState extends State<NotificacionScreen> {
  late Future<List<NotificationsShow>> _notificationsFuture;
  User? _currentUser;
  String? id_refugio = "";

  @override
  void initState() {
    super.initState();
    id_refugio = PreferencesController.preferences.getString('refugio');
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadNotifications();
  }

  //carga las notificaciones del usuario actual
  void _loadNotifications() {
    _notificationsFuture = NotificationsService().getNotificationsForUser(
      _currentUser!.uid,
      id_refugio!,
    );
  }

  //ejecuta la actualizacion de lectura del item seleccionado
  Future<void> _onTapItem(NotificationsShow item) async {
    if (item.isRead) return;

    await NotificationsService().updateReadNotificationState(
      userId: _currentUser!.uid,
      notifId: item.notifications.id,
      refugioId: id_refugio!,
    );

    setState(() {
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: FutureBuilder<List<NotificationsShow>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar notificaciones'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(child: Text('No tienes notificaciones'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return GestureDetector(
                onTap: () => _onTapItem(item),
                child: ItemNotification(
                  icon: Icon(
                    item.isRead
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: item.isRead ? Colors.grey : Colors.orange,
                  ),
                  notificationTitle: item.notifications.title,
                  notificationBody: item.notifications.body,
                  notificationTime: item.notifications.date,
                  textWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
