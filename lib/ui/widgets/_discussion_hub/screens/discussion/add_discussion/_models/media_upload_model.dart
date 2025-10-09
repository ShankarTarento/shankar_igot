import 'dart:io';

class MediaUploadModel {
  File? file;
  bool isUploaded;
  bool isErrorFile;
  String? fileUrl;
  String? fileName;

  MediaUploadModel(
      {this.file,
      required this.isUploaded,
      required this.isErrorFile,
      this.fileUrl,
      this.fileName});
}
