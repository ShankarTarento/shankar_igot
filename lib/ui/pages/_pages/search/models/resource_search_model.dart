import '../../../../../models/_models/gyaan_karmayogi_resource_details.dart';
import 'composite_search_model.dart';

class ResourceSearchModel {
  int count;
  List<ResourceDetails> resource;
  List<Facet> facets;

  ResourceSearchModel({
    required this.count,
    required this.resource,
    required this.facets,
  });

  factory ResourceSearchModel.fromJson(Map<String, dynamic> json) =>
      ResourceSearchModel(
        count: json['count'],
        resource: json['content'] != null && json['content'].isNotEmpty
            ? List<ResourceDetails>.from(
                json['content'].map((x) => ResourceDetails.fromJson(x)))
            : [],
        facets: json['facets'] != null && json['facets'].isNotEmpty
            ? List<Facet>.from(json['facets'].map((x) => Facet.fromJson(x)))
            : [],
      );
}
