import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/reporter.dart';

abstract class LoggedCubit<State> extends Cubit<State> {
  LoggedCubit(super.initialState);

  @override
  void onChange(Change<State> change) {
    AppLogReporter.talker.debug('Cubit $runtimeType changed');
    super.onChange(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    AppLogReporter.talker.error('Cubit Error: $runtimeType', error, stackTrace);
    super.onError(error, stackTrace);
  }
}
