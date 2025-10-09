
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/microsites_top_section_data_model.dart';

class MicroSitesInfraDetailsDataModel {
  String? detaulTitle;
  String? myTitle;
  String? description;
  List<Metrics>? metrics;
  SliderData? sliderData;

  MicroSitesInfraDetailsDataModel(
      { this.detaulTitle,
        this.myTitle,
        this.description,
        this.metrics,
        this.sliderData,
      });

  MicroSitesInfraDetailsDataModel.fromJson(Map<String, dynamic> json) {
    detaulTitle = json['detaulTitle'];
    myTitle = json['myTitle'];
    description = json['description'];
    if (json['metrics'] != null) {
      metrics = <Metrics>[];
      json['metrics'].forEach((v) {
        metrics!.add(Metrics.fromJson(v));
      });
    }
    sliderData = SliderData.fromJson(json["sliderData"]);
  }
}

class Metrics {
  String? value;
  String? label;

  Metrics({
    this.value,
    this.label,
  });

  Metrics.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }
}
