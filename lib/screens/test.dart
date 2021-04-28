import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:erica_learning_chinese/model/chinese_character.dart';
import 'package:erica_learning_chinese/model/chinese_char_list.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final LocalStorage storage = new LocalStorage('chinese_app');
  final ChineseCharList chineseCharList = new ChineseCharList();
  int currentIndex = 0;
  int num = 0;
  String character = '';
  String pinyin = '';
  String word = '';
  String today;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool initialized = false;

  bool displayPinyin = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    today = formatter.format(now);
  }

  int getNewIndex() {
    var rng = new Random();
    if (chineseCharList.charList.length != 0) {
      return rng.nextInt(chineseCharList.charList.length);
    } else {
      return 0;
    }
  }

  updateUI() {
    setState(() {
      character = chineseCharList.charList[currentIndex].character;
      pinyin = chineseCharList.charList[currentIndex].pinyin;
      word = chineseCharList.charList[currentIndex].word;
      num++;
    });
  }

  Future<void> nextQuestion(bool result) async {
    if (!result) {
      final SharedPreferences prefs = await _prefs;
      List<String> words = prefs.getStringList(today) ?? [];
      if (!words.contains(chineseCharList.charList[currentIndex].character)) {
        words.add(chineseCharList.charList[currentIndex].character);
      }
      prefs.setStringList(today, words);
      print(prefs.getStringList(today).toString());
    }

    currentIndex = getNewIndex();
    displayPinyin = false;
    updateUI();
  }

  Widget showAnswer() {
    if (displayPinyin) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Text(pinyin),
      );
    } else {
      return RaisedButton(
        onPressed: () {
          setState(() {
            displayPinyin = true;
          });
        },
        child: Text('看答案'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10.0),
        constraints: BoxConstraints.expand(),
        child: FutureBuilder(
          future: storage.ready,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!initialized) {
              var allChars = storage.getItem('chinese_characters');

              if (allChars != null) {
                chineseCharList.charList = List<ChineseCharacter>.from(
                  (allChars as List).map(
                    (item) => ChineseCharacter(
                      character: item['character'],
                      pinyin: item['pinyin'],
                      word: item['word'],
                    ),
                  ),
                );
              }

              currentIndex = getNewIndex();

              initialized = true;
            }
            character = chineseCharList.charList[currentIndex].character;
            pinyin = chineseCharList.charList[currentIndex].pinyin;
            word = chineseCharList.charList[currentIndex].word;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FlatButton(
                    onPressed: () {},
                    child: Text(character),
                    textTheme: ButtonTextTheme.primary,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Text(word),
                  ),
                  Divider(
                    height: 10.0,
                    thickness: 0.0,
                  ),
                  showAnswer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          nextQuestion(true);
                        },
                        child: Text('记住了'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          nextQuestion(false);
                        },
                        child: Text('没记住'),
                      )
                    ],
                  ),
                  Text(num.toString()),
                ],
              ),
            );
          },
        ));
  }
}
