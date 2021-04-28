import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localstorage/localstorage.dart';
import 'package:intl/intl.dart';
import 'package:erica_learning_chinese/model/chinese_character.dart';
import 'package:erica_learning_chinese/model/chinese_char_list.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> chars = [];
  DateTime selectedDate = DateTime.now();
  String strDate = '';
  final LocalStorage storage = new LocalStorage('chinese_app');
  final ChineseCharList chineseCharList = new ChineseCharList();
  TextEditingController controller = new TextEditingController();
  bool initialized = false;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    strDate = getFormattedDate(selectedDate);
    getWordsByDate(strDate);
  }

  String getFormattedDate(date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(selectedDate);
  }

  void getWordsByDate(date) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      chars = prefs.getStringList(date) ?? [];
      print('---------------$chars');
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        strDate = getFormattedDate(selectedDate);
      });
      getWordsByDate(strDate);
    }
  }

  void showDefinition(char) {
    for (int i = 0; i < chineseCharList.charList.length; i++) {
      if (chineseCharList.charList[i].character == char) {
        print(chineseCharList.charList[i].toString());
        _showMyDialog(chineseCharList.charList[i]);
      }
    }
  }

  Future<void> _showMyDialog(ChineseCharacter chineseCharacter) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(chineseCharacter.character),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(chineseCharacter.word),
                Text(chineseCharacter.pinyin),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(strDate),
        RaisedButton(
          onPressed: () => _selectDate(context),
          child: Text('选择日期'),
        ),
        Expanded(
          child: Container(
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

                  initialized = true;
                }

                return ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: RaisedButton(
                        color: Colors.lightBlueAccent,
                        disabledColor: Colors.lightBlueAccent,
                        child: Text(chars[index]),
                        onPressed: () {
                          showDefinition(chars[index]);
                        },
                      ),
                    );
                  },
                  itemCount: chars.length,
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
