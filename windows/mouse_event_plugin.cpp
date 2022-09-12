#include "include/mouse_event/mouse_event_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_message_codec.h>
#include <flutter/standard_method_codec.h>

#include <tchar.h>
#include <initializer_list>
#include <map>
#include <memory>
#include <sstream>

#include "mouse_event_plugin.h"
#include "map_serializer.h"


using namespace flutter;

HHOOK mouseHook;

namespace {
    std::unique_ptr<flutter::MethodChannel<>> channel = NULL;
    std::unique_ptr <flutter::EventChannel<>> eventChannel = NULL;
    std::unique_ptr <EventSink<EncodableValue>> eventSink = NULL;

    class MouseEventPlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        MouseEventPlugin();

        virtual ~MouseEventPlugin();

    private:
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
                const flutter::MethodCall <flutter::EncodableValue> &method_call,
                std::unique_ptr <flutter::MethodResult<flutter::EncodableValue>> result);
    };
}

inline int wp2keyMsg(WPARAM wp) {
  int mouseMsg = 0;
  switch (wp) {
    case WM_MOUSEMOVE:
      mouseMsg = 0;
      break;
    case WM_LBUTTONDOWN:
      mouseMsg = 10;
      break;
    case WM_LBUTTONUP:
      mouseMsg = 11;
      break;
    case WM_MBUTTONDOWN:
      mouseMsg = 20;
      break;
    case WM_MBUTTONUP:
      mouseMsg = 21;
      break;
    case WM_RBUTTONDOWN:
      mouseMsg = 30;
      break;
    case WM_RBUTTONUP:
      mouseMsg = 31;
      break;
    case WM_MOUSEWHEEL:
      mouseMsg = 41;
      break;
    default:
      mouseMsg = -1;
      break;
  }
  return mouseMsg;
}

LRESULT llMouseProc(int nCode, WPARAM wp, LPARAM lp) {
  MSLLHOOKSTRUCT k = *(MSLLHOOKSTRUCT *) lp;
  if (nCode < 0) return CallNextHookEx(mouseHook, nCode, wp, lp);
  EventSink <EncodableValue> *sink = eventSink.get();
  int keyMsg = wp2keyMsg(wp);
  sink->Success(EncodableValue(EncodableList{
          EncodableValue(keyMsg),                 //
          EncodableValue((int64_t) k.mouseData),      //
          EncodableValue((int64_t) k.flags),       //
          EncodableValue((int64_t) k.time),        //
          EncodableValue((int64_t) k.dwExtraInfo),
          EncodableValue((int64_t) k.pt.x),
          EncodableValue((int64_t) k.pt.y),
  }));
  return CallNextHookEx(mouseHook, nCode, wp, lp);
};

template<typename T = EncodableValue>
void MouseHookEnable(std::unique_ptr <EventSink<T>> &&events) {
  HMODULE hInstance = GetModuleHandle(nullptr);

  if constexpr(std::is_same_v < T, EncodableValue > )
  {
    eventSink = std::move(events);
  }

  mouseHook = SetWindowsHookEx(WH_MOUSE_LL, llMouseProc, hInstance, NULL);
}

void MouseHookDisable() {
  if (mouseHook) {
    UnhookWindowsHookEx(mouseHook);
    mouseHook = NULL;
  }
}

// int index = 0;
template<typename T = EncodableValue>
std::unique_ptr <StreamHandlerError<T>> MouseEventOnListen(
        const T *arguments, std::unique_ptr <EventSink<T>> &&events) {
  if constexpr(std::is_same_v < T, EncodableValue > )
  {
    MouseHookEnable(std::move(events));
  }
  return NULL;
}

template<typename T = EncodableValue>
std::unique_ptr <StreamHandlerError<T>> MouseEventOnError(
        const T *arguments) {
  MouseHookDisable();
  return NULL;
}

// static
void MouseEventPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar) {
  // StandardCodecSerializer *serializer = new MapSerializer();
  channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "mouse_event",
                  &flutter::StandardMethodCodec::GetInstance(
                          &MapSerializer::GetInstance()));
  auto plugin = std::make_unique<MouseEventPlugin>();
  channel->SetMethodCallHandler(
          [plugin_pointer = plugin.get()](const auto &call, auto result) {
              plugin_pointer->HandleMethodCall(call, std::move(result));
          });
  eventChannel =
          std::make_unique < flutter::EventChannel < flutter::EncodableValue >> (
                  registrar->messenger(), "mouse_event/event",
                          &flutter::StandardMethodCodec::GetInstance(
                                  &MapSerializer::GetInstance())  //
          );

  std::unique_ptr <flutter::StreamHandler<flutter::EncodableValue>>
          MouseEventStreamHandler =
          std::make_unique < StreamHandlerFunctions < EncodableValue >> (
                  MouseEventOnListen<EncodableValue>,
                          MouseEventOnError<EncodableValue>);
  eventChannel->SetStreamHandler(std::move(MouseEventStreamHandler));

  registrar->AddPlugin(std::move(plugin));
}

MouseEventPlugin::MouseEventPlugin() {

}

MouseEventPlugin::~MouseEventPlugin() { MouseHookDisable(); }

void MouseEventPlugin::HandleMethodCall(
        const flutter::MethodCall <flutter::EncodableValue> &method_call,
        std::unique_ptr <flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else {
    result->NotImplemented();
  }
}


void MouseEventPluginRegisterWithRegistrar(
        FlutterDesktopPluginRegistrarRef registrar) {
  MouseEventPlugin::RegisterWithRegistrar(
          flutter::PluginRegistrarManager::GetInstance()
                  ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

