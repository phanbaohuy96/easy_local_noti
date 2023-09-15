import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

import '../../extensions/notificaiton_scheduled_extension.dart';
import '../../models/easy_notification_model.dart';
import '../../models/notification_scheduled.dart';
import '../local_notification_service.dart';
import '../timezone_service.dart';
import 'timezone_service.impl.dart';

class LocalNotificationServiceImpl extends LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final TimezoneService _timezoneService;

  LocalNotificationServiceImpl({
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin,
    TimezoneService? timezoneService,
  })  : _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin ??
            FlutterLocalNotificationsPlugin(),
        _timezoneService = timezoneService ?? createTimezoneService() {
    _onNotificationOpended.onListen = () {
      if (_lastNotiOpened != null) {
        _onNotificationOpended.add(_lastNotiOpened!);
        _lastNotiOpened = null;
      }
    };
  }

  ///
  /// Stream
  ///
  final StreamController<EasyNotificationModel> _onNotificationOpended =
      StreamController<EasyNotificationModel>();

  ///
  ///
  ///
  bool _isInitialized = false;

  late String androidChannelId;
  late String androidChannelName;
  String? androidChannelDes;
  late String androidIcon;
  Priority androidPriority = Priority.defaultPriority;
  Importance androidImportance = Importance.defaultImportance;
  AndroidNotificationDetails? androidDetails;

  EasyNotificationModel? _lastNotiOpened;

  void close() {
    _onNotificationOpended.close();
  }

  @override
  Stream<EasyNotificationModel> get onNotificationOpened {
    debugPrint(
      '''[Listen On Notification Opened] - lastNotiOpened: ${_lastNotiOpened?.toJson()}''',
    );
    return _onNotificationOpended.stream;
  }

  Future<bool> _init() async {
    if (_isInitialized) {
      return _isInitialized;
    }

    await _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        iOS: const DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            androidChannelId,
            androidChannelName,
            description: androidChannelDes,
            importance: androidImportance,
          ),
        );

    return _isInitialized = true;
  }

  Future<dynamic> onClickNotification(String? payload) async {
    debugPrint('$runtimeType onClickNotification payload: $payload');
    if (payload != null) {
      if (_onNotificationOpended.hasListener) {
        _onNotificationOpended.add(
          EasyNotificationModel.fromJson(payload),
        );
      } else {
        _lastNotiOpened = EasyNotificationModel.fromJson(payload);
      }
    }
    return payload;
  }

  @override
  Future<void> setNotificationReminder(
    int id,
    String title,
    String body,
    DateTime dateTime, {
    int? weekday,
    NotificationScheduled scheduled = NotificationScheduled.oneTime,
    String? payload,
    AndroidNotificationDetails? androidDetails,
  }) async {
    final initResult = await _init();
    if (!initResult) {
      return;
    }

    return _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      await _createTimeZone(
        dateTime,
        scheduled,
        weekday,
      ),
      _getPlatformChannelSpecfics(androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: scheduled.dateTimeComponents,
      payload: EasyNotificationModel(
        rawPayload: payload,
        scheduled: scheduled,
      ).toJson(),
    );
  }

  @override
  Future<void> show(
    int id,
    String title,
    String body, {
    String? payload,
    AndroidNotificationDetails? androidDetails,
  }) async {
    final initResult = await _init();
    if (!initResult) {
      return;
    }

    return _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _getPlatformChannelSpecfics(androidDetails),
      payload: EasyNotificationModel(
        rawPayload: payload,
        scheduled: NotificationScheduled.oneTime,
      ).toJson(),
    );
  }

  @override
  Future<void> cancel(int id) async {
    final initResult = await _init();
    if (!initResult) {
      return;
    }
    return _flutterLocalNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> periodicallyShow(
    int id,
    String title,
    String body,
    RepeatInterval repeatInterval, {
    String? payload,
    AndroidNotificationDetails? androidDetails,
  }) async {
    final initResult = await _init();
    if (!initResult) {
      return;
    }

    return _flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      repeatInterval,
      _getPlatformChannelSpecfics(androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: EasyNotificationModel(
        rawPayload: payload,
        scheduled: NotificationScheduled.oneTime,
      ).toJson(),
    );
  }

  NotificationDetails _getPlatformChannelSpecfics(
    AndroidNotificationDetails? androidDetails,
  ) {
    final androidPlatformChannelSpecifics = [
      androidDetails,
      this.androidDetails,
      AndroidNotificationDetails(
        androidChannelId,
        androidChannelName,
        priority: androidPriority,
        importance: androidImportance,
        icon: androidIcon,
      )
    ].firstWhere((e) => e != null);

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
  }

  Future<LocalNotificationService> setup({
    required String androidChannelId,
    required String androidChannelName,
    String? androidChannelDes,
    String androidIcon = '@mipmap/ic_launcher',
    Priority androidPriority = Priority.defaultPriority,
    Importance androidImportance = Importance.defaultImportance,
    AndroidNotificationDetails? androidDetails,
  }) async {
    this.androidChannelId = androidChannelId;
    this.androidChannelName = androidChannelName;
    this.androidChannelDes = androidChannelDes;
    this.androidIcon = androidIcon;
    this.androidPriority = androidPriority;
    this.androidImportance = androidImportance;
    this.androidDetails = androidDetails;

    await _init();
    return this;
  }

  Future<TZDateTime> _createTimeZone(
    DateTime time,
    NotificationScheduled scheduled, [
    int? weekday,
  ]) async {
    final location = await _timezoneService.getCurrentLocation();

    var campareTime = time.copyWith();

    if (scheduled == NotificationScheduled.oneTime) {
      return _timezoneService.create(campareTime, location);
    }

    if (weekday != null) {
      if (weekday < time.weekday) {
        campareTime = time.subtract(Duration(
          days: time.weekday - weekday,
        ));
      } else {
        campareTime = time.add(Duration(
          days: weekday - time.weekday,
        ));
      }
    }

    while (campareTime.isBefore(DateTime.now())) {
      if (scheduled == NotificationScheduled.daily) {
        campareTime = campareTime.add(const Duration(days: 1));
      } else {
        campareTime = campareTime.add(const Duration(days: 7));
      }
    }

    return _timezoneService.create(campareTime, location);
  }
}
