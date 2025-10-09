import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([ProfileRepository, LearnRepository, http.Client])
void main() {}
