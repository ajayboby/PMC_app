import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pmc_app/BreastFeeding.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:pmc_app/WatchVideo.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:device_info/device_info.dart';
//import 'package:device_id/device_id.dart';


Future<List> dataBaseInformation() async {
  var db = mongo.Db('mongodb://10.0.2.2:27017/comments');
  await db.open();
  var collection = db.collection('userComments');
  var dataBase;
  dataBase = collection.find();
  return dataBase.toList();
}

//Future<List> findComments(String pageName) async {
//  var db = Db('mongodb://localhost:27017/comments');
//  await db.open();
//  var collection = db.collection('userComments');
//  var dataBase;
//  dataBase = collection.find({'pageName': pageName});
//  return dataBase.toList();
//}

//Future<List<String>> getDeviceDetails() async {
//  String deviceName;
//  String deviceVersion;
//  String identifier;
//  DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
//  try {
//    if (Platform.isAndroid) {
//      var build = await deviceInfoPlugin.androidInfo;
//      deviceName = build.model;
//      deviceVersion = build.version.toString();
//      identifier = build.androidId;  //UUID for Android
//    } else if (Platform.isIOS) {
//      print('deviceInfoPlugin');
//      print('');
//      var data = await deviceInfoPlugin.iosInfo;
//      deviceName = data.name;
//      deviceVersion = data.systemVersion;
//      identifier = data.identifierForVendor;  //UUID for iOS
//    }
//  } on PlatformException {
//    print('Failed to get platform version');
//  }
//
//  //if (!mounted) return;
//  return [deviceName, deviceVersion, identifier];
//}


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var connectToDataBase = await dataBaseInformation().then((val){
    print('value:');
    print(val);
    print(val.runtimeType);

  });
//  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//  if (Platform.isAndroid) {
//    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
//    print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"
//  } else if (Platform.isIOS) {
//    print('platform is iOS');
//    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
//    print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
//  }
  //List deviceId = await getDeviceDetails();

  runApp(MyApp());


}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) =>Dashboard(),
        '/breastFeeding': (context)=> BreastFeeding(),
        '/watchVideo' : (context)=> WatchVideo(),
        //'/medicalTerms': (context)=> MedicalTerms(),
        //'/nicuEquipments': (context)=> NicuEquipments(),
        //'/healthProblems': (context)=> HealthProblems(),
        //'/peerSupport': (context)=> PeerSupport(),
        //'/lifeAfterNicu': (context)=> LifeAfterNicu(),
      },
    );
  }

}


