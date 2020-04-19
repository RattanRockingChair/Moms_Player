import 'package:flutter/material.dart';
import 'musicService.dart';

enum _MusicListItemState {
  ePlaying,
  ePaused,
  eNon,
}

class MusicListItemWidget extends StatefulWidget {
  int _index;
  MusicInfo _item;
  State _state;
  _MusicListItemState _itemState = _MusicListItemState.eNon;

  MusicListItemWidget(MusicInfo item, int index) {
    _item = item;
    _index = index;
  }

  @override
  State<StatefulWidget> createState() {
    return _state = new MusicListItemWidgetState();
  }

  update(_MusicListItemState itemState) {
    _itemState = itemState;
    _state.setState(() => {});
  }

  MusicInfo getMusicInfo() {
    return _item;
  }

  bool _isActivated(){
    return _itemState == _MusicListItemState.ePaused || _itemState == _MusicListItemState.ePlaying;
  }
}

class MusicListItemWidgetState extends State<MusicListItemWidget> {
  @override
  Widget build(BuildContext context) {
    MusicListItemWidget widget = context.widget as MusicListItemWidget;

    return new Container(
      child: Row(
        children: <Widget>[
          Text(
            "${widget._index + 1}.",
            style: TextStyle(fontSize: 20),
          ),
          Spacer(flex: 1),
          Expanded(
              flex: 15,
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget._item.GetTitle(),
                    style: TextStyle(
                        fontWeight:
                            widget._isActivated()
                                ? FontWeight.bold
                                : FontWeight.normal,
                        fontSize: 18,
                        color: widget._isActivated()
                            ? Colors.cyan
                            : Colors.black),
                  ),
                  Text(
                    widget._item.GetArtist(),
                    style: TextStyle(
                      color: widget._isActivated()
                          ? Colors.cyan
                          : Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ))),
        ],
      ),
    );
  }
}

class MusicListWidget extends StatefulWidget {
  MusicService _musicSrv;
  List<MusicInfo> _musicsList = List<MusicInfo>();

  MusicListWidget(MusicService musicSrv) {
    _musicSrv = musicSrv;
  }

  @override
  State<StatefulWidget> createState() {
    return MusicListWidgetState(_musicSrv);
  }

  clearItem() {
    _musicsList.clear();
  }

  appendItem(List<MusicInfo> items) {
    _musicsList.addAll(items);
  }
}

class MusicListWidgetState extends State<MusicListWidget> {
  MusicService _musicSrv;
  int _curPlayingIndex = -1;
  List<MusicListItemWidget> _itemWidgetListBuf = List<MusicListItemWidget>();

  MusicListWidgetState(MusicService srv) {
    _musicSrv = srv;
    _musicSrv.onServiceStateChanged.listen(_OnMusicServiceStateChanged);
  }

  @override
  Widget build(BuildContext context) {
    MusicListWidget widget = context.widget as MusicListWidget;
    _itemWidgetListBuf.clear();
    _itemWidgetListBuf.length = widget._musicsList.length;

    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 1,
      ),
      itemBuilder: _buildItemWidget,
      itemCount: widget._musicsList.length,
    );
  }

  Widget _buildItemWidget(BuildContext context, int index) {
    _itemWidgetListBuf[index] =
        new MusicListItemWidget(widget._musicsList[index], index);
    return new ListTile(
        title: _itemWidgetListBuf[index], onTap: () => _OnTapItem(index));
  }

  MusicListItemWidget _getItemWidget(int index) {
    return _itemWidgetListBuf.length > index && index >= 0
        ? _itemWidgetListBuf[index]
        : null;
  }

  _OnMusicServiceStateChanged(SrvStatus stated) {
    if (stated == SrvStatus.ePlaying) {
      var newIndex = _musicSrv.CurrentMusicIndex();
      
      if (newIndex != _curPlayingIndex) {
        _UpdateItemWidgetState(newIndex, _MusicListItemState.ePlaying);
        _UpdateItemWidgetState(_curPlayingIndex, _MusicListItemState.eNon);
        _curPlayingIndex = newIndex;
      }
    } else {
      _UpdateItemWidgetState(
          _curPlayingIndex,
          stated == SrvStatus.ePaused
              ? _MusicListItemState.ePaused
              : _MusicListItemState.eNon);
    }
  }

  bool _UpdateItemWidgetState(int index, _MusicListItemState itemState) {
    var item = _getItemWidget(index);
    if (null != item) {
      item.update(itemState);
      return true;
    }

    return false;
  }

  _OnTapItem(int index) {
    var item = _getItemWidget(index);
    if (null != item) {
      _musicSrv.PlayByItem(item.getMusicInfo());
    }
  }
}
