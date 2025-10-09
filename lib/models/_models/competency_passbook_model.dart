class CompetencyPassbook {
  String? courseId;
  String? competencyTheme;
  String? competencySubThemeId;
  String? competencyArea;
  String? competencyThemeType;
  String? competencySubThemeDescription;
  String? competencyAreaId;
  String? competencySubTheme;
  String? competencyThemeId;
  String? competencyThemeDescription;
  String? competencyAreaDescription;

  CompetencyPassbook({
    this.courseId,
    this.competencyTheme,
    this.competencySubThemeId,
    this.competencyArea,
    this.competencyThemeType,
    this.competencySubThemeDescription,
    this.competencyAreaId,
    this.competencySubTheme,
    this.competencyThemeId,
    this.competencyThemeDescription,
    this.competencyAreaDescription,
  });

  factory CompetencyPassbook.fromJson(
      {required Map<String, dynamic> json,
      required courseId,
      bool useCompetencyv6 = false}) {
    return useCompetencyv6
        ? CompetencyPassbook(
            courseId: courseId,
            competencyTheme: json["competencyThemeName"],
            competencySubThemeId: json["competencySubThemeIdentifier"],
            competencyArea: json["competencyAreaName"],
            competencyThemeType: json["competencyThemeType"],
            competencySubThemeDescription:
                json["competencySubThemeDescription"],
            competencyAreaId: json["competencyAreaIdentifier"],
            competencySubTheme: json["competencySubThemeName"],
            competencyThemeId: json["competencyThemeIdentifier"],
            competencyThemeDescription: json["competencyThemeDescription"],
            competencyAreaDescription: json["competencyAreaDescription"],
          )
        : CompetencyPassbook(
            courseId: courseId,
            competencyTheme: json["competencyTheme"],
            competencySubThemeId: json["competencySubThemeId"].toString(),
            competencyArea: json["competencyArea"],
            competencyThemeType: json["competencyThemeType"],
            competencySubThemeDescription:
                json["competencySubThemeDescription"],
            competencyAreaId: json["competencyAreaId"].toString(),
            competencySubTheme: json["competencySubTheme"],
            competencyThemeId: json["competencyThemeId"].toString(),
            competencyThemeDescription: json["competencyThemeDescription"],
            competencyAreaDescription: json["competencyAreaDescription"],
          );
  }
}
