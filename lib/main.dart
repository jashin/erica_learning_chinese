import 'package:flutter/material.dart';
import 'screens/word_list.dart';
import 'screens/history.dart';
import 'screens/test.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erica学中文',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: '字'),
                Tab(text: '练习'),
                Tab(text: '错字'),
              ],
            ),
            title: Text('Erica学中文'),
          ),
          body: TabBarView(
            children: [
              WordListScreen(),
              TestScreen(),
              HistoryScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
