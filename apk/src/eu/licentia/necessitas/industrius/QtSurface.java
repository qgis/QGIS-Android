/*
    Copyright (c) 2009-2011, BogDan Vatra <bog_dan_ro@yahoo.com>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
        * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
        * Neither the name of the  BogDan Vatra <bog_dan_ro@yahoo.com> nor the
        names of its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY BogDan Vatra <bog_dan_ro@yahoo.com> ''AS IS'' AND ANY
    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL BogDan Vatra <bog_dan_ro@yahoo.com> BE LIABLE FOR ANY
    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package eu.licentia.necessitas.industrius;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

public class QtSurface extends SurfaceView implements SurfaceHolder.Callback
{
    private Bitmap m_bitmap=null;
    private boolean m_started = false;
    public QtSurface(Context context, int id)
    {
        super(context);
        setFocusable(true);
        getHolder().addCallback(this);
        getHolder().setType(SurfaceHolder.SURFACE_TYPE_GPU);
        setId(id);
    }

    public void applicationStared()
    {
        m_started = true;
        if (getWidth() < 1 ||  getHeight() < 1)
            return;
        QtApplication.lockSurface();
        QtApplication.setSurface(null);
        m_bitmap=Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.RGB_565);
        QtApplication.setSurface(m_bitmap);
        QtApplication.unlockSurface();
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder)
    {
        DisplayMetrics metrics = new DisplayMetrics();
        ((Activity) getContext()).getWindowManager().getDefaultDisplay().getMetrics(metrics);
        QtApplication.setApplicationDisplayMetrics(metrics.widthPixels,
            metrics.heightPixels, getWidth(), getHeight(), metrics.xdpi, metrics.ydpi);

        if (!m_started)
            return;

        QtApplication.lockSurface();
        QtApplication.setSurface(null);
        m_bitmap=Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.RGB_565);
        QtApplication.setSurface(m_bitmap);
        QtApplication.unlockSurface();

    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height)
    {
        Log.i(QtApplication.QtTAG,"surfaceChanged: "+width+","+height);
        if (width<1 || height<1)
                return;

        DisplayMetrics metrics = new DisplayMetrics();
        ((Activity) getContext()).getWindowManager().getDefaultDisplay().getMetrics(metrics);
        QtApplication.setApplicationDisplayMetrics(metrics.widthPixels,
            metrics.heightPixels, width, height, metrics.xdpi, metrics.ydpi);

        if (!m_started)
            return;
        QtApplication.lockSurface();
        QtApplication.setSurface(null);
        m_bitmap=Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
        QtApplication.setSurface(m_bitmap);
        QtApplication.unlockSurface();
        QtApplication.updateWindow();
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder)
    {
        if (!m_started)
            return;
        Log.i(QtApplication.QtTAG,"surfaceDestroyed ");
        QtApplication.lockSurface();
        QtApplication.setSurface(null);
        QtApplication.unlockSurface();
    }

    public void drawBitmap(Rect rect)
    {
        if (!m_started)
            return;
        QtApplication.lockSurface();
        if (null!=m_bitmap)
        {
            try
            {
                Canvas cv=getHolder().lockCanvas(rect);
                cv.drawBitmap(m_bitmap, rect, rect, null);
                getHolder().unlockCanvasAndPost(cv);
            }
            catch (Exception e)
            {
                Log.e(QtApplication.QtTAG, "Can't create main activity", e);
            }
        }
        QtApplication.unlockSurface();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event)
    {
        if (!m_started)
            return false;
        QtApplication.sendTouchEvent(event, getId());
        return true;
    }

    @Override
    public boolean onTrackballEvent(MotionEvent event)
    {
        if (!m_started)
            return false;
        QtApplication.sendTrackballEvent(event, getId());
        return true;
    }
}
