import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';
import '../../services/actividad_registrada_service.dart';

class ScienceScreen2 extends StatefulWidget {
  final int actividadId;

  const ScienceScreen2({required this.actividadId, Key? key}) : super(key: key);

  @override
  _ScienceScreen2State createState() => _ScienceScreen2State();
}

class _ScienceScreen2State extends State<ScienceScreen2> {
  final List<Map<String, dynamic>> _questions = [
    {'animal': 'Vaca', 'image': 'assets/vaca.png', 'correctEnv': 'Granja'},
    {'animal': 'Tigre', 'image': 'assets/tigre.png', 'correctEnv': 'Jungla'},
    {'animal': 'Perro', 'image': 'assets/perro.png', 'correctEnv': 'Casa'},
    {'animal': 'Elefante', 'image': 'assets/elefante.png', 'correctEnv': 'Jungla'},
    {'animal': 'Pollito', 'image': 'assets/pollito.png', 'correctEnv': 'Granja'},
  ];

  late int _currentIndex;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _buttonsEnabled = true;

  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = _getRandomIndex();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _wasBackgroundMusicPlaying = _backgroundMusic.isPlaying;
    if (_wasBackgroundMusicPlaying) _backgroundMusic.stop();

    _playAudio('dondeviveesteanimal');
  }

  int _getRandomIndex() => DateTime.now().millisecondsSinceEpoch % _questions.length;

  Future<void> _playAudio(String filename) async {
    final player = AudioPlayer();
    await player.play(AssetSource('$filename.wav'));
  }

  void _checkAnswer(String selectedEnv) {
    if (!_buttonsEnabled) return;

    final currentQuestion = _questions[_currentIndex];
    final correctEnv = currentQuestion['correctEnv']?.toString().trim();

    final bool correct = selectedEnv.trim() == correctEnv;

    setState(() {
      _isCorrect = correct;
      _showFeedback = true;
      _buttonsEnabled = false;
    });

    if (correct) {
      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        await PostRegistrarActividad.submitData(actividad: widget.actividadId);
        if (mounted) Navigator.pop(context);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _showFeedback = false;
          _buttonsEnabled = true;
        });
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_wasBackgroundMusicPlaying) _backgroundMusic.play();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final question = _questions[_currentIndex];

    final double fontScale = size.width * 0.030;
    final double imageSize = size.height * 0.25;
    final double optionSize = size.height * 0.25;
    final double paddingV = size.height * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: paddingV / 2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Contenido principal
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 🔠 Texto + ícono de volumen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TitleText(text: '¿Dónde vive este animal?')
                      ),
                      SizedBox(width: size.width * 0.02),
                      IconButton(
                        icon: Icon(Icons.volume_up,
                            size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                        onPressed: () => _playAudio('dondeviveesteanimal'),
                      ),
                    ],
                  ),

                  // 🐮 Imagen del animal
                  Image.asset(
                    question['image'],
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),

                  // 🏡 Opciones
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: size.width * 0.04,
                    runSpacing: size.height * 0.03,
                    children: ['Granja', 'Jungla', 'Casa'].map((env) {
                      String imagePath;
                      switch (env) {
                        case 'Granja':
                          imagePath = 'assets/granja.png';
                          break;
                        case 'Jungla':
                          imagePath = 'assets/jungla.png';
                          break;
                        case 'Casa':
                          imagePath = 'assets/casa.png';
                          break;
                        default:
                          imagePath = '';
                      }

                      return GestureDetector(
                        onTap: _buttonsEnabled ? () => _checkAnswer(env) : null,
                        child: Column(
                          children: [
                            Container(
                              width: optionSize,
                              height: optionSize,
                              padding: EdgeInsets.all(size.width * 0.01),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.transparent,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Image.asset(imagePath, fit: BoxFit.cover),
                            ),
                            SizedBox(height: size.height * 0.015),
                            Text(
                              env,
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  fontSize: fontScale * 0.9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEF898F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // 🎉 Animación centrada sin overlay
              if (_showFeedback)
                Positioned(
                  child: SizedBox(
                    width: size.width * 0.45,
                    height: size.height * 0.6,
                    child: Lottie.asset(
                      _isCorrect ? 'assets/correct.json' : 'assets/incorrect.json',
                      fit: BoxFit.contain,
                      repeat: false,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
