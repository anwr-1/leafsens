import 'dart:async';
import '../../models/prediction_result.dart';
import 'pb_service.dart';
import 'auth_service.dart';
import 'in_memory_session.dart';

class HistoryService {
  HistoryService._();

  static final _controller = StreamController<List<Map<String, dynamic>>>.broadcast();
  static bool _subscribed = false;

  // ─── Fetch & Notify ───────────────────────────────────────────────────────
  static Future<void> _fetchAndNotify() async {
    if (AuthService.isAdminOffline) {
      _controller.add(InMemorySession.getAll());
      return;
    }

    try {
      final authId = PbService.pb.authStore.record?.id;
      if (authId == null) {
        _controller.add([]);
        return;
      }

      final records = await PbService.pb.collection('scans').getFullList(
        sort: '-created',
      );
      
      final list = records.map((e) => e.toJson()).toList();
      _controller.add(list);
    } catch (e) {
      _controller.add([]);
    }
  }

  // ─── Save ─────────────────────────────────────────────────────────────────
  static Future<void> saveScan(PredictionResult result, String imageLocalPath) async {
    if (AuthService.isAdminOffline) {
      InMemorySession.addScan(result, imageLocalPath);
      _controller.add(InMemorySession.getAll());
      return;
    }

    final authId = PbService.pb.authStore.record?.id;
    if (authId == null) return;

    final body = {
      'plant': result.plant,
      'disease': result.disease,
      'isHealthy': result.isHealthy,
      'confidence': result.confidence,
      'rawClass': result.rawClass,
      'top3': result.top3.map((t) => {'className': t.className, 'confidence': t.confidence}).toList(),
      'imagePath': imageLocalPath,
      'user': authId,
    };

    await PbService.pb.collection('scans').create(body: body);
    await _fetchAndNotify();
  }

  // ─── Stream history ───────────────────────────────────────────────────────
  static Stream<List<Map<String, dynamic>>> getHistory() {
    _fetchAndNotify(); // initial fetch
    
    if (AuthService.isAdminOffline) {
      return _controller.stream;
    }

    // Setup realtime subscription once
    if (!_subscribed) {
      _subscribed = true;
      try {
        PbService.pb.collection('scans').subscribe('*', (e) {
          _fetchAndNotify();
        });
      } catch (_) {}
    }
    
    return _controller.stream;
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  static Future<void> deleteScan(String docId) async {
    if (AuthService.isAdminOffline) {
      InMemorySession.delete(docId);
      _controller.add(InMemorySession.getAll());
      return;
    }

    await PbService.pb.collection('scans').delete(docId);
    await _fetchAndNotify();
  }
}
