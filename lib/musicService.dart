import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum SrvStatus {
  ePlaying,
  eStoped,
  ePaused,
  eError,
}

class MusicInfo {
  String _path;
  String _title;
  String _artist;
  String tmp;

  MusicInfo(Map<String, dynamic> json) {
    _path = json["FilePath"];
    _artist = json["Artist"];
    _title = json["Title"];
  }

  String GetPath() {
    return _path;
  }

  String GetTitle(){
    return _title;
  }

  String GetArtist(){
    return _artist;
  }
}

enum AutoPlayMode{
  eNon,         // 不自动播放,即播完停止
  eSequential,  // 自动顺序播放
  eRandom       // 自动随机播放
}

class MusicService {
  static const String _channelName = "channel.momsplayer/musicfinder";
  static const _platform = const MethodChannel(_channelName);

  int _musicIndex = -1;
  List<MusicInfo> _musicItems = List<MusicInfo>();
  AudioPlayer _audioPlayer = AudioPlayer();
  AutoPlayMode _autoPlayMode = AutoPlayMode.eNon;

  final StreamController<Duration> _musicPosChangedCtrller =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _musicDurationChangedCtrller =
      StreamController<Duration>.broadcast();
  final StreamController<void> _playerCompletion =
      StreamController<void>.broadcast();
  final StreamController<SrvStatus> _playerStateChanged =
      StreamController<SrvStatus>.broadcast();

  Stream<Duration> get onMusicPosChanged => _musicPosChangedCtrller.stream;
  Stream<Duration> get onMusicDurationChanged => _musicDurationChangedCtrller.stream;
  Stream<void> get onPlayerCompletion => _playerCompletion.stream;
  Stream<SrvStatus> get onServiceStateChanged => _playerStateChanged.stream;

  MusicService() {
    _audioPlayer.onAudioPositionChanged.listen(onAudioPosChanged);
    _audioPlayer.onDurationChanged.listen(onAudioDurationChanged);
    _audioPlayer.onPlayerCompletion.listen(onAudioPlayerCompletion);
    _audioPlayer.onPlayerStateChanged.listen(onAudioPlayerStateChanged);
  }

  SrvStatus Status() {
    switch (_audioPlayer.state) {
      case AudioPlayerState.STOPPED:
      case AudioPlayerState.COMPLETED:
        return SrvStatus.eStoped;
      case AudioPlayerState.PAUSED:
        return SrvStatus.ePaused;
      case AudioPlayerState.PLAYING:
        return SrvStatus.ePlaying;
    }

    return SrvStatus.eStoped;
  }

  Play() {
    if (AudioPlayerState.PAUSED == _audioPlayer.state) {
      _audioPlayer.resume();
      return;
    } else if (AudioPlayerState.PLAYING == _audioPlayer.state) {
      return;
    }

    if (_musicIndex == -1) {
      PlayNext();
    } else if (_musicIndex < _musicItems.length) {
      _PlayCore(_musicItems[_musicIndex]);
    }
  }

  void PlayByItem(MusicInfo tobePlay) {
    Pause();

    for (var i = 0; i < _musicItems.length; i++) {
      if (_musicItems[i]._path == tobePlay._path){
        _musicIndex = i;
        _PlayCore(_musicItems[_musicIndex]);
        break;
      }
    }
  }

  Pause() {
    _audioPlayer.pause();
  }

  PlayPrevious() {
    if (_musicIndex - 1 < 0) {
      _StopCore();
      return;
    }

    _PlayCore(_musicItems[--_musicIndex]);
  }

  PlayNext() {
    if (_musicIndex + 1 >= _musicItems.length) {
      _StopCore();
      return;
    }

    _PlayCore(_musicItems[++_musicIndex]);
  }

  AutoPlay(AutoPlayMode mode){
    _autoPlayMode = mode;
  }

  _PlayCore(MusicInfo item) {
    if (_audioPlayer.state != AudioPlayerState.STOPPED) {
      _StopCore();
    }
    _audioPlayer.play(item._path);
  }

  _StopCore() {
    _audioPlayer.stop();
  }

  MusicInfo CurrentMusic() {
    return _musicIndex == -1 ? null : _musicItems[_musicIndex];
  }

  int CurrentMusicIndex(){
    return _musicIndex;
  }

  List<MusicInfo> GetAllMusicList() {
    return _musicItems;
  }

  LoadMusic() async {
    List<MusicInfo> buf = await _SearchAllMusic();

    if (buf.isEmpty) {
      return 0;
    }

    _musicItems.addAll(buf);
    return _musicItems.length;
  }

  Future<List<MusicInfo>> _SearchAllMusic() async {
    List<MusicInfo> buf = List<MusicInfo>();

    try {
      String results = await _platform.invokeMethod(_channelName);
      List<dynamic> objs = json.decode(results);

      for (var i = 0; i < objs.length; i++) {
        if (objs[i] is Map<String, dynamic>){
          buf.add(MusicInfo(objs[i] as Map<String, dynamic>));
        }
      }
    } on PlatformException catch (e) {} finally {
      
    }

    return buf;
  }

  void onAudioPosChanged(Duration event) {
    _musicPosChangedCtrller.add(event);
  }

  void onAudioDurationChanged(Duration event) {
    _musicDurationChangedCtrller.add(event);
  }

  void onAudioPlayerCompletion(void event) {
    _playerCompletion.add(event);

    if (_autoPlayMode == AutoPlayMode.eNon) {
      return;
    }

    PlayNext();
  }

  void seekTo(int second) {
    _audioPlayer.seek(Duration(seconds: second));
  }

  void onAudioPlayerStateChanged(AudioPlayerState event) {
    _playerStateChanged.add(Status());
  }
}
