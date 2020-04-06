import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'musicService.dart';

class MPButtonWidget extends StatefulWidget {
  MPButtonWidget(Key key) : super(key: key);

  VoidCallback onPressed;
  String text;

  @override
  State<MPButtonWidget> createState() {
    return MPButtonState(this.onPressed);
  }
}

class MPButtonState extends State<MPButtonWidget> {
  VoidCallback _onPressed;

  MPButtonState(this._onPressed);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Theme.of(context).colorScheme.primary,
      colorBrightness: Brightness.dark,
      onPressed: _onPressed,
      shape: CircleBorder(),
      child: Text(super.widget.text),
    );
  }
}

class MPMusicProgressWidget extends StatefulWidget {
  int duration = 0;
  int currentPos = 0;

  @override
  State<StatefulWidget> createState() {
    var state = MPMusicProgressState();
    return state;
  }
}

class MPMusicProgressState extends State<MPMusicProgressWidget> {
  @override
  Widget build(BuildContext context) {
    //context.widget
    return null;
  }
}

class PlayerControlBarWidget extends StatefulWidget {
  MPButtonWidget playBtn;
  FlatButton prevBtn;
  FlatButton nextBtn;
  GlobalKey<MPButtonState> _playBtnKey = new GlobalKey<MPButtonState>();
  MusicService _musicSrv;

  VoidCallback onPlayPause;
  VoidCallback onPrevious;
  VoidCallback onNext;

  PlayerControlBarWidget(@required MusicService musicSrv) {
    _musicSrv = musicSrv;
    _createSubCtrl();
  }

  void _createSubCtrl() {
    playBtn = new MPButtonWidget(_playBtnKey);
    playBtn.onPressed = _corePlayPause;
    playBtn.text = "播放";

    prevBtn = new FlatButton(
      onPressed: _corePrevious,
      child: Text("上一首"),
    );

    nextBtn = new FlatButton(
      onPressed: _coreNext,
      child: Text("下一首"),
    );
  }

  void _corePlayPause() {
    if (onPlayPause != null) {
      onPlayPause();
    }
  }

  void _corePrevious() {
    if (onPrevious != null) {
      onPrevious();
    }
  }

  void _coreNext() {
    if (onNext != null) {
      onNext();
    }
  }

  @override
  State<StatefulWidget> createState() {
    return PlayerControlState(_musicSrv);
  }
}

class PlayerControlState extends State<PlayerControlBarWidget> {
  MusicService _musicService;

  PlayerControlState(MusicService musicSrv) {
    _musicService = musicSrv;

    _musicService.onServiceStateChanged.listen(onMusicServiceStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build PlayerControl");

    var bar = context.widget as PlayerControlBarWidget;
    if (bar == null) {
      return null;
    }

    SizedBox play = SizedBox(width: 64, height: 64, child: bar.playBtn);

    return Container(
        child: Column(
      children: <Widget>[
        PlayerIndictorWidget(bar._musicSrv),
        Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
              children: <Widget>[bar.prevBtn, play, bar.nextBtn],
            ))
      ],
    ));
  }

  void onMusicServiceStateChanged(SrvStatus event) {
    if (context == null || context.widget == null) {
      return;
    }

    var playerCtrlWidget = context.widget as PlayerControlBarWidget;

    if (event == SrvStatus.ePlaying) {
      playerCtrlWidget._playBtnKey.currentState.widget.text = "暂停";
    } else {
      playerCtrlWidget._playBtnKey.currentState.widget.text = "播放";
    }

    playerCtrlWidget._playBtnKey.currentState.setState(()=>{});
  }
}

class PlayerIndictorWidget extends StatefulWidget {
  double curPos = 0;
  Duration duration = Duration(seconds: 0);
  MusicService _musicService;

  final StreamController<int> _posController = StreamController<int>.broadcast();

  Stream<int> get onIndictorPosChanged => _posController.stream;

  PlayerIndictorWidget(MusicService musicSrv) {
    _musicService = musicSrv;
  }

  @override
  State<StatefulWidget> createState() {
    return PlayerIndictorState(_musicService);
  }
}

class PlayerIndictorState extends State<PlayerIndictorWidget> {
  MusicService _musicService;

  PlayerIndictorState(MusicService musicSrv) {
    _musicService = musicSrv;
    _musicService.onMusicPosChanged.listen(_onMusicSrvPosChanged);
    _musicService.onMusicDurationChanged.listen(_onMusicSrvDurationChanged);
  }

  @override
  Widget build(BuildContext context) {
    print("build PlayerIndictor");
    var indictor = context.widget as PlayerIndictorWidget;

    return Container(
      child: Column(
        children: <Widget>[
          Slider(
              value: indictor.curPos,
              min: 0,
              max: indictor.duration.inSeconds.toDouble(),
              onChanged: _onSliderPosChanged),
          Container(
            margin: EdgeInsets.only(left: 5, right: 5),
            child: Row(
              children: <Widget>[
                Text("${_formatDuartion(Duration(seconds: indictor.curPos.toInt()))}"),
                Expanded(
                  child: Container(),
                ),
                Text("${_formatDuartion(indictor.duration)}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  _formatDuartion(Duration d){
    return d.toString().split('.').first.padLeft(8, "0");
  }

  void _onSliderPosChanged(double pos) {
    var indictor = context.widget as PlayerIndictorWidget;
    indictor._musicService.seekTo(pos.toInt());
    setState(() {});
  }

  void _onMusicSrvPosChanged(Duration duration) {
    var indictor = context.widget as PlayerIndictorWidget;
    indictor.curPos = duration.inSeconds.toDouble();
    setState(() {});
  }

  void _onMusicSrvDurationChanged(Duration event) {
    var indictor = context.widget as PlayerIndictorWidget;
    indictor.curPos = 0;
    indictor.duration = event;
    setState(() {});
  }
}

