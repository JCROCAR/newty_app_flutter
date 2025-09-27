import 'package:educapp_demo/screens/principal_screen.dart';
import 'package:educapp_demo/screens/settings_screen.dart';
import 'package:educapp_demo/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ParentsSectionScreen(),
    );
  }
}

class ParentsSectionScreen extends StatefulWidget {
  @override
  _ParentsSectionScreenState createState() => _ParentsSectionScreenState();
}

class _ParentsSectionScreenState extends State<ParentsSectionScreen> {
  int _selectedIndex = 0; // Índice de la pantalla seleccionada

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    // Forzar orientación horizontal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Lista de pantallas
  final List<Widget> _screens = [
    StatisticsScreen(), // Pantalla de estadísticas (pantalla por defecto)
    SettingsScreen(),   // Pantalla de configuración
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia de pantalla
    });
  }

  @override
  void dispose() {
    // Restaurar todas las orientaciones al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF87C5C4),
        leading: IconButton(
          icon: Icon(Icons.home), // Ícono de casita para "Home"
          color: Colors.white, // Color del ícono para que combine con el diseño
          onPressed: () async {
            // Forzar orientación horizontal antes de navegar
            await SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);

            // Luego navega a la pantalla principal
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(userName: 'JC'),
              ),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        iconSize: 40,
        selectedFontSize: 18,
        unselectedFontSize: 14,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}



