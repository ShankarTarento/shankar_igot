import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../../constants/index.dart';
import '../../../../../localization/index.dart';
import '../../../../../models/_models/event_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/composite_search_model.dart';

class SortBy {
  static const String createdOn = 'createdOn';
  static const String avgRating = 'avgRating';
  static const String mostRelevant = 'mostRelevant';
  static const String createdDate = 'createdDate';
  static const String aToZ = 'A-Z';
  static const String zToA = 'Z-A';
}

class SearchFilterFacet {
  static const String language = 'language';
  static const String avgRating = 'avgRating';
  static const String competencyAreaName = 'competencies_v6.competencyAreaName';
  static const String competencyThemeName =
      'competencies_v6.competencyThemeName';
  static const String competencySubThemeName =
      'competencies_v6.competencySubThemeName';
  static const String competencyArea = 'competencyArea';
  static const String competencyTheme = 'competencyTheme';
  static const String competencySubTheme = 'competencySubTheme';
  static const String courseCategory = 'courseCategory';
  static const String provider = 'sourceName';
  static const String resourceType = 'resourceType';
  static const String designation =
      'profileDetails.professionalDetails.designation';
  static const String organization = 'rootOrgName';
  static const String eventTypes = 'Types';
  static const String extContentPartner = 'contentPartner.contentPartnerName';
  static const String topicName = 'topicName';
  static const String sectorName = 'sectorName';
  static const String organisation = 'organisation';
  static const String orgName = 'orgName';
  static const String startDateTime = 'startDateTimeInEpoch';
  static const String endDateTime = 'endDateTimeInEpoch';
  static const String sector = 'sectorDetails_v1.sectorName';
  static const String subSector = 'sectorDetails_v1.subSectorName';
  static const String resourceCategory = 'resourceCategory';
  static const String years = 'years';
  static const String contextStateOrUTs = 'contextStateOrUTs';
  static const String contextSDGs = 'contextSDGs';
  static const String externalContentTopic = 'topic';
}

class SearchConstants {
  static const int minSearchLength = 100;
  static const int minSearchCharacter = 3;
  static const String liveEvents = 'Live Events';
  static const String upcoming = 'Upcoming';
  static const String pastEvents = 'Past Events';
  static const int courseFreshnessLimit = 15;
  Map<String, dynamic> get fetchDefaultSearchConfig {
    return {
      'minSearchLengthResult': 3,
      'minLengthAutoSearch': 100,
      'pills': [
        {
          'id': 'content',
          'label': 'Content',
          'hiLabel': 'सामग्री',
          'priority': 0
        },
        {'id': 'events', 'label': 'Events', 'hiLabel': 'आयोजन', 'priority': 1},
        {'id': 'people', 'label': 'People', 'hiLabel': 'लोग', 'priority': 2},
        {
          'id': 'externalContent',
          'label': 'External Content',
          'hiLabel': 'बाहरी सामग्री',
          'priority': 3
        },
        {
          'id': 'Communities',
          'label': 'Communities',
          'hiLabel': 'समुदाय',
          'priority': 4
        },
        {
          'id': 'resources',
          'label': 'Resources',
          'hiLabel': 'संसाधन',
          'priority': 5
        },
        {'id': 'all', 'label': 'All', 'hiLabel': 'सभी', 'priority': 6}
      ]
    };
  }
}

class SearchCategories {
  static const String content = 'content';
  static const String events = 'events';
  static const String people = 'people';
  static const String externalContent = 'externalContent';
  static const String communities = 'Communities';
  static const String resources = 'resources';
  static const String all = 'all';
}

class RecentSearchCategory {
  static const String course = 'courses';
  static const String events = 'events';
  static const String people = 'peoples';
  static const String externalContent = 'externalContent';
  static const String community = 'Community';
  static const String resource = 'resource';
  static const String all = 'all';
}

class SearchHelper {
  static String getEventStatus({required Event event}) {
    try {
      int timestampNow = DateTime.now().millisecondsSinceEpoch;

      // Combining date and time for start event
      String start = event.startDate + ' ' + formatTime(event.startTime);
      DateTime startDate = DateTime.parse(start);
      int timestampStartEvent = startDate.microsecondsSinceEpoch;
      double eventStartTime = timestampStartEvent / 1000;

      // Combining date and time for end event
      String expiry = event.endDate + ' ' + formatTime(event.endTime);
      DateTime expireDate = DateTime.parse(expiry);
      int timestampExpireEvent = expireDate.microsecondsSinceEpoch;
      double eventExpireTime = timestampExpireEvent / 1000;

      // Checking event status
      if (timestampNow > eventExpireTime) {
        return EnglishLang.completed;
      } else if (timestampNow <= eventExpireTime &&
          timestampNow >= eventStartTime) {
        return EnglishLang.started;
      } else {
        return EnglishLang.notStarted;
      }
    } catch (e) {
      print("Error in getEventStatus: $e");
      return "Error in processing event status";
    }
  }

  static formatTime(time) {
    return time.substring(0, 5);
  }

  static String getFacetName(String name, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final facetMap = <String, String>{
      SearchFilterFacet.language: localizations.mSearchLanguages,
      SearchFilterFacet.avgRating: localizations.mSearchRating,
      SearchFilterFacet.competencyAreaName: localizations.mStaticCompetencyArea,
      SearchFilterFacet.competencyThemeName: localizations.mCompetencyTheme,
      SearchFilterFacet.competencySubThemeName:
          localizations.mCompetencySubTheme,
      SearchFilterFacet.competencyArea: localizations.mStaticCompetencyArea,
      SearchFilterFacet.competencyTheme: localizations.mCompetencyTheme,
      SearchFilterFacet.competencySubTheme: localizations.mCompetencySubTheme,
      SearchFilterFacet.courseCategory: localizations.mStaticCategory,
      SearchFilterFacet.provider: localizations.mStaticProviders,
      SearchFilterFacet.resourceType: localizations.mStaticCategory,
      SearchFilterFacet.designation: localizations.mStaticDesignation,
      SearchFilterFacet.organization: localizations.mStaticOrganisation,
      SearchFilterFacet.eventTypes: localizations.mSearchTypeOfEvent,
      SearchFilterFacet.extContentPartner: localizations.mSearchContentPartner,
      SearchFilterFacet.topicName: localizations.mLearnCourseTopics,
      SearchFilterFacet.sectorName: localizations.mStaticSector,
      SearchFilterFacet.sector: localizations.mStaticSector,
      SearchFilterFacet.subSector: localizations.mSearchSubsector,
      SearchFilterFacet.organisation: localizations.mStaticProviders,
      SearchFilterFacet.orgName: localizations.mStaticProviders,
      SearchFilterFacet.resourceCategory: localizations.mStaticCategories,
      SearchFilterFacet.years: localizations.mSearchYears,
      SearchFilterFacet.contextStateOrUTs: localizations.mStatesAndUts,
      SearchFilterFacet.contextSDGs: localizations.mSustainableDevelopmentGoals,
      SearchFilterFacet.externalContentTopic: localizations.mSearchTopic,
    };

    return facetMap[name] ?? '';
  }

  static DateTime mergeDateAndTime({
    required DateTime date,
    required String time,
  }) {
    DateTime formattedTime = time.isNotEmpty
        ? (time.contains("+") || time.contains("-"))
            ? DateFormat("hh:mm:ss").parse(time)
            : DateFormat.Hm().parse(time)
        : DateTime(date.year, 0, 0, 0, 0, 0);

    DateTime convertedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      formattedTime.hour,
      formattedTime.minute,
      formattedTime.second,
    );
    return convertedDateTime;
  }

  List<Facet> facetUpdate(
      {required List<Facet> newFacet, required List<Facet> initialFacet}) {
    if (initialFacet.isNotEmpty) {
      newFacet.forEach((facet) {
        Facet? matchedFacet = initialFacet.cast<Facet?>().firstWhere(
            (item) => item != null && item.name == facet.name,
            orElse: () => null);
        if (matchedFacet != null) {
          if (matchedFacet.name == SearchFilterFacet.eventTypes) {
            Value? selectedType = matchedFacet.values.cast<Value?>().firstWhere(
                (val) => val != null && val.isChecked,
                orElse: () => null);
            if (selectedType != null) {
              for (Value value in facet.values) {
                if (value.name == selectedType.name) {
                  value.isChecked = selectedType.isChecked;
                  facet.count = value.count;
                  break;
                }
              }
            }
          } else {
            matchedFacet.values.forEach((val) {
              if (val.isChecked) {
                for (Value newFacetVal in facet.values) {
                  if (val.name == newFacetVal.name) {
                    newFacetVal.isChecked = val.isChecked;
                    facet.count = facet.count + newFacetVal.count;
                  }
                }
              }
            });
          }
        }
      });
    }
    return newFacet;
  }

  static bool hasFilterChanged(
      {Map<String, dynamic>? oldFilter, Map<String, dynamic>? newFilter}) {
    return !DeepCollectionEquality().equals(oldFilter, newFilter);
  }

  static bool hasSortByChanged(
      {Map<String, dynamic>? oldSortBy, Map<String, dynamic>? newSortBy}) {
    return !MapEquality().equals(oldSortBy, newSortBy);
  }

  void showOverlayMessage(String message, BuildContext parentContext,
      {int duration = 4, Color bgColor = AppColors.darkBlue}) {
    OverlayState? overlayState = Overlay.of(parentContext);
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
        builder: (context) => Builder(builder: (innerContext) {
              final bottomInset = MediaQuery.of(innerContext).viewInsets.bottom;
              final bottomPadding = bottomInset > 0 ? bottomInset + 20 : 50.0;

              return Positioned(
                bottom: bottomPadding,
                left: 20,
                right: 20,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(8),
                  color: bgColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Text(
                      message,
                      style: TextStyle(color: AppColors.appBarBackground),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }));

    // Add the overlay to the overlay state
    overlayState.insert(overlayEntry);

    // Remove the overlay after 2 seconds
    Future.delayed(Duration(seconds: duration), () {
      overlayEntry?.remove();
    });
  }
}
