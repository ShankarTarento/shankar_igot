

class AppUpdateModel {
  final OptionalUpdate? optionalUpdate;
  final MandatoryUpdate? mandatoryUpdate;

  AppUpdateModel({
    this.optionalUpdate,
    this.mandatoryUpdate,
  });

  factory AppUpdateModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateModel(
      optionalUpdate: json['optionalUpdate'] != null
          ? OptionalUpdate.fromJson(json['optionalUpdate'])
          : null,
      mandatoryUpdate: json['mandatoryUpdate'] != null
          ? MandatoryUpdate.fromJson(json['mandatoryUpdate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'optionalUpdate': optionalUpdate?.toJson(),
      'mandatoryUpdate': mandatoryUpdate?.toJson(),
    };
  }
}

class OptionalUpdate {
  final bool? enabled;
  final bool? enableCloseButton;
  final bool? enableUpdateButton;
  final String? updateMessage;
  final String? buttonText;

  OptionalUpdate({
    this.enabled,
    this.enableCloseButton,
    this.enableUpdateButton,
    this.updateMessage,
    this.buttonText,
  });

  factory OptionalUpdate.fromJson(Map<String, dynamic> json) {
    return OptionalUpdate(
      enabled: json['enabled'] ?? false,
      enableCloseButton: json['enableCloseButton'] ?? false,
      enableUpdateButton: json['enableUpdateButton'] ?? false,
      updateMessage: json['updateMessage'] ?? '',
      buttonText: json['buttonText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'enableCloseButton': enableCloseButton,
      'enableUpdateButton': enableUpdateButton,
      'updateMessage': updateMessage,
      'buttonText': buttonText,
    };
  }
}

class MandatoryUpdate {
  final bool? enabled;
  final bool? enableIgnore;
  final String? mandatoryIosVersion;
  final String? mandatoryAndroidVersion;
  final String? title;
  final String? buttonText;

  MandatoryUpdate({
    this.enabled,
    this.enableIgnore,
    this.mandatoryIosVersion,
    this.mandatoryAndroidVersion,
    this.title,
    this.buttonText,
  });

  factory MandatoryUpdate.fromJson(Map<String, dynamic> json) {
    return MandatoryUpdate(
      enabled: json['enabled'] ?? false,
      enableIgnore: json['enableIgnore'] ?? false,
      mandatoryIosVersion: json['mandatoryIosVersion'] ?? '',
      mandatoryAndroidVersion: json['mandatoryAndroidVersion'] ?? '',
      title: json['title'] ?? '',
      buttonText: json['buttonText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'enableIgnore': enableIgnore,
      'mandatoryIosVersion': mandatoryIosVersion,
      'mandatoryAndroidVersion': mandatoryAndroidVersion,
      'title': title,
      'buttonText': buttonText,
    };
  }
}

