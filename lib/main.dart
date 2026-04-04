import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gram_setu/core/theme.dart';
import 'package:gram_setu/core/theme_provider.dart';
import 'package:gram_setu/core/user_provider.dart';

import 'package:gram_setu/pages/home.dart';
import 'package:gram_setu/pages/splash.dart';
import 'package:gram_setu/pages/login.dart';
import 'package:gram_setu/pages/asha_worker.dart';
import 'package:gram_setu/pages/emergency.dart';
import 'package:gram_setu/pages/panchayat.dart';

import 'package:gram_setu/pages/doctor.dart';
import 'package:gram_setu/pages/patient.dart';
import 'package:gram_setu/pages/consultation_screen.dart';
import 'package:gram_setu/pages/prescription_viewer.dart';
import 'package:gram_setu/pages/medicine_reminder.dart';
import 'package:gram_setu/pages/health_history.dart';
import 'package:gram_setu/pages/health_assistant.dart';
import 'package:gram_setu/pages/profile_dashboard.dart';
import 'package:gram_setu/pages/vitals_recorder.dart';
import 'package:gram_setu/pages/new_patient_registration.dart';
import 'package:gram_setu/pages/new_doctor_registration.dart';
import 'package:gram_setu/pages/new_asha_registration.dart';
import 'package:gram_setu/pages/new_panchayat_registration.dart';
import 'package:gram_setu/pages/panchayat_auth_screen.dart';
import 'package:gram_setu/pages/settings_screen.dart';
import 'package:gram_setu/pages/add_patient_screen.dart';
import 'package:gram_setu/pages/asha_consultation_screen.dart';
import 'package:gram_setu/pages/health_awareness_screen.dart';
import 'package:gram_setu/pages/edit_profile.dart';
import 'package:gram_setu/pages/pending_consultations_screen.dart';
import 'package:gram_setu/pages/panchayat_records_screen.dart';
import 'package:gram_setu/pages/consultation_requests_screen.dart';
import 'package:gram_setu/pages/accepted_consultations_screen.dart';
import 'package:gram_setu/pages/search_patient_screen.dart';
import 'package:gram_setu/pages/leaderboard_screen.dart';
import 'package:gram_setu/pages/search_prescription_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const GramSetuApp(),
    ),
  );
}

class GramSetuApp extends StatelessWidget {
  const GramSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Gram Setu',
      debugShowCheckedModeBanner: false,
      theme: GramSetuTheme.lightTheme,
      darkTheme: GramSetuTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        final routes = <String, WidgetBuilder>{
          '/splash': (context) => const SplashScreen(),
          '/home': (context) => const RoleSelectionScreen(),
          '/login': (context) => const LoginScreen(),
          '/patient': (context) => const PatientDashboard(),
          '/doctor': (context) => const DoctorDashboard(),
          '/asha_worker': (context) => const AshaWorkerDashboard(),
          '/panchayat': (context) => const PanchayatDashboard(),
          '/emergency': (context) => const EmergencyScreen(),
          '/consultation': (context) => const ConsultationScreen(),
          '/prescriptions': (context) => const PrescriptionViewer(),
          '/medicine_reminder': (context) => const MedicineReminderScreen(),
          '/health_history': (context) => const HealthHistoryScreen(),
          '/health_assistant': (context) => const HealthAssistantScreen(),
          '/profile': (context) => const ProfileDashboard(),
          '/vitals_recorder': (context) => const VitalsRecorderScreen(),
          '/patient_registration': (context) => const NewPatientRegistrationScreen(),
          '/doctor_registration': (context) => const NewDoctorRegistrationScreen(),
          '/asha_registration': (context) => const NewAshaRegistrationScreen(),
          '/panchayat_registration': (context) => const NewPanchayatRegistrationScreen(),
          '/panchayat_auth': (context) => const PanchayatAuthScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/add_patient': (context) => const AddPatientScreen(),
          '/asha_consultation': (context) => const AshaConsultationScreen(),
          '/health_awareness': (context) => const HealthAwarenessScreen(),
          '/edit_profile': (context) => const EditProfileScreen(),
          '/pending_consultations': (context) => const PendingConsultationsScreen(),
          '/panchayat_records': (context) => const PanchayatRecordsScreen(),
          '/consultation_requests': (context) => const ConsultationRequestsScreen(),
          '/accepted_consultations': (context) => const AcceptedConsultationsScreen(),
          '/search_patient': (context) => const SearchPatientScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/view_prescription_search': (context) => const SearchPrescriptionScreen(),
        };

        final builder = routes[settings.name];
        if (builder == null) return null;

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
