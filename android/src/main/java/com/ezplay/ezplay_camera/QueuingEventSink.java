package com.ezplay.ezplay_camera;

import java.util.ArrayList;

import io.flutter.plugin.common.EventChannel;

public class QueuingEventSink implements EventChannel.EventSink {
    private final ArrayList<Object> eventQueue = new ArrayList<>();
    private EventChannel.EventSink delegate;
    private boolean done = false;

    public void setDelegate(EventChannel.EventSink delegate) {
        this.delegate = delegate;
        maybeFlush();
    }

    @Override
    public void endOfStream() {
        enqueue(new EndOfStreamEvent());
        maybeFlush();
        done = true;
    }

    @Override
    public void error(String code, String message, Object details) {
        enqueue(new ErrorEvent(code, message, details));
        maybeFlush();
    }

    @Override
    public void success(Object event) {
        enqueue(event);
        maybeFlush();
    }

    private void enqueue(Object event) {
        if (done) {
            return;
        }
        eventQueue.add(event);
    }

    private void maybeFlush() {
        if (delegate == null) {
            return;
        }
        for (Object event : eventQueue) {
            if (event instanceof EndOfStreamEvent) {
                delegate.endOfStream();
            } else if (event instanceof ErrorEvent) {
                ErrorEvent errorEvent = (ErrorEvent) event;
                delegate.error(errorEvent.code, errorEvent.message, errorEvent.details);
            } else {
                delegate.success(event);
            }
        }
        eventQueue.clear();
    }

    static class EndOfStreamEvent {
    }

    private static class ErrorEvent {
        String code;
        String message;
        Object details;

        ErrorEvent(String code, String message, Object details) {
            this.code = code;
            this.message = message;
            this.details = details;
        }
    }
}