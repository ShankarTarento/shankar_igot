import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class HomeTelemetryService {
  static void generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  String generateTelemetryId(String input) {
    RegExp regExp = RegExp(r'([a-z])([A-Z])');

    String result = input.replaceAllMapped(regExp, (Match match) {
      return '${match.group(1)}-${match.group(2)!.toLowerCase()}';
    });

    return result.toLowerCase();
  }
}
