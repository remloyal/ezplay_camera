import 'dart:io';

import 'package:ezplay_camera/ezplay_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'ezplay_camera_platform_interface.dart';

class EzplayCamera {
  Future<bool> initAppKey(String appKey) {
    return EzplayCameraPlatform.instance.initAppKey(appKey);
  }
}

// 控制器
class EzplayController {
  final String appKey;
  //是否开启sdk日志，默认不开启
  final bool? logEnabled;
  String accessToken;

  EzplayController(
      {required this.appKey,
      required this.accessToken,
      this.logEnabled = false});

  Future<bool> initAppKey(String appKey) {
    return EzplayCameraPlatform.instance.initAppKey(appKey);
  }

  Future<void> initPlayer(
      String deviceSerial, String verifyCode, int cameraNo) async {
    try {
      await EzplaySDK.setLogEnabled(true);
      await EzplaySDK.initAppKey(appKey);
      await EzplaySDK.setAccessToken(accessToken);
      await EzplaySDK.initPlayer(deviceSerial, verifyCode, cameraNo);

      // EzplaySDK.startRealPlay(0);
    } catch (e) {
      print('播放识别 =============> $e');
    }
  }

  void startRealPlay(int viewId) {
    EzplaySDK.startRealPlay(viewId);
  }

  void suspendPlay() {
    EzplaySDK.suspendPlay();
  }

  void stopRealPlay() async {
    await EzplaySDK.stopRealPlay();
  }

  void releasePlayer() async {
    stopRealPlay();
    await EzplaySDK.releasePlayer();
  }
}

class EzplayView extends StatefulWidget {
  final EzplayController controller;

  final String deviceSerial;
  final String verifyCode;
  final int cameraNo;
  final Widget? toolbar;
  const EzplayView(
      {super.key,
      required this.controller,
      required this.deviceSerial,
      required this.verifyCode,
      required this.cameraNo,
      this.toolbar});

  @override
  State<EzplayView> createState() => _EzplayViewState();
}

class _EzplayViewState extends State<EzplayView> {
  late EzplayController _controller;
  late bool _playing;
  late bool _mute;
  late StateSetter _toolbarSetter;

  late Future<void> _initFuture;

  late int _viewId = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _playing = false;
    _mute = false;
    _controller
        .initPlayer(widget.deviceSerial, widget.verifyCode, widget.cameraNo)
        .then((value) {
      _controller.startRealPlay(_viewId!);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.stopRealPlay();
    // _controller.releasePlayer();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = width * 9 / 16;
    return OrientationBuilder(
      builder: (context, orientation) {
        print('orientation ==========> $orientation');
        if (orientation == Orientation.portrait) {
          print('orientation ==> 当前为竖屏');
        } else {
          print('orientation ==>当前为横屏');
        }
        print(
            'orientation ==> ${orientation == Orientation.portrait ? true : false}');
        return Container(
          color: Colors.black,
          // width: width,
          // height: height,
          child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  _EZOpenView(
                    onPlatformViewCreated: (int viewId) {
                      // _portraitId = viewId;
                      _viewId = viewId;
                      // _controller.startRealPlay(viewId);
                    },
                  ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      child: SizedBox(
                        width: width,
                        child: Toolbar(
                          controller: _controller,
                          viewId: _viewId!,
                        ),
                      ))
                ],
              )),
        );
      },
    );
  }
}

class _EZOpenView extends StatelessWidget {
  final PlatformViewCreatedCallback? onPlatformViewCreated;

  const _EZOpenView({this.onPlatformViewCreated});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: 'ezplay_view',
        onPlatformViewCreated: onPlatformViewCreated,
      );
    }
    return ErrorWidget('暂不支持该平台！');
  }
}

class Toolbar extends StatefulWidget {
  const Toolbar({super.key, required this.controller, required this.viewId});
  final EzplayController controller;
  final int viewId;
  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  late EzplayController _controller;
  late bool _playing;
  late bool _mute;
  late bool _landscape;
  late StateSetter _toolbarSetter;

  late int _viewId;

  late int _portraitId;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _viewId = widget.viewId;
    _portraitId = widget.viewId;
    _playing = true;
    _mute = false;
    _landscape = true;
  }

  Widget _buildIcon(IconData data, [double? size]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Icon(
        data,
        color: Colors.white,
        size: size,
      ),
    );
  }

  void _processPlay() {
    if (_playing) {
      _playing = false;
      _controller.stopRealPlay();
    } else {
      _playing = true;
      _controller.startRealPlay(_viewId!);
    }
    _toolbarSetter(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext ctx, StateSetter setter) {
        _toolbarSetter = setter;

        Widget toolbar = Container(
          color: Colors.white54,
          height: 50,
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _processPlay,
                    child: _playing
                        ? _buildIcon(Icons.pause_circle_outline)
                        : _buildIcon(Icons.play_circle_outline),
                  ),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () {
                      _processRotation(context);
                    },
                    child: _buildIcon(Icons.screen_rotation),
                  ),
                  GestureDetector(
                    onTap: () {
                      _mute = !_mute;
                      _toolbarSetter(() {});
                    },
                    child: _mute
                        ? _buildIcon(Icons.volume_off)
                        : _buildIcon(Icons.volume_up),
                  ),
                  TextButton(onPressed: () {}, child: Text("清晰度")),
                  TextButton(onPressed: () {}, child: Text("模式")),
                ],
              )
            ],
          ),
        );
        return toolbar;
      },
    );
  }

  void _processRotation(BuildContext context) {
    if (_landscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
      // 取消状态栏
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      _landscape = false;
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      _landscape = true;
    }

    // _landscape = true;
    // // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // if (_playing) {
    //   _controller.stopRealPlay();
    // }
    // showDialog(
    //     useSafeArea: false,
    //     context: context,
    //     builder: (BuildContext ctx) {
    //       return Container(
    //         width: 200,
    //         height: 200,
    //         child: Text("全屏"),
    //       );
    //     }).then((value) {
    //   _landscape = false;
    //   _viewId = _portraitId;
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    //   // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //   if (_playing) {
    //     _controller.startRealPlay(_viewId!);
    //   }
    // });
  }
}
