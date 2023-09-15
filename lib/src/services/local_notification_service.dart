import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/easy_notification_model.dart';
import '../models/notification_scheduled.dart';
import 'impl/local_notification_service_impl.dart';

abstract class LocalNotificationService {
  static Future<LocalNotificationService> setup({
    required String androidChannelId,
    required String androidChannelName,
    String? androidChannelDes,
    String androidIcon = '@mipmap/ic_launcher',
    Priority androidPriority = Priority.defaultPriority,
    Importance androidImportance = Importance.defaultImportance,
  }) =>
      _localNotiServiceInstance.setup(
        androidChannelId: androidChannelId,
        androidChannelName: androidChannelName,
        androidChannelDes: androidChannelDes,
        androidIcon: androidIcon,
        androidPriority: androidPriority,
        androidImportance: androidImportance,
      );

  /// Schedules a notification to be shown at the specified date and time
  /// relative to a specific time zone.
  ///
  /// Note that to get the appropriate representation of the time at the native
  /// level (i.e. Android/iOS), the plugin needs to pass the time over the
  /// platform channel in yyyy-mm-dd hh:mm:ss format. Therefore, the precision
  /// is at the best to the second.
  ///
  /// See more [FlutterLocalNotificationsPlugin.zonedSchedule]
  Future<void> setNotificationReminder(
    int id,
    String title,
    String body,
    DateTime dateTime, {
    int? weekday,
    NotificationScheduled scheduled = NotificationScheduled.oneTime,
    String? payload,
    AndroidNotificationDetails? androidDetails,
  });

  /// Periodically show a notification using the specified interval.
  ///
  /// For example, specifying a hourly interval means the first time the
  /// notification will be an hour after the method has been called and
  /// then every hour after that.
  ///
  /// See more [FlutterLocalNotificationsPlugin.periodicallyShow]
  Future<void> periodicallyShow(
    int id,
    String title,
    String body,
    RepeatInterval repeatInterval, {
    String? payload,
    AndroidNotificationDetails? androidDetails,
  });

  /// Show a notification with an optional payload that will be passed back to
  /// the app when a notification is tapped.
  Future<void> show(
    int id,
    String title,
    String body, {
    String? payload,
    AndroidNotificationDetails? androidDetails,
  });

  Stream<EasyNotificationModel> get onNotificationOpened;

  Future<void> cancel(int id);
}


final _localNotiServiceInstance = LocalNotificationServiceImpl();

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  debugPrint(
    '[_onDidReceiveBackgroundNotificationResponse]: '
    '${notificationResponse.payload}',
  );

  if (notificationResponse.payload?.isNotEmpty ?? false) {
    _localNotiServiceInstance.onClickNotification(
      notificationResponse.payload!,
    );
  }
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
  NotificationResponse notificationResponse,
) {
  debugPrint('[onDidReceiveBackgroundNotificationResponse]: '
      '${notificationResponse.payload}');
}
