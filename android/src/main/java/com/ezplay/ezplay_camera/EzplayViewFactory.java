package com.ezplay.ezplay_camera;

import android.content.Context;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class EzplayViewFactory extends PlatformViewFactory  {

    private static final String TAG = "EZOpenSDK-EZOpenViewFactory";

    private Map<Integer, SurfaceView> views = new HashMap<>();

    private View playView;
    public EzplayViewFactory( BinaryMessenger channel) {
        super(StandardMessageCodec.INSTANCE);
    }

    // args是布尔类型，表示是否是横屏
    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        Log.d(TAG, "创建SurfaceView, viewId: " + viewId);
        EzplayView view = new EzplayView(context,viewId,args);
        views.put(viewId, view.getSurfaceView());
        playView = view.getSurfaceView();
        return view;
    }

    public SurfaceView getSurfaceView(Integer viewId) {
        return views.get(viewId);
    }

    public View getPlayView() {
        return playView;
    }
}
