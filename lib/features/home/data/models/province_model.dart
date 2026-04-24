import '../../domain/entities/province_entity.dart';

/// Data model: extends entity, adds JSON parsing
class ProvinceModel extends ProvinceEntity {
  const ProvinceModel({required super.id, required super.name});

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    return ProvinceModel(
      id:   (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
    );
  }
}
