class SessionQuota {
  final String tier;
  final bool isUnlimited;
  final int used;
  final int? limit;
  final int? remaining;

  const SessionQuota({
    required this.tier,
    required this.isUnlimited,
    required this.used,
    this.limit,
    this.remaining,
  });

  factory SessionQuota.fromJson(Map<String, dynamic> json) {
    return SessionQuota(
      tier: json['tier'] as String? ?? 'free',
      isUnlimited: json['is_unlimited'] as bool? ?? false,
      used: (json['used'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt(),
      remaining: (json['remaining'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tier': tier,
    'is_unlimited': isUnlimited,
    'used': used,
    'limit': limit,
    'remaining': remaining,
  };

  SessionQuota copyWith({
    String? tier,
    bool? isUnlimited,
    int? used,
    int? limit,
    int? remaining,
  }) {
    return SessionQuota(
      tier: tier ?? this.tier,
      isUnlimited: isUnlimited ?? this.isUnlimited,
      used: used ?? this.used,
      limit: limit ?? this.limit,
      remaining: remaining ?? this.remaining,
    );
  }
}

