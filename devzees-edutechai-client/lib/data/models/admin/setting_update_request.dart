class SettingUpdateRequest {
  final String value;
  final int? orderNumber;

  const SettingUpdateRequest({
    required this.value,
    this.orderNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      if (orderNumber != null) 'order_number': orderNumber,
    };
  }

  factory SettingUpdateRequest.fromJson(Map<String, dynamic> json) {
    return SettingUpdateRequest(
      value: json['value'] as String? ?? '',
      orderNumber: json['order_number'] as int?,
    );
  }
}
