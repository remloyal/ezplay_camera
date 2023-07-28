import 'dart:io';

import 'package:ezplay_camera/ezplay_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'ezplay_camera_platform_interface.dart';

// 控制器
class EzplayController {
  final String appKey;
  //是否开启sdk日志，默认不开启
  final bool? logEnabled;
  String accessToken;

  late int viewId;

  EzplayController(
      {required this.appKey,
      required this.accessToken,
      this.logEnabled = false});

  Future<bool> initAppKey() async {
    await EzplaySDK.setLogEnabled(true);
    await EzplaySDK.setAccessToken(accessToken);
    return EzplaySDK.initAppKey(appKey);
  }

  Future<void> initPlayer(String playUrl, PlayType playType) async {
    await EzplaySDK.initPlayer(
        playUrl, playType == PlayType.live ? 'live' : 'rec');
  }

  void startRealPlay() {
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

  final EzopenParam param;
  final String playUrl;

  const EzplayView(
      {super.key,
      required this.controller,
      required this.param,
      this.playUrl = ''});

  @override
  State<EzplayView> createState() => _EzplayViewState();
}

class _EzplayViewState extends State<EzplayView> {
  late EzplayController _controller;
  // late bool _landscape;

  late Future<void> _initFuture;

  late EzopenParam _ezopenParam;

  @override
  void initState() {
    super.initState();
    _ezopenParam = widget.param;

    _controller = widget.controller;
    // _landscape = false;
    _initFuture =
        _controller.initPlayer(_ezopenParam.gerUrl(), _ezopenParam.playType);
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
                      _controller.viewId = viewId;
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
