import '../../../../widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'composite_search_model.dart';

class CommunitySearchModel {
  int count;
  List<CommunityItemData> community;
  List<Facet> facets;
  List<AdditionalInfo>? additionalInfo;

  CommunitySearchModel(
      {required this.count,
      required this.community,
      required this.facets,
      this.additionalInfo});

  factory CommunitySearchModel.fromJson(Map<String, dynamic> json) =>
      CommunitySearchModel(
          count: (json['totalCount'] ?? 0) as int,
          community: json['data'] != null && json['data'].isNotEmpty
              ? List<CommunityItemData>.from(
                  json['data'].map((x) => CommunityItemData.fromJson(x)))
              : [],
          facets: getFacet(json),
          additionalInfo: (json['additionalInfo'] as List<dynamic>?)
              ?.map((item) => AdditionalInfo.fromJson(item))
              .toList());

  static List<Facet> getFacet(Map<String, dynamic> json) {
    if (json['facets'] != null && json['facets'].isEmpty) return [];
    List facetList = [];
    json['facets'].forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        facetList.add({'name': key, 'values': value});
      }
    });
    return List<Facet>.from(facetList.map((x) => Facet.fromJson(x)));
  }
}
