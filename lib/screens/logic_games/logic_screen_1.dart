import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:educapp_demo/utils/audio_singleton.dart';
import '../../services/actividad_registrada_service.dart';



class LogicScreen1 extends StatefulWidget {

  final int actividadId;

  LogicScreen1({required this.actividadId});

  @override
  _LogicScreen1State createState() => _LogicScreen1State();
}

class _LogicScreen1State extends State<LogicScreen1> {


  bool hasAnswered = false;
  bool isCorrectAnswer = false;
  int selectedIndex = -1; // Índice de la figura seleccionada

  late List<_TransportItem> _options;
  late _TransportItem _target;

  final BackgroundMusic _backgroundMusic = BackgroundMusic();
  bool _wasBackgroundMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();

    _wasBackgroundMusicPlaying = _backgroundMusic.isPlaying;
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.stop();
    }

  }

  void _initializeGame() {
    final allItems = [
      _TransportItem(name: 'vehículo', image: 'assets/vehiculo.png', gender: 'el'),
      _TransportItem(name: 'bicicleta', image: 'assets/bicicleta.png', gender: 'la'),
      _TransportItem(name: 'avión', image: 'assets/avion.png', gender: 'el'),
      _TransportItem(name: 'barco', image: 'assets/barco.png', gender: 'el'),
    ];
    allItems.shuffle();
    _target = allItems.first;
    _target.isCorrect = true;
    _options = [...allItems];
    _playAudio(_target.name.toLowerCase());
  }

  Future<void> _playAudio(String fileName) async {
    final player = AudioPlayer();
    await player.play(AssetSource('selecciona$fileName.wav'));
  }


  void checkAnswer(bool isCorrect, int index) {
    setState(() {
      selectedIndex = index;
      hasAnswered = true;
      isCorrectAnswer = isCorrect;
    });

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () async {
        if (mounted) {
          await PostRegistrarActividad.submitData(actividad: widget.actividadId);
          Navigator.pop(context);
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            hasAnswered = false;
            selectedIndex = -1;
          });
        }
      });
    }
  }


  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.play();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFFEAF6F6),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon:  Icon(Icons.volume_up, size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                  onPressed: () => _playAudio(_target.name.toLowerCase()),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TitleText(text: 'Selecciona ${_target.gender} ${_target.name}'),
                        SizedBox(height: screenSize.height * 0.03),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _options.length,
                                  (index) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: buildOption(index, _options[index], screenSize),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.04),
                        if (hasAnswered)
                          SizedBox(
                            height: isLandscape
                                ? screenSize.height * 0.25
                                : screenSize.height * 0.18,
                            width: screenSize.width * 0.4,
                            child: Lottie.asset(
                              isCorrectAnswer
                                  ? 'assets/correct.json'
                                  : 'assets/incorrect.json',
                              fit: BoxFit.contain,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildOption(int index, _TransportItem item, Size screenSize) {
    final isSelected = selectedIndex == index;
    final optionSize = screenSize.width * 0.18; // tamaño relativo adaptable

    return GestureDetector(
      onTap: () => checkAnswer(item.isCorrect, index),
      child: Container(
        width: optionSize,
        height: optionSize,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(item.image, fit: BoxFit.contain),
      ),
    );
  }

}

class _TransportItem {
  String name;
  String image;
  String gender;
  bool isCorrect;

  _TransportItem({required this.name, required this.image, required this.gender, this.isCorrect = false});
}


