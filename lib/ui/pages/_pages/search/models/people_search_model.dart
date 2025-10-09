import '../../../../../models/index.dart';
import 'composite_search_model.dart';

class PeopleSearchModel {
  int count;
  List<Suggestion> people;
  List<Facet> facets;

  PeopleSearchModel({
    required this.count,
    required this.people,
    required this.facets,
  });

  factory PeopleSearchModel.fromJson(Map<String, dynamic> json) =>
      PeopleSearchModel(
        count: json['count'],
        people: json['content'] != null && json['content'].isNotEmpty
            ? List<Suggestion>.from(
                json['content'].map((x) => Suggestion.fromJson(x)))
            : [],
        facets: json['facets'] != null && json['facets'].isNotEmpty
            ? List<Facet>.from(json['facets'].map((x) => Facet.fromJson(x)))
            : [],
      );
}
