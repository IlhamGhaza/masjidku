import 'package:adhan/adhan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:geolocator/geolocator.dart';

// Move the typedef to the top level (outside the class)
typedef NotificationResponseCallback =
    void Function(NotificationResponse response);

class PrayerNotificationService {
  static final PrayerNotificationService _instance =
      PrayerNotificationService._internal();

  factory PrayerNotificationService() {
    return _instance;
  }

  PrayerNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool notificationsInitialized = false;
  late tz.Location local;
  bool _isLocalTimeZoneResolved = true;

  // Use the typedef that's now at the top level
  NotificationResponseCallback? _onNotificationResponseCallback;

  // Method to set the callback
  void setNotificationResponseCallback(NotificationResponseCallback callback) {
    _onNotificationResponseCallback = callback;
  }

  // Map to store notification IDs for each prayer
  final Map<String, int> notificationIds = {
    'Imsak': 0,
    'Shubuh': 1,
    'Terbit': 2,
    'Zuhur': 3,
    'Ashar': 4,
    'Maghrib': 5,
    'Isya': 6,
  };

  // Map of common country codes to timezone strings
  final Map<String, String> _countryToTimezone = {
    'ID': 'Asia/Jakarta', // Indonesia
    'MY': 'Asia/Kuala_Lumpur', // Malaysia
    'SG': 'Asia/Singapore', // Singapore
    'TH': 'Asia/Bangkok', // Thailand
    'PH': 'Asia/Manila', // Philippines
    'VN': 'Asia/Ho_Chi_Minh', // Vietnam
    'US': 'America/New_York', // United States (default, will be refined)
    'GB': 'Europe/London', // United Kingdom
    'AU': 'Australia/Sydney', // Australia (default, will be refined)
    // Add more mappings as needed
  };

  Future<void> initialize({double? latitude, double? longitude}) async {
    if (notificationsInitialized) return;
    debugPrint(
      '[PrayerNotificationService] Initializing local notifications...',
    );

    // Initialize timezone data
    tz_data.initializeTimeZones();
    debugPrint('[PrayerNotificationService] Timezone data initialized.');

    try {
      // If coordinates are provided, try to determine timezone from location
      if (latitude != null && longitude != null) {
        await _setTimezoneFromCoordinates(latitude, longitude);
      } else {
        // Fall back to device timezone
        local = tz.local;
        _isLocalTimeZoneResolved = true;
        debugPrint('[PrayerNotificationService] Using device timezone: $local');
      }
    } catch (e) {
      debugPrint(
        "Error initializing timezone: $e. Falling back to UTC for notifications.",
      );
      // Fallback to UTC to prevent LateInitializationError.
      local = tz.UTC;
      _isLocalTimeZoneResolved = false;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    notificationsInitialized = true;
    debugPrint(
      '[PrayerNotificationService] Local notifications initialized successfully.',
    );
  }

  /// Set timezone based on coordinates using geocoding
  Future<void> _setTimezoneFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String? countryCode = place.isoCountryCode;

        if (countryCode != null &&
            _countryToTimezone.containsKey(countryCode)) {
          // Get timezone string for this country
          String timezoneString = _countryToTimezone[countryCode]!;

          // For large countries, refine the timezone based on longitude
          if (countryCode == 'US') {
            timezoneString = _getUSTimezone(longitude);
          } else if (countryCode == 'AU') {
            timezoneString = _getAustraliaTimezone(longitude);
          }

          // Set the timezone
          local = tz.getLocation(timezoneString);
          _isLocalTimeZoneResolved = true;
          debugPrint(
            '[PrayerNotificationService] Timezone set from coordinates: $local',
          );
        } else {
          // If country code not in our map, fall back to device timezone
          local = tz.local;
          debugPrint(
            '[PrayerNotificationService] Country code $countryCode not in timezone map. Using device timezone: $local',
          );
        }
      } else {
        throw Exception('No placemarks found for coordinates');
      }
    } catch (e) {
      debugPrint(
        '[PrayerNotificationService] Error setting timezone from coordinates: $e',
      );
      // Fall back to device timezone
      local = tz.local;
    }
  }

  // Helper method to determine US timezone based on longitude
  String _getUSTimezone(double longitude) {
    if (longitude < -125) return 'America/Los_Angeles'; // Pacific
    if (longitude < -100) return 'America/Denver'; // Mountain
    if (longitude < -87) return 'America/Chicago'; // Central
    if (longitude < -67) return 'America/New_York'; // Eastern
    return 'America/New_York'; // Default to Eastern
  }

  // Helper method to determine Australia timezone based on longitude
  String _getAustraliaTimezone(double longitude) {
    if (longitude < 129) return 'Australia/Perth'; // Western Australia
    if (longitude < 141) return 'Australia/Adelaide'; // Central Australia
    return 'Australia/Sydney'; // Eastern Australia
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null && payload == 'prayer_page_notification') {
      debugPrint(
        '[PrayerNotificationService] Notification tapped with payload: $payload',
      );

      // Call the callback if it's set
      if (_onNotificationResponseCallback != null) {
        _onNotificationResponseCallback!(response);
      }
    }
  }

  /// Schedules a persistent local notification for the given prayer name at the given
  /// prayer time.
  Future<void> schedulePrayerNotification(
    String prayerName,
    DateTime prayerTime,
    BuildContext? context,
  ) async {
    await initialize();
    debugPrint(
      '[PrayerNotificationService] Attempting to schedule notification for $prayerName at $prayerTime',
    );

    final int notificationId = notificationIds[prayerName] ?? 0;
    debugPrint(
      '[PrayerNotificationService] Notification ID for $prayerName: $notificationId',
    );

    // Only schedule if the prayer time is in the future
    if (prayerTime.isAfter(DateTime.now())) {
      debugPrint(
        '[PrayerNotificationService] Prayer time for $prayerName is in the future. Proceeding with scheduling.',
      );
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Times',
            channelDescription: 'Notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true, // Makes notification persistent
            autoCancel: false, // Prevents user from dismissing
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      try {
        debugPrint(
          '[PrayerNotificationService] Scheduling notification for $prayerName with ID $notificationId at $prayerTime using timezone $local',
        );

        String title = 'Prayer Time for $prayerName';
        String body =
            'It\'s time for $prayerName prayer at ${DateFormat.jm().format(prayerTime)}';

        if (context != null) {
          title = '${context.tr('prayer_time_for')} $prayerName';
          body =
              '${context.tr('its_time_for')} $prayerName ${context.tr('prayer_at')} ${DateFormat.jm().format(prayerTime)}';
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          tz.TZDateTime.from(prayerTime, local),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'prayer_page_notification',
        );
        debugPrint(
          '[PrayerNotificationService] Successfully scheduled notification for $prayerName (ID: $notificationId).',
        );
      } catch (e) {
        debugPrint(
          '[PrayerNotificationService] ERROR scheduling notification for $prayerName (ID: $notificationId): $e',
        );
      }
    } else {
      debugPrint(
        '[PrayerNotificationService] Prayer time for $prayerName ($prayerTime) is in the past. Notification not scheduled.',
      );
    }
  }

  /// Schedule notifications for all prayer times
  Future<void> scheduleAllPrayerNotifications({
    required String? imsak,
    required String? fajr,
    required String? sunrise,
    required String? dhuhr,
    required String? asr,
    required String? maghrib,
    required String? isha,
    required DateTime selectedDate,
    BuildContext? context,
    double? latitude,
    double? longitude,
  }) async {
    // Initialize with coordinates if provided
    await initialize(latitude: latitude, longitude: longitude);

    debugPrint(
      '[PrayerNotificationService] scheduleAllPrayerNotifications called.',
    );

    if (!_isLocalTimeZoneResolved) {
      debugPrint(
        '[PrayerNotificationService] WARNING: Local timezone was not resolved. Notifications might be scheduled based on UTC.',
      );
    }

    if (imsak != null) {
      final imsakTime = _parseTimeString(imsak, selectedDate);
      await schedulePrayerNotification('Imsak', imsakTime, context);
    }
    if (fajr != null) {
      final fajrTime = _parseTimeString(fajr, selectedDate);
      await schedulePrayerNotification('Shubuh', fajrTime, context);
    }
    if (sunrise != null) {
      final sunriseTime = _parseTimeString(sunrise, selectedDate);
      await schedulePrayerNotification('Terbit', sunriseTime, context);
    }
    if (dhuhr != null) {
      final dhuhrTime = _parseTimeString(dhuhr, selectedDate);
      await schedulePrayerNotification('Zuhur', dhuhrTime, context);
    }
    if (asr != null) {
      final asrTime = _parseTimeString(asr, selectedDate);
      await schedulePrayerNotification('Ashar', asrTime, context);
    }
    if (maghrib != null) {
      final maghribTime = _parseTimeString(maghrib, selectedDate);
      await schedulePrayerNotification('Maghrib', maghribTime, context);
    }
    if (isha != null) {
      final ishaTime = _parseTimeString(isha, selectedDate);
      await schedulePrayerNotification('Isya', ishaTime, context);
    }

    debugPrint(
      '[PrayerNotificationService] Finished scheduling all prayer notifications for date: $selectedDate',
    );
  }

  /// Parse a time string in the format of "HH:mm" and return the corresponding
  /// DateTime object with the given [date].
  DateTime _parseTimeString(String? timeString, DateTime date) {
    if (timeString == null || timeString.isEmpty) {
      debugPrint(
        '[PrayerNotificationService] _parseTimeString: timeString is null or empty for date $date. Returning date as is.',
      );
      return date;
    }
    final format = DateFormat.jm();
    final time = format.parse(timeString);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
