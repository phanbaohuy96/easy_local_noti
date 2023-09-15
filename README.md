## Usage

Add `easy_local_noti` as a dependency in your pubspec.yaml file.

### Example

```dart
/// Import package
import 'package:easy_local_noti/easy_local_noti.dart';

/// Instantiate it
final service = await LocalNotificationService.setup(
  androidChannelId: 'android_channel_id',
  androidChannelName: 'android_channel_name',
  ...
);

/// Usage
service.onNotificationOpened.listen((noti) {
  debugPrint(noti.toJson());
});

service.show(
  1,
  'title',
  'body',
);

service.cancel(1)


### Reminder

service.setNotificationReminder(
  2,
  'title: Monday',
  'body: reminder for monday',
  DateTime.now(),
  scheduled: NotificationScheduled.weekly,
  payload: jsonEncode({'id': '2', 'data': 'reminder for monday'}),
)

