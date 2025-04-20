// import 'package:logging/logging.dart';
import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

class AlarmPermissions {
  static final _log = log('AlarmPermissions');

  static Future<void> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      log('Requesting notification permission...');
      final res = await Permission.notification.request();
      log(
        'Notification permission ${res.isGranted ? '' : 'not '}granted',
      );
    }
  }

  static Future<void> checkAndroidExternalStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isDenied) {
      log('Requesting external storage permission...');
      final res = await Permission.storage.request();
      log(
        'External storage permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }

  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    log('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
      log('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
      log(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',
      );
    }
  }
}
