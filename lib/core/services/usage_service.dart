import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plushie_yourself/core/services/services.dart';

class UsageService extends Services {
  static const int _freeWeeklyLimit = 5;
  static const int _subscribedWeeklyLimit = 100;

  static CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users');

  /// Returns the Monday of the current week as a UTC date string (e.g. "2026-03-09")
  static String _currentWeekKey() {
    final now = DateTime.now().toUtc();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  static Future<_UsageData> _getData(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) {
      return _UsageData(
        count: 0,
        weekKey: _currentWeekKey(),
        isSubscribed: false,
      );
    }
    final data = doc.data()!;
    return _UsageData(
      count: (data['weeklyCount'] as int?) ?? 0,
      weekKey: (data['weekKey'] as String?) ?? _currentWeekKey(),
      isSubscribed: (data['isSubscribed'] as bool?) ?? false,
    );
  }

  static Future<UsageStatus> getStatus(String uid) async {
    final data = await _getData(uid);
    final currentWeek = _currentWeekKey();

    // Reset if new week
    final count = data.weekKey == currentWeek ? data.count : 0;
    final limit = data.isSubscribed ? _subscribedWeeklyLimit : _freeWeeklyLimit;

    return UsageStatus(
      count: count,
      limit: limit,
      isSubscribed: data.isSubscribed,
      canGenerate: count < limit,
    );
  }

  static Future<bool> canGenerate(String uid) async {
    return (await getStatus(uid)).canGenerate;
  }

  static Future<void> increment(String uid) async {
    final currentWeek = _currentWeekKey();
    final data = await _getData(uid);

    if (data.weekKey == currentWeek) {
      await _col.doc(uid).set({
        'weeklyCount': data.count + 1,
        'weekKey': currentWeek,
      }, SetOptions(merge: true));
    } else {
      // New week — reset count
      await _col.doc(uid).set({
        'weeklyCount': 1,
        'weekKey': currentWeek,
      }, SetOptions(merge: true));
    }
  }
}

class _UsageData {
  final int count;
  final String weekKey;
  final bool isSubscribed;
  const _UsageData({
    required this.count,
    required this.weekKey,
    required this.isSubscribed,
  });
}

class UsageStatus {
  final int count;
  final int limit;
  final bool isSubscribed;
  final bool canGenerate;

  const UsageStatus({
    required this.count,
    required this.limit,
    required this.isSubscribed,
    required this.canGenerate,
  });

  int get remaining => (limit - count).clamp(0, limit);

  /// Display string — subscribed users see "Unlimited"
  String get remainingLabel =>
      isSubscribed ? 'Unlimited' : '$remaining free this week';
}
