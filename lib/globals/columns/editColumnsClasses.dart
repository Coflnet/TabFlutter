class col {
  String name;
  List<param> params;
  String emoji;
  int id;

  col(
      {required this.name,
      required this.params,
      required this.id,
      required this.emoji});

  @override
  String toString() {
    return "name: ${name}params: $params id :$id";
  }
}

class param {
  String name;
  String type;
  List listOption;

  param({
    required this.name,
    required this.type,
    List? listOption,
  }) : listOption = listOption ?? [];

  void operator []=(String key, dynamic value) {
    switch (key) {
      case "name":
        name = value;
      case "type":
        type = value;
      case "listOption":
        type = value;
      default:
        throw ArgumentError("Unknown param $key");
    }
  }

  @override
  String toString() {
    return "name: $name type: $type listOption: $listOption";
  }
}
