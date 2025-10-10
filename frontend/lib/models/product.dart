import 'package:lance_certo/models/user.dart';

class Product {
  Product({
    required this.name,
    required this.description,
    required this.category,
    this.seller,
    this.id,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  String name;
  String description;
  String? imageUrl;
  String category;
  final User? seller;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      seller: json['seller'] != null
          ? User.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'category': category,
  };
}
