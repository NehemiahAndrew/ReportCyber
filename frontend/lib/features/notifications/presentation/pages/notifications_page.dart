import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'Report Status Updated',
      message: 'Your report #RPT-2024-001 has been reviewed and is now under investigation.',
      time: '2 hours ago',
      type: NotificationType.update,
      isRead: false,
    ),
    _NotificationItem(
      title: 'New Threat Alert',
      message: 'A new phishing campaign targeting banking customers has been detected in your area.',
      time: '5 hours ago',
      type: NotificationType.alert,
      isRead: false,
    ),
    _NotificationItem(
      title: 'Evidence Verified',
      message: 'The evidence you submitted for report #RPT-2024-098 has been verified.',
      time: '1 day ago',
      type: NotificationType.success,
      isRead: true,
    ),
    _NotificationItem(
      title: 'Report Resolved',
      message: 'Your report #RPT-2024-085 has been resolved. Thank you for your contribution.',
      time: '2 days ago',
      type: NotificationType.success,
      isRead: true,
    ),
    _NotificationItem(
      title: 'Security Tip',
      message: 'Remember to update your passwords regularly and enable two-factor authentication.',
      time: '3 days ago',
      type: NotificationType.info,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all read',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildNotificationCard(_notifications[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! Check back later\nfor new updates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationItem notification) {
    return Dismissible(
      key: Key(notification.title + notification.time),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            notification.isRead = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFF1E3A5F).withOpacity(0.3)
                : const Color(0xFF1E3A5F).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? const Color(0xFF1E3A5F).withOpacity(0.5)
                  : const Color(0xFF3B82F6).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notification.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (type) {
      case NotificationType.alert:
        icon = Icons.warning_amber_rounded;
        color = const Color(0xFFEF4444);
        bgColor = const Color(0xFFEF4444).withOpacity(0.2);
        break;
      case NotificationType.update:
        icon = Icons.update;
        color = const Color(0xFF3B82F6);
        bgColor = const Color(0xFF3B82F6).withOpacity(0.2);
        break;
      case NotificationType.success:
        icon = Icons.check_circle_outline;
        color = const Color(0xFF10B981);
        bgColor = const Color(0xFF10B981).withOpacity(0.2);
        break;
      case NotificationType.info:
        icon = Icons.info_outline;
        color = const Color(0xFFF59E0B);
        bgColor = const Color(0xFFF59E0B).withOpacity(0.2);
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }
}

enum NotificationType { alert, update, success, info }

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
  });
}
