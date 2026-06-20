import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/widgets/fade_slide_in.dart';
import 'package:taste_o_clock/app/core/widgets/section_card.dart';
import 'package:taste_o_clock/app/modules/notification/controllers/notification_controller.dart';
import 'package:taste_o_clock/app/modules/notification/widgets/notification_tile.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: AppFontStyle.kMulishTextStyle(
                fontSize: 20,
                c: AppColors.kTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Obx(
              () => Text(
                controller.unreadCount.value > 0
                    ? '${controller.unreadCount.value} unread'
                    : 'All caught up',
                style: AppFontStyle.kMulishTextStyle(
                  fontSize: 12,
                  c: AppColors.kTextSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => controller.notifications.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: controller.markAllAsRead,
                    child: Text(
                      'Mark all read',
                      style: AppFontStyle.kMulishTextStyle(
                        fontSize: 13,
                        c: AppColors.kPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return const EmptyStateView(
            icon: Icons.notifications_none_rounded,
            title: 'No notifications yet',
            subtitle: 'Order updates and alerts will appear here',
          );
        }

        return RefreshIndicator(
          color: AppColors.kPrimary,
          onRefresh: controller.refreshNotifications,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return StaggeredEntrance(
                index: index,
                child: NotificationTile(
                  notification: notification,
                  onTap: () => controller.openNotification(notification),
                  onDelete: () => controller.deleteNotification(notification.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
