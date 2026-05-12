import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';

class LatencyState extends StateNotifier<Map<String, int?>> {
  LatencyState() : super({});
  void updateLatencies(Map<String, int?> newLatencies) {
    state = {...state, ...newLatencies};
  }

  void clear() {
    state = {};
  }
}

final latencyProvider = StateNotifierProvider<LatencyState, Map<String, int?>>((
  ref,
) {
  return LatencyState();
});
