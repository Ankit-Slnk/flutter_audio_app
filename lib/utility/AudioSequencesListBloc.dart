import 'package:audio_demo/models/AudioPlayback.dart';
import 'package:rxdart/rxdart.dart';

class AudioSequencesList {
  static final AudioSequencesList _singletonBloc =
      new AudioSequencesList._internal();

  final audioSequencesList = BehaviorSubject<List<AudioPlayback>>();

  factory AudioSequencesList() {
    return _singletonBloc;
  }

  AudioSequencesList._internal() {
    audioSequencesList.value = [];
  }

  dispose() {
    audioSequencesList.close();
  }
}

final audioSequencesListBloc = AudioSequencesList();
