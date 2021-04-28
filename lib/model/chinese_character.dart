import 'package:flutter/cupertino.dart';

class ChineseCharacter {
  String word;
  String character;
  String pinyin;

  ChineseCharacter({this.character, this.word, this.pinyin});

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['character'] = character;
    m['word'] = word;
    m['pinyin'] = pinyin;

    return m;
  }
}
