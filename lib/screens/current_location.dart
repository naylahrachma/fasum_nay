// current_location.dart
import 'package:geolocator/geolocator.dart';

class CurrentLocation {
  Future<Position?> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Memeriksa apakah layanan lokasi diaktifkan
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Layanan lokasi tidak diaktifkan, tidak dapat melanjutkan
      return null;
    }

    // Memeriksa izin akses lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Izin lokasi ditolak
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin lokasi ditolak secara permanen, tidak dapat melanjutkan
      return null;
    }

    // Mendapatkan lokasi saat ini
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}