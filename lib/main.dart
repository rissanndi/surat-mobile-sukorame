import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:surat_mobile_sukorame/firebase_options.dart';
import 'package:surat_mobile_sukorame/screens/auth/auth_gate.dart';
import 'package:surat_mobile_sukorame/screens/account_screen.dart';
import 'package:surat_mobile_sukorame/screens/chat_list_screen.dart';
import 'package:surat_mobile_sukorame/screens/form_surat_screen.dart';
import 'package:surat_mobile_sukorame/screens/riwayat_surat_screen.dart';
import 'package:surat_mobile_sukorame/screens/notification_screen.dart';
import 'package:surat_mobile_sukorame/services/app_state.dart';
import 'package:surat_mobile_sukorame/services/notification_service.dart';
import 'package:surat_mobile_sukorame/theme/app_theme.dart';

// Fungsi untuk menangani notifikasi saat aplikasi di background/terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Pastikan Firebase terinisialisasi
  print("Menangani notifikasi background: ${message.messageId}");
  // Anda bisa tambahkan logika di sini jika perlu, misal menyimpan notifikasi ke database lokal.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://kbkaqntbkulplmmwwmhw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtia2FxbnRia3VscGxtbXd3bWh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MTk0MTYsImV4cCI6MjA3NTM5NTQxNn0.UL3MlABGTLyT4Nvaz8Zzh7Oh9gyI1RM13VEGZX-rAnQ',
  );
  
  // Setup listener notifikasi background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationService _notificationService = NotificationService();
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await Future.delayed(Duration.zero); // Wait for widget to be mounted
    if (!mounted) return;
    await _notificationService.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _appState,
      child: Builder(
        builder: (context) {
          final appState = context.watch<AppState>();
          
          return MaterialApp(
            title: 'Aplikasi Surat Sukorame',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,
            home: const AuthGate(),
            routes: {
              '/home': (context) => const AuthGate(),
              '/profile': (context) => const AccountScreen(),
              '/surat/buat': (context) => FormSuratScreen(userUid: FirebaseAuth.instance.currentUser?.uid ?? ''),
              '/surat/riwayat': (context) => const RiwayatSuratScreen(),
              '/chat': (context) => const ChatListScreen(),
              '/notifications': (context) => const NotificationScreen(),
            },
          );
        },
      ),
    );
  }
}