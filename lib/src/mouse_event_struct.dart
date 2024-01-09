import 'dart:ui';

class MouseEvent {
  late MouseEventMsg mouseMsg;
  late int mouseData;
  late int flags;
  late int time;
  late int dwExtraInfo;
  late int x;
  late int y;

  MouseEvent(List<int> list) {
    mouseMsg = toKeyEventMsg(list[0]);
    mouseData = list[1];
    flags = list[2];
    time = list[3];
    dwExtraInfo = list[4];
    x = list[5];
    y = list[6];
  }

  Offset getOffset(){
    return Offset(x.toDouble(), y.toDouble());
  }


  @override
  String toString() {
    return 'KeyEvent:${mouseMsg.name}(${x}x$y)';
  }
}

String toBinary(int num, [int len = 8]) {
  StringBuffer buf = StringBuffer();
  if (len < 0) throw ArgumentError('len() should >=0');
  while (--len >= 0) {
    buf.write((num & (0x1 << len)) > 0 ? '1' : '0');
  }
  return buf.toString();
}


enum MouseEventMsg {
  WM_CAPTURECHANGED,
  WM_LBUTTONDBLCLK,
  WM_LBUTTONDOWN,
  WM_LBUTTONUP,
  WM_MBUTTONDBLCLK,
  WM_MBUTTONDOWN,
  WM_MBUTTONUP,
  WM_MOUSEACTIVATE,
  WM_MOUSEHOVER,
  WM_MOUSEHWHEEL,
  WM_MOUSELEAVE,
  WM_MOUSEMOVE,
  WM_MOUSEWHEEL,
  WM_NCHITTEST,
  WM_NCLBUTTONDBLCLK,
  WM_NCLBUTTONDOWN,
  WM_NCLBUTTONUP,
  WM_NCMBUTTONDBLCLK,
  WM_NCMBUTTONDOWN,
  WM_NCMBUTTONUP,
  WM_NCMOUSEHOVER,
  WM_NCMOUSELEAVE,
  WM_NCMOUSEMOVE,
  WM_NCRBUTTONDBLCLK,
  WM_NCRBUTTONDOWN,
  WM_NCRBUTTONUP,
  WM_NCXBUTTONDBLCLK,
  WM_NCXBUTTONDOWN,
  WM_NCXBUTTONUP,
  WM_RBUTTONDBLCLK,
  WM_RBUTTONDOWN,
  WM_RBUTTONUP,
  WM_XBUTTONDBLCLK,
  WM_XBUTTONDOWN,
  WM_XBUTTONUP,
  WM_UNKNOWN
}

MouseEventMsg toKeyEventMsg(int v) {
  MouseEventMsg mouseMsg;
  switch (v) {
    case 0:
      mouseMsg = MouseEventMsg.WM_MOUSEMOVE;
      break;
    case 10:
      mouseMsg = MouseEventMsg.WM_LBUTTONDOWN;
      break;
    case 11:
      mouseMsg = MouseEventMsg.WM_LBUTTONUP;
      break;
    case 20:
      mouseMsg = MouseEventMsg.WM_MBUTTONDOWN;
      break;
    case 21:
      mouseMsg = MouseEventMsg.WM_MBUTTONUP;
      break;
    case 30:
      mouseMsg = MouseEventMsg.WM_RBUTTONDOWN;
      break;
    case 31:
      mouseMsg = MouseEventMsg.WM_RBUTTONUP;
      break;
    case 41:
      mouseMsg = MouseEventMsg.WM_MOUSEWHEEL;
      break;
    case 50:
      mouseMsg = MouseEventMsg.WM_XBUTTONDOWN;
      break;
    case 51:
      mouseMsg = MouseEventMsg.WM_XBUTTONUP;
      break;
    default:
      mouseMsg = MouseEventMsg.WM_UNKNOWN;
      break;
  }
  return mouseMsg;
}
