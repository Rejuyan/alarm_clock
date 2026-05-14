import 'package:alarm/alarm.dart';
import 'package:alarm/model/notification_settings.dart';
import 'package:alarm/model/volume_settings.dart';
import 'package:flutter/material.dart';

enum AlarmCategory {
  sleep,
  salat,
  meeting,
  medicine,
  focus,
  custom,
}

extension AlarmCategoryExtension on AlarmCategory {
  String get name {
    switch (this) {
      case AlarmCategory.sleep:
        return 'Sleep';
      case AlarmCategory.salat:
        return 'Salat';
      case AlarmCategory.meeting:
        return 'Meeting';
      case AlarmCategory.medicine:
        return 'Medicine';
      case AlarmCategory.focus:
        return 'Focus';
      case AlarmCategory.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case AlarmCategory.sleep:
        return Icons.bedtime_outlined;
      case AlarmCategory.salat:
        return Icons.mosque_outlined;
      case AlarmCategory.meeting:
        return Icons.work_outline;
      case AlarmCategory.medicine:
        return Icons.medical_services_outlined;
      case AlarmCategory.focus:
        return Icons.timer_outlined;
      case AlarmCategory.custom:
        return Icons.alarm_outlined;
    }
  }

  String get defaultRingtone {
    switch (this) {
      case AlarmCategory.sleep:
        return 'assets/wake_up.mp3';
      case AlarmCategory.salat:
        return 'assets/salat.mp3';
      case AlarmCategory.meeting:
        return 'assets/meeting.mp3';
      case AlarmCategory.medicine:
        return 'assets/reminder.mp3';
      case AlarmCategory.focus:
        return 'assets/focus.mp3';
      case AlarmCategory.custom:
        return 'assets/alarm.mp3';
    }
  }
}

class SmartAlarmModel {
  final int id;
  final DateTime dateTime;
  final AlarmCategory category;
  final String? label;
  final bool enabled;
  final bool shakeToStop;
  final bool mathChallenge;

  SmartAlarmModel({
    required this.id,
    required this.dateTime,
    this.category = AlarmCategory.custom,
    this.label,
    this.enabled = true,
    this.shakeToStop = false,
    this.mathChallenge = false,
  });

  AlarmSettings toAlarmSettings() {
    return AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: category.defaultRingtone,
      loopAudio: true,
      vibrate: true,
      notificationSettings: NotificationSettings(
        title: category.name,
        body: label ?? 'Time for ${category.name}!',
        stopButton: 'Stop',
      ),
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: category == AlarmCategory.sleep 
            ? const Duration(seconds: 30) 
            : Duration.zero,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'category': category.index,
      'label': label,
      'enabled': enabled,
      'shakeToStop': shakeToStop,
      'mathChallenge': mathChallenge,
    };
  }

  factory SmartAlarmModel.fromJson(Map<String, dynamic> json) {
    return SmartAlarmModel(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      category: AlarmCategory.values[json['category'] ?? 0],
      label: json['label'],
      enabled: json['enabled'] ?? true,
      shakeToStop: json['shakeToStop'] ?? false,
      mathChallenge: json['mathChallenge'] ?? false,
    );
  }
}
