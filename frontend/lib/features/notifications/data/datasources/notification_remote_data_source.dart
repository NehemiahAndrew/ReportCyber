import '../../../../core/network/api_client.dart';

abstract class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await apiClient.dio.get('/notifications');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final notifications = response.data['data']['notifications'] as List;
        return notifications.map((n) => n as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get notifications');
      }
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.dio.patch(
        '/notifications/$notificationId/read',
      );

      if (response.statusCode != 200 || response.data['status'] != 'success') {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await apiClient.dio.patch(
        '/notifications/mark-all-read',
      );

      if (response.statusCode != 200 || response.data['status'] != 'success') {
        throw Exception('Failed to mark all as read');
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await apiClient.dio.delete(
        '/notifications/$notificationId',
      );

      if (response.statusCode != 200 || response.data['status'] != 'success') {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
}
