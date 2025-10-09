
class MicroSitesContributorsDataModel {
  String? detaulTitle;
  String? defaultTitle1;
  String? myTitle;
  String? myTitle1;
  String? description;
  String? background;
  late List<Contributors> contributors;

  MicroSitesContributorsDataModel(
      { this.detaulTitle,
        this.defaultTitle1,
        this.myTitle,
        this.myTitle1,
        this.description,
        this.background,
        required this.contributors,
      });

  MicroSitesContributorsDataModel.fromJson(Map<String, dynamic> json) {
    detaulTitle = json['detaulTitle'];
    defaultTitle1 = json['defaultTitle1'];
    myTitle = json['myTitle'];
    myTitle1 = json['myTitle1'];
    description = json['description'];
    background = json['background'];
      contributors = <Contributors>[];
    if (json['contributors'] != null) {
      json['contributors'].forEach((v) {
        contributors.add(Contributors.fromJson(v));
      });
    }
  }
}

class Contributors {
  String? name;
  String? image;
  String? description;

  Contributors({
    this.name,
    this.image,
    this.description,
  });

  Contributors.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    description = json['description'];
  }
}