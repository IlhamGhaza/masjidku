import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

Future<bool> requestLocationPermission() async {
  final Location location = Location();
  try {
    PermissionStatus status = await location.hasPermission();
    if (status == PermissionStatus.granted) {
      debugPrint("Izin lokasi sudah diberikan sebelumnya.");
      return true;
    } else {
      PermissionStatus newStatus = await location.requestPermission();
      if (newStatus == PermissionStatus.granted) {
        debugPrint("Izin lokasi berhasil diberikan.");
        return true;
      } else {
        debugPrint("Izin lokasi ditolak oleh pengguna.");
        return false;
      }
    }
  } catch (e) {
    debugPrint("Error saat meminta izin lokasi: $e");

    return false;
  }
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location permissions are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are denied, pleaase allow location permissions.',
    );
  }

  return await Geolocator.getCurrentPosition();
}
