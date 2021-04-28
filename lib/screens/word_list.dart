import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:erica_learning_chinese/model/chinese_character.dart';
import 'package:erica_learning_chinese/model/chinese_char_list.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final LocalStorage storage = new LocalStorage('chinese_app');
  final ChineseCharList chineseCharList = new ChineseCharList();
  TextEditingController controller = new TextEditingController();
  bool initialized = false;

  _addCharacter(
    String character,
    String pinyin,
    String word,
  ) {
    setState(() {
      final char = new ChineseCharacter(
          character: character, word: word, pinyin: pinyin);
      chineseCharList.charList.add(char);
      _saveToStorage();
    });
  }

  _saveToStorage() {
    storage.setItem('chinese_characters', chineseCharList.toJSONEncodable());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    title: Text(chineseCharList.charList[index].character),
                    trailing: Text(chineseCharList.charList[index].pinyin),
                    subtitle: Text(chineseCharList.charList[index].word),
                    onLongPress: () {
                      setState(() {
                        chineseCharList.charList.removeAt(index);
                        _saveToStorage();
                      });
                    },
                  );
                },
                itemCount: chineseCharList.charList.length,
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddCharacter(
              onPressed: _addCharacter,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddCharacter extends StatefulWidget {
  final Function onPressed;

  AddCharacter({this.onPressed});

  @override
  _AddCharacterState createState() => _AddCharacterState();
}

class _AddCharacterState extends State<AddCharacter> {
  @override
  Widget build(BuildContext context) {
    String character;
    String pinyin;
    String word;
    bool _validateCharacter = true;
    bool _validatePinyin = true;
    bool _validateWord = true;

    return SingleChildScrollView(
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        color: Color(0xff757575),
        child: Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '加新字',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 30,
                ),
              ),
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: '请输入新字',
                  errorText: _validateCharacter ? null : '不能为空',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 10.0,
                      color: Colors.lightBlueAccent,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                onChanged: (typedText) {
                  character = typedText;
                },
              ),
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: '请输入新字的拼音',
                  errorText: _validatePinyin ? null : '不能为空',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 10.0,
                      color: Colors.lightBlueAccent,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                onChanged: (typedText) {
                  pinyin = typedText;
                },
              ),
              TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: '请用新字组词',
                  errorText: _validateWord ? null : '不能为空',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      width: 10.0,
                      color: Colors.lightBlueAccent,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                onChanged: (typedText) {
                  word = typedText;
                },
              ),
              FlatButton(
                color: Colors.lightBlueAccent,
                onPressed: () {
                  setState(() {
                    if (character == null || character == '') {
                      _validateCharacter = false;
                    } else {
                      _validateCharacter = true;
                    }
                    if (pinyin == null || pinyin == '') {
                      _validatePinyin = false;
                    } else {
                      _validatePinyin = true;
                    }
                    if (word == null || word == '') {
                      _validateWord = false;
                    } else {
                      _validateWord = true;
                    }
                  });
                  print('$character, $pinyin, $word');

                  print(_validateWord);

                  if (_validateWord && _validatePinyin && _validateCharacter) {
                    widget.onPressed(character, pinyin, word);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'ok',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
