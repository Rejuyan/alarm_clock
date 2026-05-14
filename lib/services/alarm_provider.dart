import 'dart:async';
import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:alarm_clock/models/alarm_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final alarmListProvider = AsyncNotifierProvider<AlarmListNotifier, List<AlarmSettings>>(() {
  return AlarmListNotifier();
});

class AlarmListNotifier extends AsyncNotifier<List<AlarmSettings>> {
  @override
  FutureOr<List<AlarmSettings>> build() async {
    return _fetchAlarms();
  }

  Future<List<AlarmSettings>> _fetchAlarms() async {
    final alarms = await Alarm.getAlarms();
    alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return alarms;
  }

  Future<void> refreshAlarms() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAlarms());
  }

  Future<void> addAlarm(AlarmSettings settings) async {
    await Alarm.set(alarmSettings: settings);
    await refreshAlarms();
  }

  Future<void> removeAlarm(int id) async {
    await Alarm.stop(id);
    await refreshAlarms();
  }
}

final alarmHistoryProvider = AsyncNotifierProvider<AlarmHistoryNotifier, List<SmartAlarmModel>>(() {
  return AlarmHistoryNotifier();
});

class AlarmHistoryNotifier extends AsyncNotifier<List<SmartAlarmModel>> {
  static const _historyKey = 'alarm_history';

  @override
  FutureOr<List<SmartAlarmModel>> build() async {
    return _fetchHistory();
  }

  Future<List<SmartAlarmModel>> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);
    
    if (historyJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((e) => SmartAlarmModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addToHistory(SmartAlarmModel alarm) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHistory = await _fetchHistory();
    
    // Remove duplicates (same category & time of day)
    currentHistory.removeWhere((a) => 
      a.category == alarm.category && 
      a.dateTime.hour == alarm.dateTime.hour && 
      a.dateTime.minute == alarm.dateTime.minute
    );
    
    // Add to top of list
    currentHistory.insert(0, alarm);
    
    // Keep only last 10
    if (currentHistory.length > 10) {
      currentHistory.removeLast();
    }
    
    final encoded = jsonEncode(currentHistory.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
    
    state = AsyncValue.data(currentHistory);
  }
  
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    state = const AsyncValue.data([]);
  }
}
