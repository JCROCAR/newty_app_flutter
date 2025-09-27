import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushService {
  static Future<void> init() async {
    await Firebase.initializeApp();

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();
    print('TOKENN');

    final token = await messaging.getToken();
    print('📱 Token de FCM: $token');

    // Notificación en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Notificación recibida en primer plano');
      print('🔔 Título: ${message.notification?.title}');
      print('📝 Cuerpo: ${message.notification?.body}');
    });

    // Notificación cuando se abre la app desde ella
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Notificación abrió la app');
      // Aquí puedes navegar si lo deseas
    });
  }
}
