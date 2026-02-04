import 'package:geolocator/geolocator.dart';

class GpsService {
  /// Cross-platform GPS capture (Android/iOS/Web)
  ///
  /// - Does NOT rely on permission_handler (problematic on Web).
  /// - Uses Geolocator's permission flow.
  Future<Position> capturePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع (GPS) غير مفعلة على الجهاز.');
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied) {
      throw Exception('تم رفض صلاحية الموقع. فعّلها لإرسال الاستبيان.');
    }

    if (perm == LocationPermission.deniedForever) {
      throw Exception('صلاحية الموقع مرفوضة نهائياً. فعّلها من إعدادات الجهاز/المتصفح.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }
}
