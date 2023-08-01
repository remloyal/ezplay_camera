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
            switch (call.method) {
                case "setLogEnabled":
                    Boolean enable = call.arguments();
                    if (enable != null) {
                        EZOpenSDK.showSDKLog(enable);
                    }
                    result.success(enable);
                    break;
                case "initAppKey":
                    String app_key = call.arguments();
                    boolean b = EZOpenSDK.initLib(application, app_key);
                    result.success(b);
                    break;
                case "setAccessToken":
                    String AccessToken = call.arguments();
                    EZOpenSDK.getInstance().setAccessToken(AccessToken);
                    result.success(true);
                    break;
                case "destroyLib":
                    EZOpenSDK.finiLib();
                    break;
                case "initPlayer":
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
                    boolean state = ezPlayer.setHandler(new EZOpenPlayerHandler());
//                ezPlayer.setSurfaceHold(factory.getView().getHolder());
                    ezPlayer.setPlayVerifyCode(verifyCode);
                    result.success(state);
                    break;
                case "startRealPlay":
                    Integer viewId = call.arguments();
                    ezPlayer.setSurfaceHold(factory.getSurfaceView(viewId).getHolder());
                    boolean startState = ezPlayer.startRealPlay();
                    result.success(startState);
                    break;
                case "suspendPlay":
                    //                暂停播放
                    result.success(ezPlayer.startRealPlay());
                    break;
                case "stopRealPlay":
                    result.success(ezPlayer.stopRealPlay());
                    break;
                case "release":
                    ezPlayer.release();
                    result.success(true);
                    break;
                case "setSoundEnabled":
                    Boolean enabled = call.arguments();
                    boolean enabledState;
                    if (Boolean.TRUE.equals(enabled)) {
                        enabledState = ezPlayer.openSound();
                    } else {
                        enabledState = ezPlayer.closeSound();
                    }
                    result.success(enabledState);
                    break;
                case "setVideoLevel":
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
                    boolean b1 = EZOpenSDK.getInstance().setVideoLevel(deviceSerial, cameraNo, level);
                    result.success(b1);
                    break;
                case "startPlayback":
                    long startMillis = call.argument("startMillis");
                    long endMillis = call.argument("endMillis");
                    Calendar start = Calendar.getInstance();
                    start.setTimeInMillis(startMillis);
                    Calendar end = Calendar.getInstance();
                    end.setTimeInMillis(endMillis);
                    boolean ment = ezPlayer.startPlayback(start, end);
                    result.success(ment);
                    break;

                case "stopPlayback":
                    result.success(ezPlayer.stopPlayback());
                    break;
                case "getOSDTime":
                    Calendar osdTime = ezPlayer.getOSDTime();
                    if (osdTime != null) {
                        long timeInMillis = osdTime.getTimeInMillis();
                        result.success(timeInMillis);
                    } else {
                        result.success(0);
                    }
                    break;

                case "pausePlayback":
                    // 暂停远程回放播放
                    result.success(ezPlayer.pausePlayback());
                    break;
                case "resumePlayback":
                    // 恢复远程回放播放
                    result.success(ezPlayer.resumePlayback());
                    break;
                default:
                    result.notImplemented();
                    break;
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
