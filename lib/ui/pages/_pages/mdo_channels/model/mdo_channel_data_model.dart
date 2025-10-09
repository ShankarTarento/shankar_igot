
class MdoChannelDataModel {
  String? rootOrgId;
  String? imgUrl;
  String? channel;

  MdoChannelDataModel(
      {
        this.rootOrgId,
        this.imgUrl,
        this.channel,
      });

  MdoChannelDataModel.fromJson(Map<String, dynamic> json) {
    rootOrgId = json['rootOrgId'];
    imgUrl = json['imgUrl'];
    channel = json['channel'];
  }
}
