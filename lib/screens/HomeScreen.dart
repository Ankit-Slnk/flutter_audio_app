import 'package:audio_demo/screens/TrackScreen.dart';
import 'package:audio_demo/utility/AudioSequencesListBloc.dart';
import 'package:audio_demo/widget/BottomAudioPlayer.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    List<AudioInfo> _list = [];
    audioSequencesListBloc.audioSequencesList.listen((value) {
      value.forEach((item) => _list.add(
            AudioInfo(
              item.url,
              title: item.trackName,
              desc: item.albumName,
              coverUrl: "https://dummyimage.com/300/09f/fff.png",
            ),
          ));
      if (_list.isNotEmpty) AudioManager.instance.audioList = _list;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Audio Demo"),
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
      ),
    );
  }

  Widget body() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage("assets/dummy.png"),
          ),
          title: Text("Album " + (index + 1).toString()),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TrackScreen(albumName: "Album " + (index + 1).toString()),
              ),
            );
          },
        );
      },
    );
  }

  _notify() {
    if (mounted) setState(() {});
  }
}
