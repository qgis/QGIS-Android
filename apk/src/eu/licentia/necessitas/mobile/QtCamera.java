/*
Copyright (c) 2011 Elektrobit (EB), All rights reserved.
Contact: oss-devel@elektrobit.com

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are
met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of the Elektrobit (EB) nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Elektrobit (EB) ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Elektrobit (EB) BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package eu.licentia.necessitas.mobile;

//@ANDROID-8
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.hardware.Camera.Parameters;
import android.hardware.Camera.PictureCallback;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.ShutterCallback;
import android.hardware.Camera.Size;
import android.media.MediaRecorder;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import eu.licentia.necessitas.industrius.QtApplication;
import eu.licentia.necessitas.industrius.QtLayout;

public class QtCamera implements PreviewCallback, Callback{
    private static Camera m_camera;
    public ShutterCallback shutterCallback;
    public PictureCallback rawCallback;
    public PictureCallback jpegCallback;
    private static Activity m_activity = null;
    String[] m_sceneList;
    String[] m_focusModes;
    String[] m_flashModes;
    String[] m_whiteBalanceModes;
    static String m_currentFocusMode;
    int[] m_imageFormats;
    int[] m_imageResolutions;
    private Parameters m_params;
    public static PreviewCallback m_previewCallback;
    private int m_width;
    private int m_height;
    public static MediaRecorder m_recorder=null;
    private SurfaceView m_surfaceView;
    private String m_videoOutputPath = null;
    private int m_videoOutFormat = MediaRecorder.OutputFormat.MPEG_4;
    private int m_videoFrameRate = 30;
    private int[] m_videoFramesize = new int[2];
    private long m_maxVideoFileSize=0;
    private int m_videoEncodingBitrate=0;
    private int m_audioBitRate=0;
    private int m_audioChannelsCount=0;
    int[] m_videoPreviewParams;
    public boolean m_screenOff = false;
    private int m_surfaceDestroyedOff = 0;
    public boolean m_surfaceDestroyed = false;
    QtCamera()
    {
        setActivity();
        m_previewCallback = this;
        m_videoFramesize[0] = 480;
        m_videoFramesize[1] = 360;
        m_videoPreviewParams = new int[4];
        IntentFilter filter = new IntentFilter(Intent.ACTION_SCREEN_OFF);
        BroadcastReceiver mReceiver = new ScreenReceiver();
        QtApplication.mainActivity().registerReceiver(mReceiver, filter);
        m_surfaceView = new SurfaceView(QtApplication.mainActivity());
        m_surfaceView.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        m_surfaceView.getHolder().addCallback(this);
        m_surfaceView.setFocusable(true);
        QtApplication.mainActivity().getQtLayout().addView(m_surfaceView,1,new QtLayout.LayoutParams(0,0,1,1));
    }

    public static Camera getCamera()
    {
        return m_camera;
    }

    public void setOutputFile(String filename)
    {
        m_videoOutputPath = filename;
    }

    public void setOutputFormat(int format)
    {
        m_videoOutFormat = format;
    }

    public void setVideoEncodingBitrate(int rate)
    {
        m_videoEncodingBitrate = rate;
    }

    public void setMaxVideoSize(long size)
    {
        m_maxVideoFileSize = size;
    }

    public void setVideoSettings(int[] settings)
    {
        m_videoFrameRate = settings[0];
        m_videoFramesize[0] = settings[1];
        m_videoFramesize[1] = settings[2];
    }

    public void setAudioBitRate(int rate)
    {
        m_audioBitRate = rate;
    }


    public void setAudioChannelsCount(int count)
    {
        m_audioChannelsCount = count;
    }

    public void startRecording()
    {
        m_activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                QtApplication.mainActivity().getQtLayout().updateViewLayout(m_surfaceView, new QtLayout.LayoutParams(m_videoPreviewParams[0],m_videoPreviewParams[1],m_videoPreviewParams[2],m_videoPreviewParams[3]));
            }
        });
        m_camera.stopPreview();
        m_camera.unlock();

        if(m_recorder == null)
        {
            m_recorder = new MediaRecorder();
        }
        m_recorder.setCamera(m_camera);
        m_recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        m_recorder.setVideoSource(MediaRecorder.VideoSource.DEFAULT);
        m_recorder.setOutputFormat(m_videoOutFormat);

        long currentDateTimeString = System.currentTimeMillis();
        String filePath;

        // WARNING unsafe hardcoded path !!!
        if(m_videoOutputPath == null)
        {
            if(m_videoOutFormat == 1)
            {
                filePath = "/sdcard/"+currentDateTimeString+".3gp";
            }
            else
            {
                filePath = "/sdcard/"+currentDateTimeString+".mp4";
            }
        }
        else
        {
            if(m_videoOutFormat == 1)
            {
                filePath = m_videoOutputPath+currentDateTimeString+".3gp";
            }
            else
            {
                filePath = m_videoOutputPath+currentDateTimeString+".mp4";
            }
        }

        m_recorder.setOutputFile(filePath);

        if(m_maxVideoFileSize != 0)
        {
            m_recorder.setMaxFileSize(m_maxVideoFileSize);
        }
        m_recorder.setVideoEncoder(MediaRecorder.VideoEncoder.H263);
        m_recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
        m_recorder.setVideoFrameRate(m_videoFrameRate);
        m_recorder.setVideoSize(m_videoFramesize[0], m_videoFramesize[1]);

        if(m_videoEncodingBitrate != 0)
        {
            m_recorder.setVideoEncodingBitRate(m_videoEncodingBitrate);
        }

        if(m_audioBitRate != 0)
        {
            m_recorder.setAudioEncodingBitRate(m_audioBitRate);
        }

        if(m_audioChannelsCount != 0)
        {
            m_recorder.setAudioChannels(m_audioChannelsCount);
        }

        m_recorder.setPreviewDisplay(m_surfaceView.getHolder().getSurface());
        if (m_recorder != null) {
            try {
                m_recorder.prepare();
                m_recorder.start();
            } catch (IllegalStateException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public void stopRecording()
    {
        Log.i("Stop Record  called", "in stopRecording");
        if(m_recorder != null)
        {

            m_recorder.stop();
            m_recorder.reset();
            m_recorder.release();
            m_recorder = null;
        }
        m_activity.runOnUiThread(new Runnable() {
            public void run() {
                QtApplication.mainActivity().getQtLayout().updateViewLayout(m_surfaceView, new QtLayout.LayoutParams(0,0,1,1));
            }
        });

        try {
            m_camera.reconnect();
        } catch (IOException e) {
            e.printStackTrace();
        }
        m_params = m_camera.getParameters();
        m_params.setPreviewSize(m_width,m_height);
        m_camera.setParameters(m_params);
        m_camera.setPreviewCallback(this);
        try {
            m_camera.setPreviewDisplay(null);
        } catch (IOException e) {
            e.printStackTrace();
        }
        m_camera.startPreview();
    }


    public static void setActivity()
    {
        m_activity = QtApplication.mainActivity();
    }

    public void setCameraState(int state)
    {
        switch(state)
        {

        case 0:
            openCamera();
            m_params = m_camera.getParameters();
            m_params.setPreviewFormat(ImageFormat.NV21);
            m_camera.setParameters(m_params);
            getSupportedModes();
            getSupportedImageFormats();
            getSupportedImageResolutions();
            break;

        case 1:
            m_camera.release();
            m_camera = null;
            break;

        case 2:
            Log.i("tag", "stopping the preview************");
            m_camera.setPreviewCallback(this);
            try {
                    m_camera.setPreviewDisplay(null);
            } catch (IOException e) {
                    e.printStackTrace();
            }
            m_camera.startPreview();
            callBacks();
            startFocus();
            break;

        case 3:
            stopFocus();
            m_camera.stopPreview();
            break;

        default:
                break;
        }
    }

    public static void openCamera()
    {
        if(m_camera == null)
        {
            m_camera = Camera.open();
        }
    }

    public void takePicture()
    {
        m_camera.stopPreview();
        m_camera.takePicture(null,null,jpegCallback);
    }

    public void callBacks()
    {
        /** Handles data for jpeg picture */
        jpegCallback = new PictureCallback() {
            public void onPictureTaken(byte[] data, Camera camera) {
                getImage(data);
                m_camera.setPreviewCallback(m_previewCallback);
                m_camera.startPreview();
                Log.i("Camera", "onPictureTaken - jpeg"+m_params.getPictureSize().height+m_params.getPictureSize().width);
            }
        };
    }

    public void setSceneMode(String mode)
    {
        m_params.setSceneMode(mode);
        m_camera.setParameters(m_params);
    }

    public int[] getCompensationRange()
    {
        int[] range = {0,0};
        range[0] = (int)(m_params.getMinExposureCompensation() * m_params.getExposureCompensationStep());
        range[1] = (int)(m_params.getMaxExposureCompensation() * m_params.getExposureCompensationStep());
        return range;
    }

    public void setCompensation(int value)
    {
        int compensationIndex =(int) (value/m_params.getExposureCompensationStep());
        m_params.setExposureCompensation(compensationIndex);
        m_camera.setParameters(m_params);
    }

    public void setFocusMode(String mode)
    {
        m_currentFocusMode = mode;
        m_params.setFocusMode(mode);
        m_camera.setParameters(m_params);
    }

    public void startFocus()
    {
        if(m_currentFocusMode != null)
        {
            if(m_currentFocusMode.contains("auto" ) || m_currentFocusMode.contains("macro"))
            {
                m_camera.autoFocus(null);
            }
        }
    }

    public void stopFocus()
    {
        if(m_currentFocusMode != null)
        {
            if(m_currentFocusMode.contains("auto" ) || m_currentFocusMode.contains("macro"))
            {
                m_camera.cancelAutoFocus();
            }
        }
    }


    public void getSupportedModes()
    {
        m_sceneList = new String[m_params.getSupportedSceneModes().size()];
        for(int i =0;i < m_params.getSupportedSceneModes().size();i++ )
        {
            m_sceneList[i] = m_params.getSupportedSceneModes().get(i);
        }


        m_focusModes = new String[m_params.getSupportedFocusModes().size()];
        if(m_params.getSupportedFocusModes() == null)
        {
            m_focusModes[0] = "Not Supported";
        }
        else
        {
            for(int i =0;i < m_params.getSupportedFocusModes().size();i++ )
            {
                m_focusModes[i] = "";
                m_focusModes[i] = m_params.getSupportedFocusModes().get(i);
            }
        }

        m_flashModes = new String[m_params.getSupportedFlashModes().size()];
        if(m_params.getSupportedFlashModes() == null)
        {
            m_flashModes[0] = "Not Supported";
        }
        else
        {
            for(int i =0;i < m_params.getSupportedFlashModes().size();i++ )
            {
                m_flashModes[i] = m_params.getSupportedFlashModes().get(i);
            }
        }

        m_whiteBalanceModes = new String[m_params.getSupportedWhiteBalance().size()];
        if(m_params.getSupportedWhiteBalance() == null)
        {
            m_whiteBalanceModes[0] = "Not Supported";
        }
        else
        {
            for(int i =0;i < m_params.getSupportedWhiteBalance().size();i++ )
            {
                m_whiteBalanceModes[i] = m_params.getSupportedWhiteBalance().get(i);
            }
        }
    }

    public int[] getSupportedImageResolutions()
    {
        m_imageResolutions = new int[2*m_params.getSupportedPictureSizes().size()];
        for(int i =0;i < m_params.getSupportedPictureSizes().size();i=i+2 )
        {
            Size size = m_params.getSupportedPictureSizes().get(i);
            m_imageResolutions[i] = size.width;
            m_imageResolutions[i+1] = size.height;
        }
        return m_imageResolutions;
    }

    public int[] getSupportedImageFormats()
    {
        m_imageFormats = new int[m_params.getSupportedPictureFormats().size()];
        for(int i =0;i < m_params.getSupportedPictureFormats().size();i++ )
        {
            m_imageFormats[i] = m_params.getSupportedPictureFormats().get(i);
        }
        return m_imageFormats;
    }


    public int getMaxZoom()
    {
        if(m_params.isZoomSupported())
        {
            return m_params.getMaxZoom();
        }
        return 0;
    }

    public int getZoom()
    {
        if(m_params.isZoomSupported())
        {
            return m_params.getZoom();
        }
        return 0;
    }

    public void setZoom(int zoom)
    {
        if(m_params.isZoomSupported())
        {
            m_params.setZoom(zoom);
            m_camera.setParameters(m_params);
        }
    }

    public void setFlashMode(String mode)
    {
        m_params.setFlashMode(mode);
        m_camera.setParameters(m_params);
    }

    public void setWhiteBalanceMode(String mode)
    {
        m_params.setWhiteBalance(mode);
        m_camera.setParameters(m_params);
    }

    public void setImageSettings(int[] settings)
    {
        m_params.setPictureFormat(settings[0]);
        m_params.setPictureSize(settings[1],settings[2]);
        m_camera.setParameters(m_params);
    }

    public void onPreviewFrame(byte[] data, Camera camera) {
        m_width= m_params.getPreviewSize().width;
        m_height = m_params.getPreviewSize().height;
        ByteArrayOutputStream output_stream = new ByteArrayOutputStream();
        YuvImage image =new YuvImage(data,ImageFormat.NV21,m_width,m_height,null);
        image.compressToJpeg(new Rect(0,0,m_width,m_height),60, output_stream);
        Bitmap bitmap = BitmapFactory.decodeByteArray(output_stream.toByteArray(), 0, output_stream.size());
        Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, m_width/2, m_height/2, true);//Optimization of preview data sent
        ByteArrayOutputStream imageStream = new ByteArrayOutputStream();
        scaledBitmap.compress(CompressFormat.JPEG,60, imageStream);
        getPreviewBuffers(imageStream.toByteArray());
    }

    public static native void getImage(byte[] data);
    public static native void getPreviewBuffers(byte[] data);
    public static native void stopRecord();


    public class ScreenReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(Intent.ACTION_SCREEN_OFF))
            {
                if(m_recorder != null)
                {
                    m_recorder.stop();
                    m_recorder.reset();
                    m_recorder.release();
                    m_recorder = null;
                    stopRecord();
                }
                m_screenOff = true;
                QtApplication.mainActivity().unregisterReceiver(this);
            }
        }
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width,
            int height)
    {
        if((m_screenOff == true && m_surfaceDestroyedOff == 2) || m_surfaceDestroyed == true)
        {
            m_camera = QtCamera.getCamera();
            if (m_camera!=null)
            {
                try {
                        m_camera.reconnect();
                } catch (IOException e) {
                        e.printStackTrace();
                }
                m_params = m_camera.getParameters();
                m_params.setPreviewSize(720,480);
                m_camera.setParameters(m_params);
                m_camera.setPreviewCallback(QtCamera.m_previewCallback);
                try {
                    m_camera.setPreviewDisplay(null);
                } catch (IOException e) {
                        e.printStackTrace();
                }
                m_camera.startPreview();
            }
            m_screenOff = false;
            m_surfaceDestroyedOff = 0;
            m_surfaceDestroyed = false;
        }
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
    // TODO Auto-generated method stub

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {

        if(m_screenOff == true)
        {
                m_surfaceDestroyedOff++;
        }
        else
        {
                m_surfaceDestroyed = true;
                if(QtCamera.m_recorder != null)
                {
                        QtCamera.m_recorder.stop();
                        QtCamera.m_recorder.reset();
                        QtCamera.m_recorder.release();
                        QtCamera.m_recorder = null;
                        QtCamera.stopRecord();
                }
        }
    }
}
//@ANDROID-8
