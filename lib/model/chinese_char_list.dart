import 'chinese_character.dart';

class ChineseCharList {
  List<ChineseCharacter> charList = [];

  toJSONEncodable() {
    return charList.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}
