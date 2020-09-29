import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:video_player/video_player.dart';
import 'package:pmc_app/main.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:metadata_fetch/metadata_fetch.dart';


Future<List> findComments(String pageName) async {
  var db = mongo.Db('mongodb://localhost:27017/comments');
  await db.open();
  var collection = db.collection('userComments');
  var dataBase;
  dataBase = collection.find({'pageName': pageName});
  return dataBase.toList();
}

void writeToDatabase(String pageName, String id, String userName, String comment, String uuid) async{
  var db = mongo.Db('mongodb://localhost:27017/comments');
  await db.open();
  var collection = db.collection('userComments');
  var dataBase;
  print(DateTime.now());
  dataBase = collection.find({'pageName': pageName});
  dataBase = dataBase.toList();
  print('dataBase');
  print(dataBase);
  print(id);
  print(userName);
  print(comment);

  await collection.update(await collection.findOne(mongo.where.eq("_id",id)), {r"$push": {"comments": {
    "userName": userName,
    "body": comment,
    "date": DateTime.now(),
    "uuid":uuid,
    "userLanguage":'en'
  }}});
  print('updated database');
}
void updateLikes(String pageName, String id, String uuid,int likes) async{
  var db = mongo.Db('mongodb://localhost:27017/comments');
  await db.open();
  var collection = db.collection('userComments');
  print(id);

  await collection.update(await collection.findOne(mongo.where.eq("_id",id)),mongo.modify.set('videoLikes', likes));
  print('updated likes for database');
}

void moreVideos() async{

}

class WatchVideo2 extends StatefulWidget {
  final String value;
  final String previousPageName;
  var videoTitle = {
    'Feeding Benefits': 'benefits',
    'Feeding Time': 'feedingtime',
    'Milk Expression': 'expression',
    'Milk Storage': 'storage',
    'Foods to Eat': 'food',
    'Procedure': 'procedures',
    'Conditions': 'conditions',
    'Medication': 'medication',
    'NICU Equipment': 'equipment',
    'Breathing': 'breathing',
    'Tummy': 'tummy',
    'Brain': 'brain',
    'Infections': 'sepsis',
    'Eyes': 'eyes',
    'Peer Support': 'support',
    'KMC': 'kmc',
    'Health Problems': 'hp',
    'Development Delays': 'delay',
    'Services Needed': 'services_needed',
    'Things to do at home': 'things_to_do_at_home',
  };

  //static var videoLikes;
  static var pageId;
  TextEditingController userNameController;

  WatchVideo2({Key key, this.value, this.previousPageName}) : super(key: key);

  @override
  _WatchVideoState2 createState() => _WatchVideoState2();
}

List<String> _comments = ["more videos 1", "more videos 2", "more videos 3"];

Widget _buildCommentList(List<dynamic> commentsList) {
  return ListView.builder(
    // ignore: missing_return
      itemBuilder: (context, index) {
        if (index < commentsList.length) {
          return _buildCommentItem(commentsList[index]);
        }
      });
}

Widget _buildVideoList(List<String> commentsList) {
  return ListView.builder(
    // ignore: missing_return
      itemBuilder: (context, index) {
        if (index < commentsList.length) {
          return _buildVideoItem(commentsList[index]);
        }
      });
}

Widget _buildCommentItem(String comment) {
  return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(Icons.comment),
        title: Text(comment),
      ));
}

Widget _buildVideoItem(String comment) {
  return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(Icons.play_circle_filled),
        title: Text(comment),
      ));
}



class _WatchVideoState2 extends State<WatchVideo2> {
  String _deviceid = 'Unknown';
  int videoLikes;
  var _name;
  final videoInfo = FlutterVideoInfo();
  final nameController = new TextEditingController();

  VideoPlayerController _controller;
  int playbackTime = 0;
  Size videoSize;
  Future<void> _initializeVideoPlayerFuture;
  var videoTitle = {
    'Feeding Benefits': 'benefits',
    'Feeding Time': 'feedingtime',
    'Milk Expression': 'expression',
    'Milk Storage': 'storage',
    'Foods to Eat': 'food',
    'Procedure': 'procedures',
    'Conditions': 'conditions',
    'Medication': 'medication',
    'NICU Equipment': 'equipment',
    'Breathing': 'breathing',
    'Tummy': 'tummy',
    'Brain': 'brain',
    'Infections': 'sepsis',
    'Eyes': 'eyes',
    'Peer Support': 'support',
    'KMC': 'kmc',
    'Health Problems': 'hp',
    'Development Delays': 'delay',
    'Services Needed': 'services_needed',
    'Things to do at home': 'things_to_do_at_home',
  };
  var categoryTitle = {
    'BreastFeeding': 'breastfeeding',
    'HealthProblems': 'healthproblems',
    'LifeAfterNICU': 'lifeafternicu',
    'MedicalTerms': 'medicalterms',
    'NICUEquipment': 'nicu',
    'PeerSupport': 'peer',
  };
  static var _commentsList = [];

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

  void _getComments() async {
    debugPrint(
        '/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}');
    var pageComments = await findComments(
        '/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}')
        .then((val) {
      print('value:');
      print(val);
      print(val.runtimeType);
    });
  }

  String _getPreviousPageName() {
    return categoryTitle[widget.previousPageName];
  }

  String _getVideoTitle() {
    return widget.videoTitle[widget.value];
  }
  String info = "";
  getVideoInfo() async {
    /// here file path of video required
//    String videoFilePath = 'https://off-days.com/apps/pmc/downloads/en/breastfeeding_feedingtime_vid.mp4';
//    var a = await videoInfo.getVideoInfo(videoFilePath);
//    print('this is a');
//    print(a);
//    setState(() {
//      info =
//      "title=> ${a.title}\npath=> ${a.path}\nauthor=> ${a.author}\nmimetype=> ${a.mimetype}";
//      info +=
//      "\nheight=> ${a.height}\nwidth=> ${a.width}\nfileSize=> ${a.filesize} Bytes\nduration=> ${a.duration} milisec";
//      info +=
//      "\norientation=> ${a.orientation}\ndate=> ${a.date}\nframerate=> ${a.framerate}";
//      info += "\nlocation=> ${a.location}";
//    });
    var data = extract("https://off-days.com/apps/pmc/downloads/en/breastfeeding_feedingtime_vid.mp4").then((val){
      print('extraction data:');
      print(val);
      print(val.runtimeType);

    }); // Use the extract() function to fetch data from the url
    //print('this is data: $data');
  }

  void _initPlayer() async {
    debugPrint('');
    debugPrint('previousPageName');
    debugPrint(widget.previousPageName);
    debugPrint('categoryTitle[widget.previousPageName]');
    debugPrint(categoryTitle[widget.previousPageName]);
    debugPrint('');
    debugPrint('value');
    debugPrint(widget.value);
    debugPrint('videoTitle[widget.value]');
    debugPrint(videoTitle[widget.value]);
    debugPrint('test pagename');
//    debugPrint('/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}');
//    var pageComments = await findComments('/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}').then((val){
//      print('value:');
//      print(val);
//      print(val.runtimeType);
//    });
    var url = "";
//    if (videoTitle[widget.value] == 'support') {
//      url =
//      'https://off-days.com/apps/pmc/downloads/en/${categoryTitle[widget.previousPageName]}_${widget.videoTitle[widget.value]}_1.mp4';
//    } else {
//      url =
//      'https://off-days.com/apps/pmc/downloads/en/${categoryTitle[widget.previousPageName]}_${widget.videoTitle[widget.value]}_vid.mp4';
//    }
    url = 'https://off-days.com/apps/pmc/downloads/en/breastfeeding_feedingtime_vid.mp4';

//    debugPrint(
//        'https://off-days.com/apps/pmc/downloads/en/${categoryTitle[widget.previousPageName]}_${widget.videoTitle[widget.value]}_vid.mp4');
    _controller = VideoPlayerController.network(url);
    await _controller.initialize();
    //_initializeVideoPlayerFuture = _controller.initialize();
    setState(() {});
  }

  @override

  void initState() {
//    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();
    _initPlayer();
    initDeviceId();
    _getComments();
    print('_controller.value.size');
    _controller.addListener(() {
      setState(() {
        videoSize = _controller.value.size;
        print('video size');
        print(_controller.value.size.toString());
        playbackTime = _controller.value.position.inSeconds;
      });
    });
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  Color _iconColor = Colors.grey[700];
  Color _buttonColor = Colors.grey[200];
  Color _fontColor = Colors.purple;
  IconData _iconType = Icons.favorite_border;

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Comments', icon: Icon(Icons.comment)),
    Tab(text: 'More Videos', icon: Icon(Icons.play_arrow))
  ];
  final formKey = GlobalKey<FormState>();
  final nameFormKey =  GlobalKey<FormState>();
  String enteredName;
  bool continueToPlay = false;

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Text("${widget.value}", style: TextStyle(color: Colors.purple)),
            iconTheme: new IconThemeData(color: Colors.purple),
            backgroundColor: Colors.white,
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    _iconType,
                    color: _iconColor,
                  )),
              Align(
                  alignment: Alignment.center, // Align however you like (i.e .centerRight, centerLeft)
                  child: Padding(
                    padding: const EdgeInsets.only(right:25.0),
                    child: Text(
                      videoLikes.toString(),style: TextStyle(fontSize: 20, color: Colors.black), textAlign: TextAlign.left,
                    ),
                  )
              ),
            ]),
        drawer: MainDrawer(),
        body: Center(
          child: Column(
            children: <Widget>[
              !continueToPlay? RaisedButton(
                child: Text('Continue to Play Video?'),
                onPressed: (){
                  setState(() {
                    getVideoInfo();
                    continueToPlay = true;
                  });
                },
              ):Container(),
              Text('hello world $info how are you'),
              continueToPlay? Text(info,style: TextStyle(fontSize: 21)):Container(),
              continueToPlay?(_controller.value.initialized ? _playerWidget() : Container()): Container(),
              continueToPlay?_controller.value.initialized ? Slider(
                value: playbackTime.toDouble(),
                max: _controller.value.duration.inSeconds.toDouble(),
                min: 0,
                onChanged: (v) {
                  _controller.seekTo(Duration(seconds: v.toInt()));
                },
              )
                  : Container():Container(),
              continueToPlay?FloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ):Container(),
              RaisedButton(
                onPressed: () => {
                  setState(() {
                    if (_iconColor == Colors.pink) {
                      if(videoLikes > 0){
                        videoLikes = videoLikes -1;
                      }
                      _iconType = Icons.favorite_border;
                      _iconColor = Colors.grey[700];
                    } else if (_iconColor == Colors.grey[700]) {
                      videoLikes +=1;
                      _iconType = Icons.favorite;
                      _iconColor = Colors.pink;
                    }
                  })
                },
                color: Colors.grey[100],
                //padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Text("I Like This"),
                    Icon(_iconType, color: _iconColor)
                  ],
                ),
              ),
              Container(
                  child: Expanded(
                      child: DefaultTabController(
                        length: tabs.length,
                        child: Builder(builder: (BuildContext context) {
                          final TabController tabController =
                          DefaultTabController.of(context);
                          tabController.addListener(() {
//                            if (!tabController.indexIsChanging) {
//                            }
                          });
                          return Scaffold(
                            appBar: TabBar(
                              labelColor: Colors.purple,
                              indicatorColor: Colors.purple,
                              tabs: tabs,
                            ),
                            body: continueToPlay? TabBarView(
                              children: [
                                Container(
                                    color: Colors.white,
                                    child: Column(children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Text(
                                            "You are writing comment as : ",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                              child: Form(
                                                  key: nameFormKey,
                                                  child: TextFormField(
                                                    initialValue: "Anonymous",
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10,),
                                                    onSaved: (input) => enteredName = input,
                                                  )
                                              ))
                                        ],
                                      ),
                                      Expanded(
                                        child: Form(
                                            key: formKey,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.all(20.0),
                                                  hintText: "Add Comments"),
                                              onSubmitted: (String str){
                                                _submit();
                                                debugPrint('_commentsList.toString()');
                                                debugPrint(_commentsList.toString());
                                                _commentsList.add({'userName':enteredName,'body':str, "date":DateTime.now(), 'uuid':_deviceid});
                                                debugPrint(str);
                                                debugPrint('enteredName');
                                                debugPrint(enteredName);
                                                writeToDatabase('/breastfeeding/benefits', WatchVideo2.pageId, enteredName, str, _deviceid);
                                                debugPrint('written to db');
                                              },
                                            )),
                                      ),
                                      Container(
                                          child: Expanded(
                                              child: FutureBuilder(
                                                  future: findComments('/breastfeeding/benefits'),
                                                  builder: (buildContext, AsyncSnapshot snapshot) {
                                                    if (snapshot.hasError)
                                                      throw snapshot.error;
                                                    else if (!snapshot.hasData) {
                                                      return Container(
                                                        child: Center(
                                                          child: Text("Loading..."),
                                                        ),
                                                      );
                                                    } else {
                                                      debugPrint(snapshot.data.length.toString());
                                                      for (int i = 0; i < snapshot.data.length; i++) {
                                                        var map = HashMap.from(snapshot.data[i]);
                                                        videoLikes = map['videoLikes'].toInt();
                                                        WatchVideo2.pageId = map['_id'].toString();
                                                        _commentsList=map['comments'];
                                                      }
                                                      debugPrint('this is comments list: ');
                                                      debugPrint(_commentsList.toString());
                                                      debugPrint('video likes: $videoLikes');
                                                      debugPrint('page id: ${WatchVideo2.pageId}');
                                                      return Container(
                                                          color: Colors.white,
                                                          child: ListView.builder(
                                                              itemCount: _commentsList.length,
                                                              scrollDirection: Axis.vertical,
                                                              itemBuilder: (BuildContext context, int index) {
                                                                if (index < _commentsList.length) {
                                                                  debugPrint('comments list length: ${_commentsList.length}');
                                                                  debugPrint('');
                                                                  debugPrint('${_commentsList[index]['body']}');
                                                                  return Row(
                                                                      children: [
                                                                        SizedBox(width:100,child: Align(
                                                                            alignment: Alignment.topLeft,
                                                                            child: Container(
                                                                              child: Text('${_commentsList[index]['userName']}'),
                                                                            )),
                                                                        ),
                                                                        SizedBox(width:200,child: Align(
                                                                            alignment: Alignment.topLeft,
                                                                            child: Container(
                                                                              child: Text('${_commentsList[index]['body']}'),
                                                                            )
                                                                        ))
                                                                      ]);
                                                                }})
                                                      );
                                                    }
                                                  })))
                                    ])),
                                Container(
                                    color: Colors.white,
                                    child: Column(children: <Widget>[
                                      Expanded(
                                        child: _buildVideoList(_comments),
                                      )
                                    ]))
                              ],
                            ):Container(),
                          );
                        }),
                      )))
            ],
          ),
        ),
      ),
    );
  }

  Widget _playerWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller))
      ],
    );
  }

  void _submit(){
    formKey.currentState.save();
    nameFormKey.currentState.save();
  }
}
