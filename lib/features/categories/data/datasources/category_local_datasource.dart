import 'package:hive/hive.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDatasource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Stream<List<CategoryModel>> watchCategories();
}

class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  Box<CategoryModel> get _box => Hive.box<CategoryModel>(AppConstants.hiveCategoriesBox);

  @override
  Future<List<CategoryModel>> getAllCategories() async => _box.values.toList();

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      return _box.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  @override
  Stream<List<CategoryModel>> watchCategories() {
    // Emit current snapshot immediately, then re-emit on every box change.
    return _box
        .watch()
        .map((_) => _box.values.toList())
        .startWith(_box.values.toList());
  }
}
