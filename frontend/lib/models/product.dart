import 'package:lance_certo/models/user.dart';

class Product {
  Product({
    required this.name,
    required this.description,
    required this.category,
    this.seller,
    this.productId,
    this.imageUrl,
  });

  final int? productId;
  final String name;
  final String description;
  final String? imageUrl;
  final String category;
  final User? seller;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      seller: json['seller'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'category': category,
  };
}
