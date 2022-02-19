import 'package:rxdart/rxdart.dart';

class AudioIsPlayingBloc {
  static final AudioIsPlayingBloc _singletonBloc =
      new AudioIsPlayingBloc._internal();

  final audioIsPlayingBloc = BehaviorSubject<bool>();

  factory AudioIsPlayingBloc() {
    return _singletonBloc;
  }

  AudioIsPlayingBloc._internal() {
    audioIsPlayingBloc.value = false;
  }

  dispose() {
    audioIsPlayingBloc.close();
  }
}

final audioIsPlayingBloc = AudioIsPlayingBloc();
