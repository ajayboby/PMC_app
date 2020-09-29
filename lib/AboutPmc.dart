import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:pmc_app/Dashboard.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/main.dart';

import 'package:flutter/material.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/main.dart';

import 'package:uuid/uuid.dart';

//var uuid = Uuid();

// ignore: must_be_immutable
class AboutPmc extends StatefulWidget {

  @override
  _AboutPmcState createState() => _AboutPmcState();
}

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

class _AboutPmcState extends State<AboutPmc> {
  String _deviceid = 'Unknown';
  @override
  void initState() {
    super.initState();
    initDeviceId();
//    _getDevices();
    dataBaseInformation();
  }

  Future<void> initDeviceId() async {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    print('Running on ${androidInfo.model}');  // e.g. "Moto G (4)"
    print(androidInfo.androidId);
    _deviceid = androidInfo.androidId;
  } else if (Platform.isIOS) {
    print('platform is iOS');
    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    print('Running on ${iosInfo.utsname.machine}');  // e.g. "iPod7,1"
    print('device id ${iosInfo.identifierForVendor}');
    _deviceid =iosInfo.identifierForVendor;
  }
  setState(() {});
  //_deviceid = "";
  }



  Future<void> dataBaseInformation() async {
    var db = mongo.Db('mongodb://10.0.2.2:27017/comments');
    await db.open();
    var collection = db.collection('devices');

    var key = {"uuid": _deviceid};
    var value = {"uuid": _deviceid, "userName":"Anonymous"};
    await collection.update(key, value, upsert: true);
    print('inserted to database');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //initialRoute: routeName,
      home: Scaffold(
        appBar: AppBar(
          title: Text("About PMC",style: TextStyle(color: Colors.purple)),
          iconTheme: new IconThemeData(color: Colors.purple),
          backgroundColor: Colors.white,
        ),
        drawer: MainDrawer(currentPageName: "About_PMC",),
        body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/background.png"),
              fit: BoxFit.fill,
            ),
          ),
          //padding: EdgeInsets.all(5.0),
            child: Center(child:Container(
              padding: EdgeInsets.all(25.0),
            child: Text('Preemie Mom Care is an app that provides supportive information to mothers'
                  'of hospitalized premature infants as they partake in the care of their '
                  'infants. The app was co-designed by mothers and health staff from Groote Schuur NICU.\n\n'
              'Wanjiru Mburu, a PhD student at the University of Cape Town led the project for a period'
                  'of three years. She worked closely with 40 mothers and 15 health care workers to ensure'
                  'that mothers needs are incorporated in the final prototype.\n\n'
              'The project was sponsored by Hasso plattner Institute, Germany and University of Cape Town.\n\n'
            'DEVICE ID : $_deviceid'),
            )),
          ),
        ),
      );
  }
}