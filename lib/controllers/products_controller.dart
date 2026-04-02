import 'package:get/get.dart';
import '../models/crm_models.dart';
import '../Services/crm_service.dart';

class ProductsController extends GetxController {
  final CrmService _crmService = Get.find<CrmService>();

  var allProducts = <ProductModel>[].obs;
  var products = <ProductModel>[].obs;
  var isLoading = false.obs;

  // Collection filter
  var selectedCollection = 'All'.obs;
  var collections = <String>['All'].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final fetchedProducts = await _crmService.getProducts();
      allProducts.assignAll(fetchedProducts);

      // Build unique collection list from products
      final collectionSet = <String>{'All'};
      for (final p in fetchedProducts) {
        if (p.collection != null && p.collection!.title.isNotEmpty) {
          collectionSet.add(p.collection!.title);
        }
      }
      collections.assignAll(collectionSet.toList());

      _applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setCollection(String collection) {
    selectedCollection.value = collection;
    _applyFilters();
  }

  void filterProducts(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = allProducts.toList();

    // Collection filter
    if (selectedCollection.value != 'All') {
      filtered = filtered.where((p) =>
        p.collection?.title == selectedCollection.value
      ).toList();
    }

    // Search filter
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.productName.toLowerCase().contains(q) ||
        p.productCode.toLowerCase().contains(q)
      ).toList();
    }

    products.assignAll(filtered);
  }
}
