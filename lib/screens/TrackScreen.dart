import 'package:audio_demo/models/AudioPlayback.dart';
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
        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage("assets/dummy.png"),
          ),
          title: Text("Track " + (index + 1).toString()),
          onTap: () {
            playAudio(index);
          },
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
    _notify();
  }

  _notify() {
    if (mounted) setState(() {});
  }
}
