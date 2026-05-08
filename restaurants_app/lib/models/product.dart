class Product {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final int? restaurantId;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.restaurantId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      restaurantId: json['restaurant_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'restaurant_id': restaurantId,
    };
  }
}
