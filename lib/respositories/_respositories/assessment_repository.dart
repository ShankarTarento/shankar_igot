import 'dart:convert';

import 'package:http/http.dart';
import 'package:karmayogi_mobile/services/_services/assessment_service.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/_models/guest_data_model.dart';

import '../../models/_models/assessment_info_model.dart';

class AssessmentRepository {
  AssessmentService assessmentService = AssessmentService();
  final LearnService learnService = LearnService();

  // Advanced assessment read
  Future<AssessmentInfo?> getStandaloneAssessmentInfo(String id,
      {required String parentContextId}) async {
    try {
      final res = await assessmentService.getStandaloneAssessmentInfo(id,
          parentContextId: parentContextId);
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        final info = contents['result']['questionSet'];
        return AssessmentInfo.fromJson(info);
      } else {
        var contents = jsonDecode(res.body);
        return AssessmentInfo(
            errMessage: contents['params']['errmsg'],
            questions: [],
            primaryCategory: '',
            assessmentType: '',
            showMarks: 'No');
      }
    } catch (e) {
      return AssessmentInfo(
          errMessage: e.toString(),
          questions: [],
          primaryCategory: '',
          assessmentType: '',
          showMarks: 'No');
    }
  }

  // Advanced assessment retake info
  Future<dynamic> getRetakeStandaloneAssessmentInfo(String assessmentId) async {
    try {
      Response res = await assessmentService
          .getRetakeStandaloneAssessmentInfo(assessmentId);
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        return contents['result'];
      } else {
        return res.statusCode;
      }
    } catch (e) {
      return null;
    }
  }

// Advanced assessment question list
  Future<dynamic> getStandaloneAssessmentQuestions(
      String id, List<dynamic> questionIds) async {
    try {
      final response = await assessmentService.getStandaloneAssessmentQuestions(
          id, questionIds);
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents['result']['questions'];
      } else {
        throw 'Unable to get assessment questions.';
      }
    } catch (_) {
      return _;
    }
  }

  // Basic assessment read
  Future<AssessmentInfo?> getAssessmentInfo(String id,
      {required String parentContextId}) async {
    try {
      Response res = await assessmentService.getAssessmentInfo(id,
          parentContextId: parentContextId);

      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        final info = contents['result']['questionSet'];
        if (info != null) {
          return AssessmentInfo.fromJson(info);
        }
        return null;
      } else {
        var contents = jsonDecode(res.body);
        return AssessmentInfo(
            errMessage: contents['params']['errmsg'],
            questions: [],
            primaryCategory: '',
            assessmentType: '',
            showMarks: 'No');
      }
    } catch (e) {
      return AssessmentInfo(
          errMessage: e.toString(),
          questions: [],
          primaryCategory: '',
          assessmentType: '',
          showMarks: 'No');
    }
  }

  // Basic assessment retake info
  Future<dynamic> getRetakeAssessmentInfo(String assessmentId) async {
    try {
      Response res =
          await assessmentService.getRetakeAssessmentInfo(assessmentId);
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        return contents['result'];
      } else {
        return null;
      }
    } catch (e) {
      return e;
    }
  }

// Basic assessment question list
  Future<dynamic> getAssessmentQuestions(
      String id, List<dynamic> questionIds) async {
    try {
      final response =
          await assessmentService.getAssessmentQuestions(id, questionIds);

      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents['result']['questions'];
      } else {
        throw 'Unable to get assessment questions.';
      }
    } catch (_) {
      return _;
    }
  }

  // Assessment read for assessment with artifact URL
  Future<dynamic> getAssessmentData(
    String fileUrl,
  ) async {
    Response res = await assessmentService.getAssessmentData(fileUrl);
    if (res.statusCode == 200) {
      var data = utf8.decode(res.bodyBytes);
      var contents = jsonDecode(data);
      return contents;
    } else {
      throw 'Unable to assessment data.';
    }
  }

  // public assessment info
  Future<dynamic> getPublicAssessmentInfo(
      {
        required String assessmentId,
        required String parentContextId,
        GuestDataModel? guestUserData
      }) async {
    try {
      Response res = await assessmentService.getPublicAssessmentInfo(
          assessmentId : assessmentId,
          contextId: parentContextId,
          guestUserData: guestUserData);
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        return contents['result'];
      } else {
        return res.statusCode;
      }
    } catch (e) {
      return null;
    }
  }

  // public assessment question list
  Future<dynamic> getPublicAssessmentQuestions(
      String id, String contextId, List<dynamic> questionIds, GuestDataModel? guestUserData) async {
    try {
      final response = await assessmentService.getPublicAssessmentQuestions(id, contextId, questionIds, guestUserData);
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents['result']['questions'];
      } else {
        throw 'Unable to get assessment questions.';
      }
    } catch (_) {
      return _;
    }
  }

  // pre enroll assessment read
  Future<AssessmentInfo?> getPreEnrollAssessmentInfo(String id, bool isFeatured) async {
    try {
      var response = await learnService.getCourseDetails(id, isFeatured: isFeatured);
      if (response != null) {
        return AssessmentInfo.fromJson(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
