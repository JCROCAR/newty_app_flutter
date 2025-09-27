import 'package:educapp_demo/config.dart';
import 'package:educapp_demo/utils/audio_singleton.dart'; // Importa tu Singleton
import 'package:educapp_demo/screens/login/login_screen.dart';
import 'package:educapp_demo/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackgroundMusic _music = BackgroundMusic();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  late bool _isSoundOn; // Estado del sonido
  String _selectedLanguage = 'es'; // Idioma seleccionado
  String _selectedLevel = 'Nivel 1'; // Nivel seleccionado por defecto

  @override
  void initState() {
    super.initState();
    // Inicializamos _isSoundOn con el estado actual del Singleton
    _isSoundOn = _music.isEnabled;

    // Forzar orientación vertical y ocultar barra de estado
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Cargar nivel guardado
    _loadSavedLevel();
  }

  Future<void> _loadSavedLevel() async {
    String? savedLevel = await _storage.read(key: 'selectedLevel');
    if (savedLevel != null) {
      setState(() {
        _selectedLevel = savedLevel;
      });
    }
  }

  Future<bool> deleteAccount(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.accessToken;

    if (token == null) return false;

    final id = await _storage.read(key: 'padresID');
    if (id == null) return false;

    final int idpadres = int.parse(id);
    final url = Uri.parse('${Config.baseUrl}/padres/padres/$idpadres/');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await authProvider.logout();
        await _storage.delete(key: 'padresID');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cuenta eliminada correctamente.')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
        return true;
      } else {
        print('Error eliminando cuenta: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando la cuenta.')),
        );
        return false;
      }
    } catch (e) {
      print('Error en deleteAccount: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error eliminando la cuenta.')),
      );
      return false;
    }
  }

  void _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar cuenta',
          style: GoogleFonts.openSans(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF2A452),
            ),
          ),
        ),
        content: Text(
          '¿Estás seguro de eliminar tu cuenta permanentemente?',
          style: GoogleFonts.openSans(
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.openSans(
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.openSans(
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      final success = await deleteAccount(context);
      if (success) {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar la cuenta')),
        );
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text(
          'Configuración',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),

        // Idioma
        Card(
          color: Colors.blue[50],
          child: ListTile(
            leading: Icon(Icons.language, color: Colors.blue),
            title: Text(
              'Idioma',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(
                  value: 'es',
                  child: Row(
                    children: [
                      Image.asset('assets/SPAIN.png', width: 24),
                      SizedBox(width: 8),
                      Text('Español'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      Image.asset('assets/USA.png', width: 24),
                      SizedBox(width: 8),
                      Text('English'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 15),

        // Nivel
        Card(
          color: Colors.blue[50],
          child: ListTile(
            leading: Icon(Icons.star, color: Colors.purple),
            title: Text(
              'Nivel',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            trailing: DropdownButton<String>(
              value: _selectedLevel,
              items: [
                DropdownMenuItem(
                  value: 'Nivel 1',
                  child: Text('Nivel 1'),
                ),
                DropdownMenuItem(
                  value: 'Nivel 2',
                  child: Text('Nivel 2'),
                ),
                DropdownMenuItem(
                  value: 'Nivel 3',
                  child: Text('Nivel 3'),
                ),
              ],
              onChanged: (value) async {
                setState(() {
                  _selectedLevel = value!;
                });
                await _storage.write(key: 'selectedLevel', value: _selectedLevel);
              },
            ),
          ),
        ),
        SizedBox(height: 15),

        // Música
        Card(
          color: Colors.blue[50],
          child: ListTile(
            leading: Icon(Icons.music_note, color: Colors.green),
            title: Text(
              'Música',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            trailing: Switch(
              activeColor: Colors.green,
              value: _isSoundOn,
              onChanged: (value) {
                setState(() {
                  _isSoundOn = value;
                  if (value) {
                    _music.enable();
                  } else {
                    _music.disable();
                  }
                });
              },
            ),
          ),
        ),
        SizedBox(height: 15),

        // Correo notificaciones
        Card(
          color: Colors.blue[50],
          child: ListTile(
            leading: Icon(Icons.email, color: Colors.orange),
            title: Text(
              'Correo de notificación',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            subtitle: Text('Configurar correo y horario'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationSettingsScreen()),
              );
            },
          ),
        ),
        SizedBox(height: 15),

        // Eliminar cuenta
        Card(
          color: Colors.blue[50],
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text(
              'Eliminar cuenta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => _showDeleteConfirmation(context),
          ),
        ),
        SizedBox(height: 15),

        // Cerrar sesión
        Card(
          color: Colors.blue[50],
          child: ListTile(
            leading: Icon(Icons.logout, color: Colors.black),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();

              await SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}
