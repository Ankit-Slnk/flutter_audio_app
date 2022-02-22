import 'package:audio_demo/models/AudioPlayback.dart';
import 'package:audio_demo/utility/AudioIsPlayingBloc.dart';
import 'package:audio_demo/utility/AudioSequencesListBloc.dart';
import 'package:audio_demo/widget/BottomAudioPlayer.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';

class TrackScreen extends StatefulWidget {
  String albumName;
  TrackScreen({@required this.albumName, Key key}) : super(key: key);

  @override
  _TrackScreenState createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  List<String> urls = [
    "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3",
    "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_1MG.mp3",
    "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_2MG.mp3",
    "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_5MG.mp3"
  ];
  bool isCurrentPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albumName),
      ),
      body: Column(
        children: [
          Expanded(
            child: body(),
          ),
          BottomAudioPlayer(
            callback: () {
              print("BottomAudioPlayer");
              isCurrentPlaying = audioSequencesListBloc
                          .audioSequencesList.stream.value.length !=
                      0 &&
                  AudioManager.instance.isPlaying;
              _notify();
            },
          )
        ],
      ),
    );
  }

  Widget body() {
    return ListView.builder(
      itemCount: urls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (isCurrentPlaying && AudioManager.instance.curIndex == index) {
              AudioManager.instance.toPause();
              _notify();
            } else {
              playAudio(index);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
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
                  child: Text(
                    "Track " + (index + 1).toString(),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                isCurrentPlaying && AudioManager.instance.curIndex == index
                    ? CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.black,
                      )
                    : Container()
              ],
            ),
          ),
        );
      },
    );
  }

  playAudio(int index) async {
    List<AudioPlayback> audioList = [];
    print(urls.length);
    await Future.forEach(urls, (String element) {
      audioList.add(AudioPlayback(
        albumName: widget.albumName,
        trackName: "Track " + (urls.indexOf(element) + 1).toString(),
        url: element,
      ));
    });
    AudioManager.instance.audioList.clear();
    audioSequencesListBloc.audioSequencesList.sink.add(audioList);
    await Future.delayed(Duration(milliseconds: 500));
    await AudioManager.instance.play(index: index);
    await Future.delayed(Duration(milliseconds: 1000));
    _notify();
  }

  _notify() {
    if (mounted) setState(() {});
  }
}
