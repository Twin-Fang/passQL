// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_store_verify_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppStoreVerifyRequestImpl _$$AppStoreVerifyRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AppStoreVerifyRequestImpl(
  productId: json['productId'] as String,
  signedTransaction: json['signedTransaction'] as String,
);

Map<String, dynamic> _$$AppStoreVerifyRequestImplToJson(
  _$AppStoreVerifyRequestImpl instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'signedTransaction': instance.signedTransaction,
};
