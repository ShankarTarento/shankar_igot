class StateModel {
  final String stateName;
  final String stateId;

  StateModel({
    required this.stateName,
    required this.stateId,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateName: json['stateName'],
      stateId: json['stateId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stateName': stateName,
      'stateId': stateId,
    };
  }
}