import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/learning/session_quota.dart';
import 'learning_provider.dart';

class SessionQuotaState {
  final SessionQuota? quota;
  final bool isLoading;
  final String? error;

  const SessionQuotaState({
    this.quota,
    this.isLoading = false,
    this.error,
  });

  bool get isUnlimited => quota?.isUnlimited ?? false;
  int get remaining => quota?.remaining ?? 0;
  int get used => quota?.used ?? 0;
  int get limit => quota?.limit ?? 10;
  bool get isExhausted => !isUnlimited && remaining <= 0;
  bool get isLow => !isUnlimited && remaining > 0 && remaining <= 2;

  SessionQuotaState copyWith({
    SessionQuota? quota,
    bool clearQuota = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SessionQuotaState(
      quota: clearQuota ? null : (quota ?? this.quota),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SessionQuotaNotifier extends Notifier<SessionQuotaState> {
  @override
  SessionQuotaState build() {
    return const SessionQuotaState();
  }

  Future<void> fetchQuota() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(learningServiceProvider);
      final quota = await service.fetchSessionQuota();
      state = state.copyWith(
        quota: quota,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshQuota() => fetchQuota();

  void reset() {
    state = const SessionQuotaState();
  }
}

final sessionQuotaProvider =
    NotifierProvider<SessionQuotaNotifier, SessionQuotaState>(() {
  return SessionQuotaNotifier();
});

