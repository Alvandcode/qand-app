class Product {
  final String id;
  final String title;
  final String category; // کیک خونگی | کوکی | بیسکوییت | کیک تولد
  final String description;
  final String ingredients;
  final int price; // تومان
  final String unit;
  final String asset; // مسیر عکس لوکال
  final String? imageUrl; // عکس از سوپابیس

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.ingredients,
    required this.price,
    required this.unit,
    required this.asset,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: '${m['id']}',
        title: '${m['title'] ?? ''}',
        category: '${m['category'] ?? ''}',
        description: '${m['description'] ?? ''}',
        ingredients: '${m['ingredients'] ?? ''}',
        price: (m['price'] is int) ? m['price'] as int : int.tryParse('${m['price'] ?? 0}') ?? 0,
        unit: '${m['unit'] ?? 'عدد'}',
        asset: 'assets/images/placeholder.png',
        imageUrl: m['image_url'] as String?,
      );
}
