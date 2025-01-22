import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/product_model.dart';
import 'base_product_repos.dart';

class ProductRepos extends BaseProductRepository {
  final FirebaseFirestore _firebaseFirestore;

  ProductRepos({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Product>> getAllProducts() {
    return _firebaseFirestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromSnapShot(doc);
      }).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firebaseFirestore.collection('products').add({
        'name': product.productName,
        'imageUrl': product.productImageUrl,
        'price': product.currentPrice,
        'productSize': product.productSize,
        'category': product.categoryName,
        'oldprice': product.oldPrice,
      });
      print('Product added successfully.');
    } catch (e) {
      print('Error adding product: $e');
      throw Exception('Failed to add product.');
    }
  }
}
