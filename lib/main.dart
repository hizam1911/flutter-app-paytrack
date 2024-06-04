import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:paytrack/pages/dashboard.dart';
import 'package:paytrack/pages/login.dart';
import 'package:paytrack/pages/test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paytrack/services/database_service.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paytrack/services/local_notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart'; //foreground notification
import 'package:flutter/services.dart';

String tempState = 'NA';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService().initNotification();
  tz.initializeTimeZones();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //init Firebase
  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
    FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
        );

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        tempState = '0';
      } else {
        print('User is signed in!');
        tempState = '1';
        DatabaseService().initSetPushNotification();
        DatabaseService().resetPaymentStatus();
      }
    });

    // LocalNotificationService().initNotification();
    // tz.initializeTimeZones();

    return firebaseApp;
  }

  runApp(MaterialApp(
    // theme: ThemeData(
    //   brightness: Brightness.light,
    //   useMaterial3: true,
    //   primaryColor: Colors.blue,
    //   splashFactory: InkRipple.splashFactory,
    //   splashColor: Colors.yellowAccent,
    //   colorScheme: ColorScheme?.fromSwatch().copyWith(
    //     brightness: Brightness.light,
    //     secondary: Colors.white,
    //   ),
    // ),
    home: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done) {

              print(tempState);

              if(tempState == '0') {
                return Login();
              } else if (tempState == '1') {
                return Dashboard();
              }

              // return Test();
            }
            return SizedBox(
              child: DecoratedBox(
                decoration: BoxDecoration(color: Colors.white,),
                child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.indigo,
                    )
                ),
              ),
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width / 2,
            );


          },
        ),
  ));

}