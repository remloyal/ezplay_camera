import 'package:flutter_test/flutter_test.dart';
import 'package:ezplay_camera/ezplay_camera.dart';
import 'package:ezplay_camera/ezplay_camera_platform_interface.dart';
import 'package:ezplay_camera/ezplay_camera_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEzplayCameraPlatform
    with MockPlatformInterfaceMixin
    implements EzplayCameraPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> initAppKey(String appKey) {
    // TODO: implement initAppKey
    throw UnimplementedError();
  }

  @override
  Future<bool> startRealPlay(int viewId) {
    // TODO: implement startRealPlay
    throw UnimplementedError();
  }

  @override
  Future<bool> stopRealPlay() {
    // TODO: implement stopRealPlay
    throw UnimplementedError();
  }
}

void main() {
  final EzplayCameraPlatform initialPlatform = EzplayCameraPlatform.instance;

  test('$MethodChannelEzplayCamera is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEzplayCamera>());
  });

  test('getPlatformVersion', () async {
    EzplayCamera ezplayCameraPlugin = EzplayCamera();
    MockEzplayCameraPlatform fakePlatform = MockEzplayCameraPlatform();
    EzplayCameraPlatform.instance = fakePlatform;

    expect(await ezplayCameraPlugin.getPlatformVersion(), '42');
  });
}
