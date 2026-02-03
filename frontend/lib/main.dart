import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/damage_provider.dart';
import 'providers/insurance_provider.dart';
import 'providers/health_records_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const VehicleHealthTrackerApp());
}

class VehicleHealthTrackerApp extends StatelessWidget {
  const VehicleHealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DamageProvider()),
        ChangeNotifierProvider(create: (_) => InsuranceProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordsProvider()),
      ],
      child: MaterialApp(
        title: 'Vehicle Health Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const DashboardScreen(),
      ),
    );
  }
}
