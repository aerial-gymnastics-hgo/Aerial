import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import '../models/rotation_model.dart';

/// Servicio singleton para programar alertas de rotación.
/// Arquitectura dual: flutter_local_notifications (mobile) + Web Notifications API (web).
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId   = 'rotation_alerts';
  static const _channelName = 'Alertas de Rotación';
  static const _channelDesc = 'Alertas de cambio de aparato para entrenadores';

  /// Inicializar el servicio. Llamar desde main() antes de runApp en mobile.
  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    tzdata.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(initSettings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// Programa alertas para el horario del coach.
  /// Retorna la cantidad de alertas programadas.
  Future<int> scheduleRotationAlerts({
    required List<RotationSlot> coachSchedule,
    required String coachName,
  }) async {
    final uniqueEndTimes =
        coachSchedule.map((e) => e.endTime).toSet().toList()..sort();
    int scheduledCount = 0;
    final now = DateTime.now();

    for (final timeStr in uniqueEndTimes) {
      if (timeStr.isEmpty) continue;
      final parts = timeStr.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

      final rotationTime = DateTime(now.year, now.month, now.day, hour, minute);
      final preAlarmTime  = rotationTime.subtract(const Duration(minutes: 5));

      if (kIsWeb) {
        _scheduleWebNotification(
          rotationTime: rotationTime,
          preAlarmTime: preAlarmTime,
          coachName: coachName,
          timeLabel: timeStr,
        );
        scheduledCount++;
      } else {
        if (preAlarmTime.isAfter(now)) {
          await _scheduleNativeNotification(
            id: _idFromTime(preAlarmTime, 'pre'),
            title: '⏰ Prepárate, $coachName',
            body: 'Cambio de aparato en 5 minutos ($timeStr).',
            scheduledTime: preAlarmTime,
            vibrationPattern: Int64List.fromList([0, 200, 100, 200]),
          );
          scheduledCount++;
        }
        if (rotationTime.isAfter(now)) {
          await _scheduleNativeNotification(
            id: _idFromTime(rotationTime, 'rot'),
            title: '🔄 ¡Rotación!',
            body: 'Es hora de cambiar de aparato ($timeStr).',
            scheduledTime: rotationTime,
            vibrationPattern: Int64List.fromList([0, 600, 100, 600, 100, 600]),
          );
          scheduledCount++;
        }
      }
    }
    return scheduledCount;
  }

  /// Cancela todas las alertas. En web, no hay nada que cancelar (son futures).
  Future<void> cancelAll() async {
    if (!kIsWeb) await _plugin.cancelAll();
  }

  // ── Mobile ──────────────────────────────────────────────────────────────────
  Future<void> _scheduleNativeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Int64List vibrationPattern,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      playSound: true,
      fullScreenIntent: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ── Web ─────────────────────────────────────────────────────────────────────
  void _scheduleWebNotification({
    required DateTime rotationTime,
    required DateTime preAlarmTime,
    required String coachName,
    required String timeLabel,
  }) {
    final now = DateTime.now();

    if (preAlarmTime.isAfter(now)) {
      final ms = preAlarmTime.difference(now).inMilliseconds;
      Future.delayed(Duration(milliseconds: ms), () {
        _callWebNotify('⏰ Prepárate, $coachName', 'Cambio de aparato en 5 minutos ($timeLabel).');
      });
    }

    if (rotationTime.isAfter(now)) {
      final ms = rotationTime.difference(now).inMilliseconds;
      Future.delayed(Duration(milliseconds: ms), () {
        _callWebNotify('🔄 ¡Rotación!', 'Es hora de cambiar de aparato ($timeLabel).');
      });
    }
  }

  void _callWebNotify(String title, String body) {
    try {
      js.context.callMethod('showRotationNotification', [title, body]);
    } catch (_) {}
  }

  int _idFromTime(DateTime dt, String prefix) =>
      (prefix.hashCode + dt.hour * 100 + dt.minute).abs() % 100000;
}
