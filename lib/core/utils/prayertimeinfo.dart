import 'package:intl/intl.dart';

class PrayerTimeInfo {
  final String name;
  final DateTime time;
  final String timeRemaining;

  PrayerTimeInfo({
    required this.name,
    required this.time,
    required this.timeRemaining,
  });
}

class PrayerTimeUtils {
  static Map<String, DateTime> parsePrayerTimes({
    required String? imsak,
    required String? fajr,
    required String? sunrise,
    required String? dhuhr,
    required String? asr,
    required String? maghrib,
    required String? isha,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime parseTimeString(String? timeString) {
      if (timeString == null || timeString == "-") {
        return today;
      }

      try {
        final format = DateFormat.jm();
        final time = format.parse(timeString);
        return DateTime(
          today.year,
          today.month,
          today.day,
          time.hour,
          time.minute,
        );
      } catch (e) {
        return today;
      }
    }

    return {
      'Imsak': parseTimeString(imsak),
      'Shubuh': parseTimeString(fajr),
      'Terbit': parseTimeString(sunrise),
      'Zuhur': parseTimeString(dhuhr),
      'Ashar': parseTimeString(asr),
      'Maghrib': parseTimeString(maghrib),
      'Isya': parseTimeString(isha),
    };
  }

  static PrayerTimeInfo getNextPrayer({
    required String? imsak,
    required String? fajr,
    required String? sunrise,
    required String? dhuhr,
    required String? asr,
    required String? maghrib,
    required String? isha,
  }) {
    final now = DateTime.now();
    final prayerTimes = parsePrayerTimes(
      imsak: imsak,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    );

    // Sort prayer times
    final sortedPrayers =
        prayerTimes.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

    // Find next prayer
    String nextPrayer = 'Imsak';
    DateTime nextPrayerTime = sortedPrayers.first.value.add(
      const Duration(days: 1),
    );

    for (final entry in sortedPrayers) {
      if (now.isBefore(entry.value)) {
        nextPrayer = entry.key;
        nextPrayerTime = entry.value;
        break;
      }
    }

    // If we've passed all prayers for today, next is first prayer of tomorrow
    if (now.isAfter(sortedPrayers.last.value)) {
      nextPrayer = sortedPrayers.first.key;
      nextPrayerTime = sortedPrayers.first.value.add(const Duration(days: 1));
    }

    // Calculate time remaining
    final difference = nextPrayerTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final timeRemaining = '${hours}h ${minutes}m';

    return PrayerTimeInfo(
      name: nextPrayer,
      time: nextPrayerTime,
      timeRemaining: timeRemaining,
    );
  }

  static String getCurrentPrayer({
    required String? imsak,
    required String? fajr,
    required String? sunrise,
    required String? dhuhr,
    required String? asr,
    required String? maghrib,
    required String? isha,
  }) {
    final now = DateTime.now();
    final prayerTimes = parsePrayerTimes(
      imsak: imsak,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    );

    // Find the current prayer (the most recent prayer time that has passed)
    final currentPrayerEntry =
        prayerTimes.entries
            .where(
              (entry) =>
                  entry.value.isBefore(now) ||
                  entry.value.isAtSameMomentAs(now),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return currentPrayerEntry.isNotEmpty ? currentPrayerEntry.first.key : '';
  }
}
