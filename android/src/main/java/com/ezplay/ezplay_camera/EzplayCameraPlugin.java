package com.ezplay.ezplay_camera;

import android.app.Application;
import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import com.videogo.errorlayer.ErrorInfo;
import com.videogo.openapi.EZConstants;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;

import java.util.Calendar;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * EzplayCameraPlugin
 */
public class EzplayCameraPlugin implements FlutterPlugin, MethodCallHandler {

    private static final String TAG = "EzplaySDK-CameraPlugin";

    private MethodChannel channel;

    private Application application;

    private EzplayViewFactory factory;
    private EZPlayer ezPlayer = null;

    private String deviceSerial;
    private int cameraNo;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "ezplay_camera");
        channel.setMethodCallHandler(this);
        factory = new EzplayViewFactory(binding.getBinaryMessenger());
        application = (Application) binding.getApplicationContext();
        binding.getPlatformViewRegistry().registerViewFactory("ezplay_view", factory);

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            String method = call.method;
            if ("initAppKey".equals(method)) {
                String app_key = call.arguments();
                boolean b = EZOpenSDK.initLib(application, app_key);
                result.success(b);
            }
            if ("setLogEnabled".equals(method)) {
                Boolean enable = call.arguments();
                if (enable != null) {
                    EZOpenSDK.showSDKLog(enable);
                }
                result.success(enable);
            } else if ("initAppKey".equals(method)) {
                String app_key = call.arguments();
                boolean b = EZOpenSDK.initLib(application, app_key);
                result.success(b);
            } else if ("setAccessToken".equals(method)) {
                String AccessToken = call.arguments();
                EZOpenSDK.getInstance().setAccessToken(AccessToken);
                result.success(true);
            } else if ("destroyLib".equals(method)) {
                EZOpenSDK.finiLib();
            } else if (method.equals("initPlayer")) {
                deviceSerial = call.argument("deviceSerial");
                String verifyCode = call.argument("verifyCode");
                cameraNo = call.argument("cameraNo");

                EZOpenSDK instance = EZOpenSDK.getInstance();
                if (instance == null) {
                    Log.e(TAG, "SDK未初始化");
                    result.error(
                            "sdk init error",
                            "SDK未初始化",
                            "请先调用EZOpenSDK.initLibWithAppKey()初始化SDK！"
                    );
                    return;
                }

                if (ezPlayer != null) {
                    ezPlayer.release();
                }

                ezPlayer = instance.createPlayer(deviceSerial, cameraNo);
                boolean b = ezPlayer.setHandler(new EZOpenPlayerHandler());
//                ezPlayer.setSurfaceHold(factory.getView().getHolder());
                ezPlayer.setPlayVerifyCode(verifyCode);
                result.success(b);
            } else if (method.equals("startRealPlay")) {
                Integer viewId = call.arguments();
                ezPlayer.setSurfaceHold(factory.getSurfaceView(viewId).getHolder());
                boolean b = ezPlayer.startRealPlay();
                result.success(b);
            } else if (method.equals("suspendPlay")) {
//                暂停播放
                boolean b = ezPlayer.startRealPlay();
                result.success(b);
            } else if (method.equals("stopRealPlay")) {
                boolean b = ezPlayer.stopRealPlay();
                result.success(b);
            } else if (method.equals("release")) {
                ezPlayer.release();
            } else if (method.equals("setSoundEnabled")) {
                Boolean enabled = call.arguments();
                boolean b;
                if (Boolean.TRUE.equals(enabled)) {
                    b = ezPlayer.openSound();
                } else {
                    b = ezPlayer.closeSound();
                }
                result.success(b);
            } else if (method.equals("setVideoLevel")) {
                if (ezPlayer == null) {
                    Log.e(TAG, "播放器未初始化");
                    result.error(
                            "player init error",
                            "播放器未初始化",
                            "请先调用EZOpenSDK.initPlayer()初始化播放器！"
                    );
                    return;
                }
                int level = call.arguments();
                boolean b = EZOpenSDK.getInstance().setVideoLevel(deviceSerial, cameraNo, level);
                result.success(b);
            } else if (method.equals("startPlayback")) {
                long startMillis = call.argument("startMillis");
                long endMillis = call.argument("endMillis");
                Calendar start = Calendar.getInstance();
                start.setTimeInMillis(startMillis);
                Calendar end = Calendar.getInstance();
                end.setTimeInMillis(endMillis);
                boolean b = ezPlayer.startPlayback(start, end);
                result.success(b);
            } else if (method.equals("stopPlayback")) {
                boolean b = ezPlayer.stopPlayback();
                result.success(b);
            } else if (call.method.equals("getOSDTime")) {
                Calendar osdTime = ezPlayer.getOSDTime();
                if (null != osdTime) {
                    long timeInMillis = osdTime.getTimeInMillis();
                    result.success(timeInMillis);
                } else {
                    result.success(0);
                }
            } else if (call.method.equals("pausePlayback")) {
                boolean b = ezPlayer.pausePlayback();// 暂停回放
                result.success(b);
            } else if (call.method.equals("resumePlayback")) {
                boolean b = ezPlayer.resumePlayback();// 恢复回放
                result.success(b);
            } else {
                result.notImplemented();
            }

        } catch (Exception e) {
            Log.e(TAG, "Exception:" + e.getMessage());
            result.error("error", e.getMessage(), e);
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    class EZOpenPlayerHandler extends Handler {
        @Override
        public void handleMessage(@NonNull Message msg) {
            Log.d("视频播放中", String.valueOf(msg));
            switch (msg.what) {
                case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_SUCCESS:
                    Log.d(TAG, "视频播放成功");
                    //播放成功
                    break;
                case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_FAIL:
                    //播放失败,得到失败信息
                    ErrorInfo errorInfo = (ErrorInfo) msg.obj;
                    //得到播放失败错误码
                    int code = errorInfo.errorCode;
//                    得到播放失败模块错误码
                    String moduleCode = errorInfo.moduleCode;
//                    得到播放失败描述
                    String description = errorInfo.description;
//                    得到播放失败解决方方案
                    String solution = errorInfo.sulution;
                    Log.d(TAG, "视频播放失败, " + errorInfo);

                    break;
                case EZConstants.MSG_VIDEO_SIZE_CHANGED:
                    //解析出视频画面分辨率回调
//                    try {
//                        String temp = (String) msg.obj;
//                        String[] strings = temp.split(":");
//                        int mVideoWidth = Integer.parseInt(strings[0]);
//                        int mVideoHeight = Integer.parseInt(strings[1]);
//                        //解析出视频分辨率
//                    } catch (Exception e) {
//                        e.printStackTrace();
//                    }
                    break;
                default:
                    break;
            }
        }
    }

}
