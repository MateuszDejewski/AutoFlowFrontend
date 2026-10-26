import 'package:flutter/material.dart';

import 'screens/manager_calendar_screen.dart';

void openManagerApp(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const ManagerCalendarScreen()),
  );
}
