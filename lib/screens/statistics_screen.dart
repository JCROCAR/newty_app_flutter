import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria_progreso_model.dart';
import '../services/actividad_progreso_service.dart';
import '../providers/auth_provider.dart'; // ajusta la ruta según tu proyecto

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? _correoUsuario;
  late Future<List<CategoriaProgreso>> _futureProgreso;

  @override
  void initState() {
    super.initState();
    // Esperar a que el widget esté montado para acceder a Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _correoUsuario = authProvider.userEmail;
        _futureProgreso = ActividadProgresoService().fetchProgresoCategorias(_correoUsuario!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_correoUsuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<CategoriaProgreso>>(
        future: _futureProgreso,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final categorias = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estadísticas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...categorias.map((cat) => CategoryTile(
                title: cat.categoria,
                progress: cat.porcentaje,
                icon: _getIconForCategory(cat.categoria),
                iconColor: _getColorForCategory(cat.categoria),
              )),
            ],
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String nombre) {
    switch (nombre) {
      case 'Lenguaje':
        return Icons.menu_book;
      case 'Logica':
        return Icons.extension;
      case 'Matematicas':
        return Icons.calculate;
      case 'Ciencia':
        return Icons.science;
      default:
        return Icons.category;
    }
  }

  Color _getColorForCategory(String nombre) {
    switch (nombre) {
      case 'Lenguaje':
        return Colors.orange;
      case 'Logica':
        return Colors.purple;
      case 'Matematicas':
        return Colors.blue;
      case 'Ciencia':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double progress;
  final Color iconColor;

  const CategoryTile({
    required this.icon,
    required this.title,
    required this.progress,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 50),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Comic Sans MS',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade300,
                      color: iconColor,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("${(progress * 100).toStringAsFixed(0)}%"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
