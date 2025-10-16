import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'models/surat.dart';
import 'services/surat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Check if running on Linux and provide a default configuration
  if (defaultTargetPlatform == TargetPlatform.linux) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyCKKYzCFxN8Og16wQY9e701ODwIvuXRhUA',
        appId: '1:635645933703:web:83f0632ab32f39ca2e6022',
        messagingSenderId: '635645933703',
        projectId: 'pml3e2-a1af5',
        authDomain: 'pml3e2-a1af5.firebaseapp.com',
        databaseURL: 'https://pml3e2-a1af5-default-rtdb.firebaseio.com',
        storageBucket: 'pml3e2-a1af5.firebasestorage.app',
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surat Mobile Sukorame',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Surat Mobile Sukorame'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SuratService _suratService = SuratService();
  bool _isLoading = false;
  String _message = '';

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _message = 'Menguji koneksi ke Firebase...';
    });

    try {
      // Mencoba menambahkan surat test
      final surat = Surat(
        id: '',
        nomor: 'TEST-001/2025',
        jenis: 'Surat Test',
        pemohon: 'Test User',
        nik: '3501234567890001',
        tanggal: DateTime.now().toIso8601String(),
        status: 'test',
        keterangan: 'Surat test koneksi Firebase',
      );

      final id = await _suratService.tambahSurat(surat);

      // Jika berhasil, hapus surat test
      await _suratService.hapusSurat(id);

      setState(() {
        _message = 'Koneksi ke Firebase berhasil!\nID Test: $id';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _testFirebaseConnection,
                child: const Text('Test Koneksi Firebase'),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
