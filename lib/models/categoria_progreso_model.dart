class CategoriaProgreso {
  final String categoria;
  final int total;
  final int completadas;
  final double porcentaje;

  CategoriaProgreso({
    required this.categoria,
    required this.total,
    required this.completadas,
    required this.porcentaje,
  });

  factory CategoriaProgreso.fromJson(Map<String, dynamic> json) {
    return CategoriaProgreso(
      categoria: json['categoria'],
      total: json['total'],
      completadas: json['completadas'],
      porcentaje: (json['porcentaje'] as num).toDouble(),
    );
  }
}
