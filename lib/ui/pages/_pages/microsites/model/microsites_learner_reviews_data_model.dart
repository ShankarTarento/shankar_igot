class MicroSitesLearnerDataModel {
  String? detaulTitle;
  String? myTitle;
  String? description;

  MicroSitesLearnerDataModel({
    this.detaulTitle,
    this.myTitle,
    this.description,
  });

  MicroSitesLearnerDataModel.fromJson(Map<String, dynamic> json) {
    detaulTitle = json['detaulTitle'];
    myTitle = json['myTitle'];
    description = json['description'];
  }
}

class MicroSitesLearnerReviewsDataModel {
  List<Content>? content;

  MicroSitesLearnerReviewsDataModel({this.content});

  MicroSitesLearnerReviewsDataModel.fromJson(Map<String, dynamic> json) {
    if (json['content'] != null) {
      content = <Content>[];
      json['content'].forEach((v) {
        content!.add(Content.fromJson(v));
      });
    }
  }
}

class Content {
  final String? review;
  final double? rating;
  final UserDetails? userDetails;
  final ContentInfo? contentInfo;

  Content({
    this.review,
    this.rating,
    this.userDetails,
    this.contentInfo,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      review: json['review'],
      rating: json['rating'],
      userDetails: (json['userDetails'] != null)
          ? UserDetails.fromJson(json['userDetails'])
          : UserDetails(),
      contentInfo: (json['contentInfo'] != null)
          ? ContentInfo.fromJson(json['contentInfo'])
          : ContentInfo(),
    );
  }
}

class UserDetails {
  final String? firstName;
  final String? userId;
  final String? profileImageUrl;

  UserDetails({
    this.firstName,
    this.userId,
    this.profileImageUrl,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      firstName: json['firstName'] ?? '',
      userId: json['userId'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}

class ContentInfo {
  final String? identifier;
  final List<Competency>? competencies;
  final String? description;
  final List<String>? organisation;
  final String? creatorLogo;
  final String? posterImage;
  final String? duration;
  final List<String>? additionalTags;
  final String? appIcon;
  final String? primaryCategory;
  final String? name;
  final double? avgRating;
  final String? contentType;

  ContentInfo({
    this.identifier,
    this.competencies,
    this.description,
    this.organisation,
    this.creatorLogo,
    this.posterImage,
    this.duration,
    this.additionalTags,
    this.appIcon,
    this.primaryCategory,
    this.name,
    this.avgRating,
    this.contentType,
  });

  factory ContentInfo.fromJson(Map<String, dynamic> json) {
    return ContentInfo(
      identifier: json['identifier'],
      competencies: json['competencies_v5'] != null
          ? List<Competency>.from(
              json['competencies_v5'].map((x) => Competency.fromJson(x)))
          : null,
      description: json['description'],
      organisation: List<String>.from(json['organisation']),
      creatorLogo: json['creatorLogo'],
      posterImage: json['posterImage'],
      duration: json['duration'],
      additionalTags: json['additionalTags'] != null
          ? List<String>.from(json['additionalTags'])
          : null,
      appIcon: json['appIcon'],
      primaryCategory:
          json['courseCategory'] != null && json['courseCategory'].isNotEmpty
              ? json['courseCategory']
              : json['primaryCategory'],
      name: json['name'],
      avgRating: json['avgRating']?.toDouble(),
      contentType: json['contentType'],
    );
  }
}

class Competency {
  final String? competencyArea;
  final int? competencyAreaId;
  final String? competencyAreaDescription;
  final String? competencyTheme;
  final int? competencyThemeId;
  final String? competecnyThemeDescription;
  final String? competencyThemeType;
  final String? competencySubTheme;
  final int? competencySubThemeId;
  final String? competecnySubThemeDescription;

  Competency({
    this.competencyArea,
    this.competencyAreaId,
    this.competencyAreaDescription,
    this.competencyTheme,
    this.competencyThemeId,
    this.competecnyThemeDescription,
    this.competencyThemeType,
    this.competencySubTheme,
    this.competencySubThemeId,
    this.competecnySubThemeDescription,
  });

  factory Competency.fromJson(Map<String, dynamic> json) {
    return Competency(
      competencyArea: json['competencyArea'],
      competencyAreaId: json['competencyAreaId'],
      competencyAreaDescription: json['competencyAreaDescription'],
      competencyTheme: json['competencyTheme'],
      competencyThemeId: json['competencyThemeId'],
      competecnyThemeDescription: json['competecnyThemeDescription'],
      competencyThemeType: json['competencyThemeType'],
      competencySubTheme: json['competencySubTheme'],
      competencySubThemeId: json['competencySubThemeId'],
      competecnySubThemeDescription: json['competecnySubThemeDescription'],
    );
  }
}
