import 'package:flutter/widgets.dart';
import '../../models/index.dart';
import '../../services/index.dart';

class CategoryRepository with ChangeNotifier {
  List<Category> _categoryList = [];

  /// Process list of categories
  Future<List<Category>> getListOfCategories() async {
    try {
      final categoryListInfo = await CategoryService.getCategoryList();

      _categoryList = [
        for (final item in categoryListInfo['categories'])
          Category.fromJson(item)
      ];
    } catch (_) {
      throw _;
    }

    return _categoryList;
  }
}
