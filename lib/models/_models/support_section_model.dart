class SupportSectionModel {
  String? title;
  String? thumbnail;
  String? text;
  String? date;
  String? time;
  String? button;
  String? joinLink;
  String? technicalSupport;
  String? plsContact;

  SupportSectionModel({
    this.title,
    this.thumbnail,
    this.text,
    this.date,
    this.time,
    this.button,
    this.joinLink,
    this.technicalSupport,
    this.plsContact,
  });

  factory SupportSectionModel.fromMap(Map<String, dynamic> map) {
    return SupportSectionModel(
      title: map['title'],
      thumbnail: map['thumbnail'],
      text: map['text'],
      date: map['date'],
      time: map['time'],
      button: map['button'],
      joinLink: map['joinLink'],
      technicalSupport: map['technicalSupport'],
      plsContact: map['plsContact'],
    );
  }
}
