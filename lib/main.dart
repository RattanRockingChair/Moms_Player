import 'package:flutter/material.dart';
import 'package:moms_player/musicService.dart';
import 'package:moms_player/coreWidget.dart';
import 'musicListWidget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '妈妈的播放器',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(title: '妈妈的播放器'),
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
  int _counter = 0;
  Scaffold _content;
  MusicListWidget _dataView = null;
  FlatButton _prevBtn;
  MPButtonWidget _playBtn;
  FlatButton _nextBtn;
  MusicService _musciSrv = new MusicService();

  _MyHomePageState() {}

  @override
  Widget build(BuildContext context) {
    print("home build");

    _content = Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
          future: FillPlayList(),
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
    playBar.onPlayPause = _Play;
    playBar.onNext = _Next;
    playBar.onPrevious = _Previous;
    return playBar;
  }

  FillPlayList() async {
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

  _Play() {
    if (_musciSrv.Status() == SrvStatus.ePlaying) {
      _musciSrv.Pause();
    } else {
      _musciSrv.Play();
    }
  }

  _Previous() {
    var status = _musciSrv.Status();
    if (SrvStatus.ePlaying == status || SrvStatus.ePaused == status) {
      _musciSrv.PlayPrevious();
    }
  }

  _Next() {
    var status = _musciSrv.Status();
    if (SrvStatus.ePlaying == status || SrvStatus.ePaused == status) {
      _musciSrv.PlayNext();
    }
  }
}
