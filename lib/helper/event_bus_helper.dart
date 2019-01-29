
import 'package:meta/meta.dart';

enum HDTaskEventType {
  refresh,
  query,
  scrollHeader,
  showFloatTopBtn,
}

class HDTaskEvent {
  final HDTaskEventType type;
  final value;

  HDTaskEvent({
    @required this.type,
    this.value,
  });
}