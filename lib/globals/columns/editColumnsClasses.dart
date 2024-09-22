extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

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
    return "\n name: $name params: ${params.map((p) => p.toString())} id :$id";
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

  col copy() {
    return col(
      name: name,
      emoji: emoji,
      id: id,
      params: params.map((aram) => aram.copy()).toList(),
    );
  }
}

class param {
  String name;
  String type;
  String? svalue;
  List<String>? listOption;

  param(
      {required this.name,
      required this.type,
      List<String>? listOption,
      String? svalue})
      : svalue = svalue ?? '',
        listOption = listOption ?? <String>[];

  void operator []=(String key, dynamic value) {
    switch (key) {
      case "name":
        name = value;
      case "type":
        type = value;
        svalue = "$value";
      case "listOption":
        type = value;
      case "value":
        svalue = value;
      default:
        throw ArgumentError("Unknown param $key");
    }
  }

  @override
  String toString() {
    return "\n Param name $name type $type svalue $svalue";
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'listOption': listOption,
      'svalue': svalue
    };
  }

  factory param.fromJson(Map<String, dynamic> json) {
    return param(
        name: json['name'],
        type: json['type'],
        listOption: (json['listOption'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            <String>[],
        svalue: json["svalue"] ?? "hi");
  }

  param copy() {
    return param(
        name: name,
        type: type,
        listOption: List<String>.from(listOption ?? <String>[]),
        svalue: svalue);
  }
}
