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
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pedantic/pedantic.dart';


Future<List> findComments(String pageName) async {
  var db = mongo.Db('mongodb://10.0.2.2:27017/comments');
  await db.open();
  var collection = db.collection('userComments');
  var dataBase;
  dataBase = collection.find({'pageName': pageName});
  return dataBase.toList();
}

void writeToDatabase(String pageName, String id, String userName, String comment, String uuid) async{
  var db = mongo.Db('mongodb://10.0.2.2:27017/comments');
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
  var db = mongo.Db('mongodb://10.0.2.2:27017/comments');
  await db.open();
  var collection = db.collection('userComments');
  print(id);

  await collection.update(await collection.findOne(mongo.where.eq("_id",id)),mongo.modify.set('videoLikes', likes));
  print('updated likes for database');
}

void getFileSize() async{
  print('testing file size');
  http.Response r = await http.head('https://off-days.com/apps/pmc/downloads/en/breastfeeding_feedingtime_vid.mp4');
  print('content length ${r.headers['content-length']}');
  print('content type ${r.headers['content-type']}');
  print('content length type ${r.headers['content-length'].runtimeType}');
  print(r.headers['content-type']);
}


class WatchVideoOffline extends StatefulWidget {
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

  WatchVideoOffline({Key key, this.value, this.previousPageName}) : super(key: key);
  @override
  _WatchVideoOfflineState createState() => _WatchVideoOfflineState(DefaultCacheManager());
}

List<String> _comments = ["more videos 1", "more videos 2", "more videos 3"];

//Widget _buildCommentList(List<dynamic> commentsList) {
//  return ListView.builder(
//    // ignore: missing_return
//      itemBuilder: (context, index) {
//        if (index < commentsList.length) {
//          return _buildCommentItem(commentsList[index]);
//        }
//      });
//}

Widget _buildVideoList(List<String> commentsList) {
  return ListView.builder(
    // ignore: missing_return
      itemBuilder: (context, index) {
        if (index < commentsList.length) {
          return _buildVideoItem(commentsList[index]);
        }
      });
}

Widget _buildVideoItem(String comment) {
  return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(Icons.play_circle_filled),
        title: Text(comment),
      ));
}


class _WatchVideoOfflineState extends State<WatchVideoOffline> {
  String _deviceid = 'Unknown';
  int videoLikes;
  String videoPlayerUrl = "";
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
  final BaseCacheManager _cacheManager;

  _WatchVideoOfflineState(this._cacheManager) : assert(_cacheManager!=null);

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

  Future<void> setVideoController(String videoUrl) async {
    final videoFile = await _cacheManager.getFileFromCache(videoUrl);//checking cache to see if video exists
    if (videoFile != null) {
      if(videoFile.file != null) {
        print('[VideoControllerService]: Loading video from cache');
        _controller = VideoPlayerController.file(videoFile.file);//loads video from cache
      }
    } else {
      unawaited(_cacheManager.downloadFile(videoUrl));// downloads video to cache
      _controller = VideoPlayerController.network(videoUrl);//gets video from network to play
    }
    await _controller.initialize();// initializing video controller
    setState(() {});
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

    videoPlayerUrl = 'https://off-days.com/apps/pmc/downloads/en/breastfeeding_feedingtime_vid.mp4';
    setVideoController(videoPlayerUrl);
    //await _controller.initialize();
   //_controller = setVideoController(videoPlayerUrl) as VideoPlayerController;
    setState(() {});
  }

  @override

  void initState() {
    super.initState();
    _initPlayer();
    initDeviceId();
    _getComments();
    getFileSize();
    print('_controller.value.size');
    if(_controller != null) {
      _controller.addListener(() {
        setState(() {
          print(_controller.value.size.toString());
          playbackTime = _controller.value.position.inSeconds;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _iconColor = Colors.grey[700];
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
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
          //child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                height:2020,
                child: Column(
                  children:<Widget>[
                    _controller!=null?(_controller.value.initialized ? _playerWidget() : Container()):Container(),
                    _controller!=null?(_controller.value.initialized ? Slider(
                      value: playbackTime.toDouble(),
                      max: _controller.value.duration.inSeconds.toDouble(),
                      min: 0,
                      onChanged: (v) {
                        _controller.seekTo(Duration(seconds: v.toInt()));
                      },
                    ) : Container()):Container(),
                    _controller!=null?(FloatingActionButton(
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
                    )):Container(),
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
                      child: Column(
                        children: <Widget>[
                          Text("I Like This"),
                          Icon(_iconType, color: _iconColor)
                        ],
                      ),
                    ),Container(
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
                                  body: TabBarView(
                                    children: [
                                      Container(
                                          color: Colors.deepPurple[50],
                                          child: Column(children: <Widget>[
                                              Row(
                                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                //mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Text(
                                                    "You are writing comment as : ",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  Expanded(
                                                    child:Container(
                                                      child:
                                                      Form(
                                                          key: nameFormKey,
                                                          child: TextFormField(
                                                            initialValue: "Anonymous",
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10,),
                                                            onSaved: (input) => enteredName = input,
                                                          )
                                                      )
                                                    )
                                                  )
                                                ],
                                              ),
                                            SizedBox(
                                              child: Form(
                                                  key: formKey,
                                                  child: Column(
                                                  children: [
                                                    new TextField(
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
                                                            writeToDatabase('/breastfeeding/benefits', WatchVideoOffline.pageId, enteredName, str, _deviceid);
                                                            debugPrint('written to db');
                                                          },
                                                        ),
                                                        SizedBox(
                                                            child: RaisedButton(
                                                              child: Text('Submit'),
                                                              onPressed: (){},
                                                            )
                                                          )
                                                  ]
                                                  )
                                              ),
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
                                                            //debugPrint(snapshot.data.length.toString());
                                                            for (int i = 0; i < snapshot.data.length; i++) {
                                                              var map = HashMap.from(snapshot.data[i]);
                                                              videoLikes = map['videoLikes'].toInt();
                                                              WatchVideoOffline.pageId = map['_id'].toString();
                                                              _commentsList=map['comments'];
                                                            }
                                                            debugPrint('this is comments list: ');
                                                            debugPrint(_commentsList.toString());
                                                            debugPrint('video likes: $videoLikes');
                                                            debugPrint('page id: ${WatchVideoOffline.pageId}');
                                                            return Container(
                                                                color: Colors.deepPurple[50],
                                                                child: ListView.builder(
                                                                  shrinkWrap: true,
                                                                    itemCount: _commentsList.length,
                                                                    //physics: const AlwaysScrollableScrollPhysics(),
                                                                    physics: NeverScrollableScrollPhysics(),
                                                                    scrollDirection: Axis.vertical,
                                                                    itemBuilder: (BuildContext context, int index) {
                                                                      if (index < _commentsList.length) {
                                                                        debugPrint('comments list length: ${_commentsList.length}');
                                                                        debugPrint('');
                                                                        debugPrint('${_commentsList[index]['body']}');
                                                                        return Container(
                                                                          height: 50,
                                                                          child: Card(
                                                                          child: Row(
                                                                            children: [
                                                                              SizedBox(width:100,child: Align(
                                                                                  alignment: Alignment.topLeft,
                                                                                  child: Container(
                                                                                    child: Text('${_commentsList[index]['userName']}',style: new TextStyle(
                                                                                      fontSize: 12.0,
                                                                                      color: Colors.black,
                                                                                    )),
                                                                                  )),
                                                                              ),
                                                                              SizedBox(width:200,child: Align(
                                                                                  alignment: Alignment.topLeft,
                                                                                  child: Container(
                                                                                    child: Text('${_commentsList[index]['body']}',style: new TextStyle(
                                                                                      fontSize: 16.0,
                                                                                      color: Colors.black,
                                                                                    )),
                                                                                  )
                                                                              ))
                                                                            ])));
                                                                      }})
                                                            );
                                                          }
                                                        })
                                                )
                                            )
                                          ]
                                          )
                                      ),
                                      Container(
                                          color: Colors.white,
                                          child: Column(children: <Widget>[
                                            Expanded(
                                              child: _buildVideoList(_comments),
                                            )
                                          ]))
                                    ],
                                  ),
                                );
                              }),
                            )))
                  ]
                )
              )
            ],
          //),
        ),
      )),
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
