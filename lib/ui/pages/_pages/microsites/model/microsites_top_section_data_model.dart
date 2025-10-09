import 'package:igot_ui_components/models/microsites_banner_slider_data_model.dart';

class MicroSitesTopSectionDataModel {
  String? logo;
  String? title;
  String? description;
  String? subtitle;
  String? subtitle2;
  SliderData? sliderData;
  String? mobileLogo;
  late List<ReferenceLinks> referenceLinks;

  MicroSitesTopSectionDataModel(
      {this.logo,
      this.title,
      this.description,
      this.sliderData,
      this.subtitle,
      this.subtitle2,
      this.mobileLogo,
      required this.referenceLinks});

  MicroSitesTopSectionDataModel.fromJson(Map<String, dynamic> json) {
    logo = json['logo'];
    title = json['title'];
    description = json['description'];
    subtitle = json['subTitle'];
    subtitle2 = json['subTitleTwo'];
    sliderData = SliderData.fromJson(json['sliderData']);
    mobileLogo = json['logoMobile'];
    referenceLinks = <ReferenceLinks>[];
    if (json['referenceLinks'] != null) {
      json['referenceLinks'].forEach((v) {
        referenceLinks.add(ReferenceLinks.fromJson(v));
      });
    }
  }
}

class SliderData {
  late List<MicroSiteBannerSliderDataModel> sliders;

  SliderData({
    required this.sliders,
  });

  SliderData.fromJson(Map<String, dynamic> json) {
    sliders = <MicroSiteBannerSliderDataModel>[];
    if (json['sliders'] != null) {
      json['sliders'].forEach((v) {
        sliders.add(MicroSiteBannerSliderDataModel.fromJson(v));
      });
    }
  }
}

class ReferenceLinks {
  late String label;
  late String value;

  ReferenceLinks({
    required this.label,
    required this.value,
  });

  ReferenceLinks.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }
}
