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

import java.io.IOException;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Vibrator;
import android.view.View;
import eu.licentia.necessitas.industrius.QtApplication;

public class QtFeedback extends BroadcastReceiver{
    private static View m_view=null;
    private AudioManager m_audioManager=null;
    private Vibrator m_vibrator=null;
    private int m_vibrateDuration=0;
    private int m_vibrateperiod=0;
    private int m_hapticConstant = 0;
    private MediaPlayer m_mediaPlayer= null;
    private int m_resumeTime=0;
    private AlarmManager m_alarmManager=null;
    private PendingIntent m_pendingIntent=null;

    public QtFeedback() {
        m_alarmManager = (AlarmManager) QtApplication.mainActivity().getSystemService(Activity.ALARM_SERVICE);
        m_mediaPlayer= new MediaPlayer();
        m_mediaPlayer.setLooping(false);
        m_vibrator =(Vibrator) QtApplication.mainActivity().getSystemService(Activity.VIBRATOR_SERVICE);
        m_audioManager = (AudioManager)QtApplication.mainActivity().getSystemService(Activity.AUDIO_SERVICE);
        m_view = QtApplication.mainView();
    }


    public void playThemeEffect(int soundConstant)
    {
        m_audioManager.playSoundEffect(soundConstant);
    }

    public void loadMusicFile(String path)
    {
        m_mediaPlayer.reset();
        try {
            m_mediaPlayer.setDataSource(path);
            m_mediaPlayer.prepare();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (IllegalStateException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }



    public void setFileState(int state)
    {
        switch (state) {
        case 0:
            m_mediaPlayer.pause();
            break;

        case 1:
            m_mediaPlayer.stop();
            try {
                    m_mediaPlayer.prepare();
            } catch (IllegalStateException e) {
                    e.printStackTrace();
            } catch (IOException e) {
                    e.printStackTrace();
            }
            m_mediaPlayer.seekTo(0);
            break;

        case 2:
        case 3:
            m_mediaPlayer.start();
            break;

        default:
            break;
        }
    }

    public void setVibrateState(int state)
    {
        long vibratePattern[] = {0,0,0};
        if(m_vibrateperiod == -1 || m_vibrateperiod == 0)
        {
            if(m_resumeTime == 0)
            {
                long nonPeriodPattern[] = {(long) 0,(long) m_vibrateDuration};
                vibratePattern = nonPeriodPattern;
            }
            else
            {
                long nonPeriodPattern[] = {(long) 0,(long) m_resumeTime};
                vibratePattern = nonPeriodPattern;
            }
        }
        else
        {
            long periodPattern[] = {(long) 0,(long) m_vibrateperiod,(long) m_vibrateperiod};
            vibratePattern = periodPattern;
        }

        switch(state)
        {
        case 0:
        case 1:
                m_vibrator.cancel();
                QtApplication.mainActivity().unregisterReceiver(this);
                break;
        case 2:
        case 3:
            registerReciever();
            if(m_vibrateperiod == -1 || m_vibrateperiod == 0)
            {
                m_vibrator.vibrate(vibratePattern,-1);
            }
            else
            {
                if(m_resumeTime == 0)
                {
                    m_alarmManager.set(AlarmManager.RTC_WAKEUP,(System.currentTimeMillis()+m_vibrateDuration), m_pendingIntent);
                }
                else
                {
                    m_alarmManager.set(AlarmManager.RTC_WAKEUP,(System.currentTimeMillis()+m_resumeTime), m_pendingIntent);
                }
                m_vibrator.vibrate(vibratePattern,0);
            }
        }
    }

    public void setVibraDuration(int duration,int period,int resumeTime)
    {
        m_vibrateDuration = duration;
        m_vibrateperiod = period;
        m_resumeTime = resumeTime;
    }

    public void registerReciever()
    {
        IntentFilter filter = new IntentFilter("Alarm");
        QtApplication.mainActivity().registerReceiver(this , filter);
        Intent intent = new Intent("Alarm");
        m_pendingIntent = PendingIntent.getBroadcast(QtApplication.mainActivity(), 0, intent, 0);
    }

    @Override
    public void onReceive(Context context, Intent intent)
    {
        m_vibrator.cancel();
        QtApplication.mainActivity().unregisterReceiver(this);
    }

    public void setHapticFeedback(boolean enabled)
    {

        final boolean enable = enabled;
        QtApplication.mainActivity().runOnUiThread(new Runnable() {
            public void run() {
                m_view.setHapticFeedbackEnabled(enable);
            }
        });

    }

    public void performHapticFeedback()
    {
        QtApplication.mainActivity().runOnUiThread(new Runnable() {
            public void run() {
                m_view.performHapticFeedback(m_hapticConstant);
            }
        });
    }

    public void setHapticIntensity(int hapticConst)
    {
        m_hapticConstant = hapticConst;
    }
}
