import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';
import 'package:taste_o_clock/app/core/enums/notification_type.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

String _formatNotificationDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  return '${date.day}/${date.month}/${date.year}';
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(notification.type);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: AppColors.kError.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Icon(Icons.delete_outline_rounded, color: AppColors.kError),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Ink(
            decoration: AppDecorations.surfaceCard(radius: 18.r).copyWith(
              color: isUnread
                  ? AppColors.kPrimary.withValues(alpha: 0.06)
                  : AppColors.kSurface,
              border: Border.all(
                color: isUnread
                    ? AppColors.kPrimary.withValues(alpha: 0.25)
                    : AppColors.kBorder.withValues(alpha: 0.6),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: AppAnimations.medium,
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      gradient: isUnread ? AppColors.kPrimaryGradient : null,
                      color: isUnread
                          ? null
                          : AppColors.kChipInactive,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: isUnread ? Colors.white : AppColors.kPrimary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppFontStyle.kMulishTextStyle(
                                  fontSize: 15,
                                  c: AppColors.kTextPrimary,
                                  fontWeight:
                                      isUnread ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.kPrimaryGradient,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          notification.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.kMulishTextStyle(
                            fontSize: 13,
                            c: AppColors.kTextSecondary,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _formatNotificationDate(notification.createdAt),
                          style: AppFontStyle.kMulishTextStyle(
                            fontSize: 11,
                            c: AppColors.kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(NotificationType type) {
    return switch (type) {
      NotificationType.orderStatus => Icons.delivery_dining_rounded,
      NotificationType.promotion => Icons.local_offer_rounded,
      NotificationType.general => Icons.notifications_rounded,
    };
  }
}
