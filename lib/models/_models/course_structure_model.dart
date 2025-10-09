class CourseStructure {
  final Map<String, dynamic> contentRead;
  final Map<String, dynamic> courseHierarchyInfo;

  CourseStructure(Map<String, dynamic>? contentRead,
      Map<String, dynamic>? courseHierarchyInfo)
      : contentRead = contentRead ?? {},
        courseHierarchyInfo = courseHierarchyInfo ?? {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseStructure &&
          runtimeType == other.runtimeType &&
          contentRead == other.contentRead &&
          courseHierarchyInfo == other.courseHierarchyInfo;

  @override
  int get hashCode => contentRead.hashCode ^ courseHierarchyInfo.hashCode;
}
