import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

class PbService {
  PbService._();

  // Change this to your laptop's LAN IP before the presentation
  // e.g. 'http://192.168.1.45:8090'
  // For emulator use: 'http://10.0.2.2:8090'
  static const String _baseUrl = 'http://10.0.2.2:8090';

  static final PocketBase pb = PocketBase(_baseUrl);
}
