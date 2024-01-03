
import 'dart:io';

import 'package:alarmplayer/alarmplayer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:sademiot/screens/Login_screen.dart';
import 'package:sademiot/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';



void main()async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();


  alarmplayer.StopAlarm();
  myNotifcation();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  
  
    alarmplayer.Alarm(
    url: "./assets/music/alart.mp3",  // Path of sound file.
    volume: 0.9,              // optional, set the volume, default 1.

  );
    Future.delayed(const Duration(seconds: 5)).then((value) => alarmplayer.StopAlarm());

}

myNotifcation()async{
  DatabaseReference ref = FirebaseDatabase.instance.ref("Token");
  FirebaseMessaging messaging = FirebaseMessaging.instance;

 String? token =await messaging.getToken();

  ref.onValue.listen((DatabaseEvent event) {


    List myList=[];

    if(event.snapshot.value!=null){
      final data = event.snapshot.value as Map;
      data["deviceToken"].forEach((v){
        myList.add( v);
      });
      bool isFound= myList.contains(token);
      if(!isFound)  {
        myList.add(token);
        ref.set({
          "deviceToken":myList,
          "count":myList.length
        },);
      }
    }else{
      ref.set({
        "deviceToken":[token],
        "count":1
      },);
    }





  });


  Alarmplayer alarmplayer = Alarmplayer();

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    // handle accordingly

  });
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      // DO YOUR THING HERE
      alarmplayer.StopAlarm();
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(message.data);
    // alarmplayer.StopAlarm();
    // if (message.notification != null) {
    //   alarmplayer.Alarm(
    //
    //       url: "./assets/music/alart.mp3",  // Path of sound file.
    //           volume: 0.1,              // optional, set the volume, default 1.
    //
    // );
    //
    //
    // }
  });

}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   MaterialApp(
      home: (FirebaseAuth.instance.currentUser!=null)?const HomeScreen():const LoginScreen(),
    );
  }
}
