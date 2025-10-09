import 'package:igot_ui_components/models/microsite_competency_item_data_model.dart';

class MicroSitesCompetencyStrengthDataModel {
  String? detaulTitle;
  String? myTitle;
  String? description;
  String? background;

  MicroSitesCompetencyStrengthDataModel({
    this.detaulTitle,
    this.myTitle,
    this.description,
    this.background,
  });

  MicroSitesCompetencyStrengthDataModel.fromJson(Map<String, dynamic> json) {
    detaulTitle = json['detaulTitle'];
    myTitle = json['myTitle'];
    description = json['description'];
    background = json['background'];
  }
}

class MicroSitesCompetencyDataModel {
  List<MicroSiteCompetencyItemDataModel>? competency;

  MicroSitesCompetencyDataModel({this.competency});

  MicroSitesCompetencyDataModel.fromJson(Map json,
      {bool useCompetencyv6 = false}) {
    if (useCompetencyv6) {
      if (json['content'] != null) {
        competency = <MicroSiteCompetencyItemDataModel>[];
        json['content'].forEach((v) {
          competency!.add(MicroSiteCompetencyItemDataModel.fromJson(
            v,
            useCompetencyv6: useCompetencyv6,
          ));
        });
      }
    } else {
      if (json['competency'] != null) {
        competency = <MicroSiteCompetencyItemDataModel>[];
        json['competency'].forEach((v) {
          competency!.add(MicroSiteCompetencyItemDataModel.fromJson(
            v,
            useCompetencyv6: useCompetencyv6,
          ));
        });
      }
    }
  }
}

class MicroSiteAllCompetencies {
  String? name;
  int? count;
  List<MicroSiteCompetencyItemDataModel>? competency;

  MicroSiteAllCompetencies({
    this.name,
    this.count,
    this.competency,
  });

  MicroSiteAllCompetencies.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    count = json['count'];
    if (json['facets'] != null) {
      competency = <MicroSiteCompetencyItemDataModel>[];
      json['competency'].forEach((v) {
        competency!.add(MicroSiteCompetencyItemDataModel.fromJson(v));
      });
    }
  }
}

class MicroSiteCompetenciesModel {
  List<CompetencyFacets>? facets;
  int? count;

  MicroSiteCompetenciesModel({
    this.facets,
    this.count,
  });

  MicroSiteCompetenciesModel.fromJson(Map<String, dynamic> json) {
    if (json['facets'] != null) {
      facets = <CompetencyFacets>[];
      json['facets'].forEach((v) {
        facets!.add(CompetencyFacets.fromJson(v));
      });
    }
    count = json['count'];
  }
}

class CompetencyFacets {
  List<CompetencyValue>? values;
  String? name;

  CompetencyFacets({
    this.values,
    this.name,
  });

  CompetencyFacets.fromJson(Map<String, dynamic> json) {
    if (json['values'] != null) {
      values = <CompetencyValue>[];
      json['values'].forEach((v) {
        values!.add(CompetencyValue.fromJson(v));
      });
    }
    name = json['name'];
  }
}

class CompetencyValue {
  String? name;
  int? count;

  CompetencyValue({
    this.name,
    this.count,
  });

  CompetencyValue.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    count = json['count'];
  }
}
