import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AttendanceButton extends StatefulWidget {
  final String coachId;
  final String studentId;
  final String groupId;
  final Color? primaryColor;

  const AttendanceButton({
    required this.coachId,
    required this.studentId,
    required this.groupId,
    this.primaryColor,
  });

  @override
  State<AttendanceButton> createState() => _AttendanceButtonState();
}

class _AttendanceButtonState extends State<AttendanceButton> {
  int _statusIndex = 0;
  final List<Color> _colors = [
    Colors.white54,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.redAccent,
  ];
  final List<IconData> _icons = [
    Icons.check_circle_outline,
    Icons.check_circle,
    Icons.schedule,
    Icons.cancel,
  ];
  final List<String> _statuses = ['', 'present', 'late', 'absent'];

  void _toggleStatus() async {
    final newIndex = (_statusIndex + 1) % 4;
    setState(() {
      _statusIndex = newIndex;
    });

    try {
      await FirestoreService.instance.saveAttendance(
        coachId: widget.coachId,
        studentId: widget.studentId,
        status: _statuses[newIndex],
        groupId: widget.groupId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asistencia actualizada'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _icons[_statusIndex],
        color: _colors[_statusIndex],
        size: 32,
      ),
      onPressed: _toggleStatus,
      tooltip: 'Marcar Asistencia',
    );
  }
}
