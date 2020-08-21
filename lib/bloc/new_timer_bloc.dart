import 'dart:async';

import 'package:flutter_timer/ticker.dart';
import 'package:rxdart/rxdart.dart';

enum TimerBlocState { reset, running, paused }

class TimerBloc {
  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int> _tickerSubscription;

  final _timerCount = BehaviorSubject<int>.seeded(_duration);
  final _timerState =
      BehaviorSubject<TimerBlocState>.seeded(TimerBlocState.reset);

  TimerBloc(Ticker ticker)
      : assert(ticker != null),
        _ticker = ticker;

  Stream<int> get timerCount => _timerCount;

  Stream<TimerBlocState> get timerState => _timerState;

  void reset({int duration = _duration}) {
    _timerState.add(TimerBlocState.reset);
    _tickerSubscription?.cancel();
    _timerCount.add(duration);
  }

  void start() {
    if (_timerState.value == TimerBlocState.reset) {
      _timerState.add(TimerBlocState.running);
      _tickerSubscription?.cancel();
      _tickerSubscription = _ticker
          .tick(ticks: _timerCount.value)
          .listen((duration) => _timerCount.add(duration));
    }
  }

  void resume() {
    if (_timerState.value == TimerBlocState.paused) {
      _timerState.add(TimerBlocState.running);
      _tickerSubscription?.resume();
    }
  }

  void pause() {
    if (_timerState.value == TimerBlocState.running) {
      _timerState.add(TimerBlocState.paused);
      _tickerSubscription?.pause();
    }
  }

  void dispose() {
    _tickerSubscription?.cancel();
    _timerCount?.close();
    _timerState?.close();
  }
}