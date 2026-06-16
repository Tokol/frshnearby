import 'package:flutter_riverpod/flutter_riverpod.dart';

final followedFarmsProvider =
    StateNotifierProvider<FollowedFarmsController, Set<String>>(
  (ref) => FollowedFarmsController(),
);

class FollowedFarmsController extends StateNotifier<Set<String>> {
  FollowedFarmsController() : super(const {'farmer-1'});

  void toggle(String farmerId) {
    state = state.contains(farmerId)
        ? ({...state}..remove(farmerId))
        : {...state, farmerId};
  }
}
