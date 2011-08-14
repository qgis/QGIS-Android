/*
Copyright (c) 2011 Elektrobit (EB), All rights reserved.
Contact: oss-devel@elektrobit.com

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the Elektrobit (EB) nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY Elektrobit (EB) ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Elektrobit
(EB) BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package eu.licentia.necessitas.mobile;

import java.io.IOException;
import android.media.MediaPlayer;

class QtMediaPlayer implements MediaPlayer.OnCompletionListener,MediaPlayer.OnBufferingUpdateListener
{
    int m_uniqueID;
    private static MediaPlayer m_mediaPlayer=null;


    public QtMediaPlayer(int uniqueID)
    {
        m_uniqueID = uniqueID;
    }

    private int setQtMediaPlayer(String path)
    {
        m_mediaPlayer = new MediaPlayer();
        m_mediaPlayer.setOnBufferingUpdateListener(this);
        m_mediaPlayer.setOnCompletionListener(this);
        m_mediaPlayer.reset();
        try {
            m_mediaPlayer.setDataSource(path);
        } catch (IllegalArgumentException e1) {
            e1.printStackTrace();
        } catch (IllegalStateException e1) {
            e1.printStackTrace();
        } catch (IOException e1) {
            e1.printStackTrace();
        }
        try {
            m_mediaPlayer.prepare();
        } catch (IllegalStateException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return m_mediaPlayer.getDuration();
    }

    private int getCurrentPosition()
    {
        if(m_mediaPlayer==null)
        {
            return 0;
        }
        return m_mediaPlayer.getCurrentPosition();
    }

    private void play()
    {
        if(m_mediaPlayer!=null)
        {
            m_mediaPlayer.start();
        }
    }

    private void pause()
    {
        if(m_mediaPlayer!=null)
        {
            m_mediaPlayer.pause();
        }
    }
    private void stop()
    {
        if(m_mediaPlayer!=null)
        {
            m_mediaPlayer.stop();
        }
    }
    private void seekTo(int mSec)
    {
        if(m_mediaPlayer!=null)
        {
            m_mediaPlayer.seekTo(mSec);
        }
    }
    private void setVolume(float lVolume,float rVolume)
    {
        if(m_mediaPlayer!=null)
        {
            float vol= lVolume/100;
            m_mediaPlayer.setVolume(vol,vol);
        }
    }

    private void resume()
    {
        if(m_mediaPlayer!=null)
        {
            m_mediaPlayer.start();
        }
    }
    private void release()
    {
        if(m_mediaPlayer!=null)
        {
            m_mediaPlayer.release();
        }
    }

    public void onBufferingUpdate(MediaPlayer mp, int percent) {
        bufferProgress(percent,m_uniqueID);
    }

    public void onCompletion(MediaPlayer mp) {
        playCompleted(m_uniqueID);
    }

    public static native void playCompleted(int uniqueID);
    public static native void bufferProgress(int percent,int uniqueID);

}
