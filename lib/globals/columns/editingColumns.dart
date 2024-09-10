import 'package:table_entry/globals/columns/editColumnsClasses.dart';

col editingCol =
    col(name: "", id: 1, emoji: "", params: [param(name: "", type: "")]);

class EditingColumns {
  col createNewCol(String name, int id) {
    editingCol = col(
        emoji: "",
        name: name,
        id: id,
        params: [param(name: "NewParam", type: "String")]);
    return editingCol;
  }

  void addNewParam() {
    editingCol.params.add(param(name: "NewParam", type: "String"));
  }

  void updateParam(int index, String param, dynamic value) {
    editingCol.params[index][param] = value;
    if (param == "type" || value == "listOption") {
      editingCol.params[index].listOption = ["NewOption"];
    }
  }

  void updateName(String name) {
    editingCol.name = name;
  }

  void updateEmoji(String emoji) {
    editingCol.emoji = emoji;
  }

  void updateListOption(int index, int listIndex, String value) {
    editingCol.params[index].listOption[listIndex] = value;
  }

  void saveParam() {}

  col get getEditingCol => editingCol;
}
