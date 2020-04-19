import 'package:flutter/material.dart';
import 'package:moms_player/musicService.dart';
import 'package:moms_player/coreWidget.dart';
import 'musicListWidget.dart';


const g_AppTitle = '妈妈的播放器';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: g_AppTitle,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(title: g_AppTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Scaffold _content;
  MusicListWidget _dataView;
  MusicService _musciSrv = new MusicService();

  _MyHomePageState();

  @override
  Widget build(BuildContext context) {
    print("home build");

    _content = Scaffold(
        appBar: AppBar(
          title: Text(widget.title ,style: TextStyle(color: Colors.white),),
        ),
        body: FutureBuilder(
          future: fillPlayList(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return createLoadingContentWidget();
            } else if (snapshot.connectionState == ConnectionState.done) {
              return createPlayContentWidget();
            } else {
              return new Text("error!");
            }
          },
        ));
    return _content;
  }

  Widget createLoadingContentWidget() {
    return Center(child: CircularProgressIndicator());
  }

  Widget createPlayContentWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              child: _dataView,
            ),
          ),
          createPlayBar()
        ],
      ),
    );
  }

  Widget createPlayBar() {
    var playBar = PlayerControlBarWidget(_musciSrv);
    return playBar;
  }

  fillPlayList() async {
    if (_dataView != null) {
      return;
    }

    int count = await _musciSrv.LoadMusic();

    if (count == 0) {
      return;
    }

    _dataView = MusicListWidget(_musciSrv);
    _dataView.appendItem(_musciSrv.GetAllMusicList());
  }
}
