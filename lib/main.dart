import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'generated/i18n.dart';
import 'route_generator.dart';
import 'src/controllers/controller.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  await Firebase.initializeApp();

  // Set background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: settingRepo.setting,
      builder: (context, Setting _setting, _) {
        // Firebase Messaging (new API)
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        messaging.subscribeToTopic('wamyada');

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print("onMessage: ${message.notification?.title}");
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print("onMessageOpenedApp: ${message.notification?.title}");
        });

        return MaterialApp(
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          title: _setting.appName,
          initialRoute: '/Splash',
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          locale: _setting.mobileLanguage.value,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          localeListResolutionCallback:
              S.delegate.listResolution(fallback: const Locale('en', '')),

          /// THEME FIXED (no more DynamicTheme, no more accentColor)
          theme: ThemeData(
            fontFamily: 'ProductSans',
            primaryColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: config.Colors().mainColor(1),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              headline6: TextStyle(fontSize: 22.0),
              bodyText1: TextStyle(fontSize: 14.0),
              bodyText2: TextStyle(fontSize: 15.0),
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'ProductSans',
            primaryColor: const Color(0xFF252525),
            scaffoldBackgroundColor: const Color(0xFF2C2C2C),
            colorScheme: ColorScheme.fromSeed(
              seedColor: config.Colors().mainDarkColor(1),
              brightness: Brightness.dark,
            ),
            textTheme: const TextTheme(
              headline6: TextStyle(fontSize: 22.0),
              bodyText1: TextStyle(fontSize: 14.0),
              bodyText2: TextStyle(fontSize: 15.0),
            ),
          ),
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
