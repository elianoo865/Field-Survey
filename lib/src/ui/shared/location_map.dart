import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationLite {
  final double lat;
  final double lng;
  final double? accuracy;

  const LocationLite({
    required this.lat,
    required this.lng,
    this.accuracy,
  });

  String formatShort() {
    final a = accuracy == null ? '' : ' (±${accuracy!.toStringAsFixed(0)}m)';
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}$a';
  }
}

LocationLite? parseLocationMap(Map? loc) {
  if (loc == null) return null;
  final lat = loc['lat'];
  final lng = loc['lng'];
  if (lat is num && lng is num) {
    return LocationLite(
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      accuracy: (loc['accuracy'] is num) ? (loc['accuracy'] as num).toDouble() : null,
    );
  }
  return null;
}

Future<void> openInGoogleMaps(LocationLite loc) async {
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${loc.lat},${loc.lng}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> showLocationMapSheet(
  BuildContext context,
  LocationLite loc, {
  String? title,
}) async {
  final point = LatLng(loc.lat, loc.lng);

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null && title.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              Text('الموقع: ${loc.formatShort()}'),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: 16,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'field_survey_app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: point,
                            width: 46,
                            height: 46,
                            child: const Icon(Icons.location_on, size: 46),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => openInGoogleMaps(loc),
                    icon: const Icon(Icons.map),
                    label: const Text('فتح Google Maps'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      final text = '${loc.lat}, ${loc.lng}';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('تم نسخ الإحداثيات')));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('نسخ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class LocationActions extends StatelessWidget {
  final LocationLite location;
  final String? sheetTitle;

  const LocationActions({
    super.key,
    required this.location,
    this.sheetTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        IconButton(
          tooltip: 'عرض على الخريطة',
          onPressed: () => showLocationMapSheet(context, location, title: sheetTitle),
          icon: const Icon(Icons.pin_drop_outlined),
        ),
        IconButton(
          tooltip: 'فتح Google Maps',
          onPressed: () => openInGoogleMaps(location),
          icon: const Icon(Icons.map_outlined),
        ),
      ],
    );
  }
}
