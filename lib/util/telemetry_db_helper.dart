import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';
import './../constants/index.dart';
import './../services/_services/telemetry_service.dart';

class TelemetryDbHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, AppDatabase.name),
        onCreate: (db, version) async {
      final String table = AppDatabase.telemetryEventsTable;
      final String feedbackTable = AppDatabase.feedbackTable;
      await db.execute(
          'CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT, telemetry_data TEXT)');
      return await db.execute(
          'CREATE TABLE $feedbackTable (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT, user_rating REAL)');
    }, version: 1);
  }

  static Future<void> insertEvent(Map<String, dynamic> data,
      {bool isPublic = false}) async {
    bool forceTrigger = false;
    Database db = await TelemetryDbHelper.database();
    if (data['telemetry_data']['eid'] == 'END') {
      forceTrigger = true;
    }
    data['telemetry_data'] = jsonEncode(data['telemetry_data']);
    db.insert(
      AppDatabase.telemetryEventsTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await triggerEvents(data['user_id'] ?? "",
        isPublic: isPublic, forceTrigger: forceTrigger);
  }

  static Future<List<Map<String, dynamic>>> getEvents(String userId) async {
    Database db = await TelemetryDbHelper.database();
    List<dynamic> whereArgs = [
      userId.isNotEmpty ? userId : EnglishLang.anonymousUser
    ];
    List<Map<String, dynamic>> result = await db.query(
        AppDatabase.telemetryEventsTable,
        where: 'user_id = ?',
        whereArgs: whereArgs);
    // result.forEach((row) => print(row));
    return result;
  }

  static Future<void> deleteEvents(String userId) async {
    Database db = await TelemetryDbHelper.database();
    List<dynamic> whereArgs = [userId];
    await db.delete(AppDatabase.telemetryEventsTable,
        where: 'user_id = ?', whereArgs: whereArgs);
  }

  static Future<List<Map<String, dynamic>>> triggerEvents(String userId,
      {bool forceTrigger = false, bool isPublic = false}) async {
    List<Map<String, dynamic>> result = await getEvents(userId);
    List allEventsData = [];
    bool showGetStarted = await FlutterSecureStorage()
        .read(key: Storage.getStarted)
        .then((value) {
      return value != GetStarted.finished || value == 'null';
    });
    if (!showGetStarted) {
      String? showRatingPlatform =
          await FlutterSecureStorage().read(key: Storage.showRatingPlatform);
      if (showRatingPlatform == NPS.enable) {
        String? count =
            await FlutterSecureStorage().read(key: Storage.enableRating);
        await FlutterSecureStorage().write(
            key: Storage.enableRating,
            value: ((int.parse(count ?? '0') + 1).toString()));
      }
    }
    // print('length: ' + result.length.toString());
    if (result.length > 9 || forceTrigger) {
      await deleteEvents(userId);
      result.forEach(
          (row) => allEventsData.add(jsonDecode(row['telemetry_data'])));
      final TelemetryService telemetryService = TelemetryService();
      telemetryService.triggerEvent(allEventsData, isPublic: isPublic);
    }
    return result;
  }
}
