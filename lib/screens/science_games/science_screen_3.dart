import 'package:educapp_demo/widgets/instructions_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:educapp_demo/utils/audio_singleton.dart'; // Importa tu Singleton
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../services/actividad_registrada_service.dart';



class ScienceScreen3 extends StatefulWidget {
  final int actividadId;

  ScienceScreen3({required this.actividadId});

  @override
  _ScienceScreen3State createState() => _ScienceScreen3State();
}

class _ScienceScreen3State extends State<ScienceScreen3> {


  final Set<String> _spokenLabels = {};

  late AudioPlayer audioPlayer; // Reproductor para el sonido del pollo
  final BackgroundMusic _backgroundMusic = BackgroundMusic(); // Singleton para la música de fondo
  bool _wasBackgroundMusicPlaying = false; // Estado previo de la música de fondo

  final List<Map<String, String>> items = [
    {'label': 'flor', 'image': 'assets/flor.png'},
    {'label': 'árbol', 'image': 'assets/arbol.png'},
    {'label': 'semilla', 'image': 'assets/semilla.png'},
    {'label': 'hoja', 'image': 'assets/hoja.png'},
  ];

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    // Verificar si la música de fondo está sonando y detenerla si es necesario
    _wasBackgroundMusicPlaying = _backgroundMusic.isPlaying;
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.stop();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _playAudio('averiguaelnombre');
  }

  Future<void> _playAudio(String label) async {
    final player = AudioPlayer();
    await player.play(AssetSource('$label.wav'));
  }


  Future<void> _handleTap(String label) async {
    await _playAudio(label.toLowerCase().replaceAll('á', 'a'));
    _spokenLabels.add(label);

    if (_spokenLabels.length == items.length) {
      await Future.delayed(Duration(milliseconds: 600)); // breve pausa tras último audio
      _showSuccessAndExit();
    }
  }

  void _showSuccessAndExit() async {
    // Mostrar animación de forma controlada
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(Duration(seconds: 2), () async {
          // Cierra el dialog
          Navigator.of(dialogContext).pop();
          await PostRegistrarActividad.submitData(actividad: widget.actividadId);
          Navigator.of(context).pop();
        });

        return Center(
          child: Container(
            width: 200,
            height: 200,
            child: Lottie.asset('assets/correct.json', repeat: false),
          ),
        );
      },
    );
  }



  Widget _buildItem(String label, String imageAsset) {
    return GestureDetector(
      onTap: () => _handleTap(label),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            child: Padding(

              padding: const EdgeInsets.all(8.0),
              child: Image.asset(imageAsset, width: 90, height: 90),
            ),
          ),
          SizedBox(height: 15),
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: GoogleFonts.openSans(
              textStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFFEF898F)),
            )
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Restaurar la música de fondo si estaba sonando antes de entrar
    if (_wasBackgroundMusicPlaying) {
      _backgroundMusic.play();
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2FBFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔠 Título + botón de audio
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: TitleText(text: 'Averigua el nombre de cada imagen')
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon:  Icon(Icons.volume_up, size: 40, color: Color(0xFFFF9800).withOpacity(0.8)),
                          onPressed: () {
                            _playAudio('averiguaelnombre');
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: isLandscape ? 20 : 10),

                    // 🖼️ Grid responsivo
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: isLandscape ? 4 : 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: isLandscape ? 0.9 : 0.8,
                        children: items
                            .map((item) => _buildItem(item['label']!, item['image']!))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }


}
