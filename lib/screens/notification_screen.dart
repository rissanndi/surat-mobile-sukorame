import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:surat_mobile_sukorame/services/app_state.dart';
import 'package:surat_mobile_sukorame/services/notification_service.dart';
import 'package:surat_mobile_sukorame/theme/app_theme.dart';
import 'package:surat_mobile_sukorame/widgets/common_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final userId = appState.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Silakan login terlebih dahulu')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () => _markAllAsRead(userId),
            tooltip: 'Tandai semua telah dibaca',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationService.getNotificationHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppErrorWidget(
              message: 'Terjadi kesalahan: ${snapshot.error}',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingWidget();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const AppEmptyWidget(
              message: 'Belum ada notifikasi',
              icon: Icons.notifications_none,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var notification = snapshot.data!.docs[index];
              var data = notification.data() as Map<String, dynamic>;
              bool isRead = data['read'] ?? false;

              return NotificationCard(
                title: data['title'] ?? '',
                body: data['body'] ?? '',
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                isRead: isRead,
                onTap: () {
                  if (!isRead) {
                    _notificationService.markNotificationAsRead(notification.id);
                  }
                  _handleNotificationTap(data['data']);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAllAsRead(String userId) async {
    try {
      var notifications = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      var batch = FirebaseFirestore.instance.batch();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi telah ditandai telah dibaca')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void _handleNotificationTap(Map<String, dynamic>? data) {
    if (data == null) return;

    String? route = data['route'] as String?;
    if (route != null && mounted) {
      Navigator.of(context).pushNamed(route, arguments: data);
    }
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: isRead ? null : AppTheme.primary.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                body,
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                timeago.format(timestamp, locale: 'id'),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}