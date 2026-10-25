class SystemSettingModel {
  final int id;
  final String code;
  final String value;
  final int orderNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SystemSettingModel({
    required this.id,
    required this.code,
    required this.value,
    this.orderNumber = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory SystemSettingModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      value: json['value'] as String? ?? '',
      orderNumber: json['order_number'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'value': value,
      'order_number': orderNumber,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SystemSettingModel copyWith({
    int? id,
    String? code,
    String? value,
    int? orderNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SystemSettingModel(
      id: id ?? this.id,
      code: code ?? this.code,
      value: value ?? this.value,
      orderNumber: orderNumber ?? this.orderNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemSettingModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          code == other.code &&
          value == other.value &&
          orderNumber == other.orderNumber;

  @override
  int get hashCode =>
      id.hashCode ^ code.hashCode ^ value.hashCode ^ orderNumber.hashCode;
}
