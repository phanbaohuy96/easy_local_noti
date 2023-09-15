import 'dart:convert';

import '../extensions/notificaiton_scheduled_extension.dart';
import 'notification_scheduled.dart';

class EasyNotificationModel {
  final String? rawPayload;
  final NotificationScheduled? scheduled;

  EasyNotificationModel({
    this.scheduled,
    this.rawPayload,
  });

  Map<String, dynamic> toMap() {
    return {
      'payload': rawPayload,
      'scheduled': scheduled?.type,
    };
  }

  factory EasyNotificationModel.fromMap(Map<String, dynamic> map) {
    return EasyNotificationModel(
      rawPayload: map['payload'],
      scheduled: map['scheduled'] != null
          ? NotificationScheduledEtx.of(map['scheduled'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EasyNotificationModel.fromJson(String source) =>
      EasyNotificationModel.fromMap(json.decode(source));
}
