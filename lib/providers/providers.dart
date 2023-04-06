import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'app_controller.dart';
export 'app_state.dart';
export 'settings_controller.dart';
export 'settings_state.dart';
export 'files_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
  name: 'SharedPreferencesProvider',
);

class PageIndex extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setPageIndex(int index) {
    state = index;
  }
}

final pageIndexProvider = NotifierProvider<PageIndex, int>(PageIndex.new);
