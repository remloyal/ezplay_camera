import 'dart:async';

import 'package:ezplay_camera/ezplay_camera.dart';
import 'package:ezplay_camera_example/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('萤石云播放器'),
          ),
          body: EZOpenPage()),
    );
  }
}

class EZOpenPage extends StatefulWidget {
  const EZOpenPage({super.key});

  @override
  State<EZOpenPage> createState() => _EZOpenPageState();
}

class _EZOpenPageState extends State<EZOpenPage> {
  late EzplayController _controller;

  late String appKey = '5d29f148e3d24b1ea8b2074c0cfc8d8a';
  late String accessToken =
      'at.1wkwg5ta2c5w81d99eq9ridd9wznfw86-8kzlat3hrx-0i3ima4-cfzfbisah';

  late String deviceSerial = 'E73718179';
  late String verifyCode = 'jsca2020';
  late String cameraNo = '1';

  TextEditingController appKeyController = TextEditingController();
  TextEditingController accessTokenController = TextEditingController();
  TextEditingController deviceSerialController = TextEditingController();
  TextEditingController verifyCodeController = TextEditingController();
  TextEditingController cameraNoController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _controller = EzplayController(appKey: appKey, accessToken: accessToken);

    appKeyController.text = appKey;
    accessTokenController.text = accessToken;
    deviceSerialController.text = deviceSerial;
    verifyCodeController.text = verifyCode;
    cameraNoController.text = cameraNo;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        TextField(
          controller: appKeyController,
          onChanged: (value) {
            appKey = value;
          },
          decoration: const InputDecoration(prefixIcon: Text('appKey')),
        ),
        TextField(
          controller: accessTokenController,
          onChanged: (value) {
            accessToken = value;
          },
          decoration: const InputDecoration(prefixIcon: Text('token')),
        ),
        TextField(
          controller: deviceSerialController,
          onChanged: (value) {
            deviceSerial = value;
          },
          decoration: const InputDecoration(prefixIcon: Text('序列号')),
        ),
        TextField(
          controller: verifyCodeController,
          onChanged: (value) {
            verifyCode = value;
          },
          decoration: const InputDecoration(prefixIcon: Text('验证码')),
        ),
        TextField(
          controller: cameraNoController,
          onChanged: (value) {
            cameraNo = value;
          },
          decoration: const InputDecoration(prefixIcon: Text('通道')),
        ),
        TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  Popup(
                      child: Center(
                    child: Container(
                      height: 250,
                      child: play(),
                    ),
                  ))).then((value) async {
                print('object 我销毁了');
                // _controller.stopRealPlay();
                // _controller.releasePlayer();
              });
            },
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(10),
              color: Colors.blue,
              child: const Center(
                child: Text(
                  '观看',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ))
      ],
    ));
  }

  play() {
    return EzplayView(
      controller: _controller,
      deviceSerial: deviceSerial,
      verifyCode: verifyCode,
      cameraNo: 1,
      // toolbar: Container(
      //     height: 50,
      //     child: Text(
      //       '测试一下',
      //       style: TextStyle(fontSize: 12),
      //     )),
    );
  }
}

// FutureBuilder(
//         future: _initFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return 
//             Stack(
//               children: [
//                 SizedBox(
//                   width: width,
//                   height: height,
//                   child: _EZOpenView(
//                     onPlatformViewCreated: (int viewId) {
//                       // _portraitId = viewId;
//                       _viewId = viewId;
//                       // _controller.startRealPlay(viewId);
//                     },
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),