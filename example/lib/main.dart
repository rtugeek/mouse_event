import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mouse_event/mouse_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final List<String> _err = [];
  final List<String> _event = [];
  int eventNum = 0;
  bool listenIsOn = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    List<String> err = [];
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await MouseEventPlugin.platformVersion;
    } on PlatformException {
      err.add('Failed to get platform version.');
    }
    // try {
    //   await MouseEvent.init();
    // } on PlatformException {
    //   err.add('Failed to get virtual-key map.');
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (platformVersion != null) _platformVersion = platformVersion;
      if (err.isNotEmpty) _err.addAll(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('运行于: $_platformVersion'),
                      Row(
                        children: [
                          const Text('点击按钮切换鼠标监听: '),
                          Switch(
                            value: listenIsOn,
                            onChanged: (bool newValue) {
                              setState(() {
                                listenIsOn = newValue;
                                if (listenIsOn == true) {
                                  MouseEventPlugin.startListening((mouseEvent) {
                                    setState(() {
                                      eventNum++;
                                      _event.add(mouseEvent.toString());
                                      if (_event.length > 20) {
                                        _event.removeAt(0);
                                      }
                                      debugPrint(mouseEvent.toString());
                                    });
                                  });
                                } else {
                                  MouseEventPlugin.cancelListening();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => _event.clear());
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('Clear'),
                              ),
                              Text(
                                _event.join('\n'),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            initPlatformState();
          },
        ),
      ),
    );
  }
}
