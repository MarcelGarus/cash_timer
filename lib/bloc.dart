import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class HistoryEntry {
  final DateTime start;
  final DateTime end;
  final double cash;

  Duration get duration => end.difference(start);

  HistoryEntry({@required this.start, @required this.end, @required this.cash});
  Map<String, dynamic> toJson() => {'start': start, 'end': end, 'cash': cash};
  factory HistoryEntry.fromJson(Map<String, dynamic> data) =>
      HistoryEntry(start: data['start'], end: data['end'], cash: data['cash']);
}

class HistoryBloc {
  final history = <HistoryEntry>[];
  final _historySubject = BehaviorSubject<List<HistoryEntry>>();
  Stream<List<HistoryEntry>> get historyStream => _historySubject.stream;

  HistoryBloc() {
    SharedPreferences.getInstance().then((sp) => sp
        .getStringList('history')
        .map((data) => HistoryEntry.fromJson(json.decode(data)))
        .forEach(history.add));
  }

  void dispose() => _historySubject.close();

  void add(HistoryEntry entry) {
    history.add(entry);
    _historySubject.add(history);
    SharedPreferences.getInstance()
        .then((sp) => sp.setStringList('history', history.map(json.encode)));
  }
}

class TimerBloc {
  final HistoryBloc history;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  DateTime _startTime;
  DateTime get _now => DateTime.now();
  Duration get difference => _now.difference(_startTime);
  final _differenceSubject = BehaviorSubject<Duration>();
  Stream<Duration> get differenceStream => _differenceSubject.stream;

  double _cashPerHour = 10;
  double get currentCash => (difference.inSeconds / 3600.0) * _cashPerHour;
  final _currentCashSubject = BehaviorSubject<double>();
  Stream<double> get currentCashStream => _currentCashSubject.stream;

  TimerBloc({@required this.history}) : assert(history != null);

  void startSession() {
    _isRunning = true;
    _startTime = _now;
    _run();
  }

  void endSession() {
    _isRunning = false;
    history.add(HistoryEntry(start: _startTime, end: _now, cash: currentCash));
  }

  void dispose() {
    _isRunning = false;
    _differenceSubject.close();
    _currentCashSubject.close();
  }

  Future<void> _run() async {
    while (_isRunning) {
      _differenceSubject.add(difference);
      _currentCashSubject.add(currentCash);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
}
