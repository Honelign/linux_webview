import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_cef/webview_cef.dart';
import 'package:webview_cef/src/webview_inject_user_script.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewController _controller;

  // late WebViewController _controller2;
  final _textController = TextEditingController();
  String title = "";
  Map allCookies = {};

  @override
  void initState() {
    var injectUserScripts = InjectUserScripts();
    injectUserScripts.add(UserScript("console.log('injectScript_in_LoadStart')",
        ScriptInjectTime.LOAD_START));
    injectUserScripts.add(UserScript(
        "console.log('injectScript_in_LoadEnd')", ScriptInjectTime.LOAD_END));

    // CSS Injection Script Example
    // injectUserScripts.add(UserScript(
    //   '''
    //     const style = document.createElement('style');
    //     style.innerHTML = `
    //       body {
    //         background-color: yellow;
    //       }
    //     `;
    //
    //     document.head.appendChild(style);
    //   ''',
    //   ScriptInjectTime.LOAD_END,
    // ));

    _controller = WebviewManager().createWebView(
        loading: const Text("not initialized"),
        injectUserScripts: injectUserScripts);
    // _controller2 =
    //     WebviewManager().createWebView(loading: const Text("not initialized"));
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _controller.dispose();
    WebviewManager().quit();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await WebviewManager().initialize(userAgent: "test/userAgent");
    String url = "https://www.youtube.com/watch?v=tPEE9ZwTmy0";
    _textController.text = url;
    //unified interface for all platforms set user agent
    _controller.setWebviewListener(WebviewEventsListener(
      onTitleChanged: (t) {
        setState(() {
          title = t;
        });
      },
      onUrlChanged: (url) {
        _textController.text = url;
        final Set<JavascriptChannel> jsChannels = {
          JavascriptChannel(
              name: 'Print',
              onMessageReceived: (JavascriptMessage message) {
                print(message.message);
                _controller.sendJavaScriptChannelCallBack(
                    false,
                    "{'code':'200','message':'print succeed!'}",
                    message.callbackId,
                    message.frameId);
              }),
        };
        //normal JavaScriptChannels
        _controller.setJavaScriptChannels(jsChannels);
        //also you can build your own jssdk by execute JavaScript code to CEF
        _controller.executeJavaScript("function abc(e){return 'abc:'+ e}");
        _controller
            .evaluateJavascript("abc('test')")
            .then((value) => print(value));
      },
      onLoadStart: (controller, url) {
        print("onLoadStart => $url");
      },
      onLoadEnd: (controller, url) {
        print("onLoadEnd => $url");
      },
    ));

    await _controller.initialize(_textController.text);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
          body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    _controller.reload();
                  },
                  child: const Icon(Icons.refresh),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    _controller.goBack();
                  },
                  child: const Icon(Icons.arrow_left),
                ),
              ),
              SizedBox(
                height: 48,
                child: MaterialButton(
                  onPressed: () {
                    _controller.goForward();
                  },
                  child: const Icon(Icons.arrow_right),
                ),
              ),
              Expanded(
                child: TextField(
                  readOnly: true,
                  controller: _textController,
                  onSubmitted: (url) {
                    _controller.loadUrl(url);
                    WebviewManager().visitAllCookies().then((value) {
                      allCookies = Map.of(value);
                      if (url == "youtube.com") {
                        if (!allCookies.containsKey('.$url') ||
                            !Map.of(allCookies['.$url']).containsKey('test')) {
                          WebviewManager().setCookie(url, 'test', 'test123');
                        } else {
                          WebviewManager().deleteCookie(url, 'test');
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          Expanded(
              child: Row(
            children: [
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, child) {
                  return _controller.value
                      ? Expanded(child: _controller.webviewWidget)
                      : _controller.loadingWidget;
                },
              ),
          
            ],
          ))
        ],
      )),
    );
  }
}
