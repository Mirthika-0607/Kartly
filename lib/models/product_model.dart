import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Product {
  String? productId;
  String? productName;
  String? productDescription;
  String? productPrice;
  String? productCategory;
  String? productImage;
  double? productRating;
  Product({
    this.productId,
    this.productName,
    this.productDescription,
    this.productPrice,
    this.productCategory,
    this.productImage,
    this.productRating,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}