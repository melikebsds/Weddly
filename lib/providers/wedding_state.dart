import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../models/invitation.dart';
import '../models/wedding_space.dart';
import '../models/wedding_task.dart';
import '../services/category_api_service.dart';
import '../services/invitation_api_service.dart';
import '../services/secure_storage_service.dart';
import '../services/task_api_service.dart';
import '../services/wedding_space_api_service.dart';

/// Faz 5: Artık mock/local veri değil, gerçek backend API'si kullanılıyor.
/// Aktif WeddingSpace, kategoriler ve görevler burada tutulur.
class WeddingState extends ChangeNotifier {
  WeddingState({
    required WeddingSpaceApiService weddingSpaceApi,
    required CategoryApiService categoryApi,
    required TaskApiService taskApi,
    required InvitationApiService invitationApi,
    required SecureStorageService storage,
  })  : _weddingSpaceApi = weddingSpaceApi,
        _categoryApi = categoryApi,
        _taskApi = taskApi,
        _invitationApi = invitationApi,
        _storage = storage;

  final WeddingSpaceApiService _weddingSpaceApi;
  final CategoryApiService _categoryApi;
  final TaskApiService _taskApi;
  final InvitationApiService _invitationApi;
  final SecureStorageService _storage;

  WeddingSpace? activeSpace;
  List<WeddingCategory> categories = [];
  final Map<String, List<WeddingTask>> tasksByCategory = {};

  bool isLoading = false;

  bool get hasActiveSpace => activeSpace != null;

  List<WeddingTask> tasksForCategory(String categoryId) => tasksByCategory[categoryId] ?? [];

  /// Uygulama açılışında daha önce seçilmiş bir hazırlık alanı var mı diye bakar.
  Future<void> restoreActiveSpace() async {
    final storedId = await _storage.readActiveWeddingSpaceId();
    if (storedId == null) return;

    try {
      final space = await _weddingSpaceApi.getById(storedId);
      await _activateSpace(space);
    } catch (_) {
      // Alan artık erişilemiyor olabilir (silinmiş/üyelik kalkmış); onboarding'e düşülür.
    }
  }

  Future<WeddingSpace> createSpace({required String name, DateTime? weddingDate}) async {
    final space = await _weddingSpaceApi.create(name: name, weddingDate: weddingDate);
    await _activateSpace(space);
    return space;
  }

  Future<WeddingSpace> joinSpaceWithCode(String invitationCode) async {
    final result = await _invitationApi.join(invitationCode);
    final space = await _weddingSpaceApi.getById(result.weddingSpaceId);
    await _activateSpace(space);
    return space;
  }

  /// Kullanıcının zaten üyesi olduğu bir alanı (örn. onboarding'de bulunan
  /// ilk alan) aktif hâle getirir.
  Future<void> restoreOrActivate(WeddingSpace space) => _activateSpace(space);

  Future<void> _activateSpace(WeddingSpace space) async {
    activeSpace = space;
    await _storage.saveActiveWeddingSpaceId(space.id);
    await reloadAll();
  }

  Future<void> reloadAll() async {
    if (activeSpace == null) return;

    isLoading = true;
    notifyListeners();

    categories = await _categoryApi.getForSpace(activeSpace!.id);

    final results = await Future.wait(categories.map((c) => _taskApi.getForCategory(c.id)));
    tasksByCategory.clear();
    for (var i = 0; i < categories.length; i++) {
      tasksByCategory[categories[i].id] = results[i];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> setWeddingDate(DateTime? date) async {
    final space = activeSpace;
    if (space == null) return;

    final updated = await _weddingSpaceApi.update(space.id, name: space.name, weddingDate: date);
    activeSpace = updated;
    notifyListeners();
  }

  Future<void> renameActiveSpace(String name) async {
    final space = activeSpace;
    if (space == null) return;

    final updated = await _weddingSpaceApi.update(space.id, name: name, weddingDate: space.weddingDate);
    activeSpace = updated;
    notifyListeners();
  }

  Future<Invitation> createInvitation() async {
    final space = activeSpace;
    if (space == null) {
      throw StateError('Aktif hazırlık alanı yok');
    }
    return _invitationApi.create(space.id);
  }

  int totalTaskCount() => categories.fold(0, (sum, c) => sum + c.totalTaskCount);

  int completedTaskCount() => categories.fold(0, (sum, c) => sum + c.completedTaskCount);

  double completionRatio() {
    final total = totalTaskCount();
    if (total == 0) return 0;
    return completedTaskCount() / total;
  }

  double estimatedTotal() => _budgetRelevantTasks().fold(0, (sum, t) => sum + (t.estimatedPrice ?? 0));

  double actualTotal() => _budgetRelevantTasks().fold(0, (sum, t) => sum + (t.actualPrice ?? 0));

  int? daysUntilWedding() {
    final weddingDate = activeSpace?.weddingDate;
    if (weddingDate == null) return null;
    final now = DateTime.now();
    return weddingDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  Future<void> addTask(
    String categoryId, {
    required String title,
    String? subCategory,
    String? description,
    double? estimatedPrice,
    double? actualPrice,
    ResponsibleParty responsibleParty = ResponsibleParty.unspecified,
    String? productUrl,
    DateTime? dueDate,
    WeddingTaskStatus status = WeddingTaskStatus.toBuy,
  }) async {
    final task = await _taskApi.create(
      categoryId,
      title: title,
      subCategory: subCategory,
      description: description,
      estimatedPrice: estimatedPrice,
      actualPrice: actualPrice,
      responsibleParty: responsibleParty,
      productUrl: productUrl,
      dueDate: dueDate,
      status: status,
    );
    tasksByCategory[categoryId] = [...tasksForCategory(categoryId), task];
    await _refreshCategoryCounts();
    notifyListeners();
  }

  Future<void> updateTask(
    WeddingTask task, {
    required String title,
    String? subCategory,
    String? description,
    double? estimatedPrice,
    double? actualPrice,
    required ResponsibleParty responsibleParty,
    String? productUrl,
    DateTime? dueDate,
    required WeddingTaskStatus status,
  }) async {
    final updated = await _taskApi.update(
      task.id,
      title: title,
      subCategory: subCategory,
      description: description,
      estimatedPrice: estimatedPrice,
      actualPrice: actualPrice,
      responsibleParty: responsibleParty,
      productUrl: productUrl,
      dueDate: dueDate,
      status: status,
    );
    _replaceTask(updated);
    await _refreshCategoryCounts();
    notifyListeners();
  }

  Future<void> deleteTask(WeddingTask task) async {
    await _taskApi.delete(task.id);
    tasksByCategory[task.categoryId] =
        tasksForCategory(task.categoryId).where((t) => t.id != task.id).toList();
    await _refreshCategoryCounts();
    notifyListeners();
  }

  Future<void> setTaskStatus(WeddingTask task, WeddingTaskStatus status) async {
    final updated = await _taskApi.setStatus(task.id, status);
    _replaceTask(updated);
    await _refreshCategoryCounts();
    notifyListeners();
  }

  void _replaceTask(WeddingTask task) {
    final list = tasksForCategory(task.categoryId);
    final index = list.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    final updatedList = List<WeddingTask>.of(list);
    updatedList[index] = task;
    tasksByCategory[task.categoryId] = updatedList;
  }

  Future<void> _refreshCategoryCounts() async {
    if (activeSpace == null) return;
    categories = await _categoryApi.getForSpace(activeSpace!.id);
  }

  /// İhtiyaç Yok işaretlenen görevler bütçe hesaplamalarından tamamen hariç tutulur.
  List<WeddingTask> _budgetRelevantTasks() => tasksByCategory.values
      .expand((tasks) => tasks)
      .where((t) => t.status != WeddingTaskStatus.notNeeded)
      .toList();

  /// Vadesi olan ve henüz ödenmemiş (Alınacak) görevleri tarihe göre sıralı döner.
  List<WeddingTask> upcomingPayments() {
    final tasks = _budgetRelevantTasks()
        .where((t) => t.dueDate != null && t.status == WeddingTaskStatus.toBuy)
        .toList();
    tasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    return tasks;
  }

  /// Bu ay vadesi gelen ödenmemiş görevlerin tahmini tutar toplamı.
  double upcomingPaymentsTotalThisMonth() {
    final now = DateTime.now();
    return upcomingPayments()
        .where((t) => t.dueDate!.year == now.year && t.dueDate!.month == now.month)
        .fold(0, (sum, t) => sum + (t.estimatedPrice ?? 0));
  }
}
