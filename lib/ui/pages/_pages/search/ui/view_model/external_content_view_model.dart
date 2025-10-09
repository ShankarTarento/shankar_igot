import '../../models/composite_search_model.dart';
import '../../repository/search_repository.dart';
import '../../utils/search_helper.dart';

class ExternalContentViewModel {
  Future<CompositeSearchModel?> getExternalContentData(
      {CompositeSearchModel? existingData,
      Map<String, dynamic>? filters,
      String? searchText,
      int? pageNo,
      Map<String, dynamic>? sortBy}) async {
    CompositeSearchModel? externalData;
    try {
      externalData = await getExternalCourse(
          facets: [
            SearchFilterFacet.competencyAreaName,
            SearchFilterFacet.competencyThemeName,
            SearchFilterFacet.competencySubThemeName,
            SearchFilterFacet.extContentPartner,
            SearchFilterFacet.externalContentTopic
          ],
          filters: filters,
          searchText: searchText,
          pageNo: pageNo,
          sortBy: sortBy);

      if (externalData != null && externalData.content.isNotEmpty) {
        if (existingData != null && existingData.content.isNotEmpty) {
          existingData.content.addAll(externalData.content);
        } else {
          existingData = externalData;
        }
        existingData.facets.removeWhere((facet) => facet.values.isEmpty);
      } else if (existingData == null) {
        existingData = externalData;
      }
      return existingData;
    } catch (err) {
      print(err);
      return null;
    }
  }

  Future<CompositeSearchModel?> getExternalCourse(
      {Map<String, dynamic>? filters,
      required List<String> facets,
      int? limit,
      String? searchText,
      int? pageNo,
      Map<String, dynamic>? sortBy}) async {
    CompositeSearchModel? externalData = await SearchRepository()
        .searchExternalCourses(
            query: searchText ?? '',
            facet: facets,
            offset: pageNo ?? 0,
            filters: filters,
            limit: limit,
            sortBy: sortBy != null &&
                    sortBy.isNotEmpty &&
                    sortBy.entries.first.key != SearchFilterFacet.avgRating
                ? sortBy.entries.first.key
                : '');
    return externalData;
  }
}
