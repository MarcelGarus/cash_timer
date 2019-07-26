import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

import 'bloc.dart';
import 'history.dart';
import 'utils.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          Provider<HistoryBloc>(
            builder: (_) => HistoryBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          ProxyProvider<HistoryBloc, TimerBloc>(
            builder: (_, history, __) => TimerBloc(history: history),
            dispose: (_, bloc) => bloc.dispose(),
          ),
        ],
        child: CashTimerApp(),
      ),
    );

class CashTimerApp extends StatefulWidget {
  @override
  _CashTimerAppState createState() => _CashTimerAppState();
}

class _CashTimerAppState extends State<CashTimerApp> {
  TimerBloc get _bloc => Provider.of<TimerBloc>(context);
  void _startSession() => setState(_bloc.startSession);
  void _endSession() => setState(_bloc.endSession);

  @override
  void initState() {
    super.initState();

    AudioPlayer advancedPlayer = AudioPlayer();
    AudioCache audioCache = AudioCache(fixedPlayer: advancedPlayer);

    Future.delayed(Duration.zero, () {
      double _lastValue = 0;
      Provider.of<TimerBloc>(context).currentCashStream.listen((newValue) {
        if (newValue / 10 != _lastValue / 10) {
          audioCache.play('cha-ching.mp3');
        } else if ((newValue * 100) % 10 != (_lastValue * 100) % 10) {
          audioCache.play('coin.mp3');
        }
        _lastValue = newValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cash Timer',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        backgroundColor: Colors.orange,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
            HistoryButton(),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CashTimer(),
              TimeStreakView(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _bloc.isRunning ? _endSession : _startSession,
          backgroundColor: Colors.white,
          icon: AnimatedSwitcher(
            duration: Duration(milliseconds: 5000),
            transitionBuilder: (child, animation) =>
                RotationTransition(turns: animation, child: child),
            child: Icon(_bloc.isRunning ? Icons.stop : Icons.play_arrow),
          ),
          label: Text(_bloc.isRunning ? 'End session' : 'Start session'),
        ),
      ),
    );
  }
}

class CashTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: Provider.of<TimerBloc>(context).currentCashStream,
      builder: (context, snapshot) {
        return Text(
          '${snapshot.data?.toStringAsFixed(2) ?? '-'} €',
          style: TextStyle(
            fontSize: 72,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu Mono',
          ),
        );
      },
    );
  }
}

class TimeStreakView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: Provider.of<TimerBloc>(context).differenceStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return Text(
          'working for ${stringifyDuration(snapshot.data)} straight',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto Condensed',
          ),
        );
      },
    );
  }
}

class HistoryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HistoryScreen(),
      )),
      icon: Icon(Icons.settings, color: Colors.white),
    );
  }
}
