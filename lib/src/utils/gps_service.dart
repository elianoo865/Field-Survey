import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GpsService {
  Future<Position> capturePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع (GPS) غير مفعلة على الجهاز.');
    }

    // Ask permission (Android/iOS)
    final perm = await Permission.location.request();
    if (!perm.isGranted) {
      throw Exception('تم رفض صلاحية الموقع. فعّلها لإرسال الاستبيان.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }
}
