import 'package:timezone/timezone.dart';

abstract class TimezoneService {
  Future<String> get timezone;

  Future<Location> getCurrentLocation([String? timeZoneName]);

  Future<TZDateTime> create(DateTime time, [Location? location]);
}
