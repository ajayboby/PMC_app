import 'package:flutter/material.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/main.dart';

class LifeAfterNicu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //initialRoute: routeName,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Life After NICU",style: TextStyle(color: Colors.purple)),
          iconTheme: new IconThemeData(color: Colors.purple),
          backgroundColor: Colors.white,
        ),
        drawer: MainDrawer(currentPageName: "Life_After_NICU",),
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
              CreateGridTile(title:'KMC',subtitle:'Watch Video', imageURL:'assets/lifeAfter/kmc.jpg',currentPage: "LifeAfterNICU",),
              CreateGridTile(title:'Health Problems',subtitle:'Watch Video', imageURL:'assets/lifeAfter/healthProblems.jpg',currentPage: "LifeAfterNICU"),
              CreateGridTile(title:'Development Delays',subtitle:'Watch Video', imageURL:'assets/lifeAfter/developmentDelays.jpg',currentPage: "LifeAfterNICU"),
              CreateGridTile(title:'Services Needed',subtitle:'Watch Video', imageURL:'assets/lifeAfter/servicesNeeded.jpg',currentPage: "LifeAfterNICU"),
              CreateGridTile(title:'Things to do at home',subtitle:'Watch Video', imageURL:'assets/lifeAfter/atHome.jpg',currentPage: "LifeAfterNICU"),
            ],
          ),
        ),
      ),
    );
  }
}