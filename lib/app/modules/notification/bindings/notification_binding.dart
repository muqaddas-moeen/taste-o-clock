import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/notification/controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<NotificationController>();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshNotifications();
      }
    });
  }
}
