// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  productId: json['productId'] as String?,
  productName: json['productName'] as String?,
  productDescription: json['productDescription'] as String?,
  productPrice: json['productPrice'] as String?,
  productCategory: json['productCategory'] as String?,
  productImage: json['productImage'] as String?,
  productRating: (json['productRating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'productId': instance.productId,
  'productName': instance.productName,
  'productDescription': instance.productDescription,
  'productPrice': instance.productPrice,
  'productCategory': instance.productCategory,
  'productImage': instance.productImage,
  'productRating': instance.productRating,
};