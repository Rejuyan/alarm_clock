import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
