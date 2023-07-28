import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ezplay_camera_platform_interface.dart';

/// An implementation of [EzplayCameraPlatform] that uses method channels.
class MethodChannelEzplayCamera extends EzplayCameraPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ezplay_camera');

  @override
  Future<bool> initAppKey(String appKey) async {
    final version = await methodChannel.invokeMethod('initAppKey', appKey);
    return version;
  }

  @override
  Future<void> setLogEnabled(bool enabled) async {
    return await methodChannel.invokeMethod('setLogEnabled', enabled);
  }

  @override
  Future<void> setAccessToken(String accessToken) async {
    return await methodChannel.invokeMethod('setAccessToken', accessToken);
  }

  @override
  Future<void> destroyLib() async {
    return await methodChannel.invokeMethod('destroyLib');
  }

  @override
  Future<bool> initPlayer(String playUrl, String playType) async {
    Map<String, dynamic> args = {
      'playUrl': playUrl,
      'playType': playType,
    };
    return await methodChannel.invokeMethod('initPlayer', args);
  }

  @override
  Future<bool> startRealPlay(int viewId) async {
    return await methodChannel.invokeMethod('startRealPlay', viewId);
  }

  @override
  Future<bool> stopRealPlay() async {
    return await methodChannel.invokeMethod('stopRealPlay');
  }

  @override
  Future<void> release() async {
    return await methodChannel.invokeMethod('release');
  }

  @override
  Future<bool> setSoundEnabled(bool enabled) async {
    return await methodChannel.invokeMethod('setSoundEnabled', enabled);
  }

  @override
  Future<bool> setVideoLevel(int value) async {
    return await methodChannel.invokeMethod('setVideoLevel', value);
  }

  @override
  Future<bool> startPlayback(int startMillis, int endMillis) async {
    Map<String, int> args = {
      'startMillis': startMillis,
      'endMillis': endMillis
    };
    return await methodChannel.invokeMethod('startPlayback', args);
  }

  @override
  Future<bool> stopPlayback() async {
    return await methodChannel.invokeMethod('stopPlayback');
  }

  @override
  Future<bool> pausePlayback() async {
    return await methodChannel.invokeMethod('pausePlayback');
  }

  @override
  Future<bool> resumePlayback() async {
    return await methodChannel.invokeMethod('resumePlayback');
  }

  @override
  Future<int> getOSDTime() async {
    return await methodChannel.invokeMethod('getOSDTime');
  }
}
