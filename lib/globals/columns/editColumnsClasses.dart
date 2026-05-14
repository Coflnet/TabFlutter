extension StringExtension on String {
  String capitalize() {
    if (this.length == 0) {
      return "Date";
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class col {
  String name;
  List<param> params;
  String emoji;
  int id;
  DateTime createdDate;

  col(
      {required this.name,
      required this.params,
      required this.id,
      DateTime? createdDate,
      required this.emoji})
      : createdDate = DateTime.now();

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
  dynamic svalue;
  List<String>? listOption;
  // Human-readable description of the column. Used by the phase-2 LLM
  // transcript-to-CSV extractor to know what the column means. Optional;
  // legacy data omits it. Keep short — recommend < 200 chars.
  String description;

  param(
      {required this.name,
      required this.type,
      List<String>? listOption,
      dynamic svalue,
      this.description = ''})
      : svalue = svalue ?? '',
        listOption = listOption ?? <String>[];

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
      case "description":
        description = value?.toString() ?? '';
      default:
        throw ArgumentError("Unknown param $key");
    }
  }

  @override
  String toString() {
    return "\n Param name $name type $type svalue $svalue  listOption $listOption description $description";
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'listOption': listOption,
      'svalue': svalue,
      'description': description,
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
        svalue: json["svalue"] ?? "hi",
        description: json['description']?.toString() ?? '');
  }

  param copy() {
    return param(
        name: name,
        type: type,
        listOption: List<String>.from(listOption ?? <String>[]),
        svalue: svalue,
        description: description);
  }
}
