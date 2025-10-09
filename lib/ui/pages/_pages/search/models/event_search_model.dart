import 'package:karmayogi_mobile/models/_models/event_model.dart';

import 'composite_search_model.dart';

class EventSearchModel {
  int count;
  List<Event> events;
  List<Facet> facets;

  EventSearchModel({
    required this.count,
    required this.events,
    required this.facets,
  });

  factory EventSearchModel.fromJson(Map<String, dynamic> json) =>
      EventSearchModel(
        count: json['count'],
        events: json['Event'] != null && json['Event'].isNotEmpty
            ? List<Event>.from(json['Event'].map((x) => Event.fromJson(x)))
            : [],
        facets: json['facets'] != null && json['facets'].isNotEmpty
            ? List<Facet>.from(json['facets'].map((x) => Facet.fromJson(x)))
            : [],
      );
}
