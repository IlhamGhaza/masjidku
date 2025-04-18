import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/prayertimeinfo.dart';

class NextPrayerWidget extends StatelessWidget {
  final String imsak;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const NextPrayerWidget({
    Key? key,
    required this.imsak,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nextPrayerInfo = PrayerTimeUtils.getNextPrayer(
      imsak: imsak,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    );

    final nextPrayer = nextPrayerInfo.name;
    final nextTime = DateFormat.jm().format(nextPrayerInfo.time);
    final timeRemaining = nextPrayerInfo.timeRemaining;

    return Row(
      children: [
        Icon(Icons.timer_outlined, color: Colors.white, size: 18),
        SizedBox(width: 4),
        Text(
          "$nextPrayer: $nextTime",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 4),
        Text('to', style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(width: 4),
        Text(
          timeRemaining,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
