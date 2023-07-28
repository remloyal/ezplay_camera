import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ezplay_camera_method_channel.dart';

abstract class EzplayCameraPlatform extends PlatformInterface {
  /// Constructs a EzplayCameraPlatform.
  EzplayCameraPlatform() : super(token: _token);

  static final Object _token = Object();

  static EzplayCameraPlatform _instance = MethodChannelEzplayCamera();

  /// The default instance of [EzplayCameraPlatform] to use.
  ///
  /// Defaults to [MethodChannelEzplayCamera].
  static EzplayCameraPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EzplayCameraPlatform] when
  /// they register themselves.
  static set instance(EzplayCameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> initAppKey(String appKey) {
    throw UnimplementedError('platformVersion() has not been initAppKey.');
  }

  Future<void> setLogEnabled(bool enabled) {
    throw UnimplementedError('setLogEnabled() has not been implemented.');
  }

  Future<void> setAccessToken(String accessToken) {
    throw UnimplementedError('setAccessToken() has not been implemented.');
  }

  Future<void> destroyLib() {
    throw UnimplementedError('destroyLib() has not been implemented.');
  }

  Future<bool> initPlayer(
      String deviceSerial, String verifyCode, int cameraNo) {
    throw UnimplementedError('initPlayer() has not been implemented.');
  }

  Future<bool> startRealPlay(int viewId) {
    throw UnimplementedError('startRealPlay() has not been implemented.');
  }

  Future<bool> stopRealPlay() {
    throw UnimplementedError('stopRealPlay() has not been implemented.');
  }

  Future<void> release() {
    throw UnimplementedError('release() has not been implemented.');
  }

  Future<bool> setSoundEnabled(bool enabled) {
    throw UnimplementedError('setSoundEnabled() has not been implemented.');
  }

  Future<bool> setVideoLevel(int value) {
    throw UnimplementedError('setVideoLevel() has not been implemented.');
  }

  Future<bool> startPlayback(int startMillis, int endMillis) {
    throw UnimplementedError('startPlayback() has not been implemented.');
  }

  Future<bool> stopPlayback() {
    throw UnimplementedError('stopPlayback() has not been implemented.');
  }

  Future<bool> pausePlayback() {
    throw UnimplementedError('pausePlayback() has not been implemented.');
  }

  Future<bool> resumePlayback() {
    throw UnimplementedError('resumePlayback() has not been implemented.');
  }

  Future<int> getOSDTime() {
    throw UnimplementedError('getOSDTime() has not been implemented.');
  }
}
