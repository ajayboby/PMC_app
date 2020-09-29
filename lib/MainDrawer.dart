import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pmc_app/AboutPmc.dart';
import 'package:pmc_app/BreastFeeding.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:pmc_app/HealthProblems.dart';
import 'package:pmc_app/LifeAfterNicu.dart';
import 'package:pmc_app/MedicalTerms.dart';
import 'package:pmc_app/NicuEquipment.dart';
import 'package:pmc_app/PeerSupport.dart';
import 'package:pmc_app/WatchVideo.dart';
import 'package:pmc_app/watchVideo2.dart';
import 'package:pmc_app/watchVideoOffline.dart';

class MainDrawer extends StatelessWidget {
  final String currentPageName;
  Colors colorName;
  String drawerTitle;
  MainDrawer({Key key, this.currentPageName}) : super(key: key);

  Color getColor(currentPageName, drawerPageTitle){
    if(currentPageName == drawerPageTitle) {
      return Colors.purple;
    } else{
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('currentPageName');
    debugPrint(currentPageName);
    return Drawer(
      child: ListView(children: <Widget>[
        Container(
            width: double.infinity,
            color: Colors.purple[50],
            padding: const EdgeInsets.all(20.0),
            child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
//                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/icon.png'),
                          fit: BoxFit.cover
                        )
                      ),
                    ),
                    Text('Preemie Mom Care', style: TextStyle(fontSize: 22, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    Text('Designed for & by preemie mom', style: TextStyle(fontSize: 16, color: Colors.purple)),
                  ],
                ))),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Dashboard'),
            onTap: (){
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new Dashboard())
              );
            },
          ),
          color: getColor(currentPageName, "Dashboard"),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Breast Feeding'),
            onTap: (){
              debugPrint('movieTitle: $ModalRoute.of(context).settings.name');
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new BreastFeeding())
              );
            },
          ),
          color: getColor(currentPageName, "Breast_Feeding"),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Medical Terms'),
            onTap: (){
              //Navigator.pushReplacementNamed(context, Routes.medicalTerms);
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new MedicalTerms())
              );
            },
          ),
          color: getColor(currentPageName, "Medical_Terms"),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('NICU Equipment'),
            onTap: (){
              //Navigator.pushReplacementNamed(context, Routes.nicuEquipments);
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new NicuEquipment())
              );
            },
          ),
          color: getColor(currentPageName, "NICU_Equipment"),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Health Problems'),
            onTap: (){
              //Navigator.pushReplacementNamed(context, Routes.healthProblems);
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new HealthProblems())
              );
            },
          ),
          color: getColor(currentPageName, "Health_Problems"),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Peer Support'),
            onTap: (){
              //Navigator.pushReplacementNamed(context, Routes.peerSupport);
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new PeerSupport())
              );
            },
          ),
          color: getColor(currentPageName, "Peer_Support"),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            onTap: (){
              //Navigator.pushReplacementNamed(context, Routes.lifeAfterNICU);
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new LifeAfterNicu())
              );
            },
            title: Text('Life After NICU'),
          ),
          color: getColor(currentPageName, "Life_After_NICU"),
        ),
       Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('About PMC'),
            onTap: (){
              debugPrint('movieTitle: $ModalRoute.of(context).settings.name');
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new AboutPmc())
              );
            },
          ),
         color: getColor(currentPageName, "About_PMC"),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Language'),
            onTap: null,
          ),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Watch video 2'),
            onTap: (){
              debugPrint('movieTitle: $ModalRoute.of(context).settings.name');
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new WatchVideo2())
              );
            },
          ),
        ),
        Ink(
          child: ListTile(
            leading: Icon(Icons.star_border),
            title: Text('Offline Video'),
            onTap: (){
              debugPrint('movieTitle: $ModalRoute.of(context).settings.name');
              Navigator.push(context, new MaterialPageRoute(
                  builder: (context) =>
                  new WatchVideoOffline())
              );
            },
          ),
        )
//        ListTile(
//          leading: Icon(Icons.star_border),
//          title: Text('Video Player'),
//          onTap: (){
//            debugPrint('movieTitle: $ModalRoute.of(context).settings.name');
//            Navigator.push(context, new MaterialPageRoute(
//                builder: (context) =>
//                new WatchVideo())
//            );
//          },
//        ),
      ]),
    );
  }
}
