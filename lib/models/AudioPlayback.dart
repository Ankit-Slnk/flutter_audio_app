import 'package:flutter/material.dart';

class AudioPlayback {
  String url;
  String trackName;
  String albumName;

  AudioPlayback({
    String url,
    @required String trackName,
    @required String albumName,
  }) {
    this.url = url;
    this.trackName = trackName;
    this.albumName = albumName;
  }
}
