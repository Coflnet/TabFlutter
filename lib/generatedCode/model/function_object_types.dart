//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class FunctionObjectTypes {
  /// Instantiate a new enum with the provided [value].
  const FunctionObjectTypes._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const string = FunctionObjectTypes._(r'String');
  static const integer = FunctionObjectTypes._(r'Integer');
  static const number = FunctionObjectTypes._(r'Number');
  static const object = FunctionObjectTypes._(r'Object');
  static const array = FunctionObjectTypes._(r'Array');
  static const boolean = FunctionObjectTypes._(r'Boolean');
  static const null_ = FunctionObjectTypes._(r'Null');

  /// List of all possible values in this [enum][FunctionObjectTypes].
  static const values = <FunctionObjectTypes>[
    string,
    integer,
    number,
    object,
    array,
    boolean,
    null_,
  ];

  static FunctionObjectTypes? fromJson(dynamic value) => FunctionObjectTypesTypeTransformer().decode(value);

  static List<FunctionObjectTypes> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FunctionObjectTypes>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FunctionObjectTypes.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [FunctionObjectTypes] to String,
/// and [decode] dynamic data back to [FunctionObjectTypes].
class FunctionObjectTypesTypeTransformer {
  factory FunctionObjectTypesTypeTransformer() => _instance ??= const FunctionObjectTypesTypeTransformer._();

  const FunctionObjectTypesTypeTransformer._();

  String encode(FunctionObjectTypes data) => data.value;

  /// Decodes a [dynamic value][data] to a FunctionObjectTypes.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  FunctionObjectTypes? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'String': return FunctionObjectTypes.string;
        case r'Integer': return FunctionObjectTypes.integer;
        case r'Number': return FunctionObjectTypes.number;
        case r'Object': return FunctionObjectTypes.object;
        case r'Array': return FunctionObjectTypes.array;
        case r'Boolean': return FunctionObjectTypes.boolean;
        case r'Null': return FunctionObjectTypes.null_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [FunctionObjectTypesTypeTransformer] instance.
  static FunctionObjectTypesTypeTransformer? _instance;
}

