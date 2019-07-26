import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc.dart';
import 'utils.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<HistoryEntry>>(
        stream: Provider.of<HistoryBloc>(context).historyStream,
        builder: (context, snapshot) {
          return ListView(
            children: (snapshot.data ?? []).map((entry) {
              return ListTile(
                title: Text(stringifyDuration(entry.duration)),
                subtitle: Text('made ${entry.cash.toStringAsFixed(2)} €'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
