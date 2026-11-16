class SessionQuota {
  final String tier;
  final bool isUnlimited;
  final int used;
  final int? limit;
  final int? remaining;
  final int? followUpLimit;
  final int? youtubeLimit;

  const SessionQuota({
    required this.tier,
    required this.isUnlimited,
    required this.used,
    this.limit,
    this.remaining,
    this.followUpLimit,
    this.youtubeLimit,
  });

  factory SessionQuota.fromJson(Map<String, dynamic> json) {
    return SessionQuota(
      tier: json['tier'] as String? ?? 'free',
      isUnlimited: json['is_unlimited'] as bool? ?? false,
      used: (json['used'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt(),
      remaining: (json['remaining'] as num?)?.toInt(),
      followUpLimit: (json['follow_up_limit'] as num?)?.toInt(),
      youtubeLimit: (json['youtube_limit'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tier': tier,
    'is_unlimited': isUnlimited,
    'used': used,
    'limit': limit,
    'remaining': remaining,
    'follow_up_limit': followUpLimit,
    'youtube_limit': youtubeLimit,
  };

  SessionQuota copyWith({
    String? tier,
    bool? isUnlimited,
    int? used,
    int? limit,
    int? remaining,
    int? followUpLimit,
    int? youtubeLimit,
  }) {
    return SessionQuota(
      tier: tier ?? this.tier,
      isUnlimited: isUnlimited ?? this.isUnlimited,
      used: used ?? this.used,
      limit: limit ?? this.limit,
      remaining: remaining ?? this.remaining,
      followUpLimit: followUpLimit ?? this.followUpLimit,
      youtubeLimit: youtubeLimit ?? this.youtubeLimit,
    );
  }
}

