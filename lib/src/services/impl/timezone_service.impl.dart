import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../easy_local_noti.dart';
import '../timezone_service.dart';

class TimezoneServiceImpl extends TimezoneService {
  TimezoneServiceImpl() {
    initializeTimeZones();
  }

  @override
  Future<String> get timezone async {
    if (UniversalPlatform.isWindows) {
      return 'windows-timezone';
    }
    return FlutterNativeTimezone.getLocalTimezone();
  }

  @override
  Future<Location> getCurrentLocation([String? timeZoneName]) async {
    if (timeZoneName?.isNotEmpty != true) {
      return getLocation(await timezone);
    } else {
      return getLocation(timeZoneName!);
    }
  }

  @override
  Future<TZDateTime> create(DateTime time, [Location? location]) async {
    if (location == null) {
      final cur = await getCurrentLocation();
      return TZDateTime.from(time, cur);
    } else {
      return TZDateTime.from(time, location);
    }
  }
}

TimezoneService createTimezoneService() => TimezoneServiceImpl();
