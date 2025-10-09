import '../../models/resource_search_model.dart';
import '../../repository/search_repository.dart';

class ResourceSearchViewModel {
  final SearchRepository searchRepository = SearchRepository();

  Future<ResourceSearchModel?> getResourceData(
      {Map<String, dynamic>? filters,
      required List<String> facets,
      required Map<String, dynamic>? sortBy,
      int? limit,
      int pageNo = 0,
      String searchText = ''}) async {
    // Fetch search data
    ResourceSearchModel? result = await searchRepository.getResourceData(
        pageNo: pageNo,
        searchText: searchText,
        filters: filters,
        ttl: Duration.zero,
        facets: facets,
        sortBy: sortBy,
        limit: limit ?? 1);

    return result;
  }
}
