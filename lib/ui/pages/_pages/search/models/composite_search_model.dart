import '../../../../../models/index.dart';

class CompositeSearchModel {
  int count;
  List<Course> content;
  List<Facet> facets;

  CompositeSearchModel({
    required this.count,
    required this.content,
    required this.facets,
  });

  factory CompositeSearchModel.fromJson(Map<String, dynamic> json) =>
      CompositeSearchModel(
        count: json['count'] != null
            ? json['count']
            : json['totalCount'] != null
                ? json['totalCount']
                : 0,
        content: json['content'] != null && json['content'].isNotEmpty
            ? List<Course>.from(json['content'].map((x) => Course.fromJson(x)))
            : json['data'] != null && json['data'].isNotEmpty
                ? List<Course>.from(json['data'].map((x) => Course.fromJson(x)))
                : [],
        facets: json['facets'] != null && json['facets'].isNotEmpty
            ? List<Facet>.from(json['facets'].map((x) => Facet.fromJson(x)))
            : [],
      );

  /// Adds a `copyWith()` method to modify specific properties
  CompositeSearchModel copyWith({
    int? count,
    List<Course>? content,
    List<Facet>? facets,
  }) {
    return CompositeSearchModel(
      count: count ?? this.count,
      content: content ?? List.from(this.content), // Ensure a copy is made
      facets: facets ?? List.from(this.facets), // Ensure a copy is made
    );
  }
}

class Facet {
  List<Value> values;
  String name;
  int count;
  bool useSingleChoice;

  Facet(
      {required this.values,
      required this.name,
      required this.count,
      this.useSingleChoice = false});

  factory Facet.fromJson(Map<String, dynamic> json) => Facet(
      values: List<Value>.from(json['values'].map((x) => Value.fromJson(x))),
      name: json['name'],
      count: json['count'] ?? 0,
      useSingleChoice: false);

  Map<String, dynamic> toJson() => {
        'values': List<dynamic>.from(values.map((x) => x.toJson())),
        'name': name,
      };

  /// Custom copy method to create a deep copy
  Facet copy() {
    return Facet(
        values:
            values.map((value) => value.copy()).toList(), // Deep copy of values
        name: name,
        count: count,
        useSingleChoice: useSingleChoice);
  }

  Facet copyWith(
      {List<Value>? values, String? name, int? count, bool? useSingleChoice}) {
    return Facet(
        values: values ?? this.values.map((value) => value.copy()).toList(),
        name: name ?? this.name,
        count: count ?? this.count,
        useSingleChoice: useSingleChoice ?? this.useSingleChoice);
  }
}

class Value {
  String name;
  int count;
  bool isChecked;
  bool isExpanded;
  bool showMore;
  bool isExpandable;
  Facet? subFacet;

  Value(
      {required this.name,
      required this.count,
      required this.isChecked,
      required this.isExpanded,
      required this.showMore,
      this.isExpandable = false,
      this.subFacet});

  factory Value.fromJson(Map<String, dynamic> json) => Value(
      name: json['name'] != null
          ? json['name']
          : json['value'] != null
              ? json['value']
              : '',
      count: json['count'],
      isChecked: false,
      subFacet: null,
      isExpanded: false,
      showMore: false,
      isExpandable: false);

  Map<String, dynamic> toJson() => {'name': name, 'count': count};

  /// Custom copy method to create a deep copy
  Value copy() {
    return Value(
        name: name,
        count: count,
        isChecked: isChecked,
        subFacet: subFacet?.copy(), // Deep copy of subFacet if it's not null
        isExpanded: isExpanded,
        showMore: showMore,
        isExpandable: isExpandable);
  }

  Value copyWith(
      {String? name,
      int? count,
      bool? isChecked,
      Facet? subFacet,
      bool? isExpanded,
      bool? showMore,
      bool? isExpandable}) {
    return Value(
        name: name ?? this.name,
        count: count ?? this.count,
        isChecked: isChecked ?? this.isChecked,
        subFacet: subFacet ?? this.subFacet,
        isExpanded: isExpanded ?? this.isExpanded,
        showMore: showMore ?? this.showMore,
        isExpandable: isExpandable ?? this.isExpandable);
  }
}
