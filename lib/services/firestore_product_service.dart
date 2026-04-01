import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_product.dart';

class FirestoreProductService {
  final FirebaseFirestore _db;

  FirestoreProductService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<List<FirestoreProduct>> getProductsForProfile({
    required String? skinType,
    required String? concern,
    List<String> conditionIds = const [],
    int limit = 8,
  }) async {
    final tags = <String>{};
    if (skinType != null && skinType.isNotEmpty) tags.add(skinType);
    if (concern != null && concern.isNotEmpty) tags.add(concern);
    tags.addAll(conditionIds);

    Query<Map<String, dynamic>> query = _db.collection('products');

    if (tags.isNotEmpty) {
      query = query.where('searchTags', arrayContainsAny: tags.take(10).toList());
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => FirestoreProduct.fromJson(doc.id, doc.data()))
        .where((p) => p.affiliateUrl.isNotEmpty)
        .toList();
  }
}
