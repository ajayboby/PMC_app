import 'package:flutter/material.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/main.dart';

class NicuEquipment extends StatelessWidget {
  String appPageTitle = "NicuEquipment";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //initialRoute: routeName,
      home: Scaffold(
        appBar: AppBar(
          title: Text("NICU Equipment",style: TextStyle(color: Colors.purple)),
          iconTheme: new IconThemeData(color: Colors.purple),
          backgroundColor: Colors.white,
        ),
        drawer: MainDrawer(currentPageName: "NICU_Equipment",),
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
              CreateGridTile(title:'NICU Equipment',subtitle:'Watch Video', imageURL:'assets/dashboard/nicuEquipment.jpg',currentPage: "NICUEquipment"),
            ],
          ),
        ),
      ),
    );
  }
}