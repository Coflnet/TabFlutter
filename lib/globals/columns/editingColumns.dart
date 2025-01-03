import 'package:spables/globals/columns/editColumnsClasses.dart';
import 'package:spables/globals/columns/saveColumn.dart';
import 'package:spables/globals/recentLogRequest/recentLogHandler.dart';

col editingCol =
    col(name: "", id: 1, emoji: "", params: [param(name: "", type: "")]);
int editingIndex = 0;

class EditingColumns {
  col createNewCol(String name, int id) {
    editingCol = col(
        emoji: "",
        name: name,
        id: id,
        params: [param(name: "", type: "", svalue: "")]);
    return editingCol;
  }

  void addNewParam() {
    editingCol.params.add(param(name: "", type: "", svalue: ""));
  }

  void updateParam(int index, String param, dynamic value) {
    editingCol.params[index][param] = value;
    if (param == "type" || value == "listOption") {
      editingCol.params[index].listOption = [];
    }
  }

  void updateName(String name) {
    editingCol.name = name;
  }

  void updateEmoji(String emoji) {
    editingCol.emoji = emoji;
  }

  void updateListOption(int index, int listIndex, String value) {
    editingCol.params[index].listOption?[listIndex] = value;
  }

  void addListOption(int index) {
    editingCol.params[index].listOption?.add("");
  }

  void saveCol() {
    RecentLogHandler().updateCollumn(editingCol);
  }

  col get getEditingCol => editingCol;
  int get getEditingIndex => editingIndex;
  set setEditingIndex(v) => editingIndex = v;
  set setEditingCol(col value) {
    editingCol = value;
  }
}
