library;

/// Models for Subscriptions & Payments

class CreateOrderRequest {
  final String tier;
  final String billingCycle;
  final String gatewayProvider;
  final String? couponCode;
  final String currency;

  CreateOrderRequest({
    required this.tier,
    this.billingCycle = 'monthly',
    this.gatewayProvider = 'razorpay',
    this.couponCode,
    this.currency = 'USD',
  });

  Map<String, dynamic> toJson() => {
        'tier': tier,
        'billing_cycle': billingCycle,
        'gateway_provider': gatewayProvider,
        if (couponCode != null && couponCode!.isNotEmpty) 'coupon_code': couponCode,
        'currency': currency,
      };
}

class CreateOrderResponse {
  final bool success;
  final String orderId;
  final String keyId;
  final double amount;
  final int amountSubunits;
  final String currency;
  final String tier;
  final String billingCycle;
  final String gatewayProvider;
  final String? userName;
  final String? userEmail;
  final String? userMobile;
  final String? message;

  CreateOrderResponse({
    required this.success,
    required this.orderId,
    required this.keyId,
    required this.amount,
    required this.amountSubunits,
    required this.currency,
    required this.tier,
    required this.billingCycle,
    required this.gatewayProvider,
    this.userName,
    this.userEmail,
    this.userMobile,
    this.message,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      success: json['success'] as bool? ?? false,
      orderId: json['order_id'] as String? ?? '',
      keyId: json['key_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      amountSubunits: (json['amount_subunits'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      tier: json['tier'] as String? ?? 'pro',
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      gatewayProvider: json['gateway_provider'] as String? ?? 'razorpay',
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      userMobile: json['user_mobile'] as String?,
      message: json['message'] as String?,
    );
  }
}

class CheckoutPaymentRequest {
  final String tier;
  final String billingCycle;
  final String gatewayProvider;
  final String? couponCode;
  final String currency;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  CheckoutPaymentRequest({
    required this.tier,
    this.billingCycle = 'monthly',
    this.gatewayProvider = 'razorpay',
    this.couponCode,
    this.currency = 'USD',
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
  });

  Map<String, dynamic> toJson() => {
        'tier': tier,
        'billing_cycle': billingCycle,
        'gateway_provider': gatewayProvider,
        if (couponCode != null && couponCode!.isNotEmpty) 'coupon_code': couponCode,
        'currency': currency,
        if (razorpayOrderId != null) 'razorpay_order_id': razorpayOrderId,
        if (razorpayPaymentId != null) 'razorpay_payment_id': razorpayPaymentId,
        if (razorpaySignature != null) 'razorpay_signature': razorpaySignature,
      };
}

class CheckoutPaymentResponse {
  final bool success;
  final String message;
  final String? transactionId;
  final String tier;
  final String billingCycle;
  final double amountPaid;
  final String currency;
  final String gatewayProvider;
  final DateTime? currentPeriodEnd;

  CheckoutPaymentResponse({
    required this.success,
    required this.message,
    this.transactionId,
    required this.tier,
    required this.billingCycle,
    required this.amountPaid,
    required this.currency,
    required this.gatewayProvider,
    this.currentPeriodEnd,
  });

  factory CheckoutPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutPaymentResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      transactionId: json['transaction_id'] as String?,
      tier: json['tier'] as String? ?? 'pro',
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      gatewayProvider: json['gateway_provider'] as String? ?? 'razorpay',
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.tryParse(json['current_period_end'] as String)
          : null,
    );
  }
}

class CouponValidationResult {
  final bool valid;
  final String couponCode;
  final double discountPercent;
  final double discountAmount;
  final double originalPrice;
  final double finalPrice;
  final String message;

  CouponValidationResult({
    required this.valid,
    required this.couponCode,
    required this.discountPercent,
    required this.discountAmount,
    required this.originalPrice,
    required this.finalPrice,
    required this.message,
  });

  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    return CouponValidationResult(
      valid: json['valid'] as bool? ?? false,
      couponCode: json['coupon_code'] as String? ?? '',
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['final_price'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
    );
  }
}

class PaymentTransactionModel {
  final int id;
  final String transactionId;
  final String userId;
  final String gatewayProvider;
  final double amount;
  final String currency;
  final String status;
  final String tier;
  final String billingCycle;
  final String? paymentMethod;
  final String? couponCode;
  final DateTime createdAt;

  PaymentTransactionModel({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.gatewayProvider,
    required this.amount,
    required this.currency,
    required this.status,
    required this.tier,
    required this.billingCycle,
    this.paymentMethod,
    this.couponCode,
    required this.createdAt,
  });

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'] as int? ?? 0,
      transactionId: json['transaction_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      gatewayProvider: json['gateway_provider'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'completed',
      tier: json['tier'] as String? ?? 'pro',
      billingCycle: json['billing_cycle'] as String? ?? 'monthly',
      paymentMethod: json['payment_method'] as String?,
      couponCode: json['coupon_code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class TierPricingItem {
  final double monthly;
  final double annual;

  const TierPricingItem({
    required this.monthly,
    required this.annual,
  });

  factory TierPricingItem.fromJson(Map<String, dynamic> json) {
    return TierPricingItem(
      monthly: (json['monthly'] as num?)?.toDouble() ?? 0.0,
      annual: (json['annual'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'monthly': monthly,
        'annual': annual,
      };
}

class PricingCatalogModel {
  final String currency;
  final Map<String, TierPricingItem> tiers;

  const PricingCatalogModel({
    this.currency = 'USD',
    required this.tiers,
  });

  factory PricingCatalogModel.fromJson(Map<String, dynamic> json) {
    final rawTiers = json['tiers'] as Map<String, dynamic>? ?? {};
    final parsedTiers = <String, TierPricingItem>{};
    for (final entry in rawTiers.entries) {
      if (entry.value is Map<String, dynamic>) {
        parsedTiers[entry.key.toLowerCase()] =
            TierPricingItem.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    return PricingCatalogModel(
      currency: json['currency'] as String? ?? 'USD',
      tiers: parsedTiers,
    );
  }

  static const PricingCatalogModel defaultCatalog = PricingCatalogModel(
    currency: 'USD',
    tiers: {
      'free': TierPricingItem(monthly: 0.0, annual: 0.0),
      'pro': TierPricingItem(monthly: 19.0, annual: 180.0),
      'ultra': TierPricingItem(monthly: 49.0, annual: 470.0),
    },
  );

  TierPricingItem getTier(String tier) {
    return tiers[tier.toLowerCase()] ??
        defaultCatalog.tiers[tier.toLowerCase()] ??
        const TierPricingItem(monthly: 0.0, annual: 0.0);
  }

  double getPrice(String tier, String billingCycle) {
    final t = getTier(tier);
    return billingCycle.toLowerCase() == 'annual' ? t.annual : t.monthly;
  }

  /// Calculates the dynamic annual discount percentage compared to 12 monthly payments for any tier.
  int getAnnualSavingsPercent([String tier = 'pro']) {
    final monthly = getPrice(tier, 'monthly');
    final annual = getPrice(tier, 'annual');
    if (monthly <= 0 || annual <= 0) return 0;
    final totalMonthly = monthly * 12.0;
    if (annual >= totalMonthly) return 0;
    final savings = ((totalMonthly - annual) / totalMonthly) * 100.0;
    return savings.round();
  }

  /// Returns the savings label for a specific tier (e.g. 'SAVE 21%' for Pro, 'SAVE 20%' for Ultra).
  String getAnnualSavingsLabel([String tier = 'pro']) {
    final pct = getAnnualSavingsPercent(tier);
    return pct > 0 ? 'SAVE $pct%' : 'ANNUAL';
  }

  /// Returns the discount badge for a specific tier (e.g. '21% OFF' for Pro, '20% OFF' for Ultra).
  String getAnnualDiscountBadge([String tier = 'pro']) {
    final pct = getAnnualSavingsPercent(tier);
    return pct > 0 ? '$pct% OFF' : 'ANNUAL';
  }

  /// Returns a smart badge label for the global monthly/annual toggle switch.
  /// If both Pro and Ultra offer the same discount, displays e.g. "20% OFF".
  /// If they differ, displays e.g. "UP TO 21% OFF".
  String getGlobalAnnualDiscountBadge() {
    final pro = getAnnualSavingsPercent('pro');
    final ultra = getAnnualSavingsPercent('ultra');
    if (pro <= 0 && ultra <= 0) return 'ANNUAL';
    if (pro == ultra) return '$pro% OFF';
    final maxPct = pro > ultra ? pro : ultra;
    return 'UP TO $maxPct% OFF';
  }

  /// Returns a smart savings label for the global monthly/annual toggle switch.
  /// If both Pro and Ultra offer the same discount, displays e.g. "SAVE 20%".
  /// If they differ, displays e.g. "SAVE UP TO 21%".
  String getGlobalAnnualSavingsLabel() {
    final pro = getAnnualSavingsPercent('pro');
    final ultra = getAnnualSavingsPercent('ultra');
    if (pro <= 0 && ultra <= 0) return 'ANNUAL';
    if (pro == ultra) return 'SAVE $pro%';
    final maxPct = pro > ultra ? pro : ultra;
    return 'SAVE UP TO $maxPct%';
  }
}

