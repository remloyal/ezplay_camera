import 'dart:io';

import 'package:ezplay_camera/ezplay_plugin.dart';
import 'package:ezplay_camera/player_date_time_picker.dart';
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

  late int osdTime = 0;

  // 播放状态
  late bool playing = false;
  // 是否静音
  late bool mute = true;

  // 是否回放
  late bool playback = false;

  //回放开始时间
  DateTime? _startTime;

  DateTime? get startTime => _startTime;

  //回放结束时间
  DateTime? _endTime;

  DateTime? get endTime => _endTime;

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

  // 初始化播放
  void startRealPlay(int viewId) {
    EzplaySDK.startRealPlay(viewId);
  }

  // 开始直播
  void suspendPlay() {
    EzplaySDK.suspendPlay();
  }

  // 暂停直播
  void stopRealPlay() async {
    await EzplaySDK.stopRealPlay();
  }

  // 停止直播
  void releasePlayer() async {
    stopRealPlay();
    await EzplaySDK.releasePlayer();
  }

  // 开始远程SD卡回放---按时间回放
  void startPlayback(int startMillis, int endMillis) async {
    stopRealPlay();
    playback = await EzplaySDK.startPlayback(startMillis, endMillis);
    if (playback) {
    } else {}
  }

  // 停止远程回放
  void stopPlayback() async {
    await EzplaySDK.stopPlayback();
  }

  // 暂停远程回放播放
  void pausePlayback() async {
    await EzplaySDK.pausePlayback();
  }

  // 恢复远程回放播放
  void resumePlayback() async {
    await EzplaySDK.resumePlayback();
  }

  // 获取当前播放时间戳
  Future<int> getOSDTime() async {
    osdTime = await EzplaySDK.getOSDTime();
    return osdTime;
  }

  //开启/关闭声音
  Future<bool> setSoundEnabled(bool enabled) async {
    return EzplaySDK.setSoundEnabled(enabled);
  }
}

// 显示组件
class EzplayView extends StatefulWidget {
  final EzplayController controller;

  final String deviceSerial;
  final String verifyCode;
  final int cameraNo;
  final Widget? toolbar;
  final double? width;
  final double? height;
  const EzplayView(
      {super.key,
      required this.controller,
      required this.deviceSerial,
      required this.verifyCode,
      required this.cameraNo,
      this.toolbar,
      this.width,
      this.height});

  @override
  State<EzplayView> createState() => _EzplayViewState();
}

class _EzplayViewState extends State<EzplayView> {
  late EzplayController _controller;
  late double width;
  late double height;

  late int _viewId = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
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
    width = widget.width != null ? widget.width! : size.width;
    height = widget.height != null ? widget.height! : width * 9 / 16;
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
    } else if (Platform.isIOS) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: UiKitView(
          viewType: "ezplay_view",
          onPlatformViewCreated: onPlatformViewCreated,
        ),
      );
    } else {
      return ErrorWidget('暂不支持该平台！');
    }
  }
}

// 控制组件
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
      _controller.suspendPlay();
    }
    _toolbarSetter(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext ctx, StateSetter setter) {
        _toolbarSetter = setter;

        Widget toolbar = Container(
          color: const Color.fromRGBO(255, 255, 255, 0.3),
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
                      _controller.setSoundEnabled(_mute);
                      _toolbarSetter(() {});
                    },
                    child: _mute
                        ? _buildIcon(Icons.volume_off)
                        : _buildIcon(Icons.volume_up),
                  ),
                  TextButton(onPressed: () {}, child: Text("清晰度")),
                  TextButton(onPressed: () {}, child: Text("模式")),
                  TextButton(
                      onPressed: () {
                        showPlayerDateTimePicker(context, _controller.startTime,
                                _controller.endTime)
                            .then((value) {
                          print(
                              'showPlayerDateTimePicker ============> ${value![0]} ${value![1]}');
                          // if (value == null) return;
                          // _controller.stopPlay();
                          // _controller.isReal = false;
                          _controller._startTime = value[0];
                          _controller._endTime = value[1];
                          int starttime = value[0].millisecondsSinceEpoch;
                          int endtime = value[1].millisecondsSinceEpoch;

                          _controller.startPlayback(starttime, endtime);
                        });
                      },
                      child: Text("回放")),
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
  }
}
