import 'package:flutter/material.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/main.dart';

class HealthProblems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //initialRoute: routeName,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Health Problems",style: TextStyle(color: Colors.purple)),
          iconTheme: new IconThemeData(color: Colors.purple),
          backgroundColor: Colors.white,
        ),
        drawer: MainDrawer(currentPageName: "Health_Problems",),
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
              CreateGridTile(title:'Breathing',subtitle:'Watch Video', imageURL:'assets/healthProblems/breathing.jpg',currentPage: "HealthProblems"),
              CreateGridTile(title:'Tummy',subtitle:'Watch Video', imageURL:'assets/healthProblems/tummy.jpg',currentPage: "HealthProblems"),
              CreateGridTile(title:'Brain',subtitle:'Watch Video', imageURL:'assets/healthProblems/brain.jpg',currentPage: "HealthProblems"),
              CreateGridTile(title:'Infections',subtitle:'Watch Video', imageURL:'assets/healthProblems/infections.jpg',currentPage: "HealthProblems"),
              CreateGridTile(title:'Eyes',subtitle:'Watch Video', imageURL:'assets/healthProblems/eyes.jpg',currentPage: "HealthProblems"),
            ],
          ),
        ),
      ),
    );
  }
}