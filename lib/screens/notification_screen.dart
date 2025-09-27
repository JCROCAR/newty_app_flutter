import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/notificacion_service.dart';
import '../../providers/auth_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _selectedDays = [];

  String? _correoUsuario;

  final List<String> _daysOfWeek = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _correoUsuario = authProvider.userEmail;
      });
      print("CORRREOOO");
      print(authProvider.userEmail);
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    if (_correoUsuario == null) return;

    final data = await _notificationService.getSettings(_correoUsuario!);
    if (data != null) {
      List<String> diasGuardados = List<String>.from(data['dias'] ?? []);
      String? horaGuardada = data['hora'];

      if (horaGuardada != null) {
        final parts = horaGuardada.split(':');
        setState(() {
          _selectedDays = diasGuardados;
          _selectedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        });
      }

      print('Días recibidos: $diasGuardados');

    }
  }

  void _saveSettings() async {
    if (_correoUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró el correo del usuario')),
      );
      return;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona al menos un día')),
      );
      return;
    }

    final horaStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final success = await _notificationService.saveSettings(
      correo: _correoUsuario!,
      dias: _selectedDays,
      hora: horaStr,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configuración guardada')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar configuración')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyleTitle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: 'Comic Sans MS',
    );

    final cardColor = Colors.blue[50];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardColor,
        iconTheme: IconThemeData(color: Colors.orange),
        elevation: 0,
      ),
      backgroundColor: cardColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Días de notificación',
              style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                  )
              ),
            ),
            const SizedBox(height: 10),
            ..._daysOfWeek.map((day) {
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: CheckboxListTile(
                  title: Text(
                    day,
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87
                      )
                    ),
                  ),
                  activeColor: Colors.orange,
                  checkColor: Colors.white,
                  value: _selectedDays.contains(day),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hora: ${_selectedTime.format(context)}',
                      style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                          )
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFED7749),
                        padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(alwaysUse24HourFormat: false),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedTime = picked;
                          });
                        }
                      },
                      child: Text(
                        'Elegir hora',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          )
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7C3AC8),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Guardar',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
