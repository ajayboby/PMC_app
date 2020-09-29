import 'package:flutter/material.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/main.dart';

class MedicalTerms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //initialRoute: routeName,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Medical Terms",style: TextStyle(color: Colors.purple)),
          iconTheme: new IconThemeData(color: Colors.purple),
          backgroundColor: Colors.white,
        ),
        drawer: MainDrawer(currentPageName: "Medical_Terms",),
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
              CreateGridTile(title:'Procedure',subtitle:'Watch Video', imageURL:'assets/medicalTerms/procedure.jpg',currentPage: "MedicalTerms"),
              CreateGridTile(title:'Conditions',subtitle:'Watch Video', imageURL:'assets/medicalTerms/conditions.jpg',currentPage: "MedicalTerms"),
              CreateGridTile(title:'Medication',subtitle:'Watch Video', imageURL:'assets/medicalTerms/medication.jpg',currentPage: "MedicalTerms"),
            ],
          ),
        ),
      ),
    );
  }
}