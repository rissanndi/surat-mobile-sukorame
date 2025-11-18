import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/screens/account_screen.dart';
import 'package:surat_mobile_sukorame/screens/home_screen.dart';
import 'package:surat_mobile_sukorame/screens/webview_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex =
      0; // 0 untuk Beranda, 1 untuk WebView, 2 untuk Akun, 3 untuk About

  // Daftar halaman yang akan ditampilkan
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    WebViewScreen(
      url: 'https://youtu.be/DsKELePdcvs?si=TF0SHV1FI1vvN9BV',
      title: 'Video Kelurahan Sukorame',
    ),
    AccountScreen(),
    WebViewScreen(
      url: 'https://kel-sukorame.kedirikota.go.id/index.php/profil',
      title: 'Profil Kelurahan Sukorame',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
