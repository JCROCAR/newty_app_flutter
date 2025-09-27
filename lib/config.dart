class Config {
  // URL base para desarrollo
  //static const String _baseUrlDev = 'http://10.0.2.2:8000/api';
  static const String _baseUrlDev = 'http://192.168.1.72:8000/api';

  // URL base para producción
  static const String _baseUrlProd = 'https://tuapi.com/api';

  static String get baseUrl {
    // Aquí decides si estás en modo desarrollo o producción
    // Puedes usar una variable de entorno o un flag en el código
    // Para este ejemplo, usaremos un booleano que deberás ajustar manualmente
    bool isProduction = false; // Cambia a true cuando estés en producción

    return isProduction ? _baseUrlProd : _baseUrlDev;
  }
}