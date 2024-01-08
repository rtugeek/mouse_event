import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:logger/logger.dart';
import 'mouse_event_struct.dart';

typedef Listener = void Function(MouseEvent mouseEvent);
typedef CancelListening = void Function();

Logger log = Logger();

class MouseEventPlugin {
  static const MethodChannel _channel = MethodChannel('mouse_event');
  static const EventChannel _eventChannel = EventChannel('mouse_event/event');

  MouseEventPlugin();

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static int nextListenerId = 1;
  static CancelListening? _cancelListening;

  static Future<void> startListening(Listener listener) async {
    final subscription =
        _eventChannel.receiveBroadcastStream(nextListenerId++).listen(//listener
            (dynamic msg) {
      final list = List<int>.from(msg);
      final mouseEvent = MouseEvent(list);
        listener(mouseEvent);
    }, cancelOnError: true);
    debugPrint('mouse_event/event startListening');
    _cancelListening = () {
      subscription.cancel();
      debugPrint('mouse_event/event canceled');
    };
  }

  static Future<void> cancelListening() async {
    if (_cancelListening != null) {
      _cancelListening!();
      _cancelListening = null;
    } else {
      debugPrint('mouse_event/event No Need');
    }
  }
}
