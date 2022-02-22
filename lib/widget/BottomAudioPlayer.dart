import 'package:audio_demo/models/AudioPlayback.dart';
import 'package:audio_demo/screens/AudioPlayerScreen.dart';
import 'package:audio_demo/utility/AudioIsPlayingBloc.dart';
import 'package:audio_demo/utility/AudioSequencesListBloc.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';

class BottomAudioPlayer extends StatefulWidget {
  Function callback;
  BottomAudioPlayer({
    this.callback,
    Key key,
  }) : super(key: key);

  @override
  _BottomAudioPlayerState createState() => _BottomAudioPlayerState();
}

class _BottomAudioPlayerState extends State<BottomAudioPlayer> {
  AudioPlayback audioPlayback;

  updatePlayback() {
    widget.callback();
    if (audioSequencesListBloc.audioSequencesList.stream.value.length > 0) {
      audioPlayback = audioSequencesListBloc
          .audioSequencesList.stream.value[AudioManager.instance.curIndex];
      _notify();
    }
  }

  @override
  void initState() {
    super.initState();
    AudioManager.instance.onEvents((events, args) {
      print("events");
      print("$events");
      print("args");
      print("$args");

      updatePlayback();

      switch (events) {
        case AudioManagerEvents.start:
          print("********");
          print("START");
          print("********");
          break;
        case AudioManagerEvents.ready:
          break;
        case AudioManagerEvents.seekComplete:
          break;
        case AudioManagerEvents.buffering:
          // isLoading = true;
          // _notify();
          // print(args["buffer"].toString());
          // if (args["buffer"].toString() == "100.0") {
          //   isLoading = false;
          //   _notify();
          // }
          break;
        case AudioManagerEvents.playstatus:
          audioIsPlayingBloc.audioIsPlayingBloc.sink.add(args);
          _notify();
          break;
        case AudioManagerEvents.timeupdate:
          break;
        case AudioManagerEvents.error:
          break;
        case AudioManagerEvents.stop:
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
    return Container(
      child: StreamBuilder(
        initialData: <AudioPlayback>[],
        stream: audioSequencesListBloc.audioSequencesList.stream,
        builder: (context, AsyncSnapshot<List<AudioPlayback>> snapshot) {
          return snapshot.data.length == 0
              ? Container()
              : body(snapshot.data[AudioManager.instance.curIndex]);
        },
      ),
    );
  }

  Widget body(AudioPlayback audioPlayback) {
    return audioPlayback == null
        ? Container()
        : GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => AudioPlayerScreen(),
                ),
              );
              _notify();
              updatePlayback();
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage("assets/dummy.png"),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audioPlayback.trackName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          audioPlayback.albumName,
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  IconButton(
                    iconSize: 24,
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
                            _notify();
                          } else {
                            await AudioManager.instance.play();
                            _notify();
                          }
                        },
                        padding: const EdgeInsets.all(0.0),
                        icon: Icon(
                          snapshot.data ? Icons.pause : Icons.play_arrow,
                          size: 35,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    iconSize: 24,
                    icon: Icon(
                      Icons.skip_next,
                      color: Colors.black,
                    ),
                    onPressed: () => AudioManager.instance.next(),
                  ),
                ],
              ),
            ),
          );
  }

  _notify() {
    if (mounted) setState(() {});
  }
}
