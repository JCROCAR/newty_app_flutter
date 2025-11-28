import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:io'; // Necesario para Platform

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:provider/provider.dart'; // Si necesitas el provider aquí

class FirebasePushService {
  
  static Future<void> init() async {
    // 1. Inicialización de Firebase
    // Asumiendo que ya se hizo en el main(), pero lo incluimos por buenas prácticas
    // await Firebase.initializeApp();

    final messaging = FirebaseMessaging.instance;
    
    // 2. Pedir Permisos
    await messaging.requestPermission();
    
    // 3. Configurar Handlers (Primer plano y Apertura)
    _setupMessageHandlers();
    
    // 4. Iniciar Escucha del Token
    _startTokenListener(messaging);
  }
  
  static void _setupMessageHandlers() {
    // Notificación en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Notificación recibida en primer plano');
      // ... Lógica de UI/Notificación local ...
    });

    // Notificación cuando se abre la app desde ella
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Notificación abrió la app');
      // ... Lógica de Navegación ...
    });
  }

  static void _startTokenListener(FirebaseMessaging messaging) {
    // Primero, intenta obtener el token inmediatamente si ya está disponible.
    // Usamos el try-catch para evitar que el fallo detenga el resto del código.
    messaging.getToken().then((token) {
      if (token != null) {
        print('📱 Token de FCM (Inmediato): $token');
        // saveTokenToBackend(token);
      }
    }).catchError((e) {
      // Capturamos el error APNS-token-not-set y lo ignoramos, esperando el listener.
      print('⚠️ Error al obtener token inicial (esperando listener): $e');
    });

    // Lo más importante: Escuchamos cuando el token ESTÉ listo o se refresque.
    messaging.onTokenRefresh.listen((newToken) {
      print('🔄 Token de FCM Actualizado/Disponible: $newToken');
      // Asegúrate de enviar este token a tu backend de Django/API
      // saveTokenToBackend(newToken);
    }).onError((error) {
      print("❌ Error al escuchar el token: $error");
    });
  }
}
