package com.ezplay.ezplay_camera;

import android.content.Context;
import android.view.SurfaceView;
import android.view.View;

import androidx.annotation.Nullable;

import io.flutter.plugin.platform.PlatformView;

public class EzplayView implements PlatformView {

    private SurfaceView surfaceView;

//    public EzplayView(Context context) {
//        surfaceView = new SurfaceView(context);
//    }

    public EzplayView(Context context, int viewId, Object args) {
        surfaceView = new SurfaceView(context);
    }

    public SurfaceView getSurfaceView() {
        return surfaceView;
    }

    @Nullable
    @Override
    public View getView() {
        return surfaceView;
    }

    @Override
    public void dispose() {

    }
}
