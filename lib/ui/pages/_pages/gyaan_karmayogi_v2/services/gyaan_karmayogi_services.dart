import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_category_model.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_resource_details.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_resource_model.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_sector_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/_services/gyaan_karmayogi_service.dart';
import 'package:karmayogi_mobile/util/app_config.dart';

class GyaanKarmayogiServicesV2 extends ChangeNotifier {
  final String coursesUrl = ApiUrl.baseUrl + ApiUrl.getTrendingCourses;
  List<String> _sectorFilters = [];
  List<String> _subSectorFilters = [];
  List<String> _resourceCategoriesFilters = [];
  List<String> _createdFor = [];
  Map<String, dynamic> amritGyaanConfig = {};
  List<String> get sectorFilters => _sectorFilters;

  List<String> get subSectorFilters => _subSectorFilters;

  List<String> get resourceCategoriesFilters => _resourceCategoriesFilters;
  List<String> get createdFor => _createdFor;

  List<String> selectedSector = [];

  getAllFilterData(
      {List<String>? sectorsFilter,
      String? searchQuery,
      List<String>? createdFor,
      List<String>? subSectorFilter,
      List<String>? resourceCategoryFilter}) async {
    _sectorFilters = [];
    _subSectorFilters = [];
    _resourceCategoriesFilters = [];
    List<String> availableSectors =
        await GyaanKarmayogiServicesV2().getAvailableSectors();
    List<dynamic> allowedCategories =
        await GyaanKarmayogiServicesV2().getAllowedCategories();

    Response response = await GyaanKarmayogiApiService().getGyaanKarmayogiData(
        contentType: createdFor == null ? ['Resource', 'Course'] : null,
        sectors: sectorsFilter != null && sectorsFilter.isNotEmpty
            ? sectorsFilter
            : availableSectors,
        subSector: subSectorFilter,
        resourceCategory: resourceCategoryFilter,
        createdFor: createdFor ?? [AppConfiguration().amritGyaanOrgId ?? ''],
        searchQuery: searchQuery);

    var data = jsonDecode(response.body);

    List facets = data["result"]["facets"];
    facets.forEach(
      (e) {
        if (e["name"] == "sectorDetails_v1.sectorName") {
          e["values"].forEach((element) {
            _sectorFilters.add(element["name"]);
          });
        } else if (e["name"] == "sectorDetails_v1.subSectorName") {
          e["values"].forEach((element) {
            _subSectorFilters.add(element["name"]);
          });
        } else if (e["name"] == "resourceCategory") {
          e["values"].forEach((element) {
            _resourceCategoriesFilters.add(element["name"]);
          });
        }
      },
    );
    _resourceCategoriesFilters
        .retainWhere((item) => allowedCategories.contains(item.toString()));
    _resourceCategoriesFilters.sort();

    notifyListeners();
  }

  Future<List<String>> getSubsector(
      {String? sectorFilter,
      String? subsectorFilter,
      required bool returnSubsector}) async {
    List<String> subSectors = [];
    List<String> resourceCategories = [];
    List<String> availableSectors =
        await GyaanKarmayogiServicesV2().getAvailableSectors();
    List<dynamic> allowedCategories =
        await GyaanKarmayogiServicesV2().getAllowedCategories();

    Response response = await GyaanKarmayogiApiService().getGyaanKarmayogiData(
        sectors: sectorFilter != null ? [sectorFilter] : availableSectors,
        subSector: subsectorFilter != null ? [subsectorFilter] : []);

    var data = jsonDecode(response.body);

    List facets = data["result"]["facets"];
    facets.forEach(
      (e) {
        if (e["name"] == "sectorDetails_v1.subSectorName") {
          e["values"].forEach((element) {
            subSectors.add(element["name"]);
          });
        } else if (e["name"] == "resourceCategory") {
          e["values"].forEach((element) {
            resourceCategories.add(element["name"]);
          });
        }
      },
    );
    resourceCategories
        .retainWhere((item) => allowedCategories.contains(item.toString()));
    resourceCategories.sort();
    subSectors.sort();

    return returnSubsector ? subSectors : resourceCategories;
  }

  Future<List<GyaanKarmayogiSector>> getAllSectors() async {
    List<GyaanKarmayogiSector> gyaanKarmayogiSectors = [];

    Response response = await GyaanKarmayogiApiService().getSectorsData();

    var result = jsonDecode(response.body);
    List sector = result["result"]["sectors"];
    sector.forEach(
      (element) {
        gyaanKarmayogiSectors.add(GyaanKarmayogiSector.fromJson(element));
      },
    );

    return gyaanKarmayogiSectors;
  }

  Future<List<GyaanKarmayogiSector>> getAvailableSectorWithIcon() async {
    List<String> availableSectors = [];
    List<GyaanKarmayogiSector> gyaanKarmayogiSectors = await getAllSectors();
    List<GyaanKarmayogiSector> updatedList = [];

    Response response = await GyaanKarmayogiApiService().getAvailableSectors();
    var data = jsonDecode(response.body);

    List facets = data["result"]["facets"];
    facets.forEach(
      (e) {
        if (e["name"] == "sectorDetails_v1.sectorName") {
          e["values"].forEach((element) {
            availableSectors.add(element["name"]);
          });
        }
      },
    );

    gyaanKarmayogiSectors.forEach((sector) {
      if (availableSectors.contains(sector.name.toLowerCase())) {
        updatedList.add(sector);
      }
    });

    return updatedList;
  }

  Future<List<String>> getAvailableSectors() async {
    List<String> availableSectors = [];

    Response response = await GyaanKarmayogiApiService().getAvailableSectors();
    var data = jsonDecode(response.body);

    List facets = data["result"]["facets"];
    facets.forEach(
      (e) {
        if (e["name"] == "sectorDetails_v1.sectorName") {
          e["values"].forEach((element) {
            availableSectors.add(element["name"]);
          });
        }
      },
    );
    availableSectors.sort();
    return availableSectors;
  }

  Future<List<dynamic>> getAllowedCategories() async {
    Response response = await GyaanKarmayogiApiService().getGyaanConfig();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> categories = data["allowedCategories"] ?? [];
      return categories;
    } else {
      return [];
    }
  }

  static Future<List<GyaanKarmayogiResource>> getGyaanKarmaYogiResources(
      {List<String>? sectorsFilter,
      String? searchQuery,
      List<String>? subSectorFilter,
      List<String>? createdFor,
      List<String>? contextSDGs,
      List<String>? contextStateOrUTs,
      List<String>? contextYear,
      List<String>? resourceCategoryFilter}) async {
    List<GyaanKarmayogiResource> gyaanKarmayogiResource = [];
    List<String> availableSectors =
        await GyaanKarmayogiServicesV2().getAvailableSectors();

    Response response = await GyaanKarmayogiApiService()
        .getGyaanKarmaYogiResources(
            contextSDGs: contextSDGs,
            contextStateOrUTs: contextStateOrUTs,
            contextYear: contextYear,
            sectors: sectorsFilter != null && sectorsFilter.isNotEmpty
                ? sectorsFilter
                : availableSectors,
            contentType: createdFor == null ? ['Resource', 'Course'] : null,
            subSector: subSectorFilter,
            createdFor:
                createdFor ?? [AppConfiguration().amritGyaanOrgId ?? ''],
            resourceCategory: resourceCategoryFilter);

    if (response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      List resources = contents["result"]["content"];

      for (var resource in resources) {
        gyaanKarmayogiResource.add(GyaanKarmayogiResource.fromJson(resource));
      }
    } else {
      debugPrint("#######################---error");
    }
    return gyaanKarmayogiResource;
  }

  List<FilterModel> sectors = [];
  List<FilterModel> subSectors = [];
  List<FilterModel> categories = [];
  List<FilterModel> contextStateOrUTs = [];
  List<FilterModel> contextYear = [];
  List<FilterModel> contextSDGs = [];

  Future<List<FilterModel>> fetchFilters() async {
    List<dynamic> allowedCategories =
        await GyaanKarmayogiServicesV2().getAllowedCategories();
    try {
      Response response = await GyaanKarmayogiApiService()
          .getGyaanKarmayogiData(contentType: ['Resource', 'Course']);
      dynamic content = response.body;
      Map<String, dynamic> data = jsonDecode(content);
      List facets = data["result"]["facets"];

      for (var e in facets) {
        if (e["name"] == "sectorDetails_v1.sectorName") {
          sectors = e["values"]
              .map<FilterModel>(
                  (element) => FilterModel(title: element["name"]))
              .toList();
        } else if (e["name"] == "sectorDetails_v1.subSectorName") {
          subSectors = e["values"]
              .map<FilterModel>(
                  (element) => FilterModel(title: element["name"]))
              .toList();
        } else if (e["name"] == "resourceCategory") {
          categories = e["values"]
              .map<FilterModel>(
                  (element) => FilterModel(title: element["name"]))
              .toList();
        } else if (e["name"] == "contextYear") {
          contextYear = e["values"]
              .map<FilterModel>(
                  (element) => FilterModel(title: element["name"]))
              .toList();
        } else if (e["name"] == "contextStateOrUTs") {
          contextStateOrUTs = e["values"]
              .map<FilterModel>(
                  (element) => FilterModel(title: element["name"]))
              .toList();
        } else if (e["name"] == "contextSDGs") {
          contextSDGs = e["values"]
              .map<FilterModel>(
                  (element) => FilterModel(title: element["name"]))
              .toList();
        }
      }
      categories.retainWhere((item) => allowedCategories.contains(item.title));
      contextSDGs.sort((a, b) => a.title.compareTo(b.title));
      contextStateOrUTs.sort((a, b) => a.title.compareTo(b.title));
      sectors.sort((a, b) => a.title.compareTo(b.title));
      subSectors.sort((a, b) => a.title.compareTo(b.title));
      categories.sort((a, b) => a.title.compareTo(b.title));

      notifyListeners();
      return [];
    } catch (e) {
      print("Error fetching filters: $e");
      return [];
    }
  }

  static Future<ResourceDetails?> getResourceDetails({
    required String id,
  }) async {
    try {
      ResourceDetails resourceDetails;
      Response res =
          await GyaanKarmayogiApiService().getResourceDetails(id: id);
      var courseDetails = jsonDecode(utf8.decode(res.bodyBytes));

      resourceDetails =
          ResourceDetails.fromJson(courseDetails['result']['content']);
      return resourceDetails;
    } catch (e) {
      debugPrint("Error fetching resource details: $e");
      return null;
    }
  }

  Future<List<String>> getCreatedForData() async {
    _createdFor = [];
    Response response =
        await GyaanKarmayogiApiService().getGyaanKarmayogiData();

    var data = jsonDecode(response.body);

    List facets = data["result"]["facets"];
    facets.forEach(
      (e) {
        if (e["name"] == "createdFor") {
          e["values"].forEach((element) {
            _createdFor.add(element["name"]);
          });
        }
      },
    );
    _createdFor
        .removeWhere((item) => item == AppConfiguration().amritGyaanOrgId);
    notifyListeners();
    return _createdFor;
  }

  getAmritGyaanConfig() async {
    var responseData = await LearnRepository().getMicroSiteFormData(
        orgId: '*', type: 'page', subtype: 'amrit-gyaan-kosh');
    amritGyaanConfig = responseData['data'];
    notifyListeners();
  }
}
