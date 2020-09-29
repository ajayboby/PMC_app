import 'package:flutter/material.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/Dashboard.dart';

class BreastFeeding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //initialRoute: routeName,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Breast Feeding",style: TextStyle(color: Colors.purple)),
          iconTheme: new IconThemeData(color: Colors.purple),
          backgroundColor: Colors.white,
        ),
        drawer: MainDrawer(currentPageName: "Breast_Feeding"),
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
              Container(
                child: CreateGridTile(title:'Feeding Benefits',subtitle:'Watch Video', imageURL:'assets/breastFeeding/feedingBenefits.jpg',currentPage: "BreastFeeding"),
                  height: 600,
                  width: 200
              ),
              CreateGridTile(title:'Feeding Time',subtitle:'Watch Video', imageURL:'assets/breastFeeding/feedingTime.jpg',currentPage: "BreastFeeding"),
              CreateGridTile(title:'Milk Expression',subtitle:'Watch Video', imageURL:'assets/breastFeeding/milkExpression.jpg',currentPage: "BreastFeeding"),
              CreateGridTile(title:'Milk Storage',subtitle:'Watch Video', imageURL:'assets/breastFeeding/milkStorage.jpg',currentPage: "BreastFeeding"),
              CreateGridTile(title:'Foods to Eat',subtitle:'Watch Video', imageURL:'assets/breastFeeding/foodsToEat.jpg',currentPage: "BreastFeeding"),
            ],
          ),
        ),
      ),
    );
  }
}
