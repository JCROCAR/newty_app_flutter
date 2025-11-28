import 'package:educapp_demo/screens/language_games/LanguageGamesScreen.dart';
import 'package:educapp_demo/screens/math_games/MathGamesScreen.dart';
import 'package:educapp_demo/screens/science_games/ScienceGamesScreen.dart';
import 'package:educapp_demo/screens/logic_games/logic_screen_1.dart';
import 'package:educapp_demo/screens/math_games/math_screen_1.dart';
import 'package:educapp_demo/screens/transition/parents_section_access_screen.dart';
import 'package:educapp_demo/screens/science_games/science_screen_1.dart';
import 'package:educapp_demo/screens/logic_games/LogicGamesScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class HomeScreen extends StatefulWidget {
  final String userName;

  HomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BackgroundMusic _music = BackgroundMusic();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String _selectedLevel = "Nivel 1"; // valor por defecto

  final List<Map<String, String>> categories = [
    {'name': 'LÓGICA', 'image': 'logica_categoria.png'},
    {'name': 'MATEMÁTICA', 'image': 'matematica_categoria.png'},
    {'name': 'CIENCIAS', 'image': 'ciencia_categoria.png'},
    {'name': 'LENGUAJE', 'image': 'lenguaje_categoria.png'},
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_music.isEnabled) {
      _music.play();
    }

    _loadSavedLevel(); // 🔹 Cargar el nivel guardado
  }

  Future<void> _loadSavedLevel() async {
    String? savedLevel = await _storage.read(key: 'selectedLevel');
    if (savedLevel != null) {
      setState(() {
        _selectedLevel = savedLevel;
      });
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

  void _navigateToCategory(String categoryName) {
    Widget screen;
    switch (categoryName) {
      case 'LÓGICA':
        screen = LogicGamesSection();
        break;
      case 'MATEMÁTICA':
        screen = MathGamesSection();
        break;
      case 'CIENCIAS':
        screen = ScienceGamesSection();
        break;
      case 'LENGUAJE':
        screen = LanguageGamesSection();
        break;
      default:
        screen = CategoryScreen(categoryName: categoryName);
        break;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/fondo_azul.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // 🔹 Nivel centrado arriba
          Positioned(
            top: 16.0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: Color(0xFFEF898F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFFEF898F),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFEF898F).withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _selectedLevel,
                  style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Avatar + nombre usuario (a la izquierda)
          Positioned(
            top: 16.0,
            left: 16.0,
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: const DecorationImage(
                        image: AssetImage('assets/Newtymascota.png'),
                        fit: BoxFit.contain,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.userName,
                    style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 🔹 Categorías
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GestureDetector(
                        onTap: () => _navigateToCategory(category['name']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: 140,
                          height: 180,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/${category['image']}',
                                  width: 115,
                                  height: 115,
                                ),
                              ),
                              Text(
                                category['name']!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    color: Color(0xFFED7749).withOpacity(0.8),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFF2A452),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 94,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage('assets/Newtymascota.png'),
                        fit: BoxFit.contain,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Text(
                    'Newty',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'kbdarkhour',
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.emoji_people,
                size: 40,
                color: Colors.blue,
              ),
              title: Text(
                'Padres',
                style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParentSectionAccess(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  final String categoryName;

  CategoryScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Center(
        child: Text(
          'Bienvenido a la categoría $categoryName',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class LogicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lógica')),
      body: Center(child: Text('Contenido de Lógica')),
    );
  }
}

class MathScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Matemática')),
      body: Center(child: Text('Contenido de Matemática')),
    );
  }
}

class ScienceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ciencias')),
      body: Center(child: Text('Contenido de Ciencias')),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lenguaje')),
      body: Center(child: Text('Contenido de Lenguaje')),
    );
  }
}
