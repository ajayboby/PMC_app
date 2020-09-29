import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:pmc_app/AboutPmc.dart';
import 'package:pmc_app/BreastFeeding.dart';
import 'package:pmc_app/HealthProblems.dart';
import 'package:pmc_app/LifeAfterNicu.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/MedicalTerms.dart';
import 'package:pmc_app/NicuEquipment.dart';
import 'package:pmc_app/PeerSupport.dart';
import 'package:pmc_app/WatchVideo.dart';
import 'package:pmc_app/main.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;


class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _deviceid = 'Unknown';
  void initState() {
    super.initState();
    initDeviceId();
//    _getDevices();
    dataBaseInformation();
  }

  Future<void> initDeviceId() async {
    DeviceInfoPlugin device = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await device.androidInfo;
      _deviceid = android.androidId;
    } else if (Platform.isIOS) {
      IosDeviceInfo ios = await device.iosInfo;
      _deviceid =ios.identifierForVendor;
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
          title: Text("Preemie Mom Care",style: TextStyle(color: Colors.purple)),
          iconTheme: new IconThemeData(color: Colors.purple),
          backgroundColor: Colors.white,
        ),
        drawer: MainDrawer(currentPageName: "Dashboard",),
        body: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/background.png"),
              fit: BoxFit.fill,
            ),
          ),
          //padding: EdgeInsets.all(5.0),
          child: GridView.count(crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            children: <Widget>[
              CreateGridTile(title:'Breast Feeding',subtitle:'Learn More', imageURL:'assets/dashboard/breastFeeding.jpg',currentPage: "DashBoard"),
              CreateGridTile(title:'Medical Terms',subtitle:'Learn More', imageURL:'assets/dashboard/medicalTerms.jpg',currentPage: "DashBoard"),
              CreateGridTile(title:'NICU Equipment',subtitle:'Learn More', imageURL:'assets/dashboard/nicuEquipment.jpg',currentPage: "DashBoard"),
              CreateGridTile(title:'Health Problems',subtitle:'Learn More', imageURL:'assets/dashboard/healthProblems.jpg',currentPage: "DashBoard"),
              CreateGridTile(title:'Peer Support',subtitle:'Learn More', imageURL:'assets/dashboard/peerSupport.jpg',currentPage: "DashBoard"),
              CreateGridTile(title:'Life After NICU',subtitle:'Learn More', imageURL:'assets/dashboard/lifeAfterNicu.jpg',currentPage: "DashBoard"),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateGridTile extends StatelessWidget {
  CreateGridTile({this.title, this.subtitle, this.imageURL, this.currentPage});
  final String title;
  final String subtitle;
  final String imageURL;
  final String currentPage;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          onTap: (){
            if(this.subtitle == "Watch Video") {
              debugPrint(this.title);
              debugPrint(this.currentPage);
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new WatchVideo(value: this.title, previousPageName: this.currentPage))
              );
            } else {
              switch(this.title){
                case "Breast Feeding":{
                  debugPrint(this.title);
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new BreastFeeding())
                  );
                }
                break;
                case "Medical Terms":{
                  debugPrint(this.title);
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new MedicalTerms())
                  );
                }
                break;
                case "NICU Equipment":{
                  debugPrint(this.title);
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new NicuEquipment())
                  );
                }
                break;
                case "Health Problems":{
                  debugPrint(this.title);
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new HealthProblems())
                  );
                }
                break;
                case "Peer Support":{
                  debugPrint(this.title);
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new PeerSupport())
                  );
                }
                break;
                case "Life After NICU":{
                  debugPrint(this.title);
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new LifeAfterNicu())
                  );
                }
                break;

                default:{
                  debugPrint(this.title);
                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new Dashboard())
                  );
                }
              }
            }
          },
          child: Align(
              child: Column(
                  children: <Widget>[
                    Image(image: AssetImage(imageURL),fit: BoxFit.scaleDown,alignment: Alignment.center,),
                    Center(child: Text(title,style: new TextStyle(fontSize: 17.0, color: Colors.purple),)),
                    Text(subtitle, style: new TextStyle(fontSize: 12.0, color: Colors.purple),)
                  ]
              )
          )
      ),
    );
  }
}
