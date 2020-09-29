import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:pedantic/pedantic.dart';
import 'package:pmc_app/MainDrawer.dart';
import 'package:pmc_app/Dashboard.dart';
import 'package:video_player/video_player.dart';
import 'package:pmc_app/main.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

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

  await collection.update(await collection.findOne(mongo.where.eq("_id",id)), {r"$push": {"comments": {
    "userName": userName,
    "body": comment,
    "date": DateTime.now(),
    "uuid":uuid,
    "userLanguage":'en'
  }}});
  print('updated database');
}

void updateLikes(String id,int likes, String uuid, String operation) async{
  var db = mongo.Db('mongodb://10.0.2.2:27017/comments');
  await db.open();
  var collection = db.collection('userComments');
  print('uuid');
  print(uuid);
  print(id);
  if(operation == "update") {
    await collection.update(await collection.findOne(mongo.where.eq("_id", id)),
        {r"$push": {"likedDevice": uuid}}, upsert: true);
    print('updated likes for database');
  }
  if(operation == "remove") {
    await collection.update(await collection.findOne(mongo.where.eq("_id", id)),
        {r"$pull": {"likedDevice": uuid}});
    print('updated likes for database');
  }
}
//

class WatchVideo extends StatefulWidget {
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

//  var categoryTitle = {
//    'Breast Feeding':'breastfeeding',
//    'Health Problems':'healthproblems',
//    'Life After NICU':'lifeafternicu',
//    'Medical Terms':'medicalterms',
//    'NICU Equipment':'nicu',
//    'Peer Support':'peer',
//  };

  WatchVideo({Key key, this.value, this.previousPageName}) : super(key: key);

  @override
  _WatchVideoState createState() => _WatchVideoState(DefaultCacheManager());
}

//Widget _buildCommentList(List<dynamic> commentsList) {
//  return ListView.builder(
//      // ignore: missing_return
//      itemBuilder: (context, index) {
//    if (index < commentsList.length) {
//      return _buildCommentItem(commentsList[index]);
//    }
//  });
//}

Widget _buildVideoList(List<String> videoList, String pageName) {
    return ListView.builder(
      // ignore: missing_return
        itemBuilder: (context, index) {
          if (index < videoList.length) {
            return _buildVideoItem(videoList[index], pageName);
          }
        }
    );
}

Widget _buildVideoItem(String moreVideoTitle, String currentPageName) {
  return Card(
      color: Colors.white,
      child: ListTile(
        leading: Icon(Icons.play_circle_filled),
        title: Text(moreVideoTitle),
        onTap: (){
          debugPrint('widget.previousPageName : $currentPageName' );
        },
      ));
}



class _WatchVideoState extends State<WatchVideo> {
  String _deviceid = 'Unknown';
  int videoLikes = 0;
  String queryUrl;
  final nameController = new TextEditingController();
  String videoLocation = "";
  bool continueToPlay = false;

  bool deviceLiked = false;

  VideoPlayerController _controller;
  int playbackTime = 0;
  String videoSize;
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
  //static var moreVideosList = ["more videos 1", "more videos 2", "more videos 3"];
  List<dynamic> moreVideosList = [];
  final BaseCacheManager cacheManager;

  _WatchVideoState(this.cacheManager) : assert(cacheManager!=null);

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
  }
//------------------------------------------------------------------------------
  Future<void> getFileSize(String url) async{
    print('testing file size');
    http.Response r = await http.head(url);
    print('content length ${r.headers['content-length']}');
    print('content type ${r.headers['content-type']}');
    print(r.headers['content-type']);
    videoSize = r.headers['content-length'];
    print('convertBytesToMb');
    print(videoSize);
    videoSize!=null ? convertBytesToMb(int.parse(videoSize)): videoSize;
    setState(() {});
  }

  String convertBytesToMb(int byteSize){
    if (byteSize <= 0 || byteSize == null) {
      print('bytes is 0');
      videoSize = "0MB";
    } else {
      var i = (log(byteSize) / log(1024)).floor();
      videoSize = ((byteSize / pow(1024, i)).toStringAsFixed(2)) + ' MB';
    }
  }
//------------------------------------------------------------------------------
  void checkLikes(String uuid) async{
    var connectToDataBase = await dataBaseInformation().then((val){
      print('likes value:');
      print(val[0]['likedDevice']);
      print('-------------');
      print(val.runtimeType);
      var likedDevices = val[0]['likedDevice'];
      for(int i=0;i<likedDevices.length;i++){
        if(likedDevices[i] == uuid){
          print('this is true');
          setState(() {
            deviceLiked = true;
          });
        }
      }
    });
  }

//  void _getComments() async {
//    debugPrint(
//        '/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}');
//    var pageComments = await findComments(
//            '/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}')
//        .then((val) {
//      print('value:');
//      print(val);
//      print(val.runtimeType);
//    });
//  }
//
//  String _getPreviousPageName() {
//    return categoryTitle[widget.previousPageName];
//  }
//
//  String _getVideoTitle() {
//    return widget.videoTitle[widget.value];
//  }

  Future<void> setVideoController(String videoUrl) async {
    final videoFile = await cacheManager.getFileFromCache(videoUrl);//checking cache to see if video exists
    if (videoFile != null) {
      if(videoFile.file != null) {
        videoLocation = "cache";
        continueToPlay = true;
        _controller = VideoPlayerController.file(videoFile.file);//loads video from cache
      }
    } else {
      videoLocation = "network";
      unawaited(cacheManager.downloadFile(videoUrl));// downloads video to cache
      _controller = VideoPlayerController.network(videoUrl);//gets video from network to play
    }
    await _controller.initialize();// initializing video controller
    if (_controller != null){
      _controller.addListener(() {
        setState(() {
          playbackTime = _controller.value.position.inSeconds;
        });
      });
    }
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
//    debugPrint('/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}');
//    var pageComments = await findComments('/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}').then((val){
//      print('value:');
//      print(val);
//      print(val.runtimeType);
//    });
    var url = "";
    if (videoTitle[widget.value] == 'support') {
      url =
          'https://off-days.com/apps/pmc/downloads/en/${categoryTitle[widget.previousPageName]}_${widget.videoTitle[widget.value]}_1.mp4';
    } else {
      url =
          'https://off-days.com/apps/pmc/downloads/en/${categoryTitle[widget.previousPageName]}_${widget.videoTitle[widget.value]}_vid.mp4';
    }

    debugPrint(
        'https://off-days.com/apps/pmc/downloads/en/${categoryTitle[widget.previousPageName]}_${widget.videoTitle[widget.value]}_vid.mp4');
    queryUrl = url;
    setVideoController(url);
//    _controller = VideoPlayerController.network(url);
//    await _controller.initialize();
    //_initializeVideoPlayerFuture = _controller.initialize();
    setState(() {});
  }
  Color _iconColor = Colors.grey[700];
  IconData _iconType = Icons.favorite_border;

  @override

  void initState() {
//    _initializeVideoPlayerFuture = _controller.initialize();

    super.initState();
    _initPlayer();
    initDeviceId();
    checkLikes(_deviceid);
    print('checks value');
    getFileSize(queryUrl);

    print(deviceLiked);
    //_getComments();
    if (_controller != null){
      _controller.addListener(() {
        setState(() {
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

  final List<Tab> tabs = <Tab>[
    Tab(text: 'Comments', icon: Icon(Icons.comment)),
    Tab(text: 'More Videos', icon: Icon(Icons.play_arrow))
  ];

  final formKey = GlobalKey<FormState>();
  final nameFormKey =  GlobalKey<FormState>();
  String enteredName;
  List deviceLikes;

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title:
                Text("${widget.value}", style: TextStyle(color: Colors.purple)),
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
            children: <Widget>[
              Container(child: Text('Video Playing from : $videoLocation')),
              Container(
                  color: Colors.white,
                  height:2020,
            child: Column(
                children:<Widget>[
                  !continueToPlay?SizedBox(height: 50): Container(),
                  !continueToPlay? Center(
                    child: Text('Video Size : $videoSize',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,), textAlign: TextAlign.center,),
                  ):Container(),
                  !continueToPlay?SizedBox(height: 50): Container(),
              !continueToPlay? Center(child:RaisedButton(
                child: Text('Continue to Play Video?'),
                onPressed: (){
                  setState(() {
                    checkLikes(_deviceid);
                    continueToPlay = true;
                    print('checkLikes(_deviceid)');
                    print('checks value');
                    print(deviceLiked);
                    if(deviceLiked == true){
                      _iconColor = Colors.pink;
                      _iconType = Icons.favorite;
                    };
                  });
                },
              )):Container(),
              continueToPlay? _controller.value.initialized ? _playerWidget() : Container() : Container(),
              continueToPlay? _controller.value.initialized ? Slider(
                      value: playbackTime.toDouble(),
                      max: _controller.value.duration.inSeconds.toDouble(),
                      min: 0,
                      onChanged: (v) {
                        _controller.seekTo(Duration(seconds: v.toInt()));
                      },
                    )
                  : Container(): Container(),
              continueToPlay? FloatingActionButton(
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
                        videoLikes = videoLikes - 1;
                      }
                      _iconType = Icons.favorite_border;
                      _iconColor = Colors.grey[700];
                      updateLikes(WatchVideo.pageId,videoLikes,_deviceid, 'remove');
                    } else if (_iconColor == Colors.grey[700]) {
                      videoLikes +=1;
                      _iconType = Icons.favorite;
                      _iconColor = Colors.pink;
                      updateLikes(WatchVideo.pageId,videoLikes,_deviceid,'update');
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
                    //if (!tabController.indexIsChanging) {}
                  });
                  return Scaffold(
                    appBar: TabBar(
                      labelColor: Colors.purple,
                      indicatorColor: Colors.purple,
                      tabs: tabs,
                    ),
                    body: continueToPlay ? TabBarView(
                      children: [
                        Container(
                            color: Colors.deepPurple[50],
                            child: Column(children: <Widget>[
                              Row(children: <Widget>[Icon(Icons.warning), Text(' Disclaimer', style: TextStyle(fontWeight: FontWeight.bold))],),
                              Card(
                                child:
                                Text('The material and information contained in the videos are for general information \n'
                                    'purposes only and should not be misconstrued as specific medical treatment advice.'
                                    'The information is not a substitute for professional medical expertise or treatment.  \n'
                                    'Any opinions and suggestions expressed in the comments are solely those of the commenter \n'
                                    'and is not endorsed by the developers of this app.  Medical advice provided in the \n'
                                    'comments should be regarded with caution.  \n'
                                    'For medical advice always consult your healthcare provider.\n'
                                ),
                              ),
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
                                    child: Container(
                                        child: Form(
                                            key: nameFormKey,
                                          child:
                                          TextFormField(
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
      //                                    debugPrint('_commentsList.toString()');
      //                                    debugPrint(_commentsList.toString());
                                            _commentsList.add({'userName':enteredName,'body':str, "date":DateTime.now(), 'uuid':_deviceid});
      //                                    debugPrint(str);
      //                                    debugPrint('enteredName');
      //                                    debugPrint(enteredName);
                                            writeToDatabase('/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}', WatchVideo.pageId, enteredName, str, _deviceid);
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
                                  ),
                                )
                              ),
                              Container(
                                  child: Expanded(
                                      child: FutureBuilder(
                                          future: findComments('/${categoryTitle[widget.previousPageName]}/${widget.videoTitle[widget.value]}'),
                                          builder: (buildContext, AsyncSnapshot snapshot) {
                                            if (snapshot.hasError)
                                              throw snapshot.error;
                                            else if (!snapshot.hasData) {
                                              return Container(
                                                child: Center(
                                                  child: Text("Loading Comments"),
                                                ),
                                              );
                                            } else {
                                              debugPrint('snapshot.data.length');
                                              debugPrint(snapshot.data.length.toString());
                                              for (int i = 0; i < snapshot.data.length; i++) {
                                                var map = HashMap.from(snapshot.data[i]);
                                                print('map $map');
                                                print('map Videos ${map['moreVideos']}');
                                                print('map Videos ${map['moreVideos'].runtimeType}');
                                                //debugPrint(map['comments'].toString());
                                                  videoLikes = map['videoLikes'].toInt();
                                                  deviceLikes = map['likedDevice'];
                                                  WatchVideo.pageId = map['_id'].toString();
                                                  _commentsList=map['comments'];
                                                 moreVideosList = map['moreVideos'];
                                              }
                                              debugPrint('this is comments list: ');
                                              //debugPrint(_commentsList.toString());
                                              //debugPrint('this is more videos: ${moreVideosList.toString()}');
                                              debugPrint('video likes: $videoLikes');
                                              debugPrint('page id: ${WatchVideo.pageId}');
                                              return Container(
                                                  color: Colors.deepPurple[50],
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: _commentsList.length,
                                                      scrollDirection: Axis.vertical,
                                                      physics: NeverScrollableScrollPhysics(),
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

                                  ))
                            ])),
                        Container(
                            color: Colors.white,
                            child: Column(children: <Widget>[
                              Expanded(
                                //child: moreVideosList.length>0?_buildVideoList(moreVideosList, widget.previousPageName):Container(),
                                child:Container(
//                                    child:Text(
//                                        moreVideosList.toString()
//                                    )
                                   child: moreVideosList.length>0 ? new ListView.builder
                                      (
                                        itemCount: moreVideosList.length,
                                        itemBuilder: (BuildContext ctxt, int Index) {
                                          return new Card(
                                              color: Colors.white,
                                              child: ListTile(
                                                leading: Icon(Icons.play_circle_filled),
                                                title: Text(moreVideosList[Index]),
                                                onTap: (){
                                                  //debugPrint('widget.previousPageName : ${widget.previousPageName}' );
                                                  Navigator.push(context, new MaterialPageRoute(
                                                      builder: (context) =>
                                                  new WatchVideo(value: moreVideosList[Index], previousPageName: widget.previousPageName)));
                                                },
                                              )
                                              //moreVideosList[Index]

                                          );
                                        }
                                    ):Container(child: Text('There are no other videos related to this topic'),)
                                ),
                              )
                            ]))
                      ],
                    ):Container(),
                  );
                }),
              )))
                ])
              )],
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
