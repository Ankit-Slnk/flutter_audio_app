import 'package:audio_demo/models/AudioPlayback.dart';
import 'package:audio_demo/utility/AudioIsPlayingBloc.dart';
import 'package:audio_demo/utility/AudioSequencesListBloc.dart';
import 'package:audio_demo/utility/utiity.dart';
import 'package:audio_demo/widget/AudioSeekBar.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';

class AudioPlayerScreen extends StatefulWidget {
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool isFav = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _slider = Duration.zero;
  Duration _bufferedPosition = Duration.zero;
  PlayMode playMode = AudioManager.instance.playMode;
  List<AudioPlayback> playList = [];

  @override
  void initState() {
    super.initState();
    setupAudio();
  }

  void setupAudio() {
    playList = audioSequencesListBloc.audioSequencesList.stream.value;

    AudioManager.instance.onEvents((events, args) {
      print("events");
      print("$events");
      print("args");
      print("$args");

      switch (events) {
        case AudioManagerEvents.start:
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = Duration.zero;

          AudioPlayback audioPlayback =
              playList[AudioManager.instance.curIndex];

          _notify();
          break;
        case AudioManagerEvents.ready:
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _notify();
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = Duration(
              milliseconds:
                  _position.inMilliseconds ~/ _duration.inMilliseconds);
          _notify();
          break;
        case AudioManagerEvents.buffering:
          // isLoading = true;
          // _notify();
          // print(args["buffer"].toString());
          // if (args["buffer"].toString() == "100.0") {
          //   isLoading = false;
          //   _notify();
          // }
          _duration = AudioManager.instance.duration;
          if (_duration != Duration.zero) {
            _bufferedPosition = Duration(
                milliseconds: (_duration.inMilliseconds *
                        int.tryParse(
                          args["buffer"].toString(),
                        )) ~/
                    100);
          }

          break;
        case AudioManagerEvents.playstatus:
          audioIsPlayingBloc.audioIsPlayingBloc.sink.add(args);
          _notify();
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          if (_position != Duration.zero || _duration != Duration.zero)
            _slider = Duration(
                milliseconds:
                    _position.inMilliseconds ~/ _duration.inMilliseconds);
          _notify();
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16,
          ),
          audioControls(),
          Expanded(
            child: playList.length == 0 ? Container() : playlistView(),
          ),
        ],
      ),
    );
  }

  Widget playlistView() {
    return ListView.separated(
      itemBuilder: (context, index) {
        return playListItemView(index);
      },
      separatorBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: Divider(
            color: Colors.grey,
          ),
        );
      },
      itemCount: playList.length,
    );
  }

  updatePlaylist() async {
    List<AudioInfo> _list = [];
    await Future.forEach(audioSequencesListBloc.audioSequencesList.value,
        (AudioPlayback element) {
      _list.add(
        AudioInfo(
          element.url,
          title: element.trackName,
          desc: element.albumName,
          coverUrl:
              "https://dummyimage.com/512x512/000/fff.png", // must pass artCoverUrl starting with http to play audio from server
        ),
      );
    });
    await Future.delayed(Duration(milliseconds: 500));
    AudioManager.instance.audioList = _list;
    _notify();
  }

  Widget playListItemView(int index) {
    return ListTile(
      title: Text(
        playList[index].trackName,
        style: TextStyle(fontSize: 18),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        playList[index].albumName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: CircleAvatar(
        radius: 5,
        backgroundColor: AudioManager.instance.curIndex == index
            ? Colors.black
            : Colors.transparent,
      ),
      onTap: () async {
        await AudioManager.instance.play(index: index);
      },
    );
  }

  Widget audioControls() {
    return Column(children: <Widget>[
      SizedBox(
        height: 40,
      ),
      Container(
        height: 200,
        width: 200,
        child: CircleAvatar(
          radius: 200,
          backgroundImage: AssetImage("assets/dummy.png"),
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AudioManager.instance.info == null
                ? ""
                : AudioManager.instance.info.title,
            style: TextStyle(
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      SizedBox(
        height: 4,
      ),
      Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AudioManager.instance.info == null
                ? ""
                : AudioManager.instance.info.desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: songProgress(context),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              width: 36,
            ),
            IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_previous,
                color: Colors.black,
              ),
              onPressed: () => AudioManager.instance.previous(),
            ),
            StreamBuilder(
              initialData: false,
              stream: audioIsPlayingBloc.audioIsPlayingBloc.stream,
              builder: (context, AsyncSnapshot<bool> snapshot) {
                return IconButton(
                  onPressed: () async {
                    if (snapshot.data) {
                      await AudioManager.instance.toPause();
                    } else {
                      await AudioManager.instance.play();
                    }
                    _notify();
                  },
                  padding: const EdgeInsets.all(0.0),
                  icon: Icon(
                    snapshot.data ? Icons.pause : Icons.play_arrow,
                    size: 48.0,
                    color: Colors.black,
                  ),
                );
              },
            ),
            IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_next,
                color: Colors.black,
              ),
              onPressed: () {
                AudioManager.instance.next();
                _notify();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.stop,
                color: Colors.black,
              ),
              onPressed: () {
                AudioManager.instance.stop();
                _notify();
              },
            ),
          ],
        ),
      ),
    ]);
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(
      color: Colors.black,
      fontSize: 10,
    );
    if (_position > _duration) {
      _position = _duration;
    }
    if (_bufferedPosition > _duration) {
      _bufferedPosition = _duration;
    }
    return Row(
      children: <Widget>[
        Text(
          Utility.formatDuration(_position),
          style: style,
        ),
        Expanded(
          child: AudioSeekBar(
            duration: _duration,
            position: _position,
            bufferedPosition: _bufferedPosition,
            onChangeEnd: (newPosition) {
              AudioManager.instance.seekTo(newPosition);
            },
          ),
        ),
        Text(
          Utility.formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  _notify() {
    if (mounted) setState(() {});
  }
}
