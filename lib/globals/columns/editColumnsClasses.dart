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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'params': params.map((p) => p.toJson()).toList(),
      'emoji': emoji,
      'id': id,
    };
  }

  factory col.fromJson(Map<String, dynamic> json) {
    return col(
      name: json['name'],
      params: (json['params'] as List)
          .map((p) => param.fromJson(p as Map<String, dynamic>))
          .toList(),
      id: json['id'],
      emoji: json['emoji'],
    );
  }
}

class param {
  String name;
  String type;
  String? svalue;
  List? listOption;

  param(
      {required this.name,
      required this.type,
      List? listOption,
      String? svalue})
      : svalue = svalue ?? '',
        listOption = listOption ?? [];

  void operator []=(String key, dynamic value) {
    switch (key) {
      case "name":
        name = value;
      case "type":
        type = value;
      case "listOption":
        type = value;
      case "value":
        svalue = value;
      default:
        throw ArgumentError("Unknown param $key");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'listOption': listOption,
    };
  }

  factory param.fromJson(Map<String, dynamic> json) {
    return param(
      name: json['name'],
      type: json['type'],
      listOption: json['listOption'] ?? [],
    );
  }
}
