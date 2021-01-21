import 'package:meta/meta.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class SearchResult {
  final bool cancelo;
  final bool manual;
  final LatLng coordenadasDestino;
  final String nombreDestino;
  final String descDestino;

  SearchResult(
      {@required this.cancelo,
      this.manual,
      this.coordenadasDestino,
      this.nombreDestino,
      this.descDestino});
}
