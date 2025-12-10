/// Firestore에 저장될 아이템 모델.
class Item {
  final String id;
  final String name;
  final int quantity;
  final DateTime timestamp;

  Item({
    required this.id,
    required this.name,
    required this.quantity,
    required this.timestamp,
  });

  /// Firestore 문서를 앱 모델로 변환.
  factory Item.fromFirestore(Map<String, dynamic> firestore, String id) {
    final timestamp = firestore['timestamp'] != null
        ? firestore['timestamp'].toDate()
        : DateTime.now();

    return Item(
      id: id,
      name: firestore['name'] as String,
      quantity: firestore['quantity'] as int,
      timestamp: timestamp,
    );
  }

  /// 앱 모델을 Firestore 문서 형태로 변환.
  Map<String, dynamic> toFirestore() {
    return {'name': name, 'quantity': quantity, 'timestamp': timestamp};
  }
}
