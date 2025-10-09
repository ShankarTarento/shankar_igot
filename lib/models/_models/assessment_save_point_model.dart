// To parse this JSON data, do
//
//     final savePointModel = savePointModelFromJson(jsonString);

import 'dart:convert';

SavePointModel savePointModelFromJson(String str) => SavePointModel.fromJson(json.decode(str));

String savePointModelToJson(SavePointModel data) => json.encode(data.toJson());

class SavePointModel {
    List<Result> result;

    SavePointModel({
        required this.result,
    });

    factory SavePointModel.fromJson(Map<String, dynamic> json) => SavePointModel(
        result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
    };
}

class Result {
    String sectionId;
    String type;
    String sectionTime;
    List<Child> children;

    Result({
        required this.sectionId,
        required this.type,
        required this.sectionTime,
        required this.children,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        sectionId: json["sectionId"],
        type: json["type"],
        sectionTime: json["sectionTime"],
        children: List<Child>.from(json["children"].map((x) => Child.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "sectionId": sectionId,
        "type": type,
        "sectionTime": sectionTime,
        "children": List<dynamic>.from(children.map((x) => x.toJson())),
    };
}

class Child {
    String questionId;
    EditorState editorState;

    Child({
        required this.questionId,
        required this.editorState,
    });

    factory Child.fromJson(Map<String, dynamic> json) => Child(
        questionId: json["questionId"],
        editorState: EditorState.fromJson(json["editorState"]),
    );

    Map<String, dynamic> toJson() => {
        "questionId": questionId,
        "editorState": editorState.toJson(),
    };
}

class EditorState {
    List<Option> options;

    EditorState({
        required this.options,
    });

    factory EditorState.fromJson(Map<String, dynamic> json) => EditorState(
        options: List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
    };
}

class Option {
    String selectedOptionIndex;
    bool selectedAnswer;
    String timeSpent;

    Option({
        required this.selectedOptionIndex,
        required this.selectedAnswer,
        required this.timeSpent,
    });

    factory Option.fromJson(Map<String, dynamic> json) => Option(
        selectedOptionIndex: json["selectedOptionIndex"],
        selectedAnswer: json["selectedAnswer"],
        timeSpent: json["timeSpent"],
    );

    Map<String, dynamic> toJson() => {
        "selectedOptionIndex": selectedOptionIndex,
        "selectedAnswer": selectedAnswer,
        "timeSpent": timeSpent,
    };
}
