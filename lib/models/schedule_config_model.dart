
class ScheduleConfig {
  final String startTime;
  final String endTime;
  final int blockDuration;
  final List<String> generatedSlots;

  ScheduleConfig({
    required this.startTime,
    required this.endTime,
    required this.blockDuration,
    required this.generatedSlots,
  });

  factory ScheduleConfig.fromMap(Map<String, dynamic> map) {
    return ScheduleConfig(
      startTime: map['startTime'] ?? '16:00',
      endTime: map['endTime'] ?? '20:00',
      blockDuration: map['blockDuration'] ?? 30,
      generatedSlots: List<String>.from(map['generatedSlots'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'blockDuration': blockDuration,
      'generatedSlots': generatedSlots,
    };
  }

  factory ScheduleConfig.defaultConfig() {
    return ScheduleConfig(
      startTime: '16:00',
      endTime: '20:00',
      blockDuration: 30,
      generatedSlots: [
        '16:00-16:30',
        '16:30-17:00',
        '17:00-17:30',
        '17:30-18:00',
        '18:00-18:30',
        '18:30-19:00',
        '19:00-19:30',
        '19:30-20:00',
      ],
    );
  }
}
