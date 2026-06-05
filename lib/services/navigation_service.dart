import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/admin_dashboard.dart';
import '../screens/coach_dashboard.dart';
import '../screens/parent_dashboard.dart';
import '../screens/student_dashboard.dart';
import '../screens/caja_dashboard.dart';
import '../screens/landing_page.dart';

class NavigationService {
  static void navigateByRole(User user, BuildContext context) {
    Widget dashboard;
    switch (user.role) {
      case UserRole.admin:
        dashboard = AdminDashboard(currentUser: user);
        break;
      case UserRole.coach:
        dashboard = CoachDashboard(currentUser: user);
        break;
      case UserRole.parent:
        dashboard = ParentDashboard(currentUser: user);
        break;
      case UserRole.student:
        dashboard = StudentDashboard(currentUser: user);
        break;
      case UserRole.caja:
        dashboard = CajaDashboard(currentUser: user);
        break;
      case UserRole.viewer:
        dashboard = const LandingPage(); // fallback
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => dashboard),
      (route) => false,
    );
  }
}
