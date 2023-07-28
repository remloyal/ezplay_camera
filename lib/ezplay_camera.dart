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
    await EzplaySDK.setLogEnabled(true);
    await EzplaySDK.initAppKey(appKey);
    await EzplaySDK.setAccessToken(accessToken);
    await EzplaySDK.initPlayer(deviceSerial, verifyCode, cameraNo);
  }

  void startRealPlay(int viewId) {
    EzplaySDK.startRealPlay(viewId);
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

  const EzplayView(
      {super.key,
      required this.controller,
      required this.deviceSerial,
      required this.verifyCode,
      required this.cameraNo});

  @override
  State<EzplayView> createState() => _EzplayViewState();
}

class _EzplayViewState extends State<EzplayView> {
  late EzplayController _controller;
  late bool _playing;
  late bool _mute;
  // late bool _landscape;
  late StateSetter _toolbarSetter;

  late Future<void> _initFuture;

  late int? _viewId;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _playing = false;
    _mute = false;
    // _landscape = false;
    _initFuture = _controller.initPlayer(
        widget.deviceSerial, widget.verifyCode, widget.cameraNo);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = width * 9 / 16;

    return Container(
      color: Colors.black,
      width: width,
      height: height + kToolbarHeight,
      child: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                SizedBox(
                  width: width,
                  height: height,
                  child: _EZOpenView(
                    onPlatformViewCreated: (int viewId) {
                      // _portraitId = viewId;
                      _viewId = viewId;
                      // _controller.startRealPlay(viewId);
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
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
