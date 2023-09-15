
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_scheduled.dart';

extension NotificationScheduledEtx on NotificationScheduled {
  DateTimeComponents? get dateTimeComponents {
    switch (this) {
      case NotificationScheduled.daily:
        return DateTimeComponents.time;
      case NotificationScheduled.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      default:
        return null;
    }
  }

  static NotificationScheduled? of(int type) {
    for (final e in NotificationScheduled.values) {
      if (e.type == type) {
        return e;
      }
    }
    return null;
  }
}