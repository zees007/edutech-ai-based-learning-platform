class SubscriptionTierModel {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String roleId;
  final String? roleName;
  final double priceMonthly;
  final double priceAnnual;
  final String currency;
  final int? monthlySessionLimit;
  final int? followUpLimitPerStep;
  final int? youtubeLimitPerStep;
  final double streakMultiplier;
  final bool isPublic;
  final int orderIndex;
  final bool retired;
  final int activeSubscribersCount;
  final DateTime? createdAt;

  const SubscriptionTierModel({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    required this.roleId,
    this.roleName,
    this.priceMonthly = 0.0,
    this.priceAnnual = 0.0,
    this.currency = 'USD',
    this.monthlySessionLimit,
    this.followUpLimitPerStep,
    this.youtubeLimitPerStep,
    this.streakMultiplier = 1.0,
    this.isPublic = true,
    this.orderIndex = 0,
    this.retired = false,
    this.activeSubscribersCount = 0,
    this.createdAt,
  });

  bool get isUnlimitedSessions => monthlySessionLimit == null;
  bool get isUnlimitedFollowUps => followUpLimitPerStep == null;
  bool get isUnlimitedYoutube => youtubeLimitPerStep == null;

  factory SubscriptionTierModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionTierModel(
      id: json['id'] as String? ?? '',
      slug: (json['slug'] as String? ?? '').toLowerCase().trim(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      roleId: json['role_id'] as String? ?? '',
      roleName: json['role_name'] as String?,
      priceMonthly: (json['price_monthly'] as num?)?.toDouble() ?? 0.0,
      priceAnnual: (json['price_annual'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      monthlySessionLimit: (json['monthly_session_limit'] as num?)?.toInt(),
      followUpLimitPerStep: (json['follow_up_limit_per_step'] as num?)?.toInt(),
      youtubeLimitPerStep: (json['youtube_limit_per_step'] as num?)?.toInt(),
      streakMultiplier: (json['streak_multiplier'] as num?)?.toDouble() ?? 1.0,
      isPublic: json['is_public'] as bool? ?? true,
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      retired: json['retired'] as bool? ?? false,
      activeSubscribersCount: (json['active_subscribers_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'description': description,
      'role_id': roleId,
      'role_name': roleName,
      'price_monthly': priceMonthly,
      'price_annual': priceAnnual,
      'currency': currency,
      'monthly_session_limit': monthlySessionLimit,
      'follow_up_limit_per_step': followUpLimitPerStep,
      'youtube_limit_per_step': youtubeLimitPerStep,
      'streak_multiplier': streakMultiplier,
      'is_public': isPublic,
      'order_index': orderIndex,
      'retired': retired,
      'active_subscribers_count': activeSubscribersCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  SubscriptionTierModel copyWith({
    String? id,
    String? slug,
    String? name,
    String? description,
    String? roleId,
    String? roleName,
    double? priceMonthly,
    double? priceAnnual,
    String? currency,
    int? monthlySessionLimit,
    int? followUpLimitPerStep,
    int? youtubeLimitPerStep,
    double? streakMultiplier,
    bool? isPublic,
    int? orderIndex,
    bool? retired,
    int? activeSubscribersCount,
    DateTime? createdAt,
  }) {
    return SubscriptionTierModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      description: description ?? this.description,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      priceMonthly: priceMonthly ?? this.priceMonthly,
      priceAnnual: priceAnnual ?? this.priceAnnual,
      currency: currency ?? this.currency,
      monthlySessionLimit: monthlySessionLimit ?? this.monthlySessionLimit,
      followUpLimitPerStep: followUpLimitPerStep ?? this.followUpLimitPerStep,
      youtubeLimitPerStep: youtubeLimitPerStep ?? this.youtubeLimitPerStep,
      streakMultiplier: streakMultiplier ?? this.streakMultiplier,
      isPublic: isPublic ?? this.isPublic,
      orderIndex: orderIndex ?? this.orderIndex,
      retired: retired ?? this.retired,
      activeSubscribersCount: activeSubscribersCount ?? this.activeSubscribersCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

