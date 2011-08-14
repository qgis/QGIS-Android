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

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.util.Log;
import eu.licentia.necessitas.industrius.QtApplication;

public class QtSensors implements SensorEventListener
{
    private static SensorManager m_SensorManager;
    private Sensor m_Sensor;
    private int m_uniqueId=-1;
    private int m_sensorType;
    private List<Sensor> getListSensor;

    public QtSensors(int uniqueID,int datarate,int sensorType)
    {
        m_uniqueId=uniqueID;
        m_sensorType=sensorType;
        getListSensor=new ArrayList<Sensor>();
        getListSensor=m_SensorManager.getSensorList(m_sensorType);
        if(!getListSensor.isEmpty())
        {
            start(datarate);
        }
        else
        {
            Log.i("QtSensors", "Sensor not avialable");
        }
    }

    private static void registerSensors ()
    {
        m_SensorManager = (SensorManager)QtApplication.mainActivity().getSystemService(Activity.SENSOR_SERVICE);
    }

    private void start (int datarate)
    {
        m_Sensor = m_SensorManager.getDefaultSensor(m_sensorType);
        m_SensorManager.registerListener(this, m_Sensor,datarate);
    }

    public void stop ()
    {
        if(!getListSensor.isEmpty())
        {
            m_SensorManager.unregisterListener(this, m_Sensor);
        }
    }

    public void onSensorChanged(SensorEvent event) {

        if(event.sensor.getType()==Sensor.TYPE_PROXIMITY)
        {
            event.values[0]=(event.values[0]<event.sensor.getMaximumRange())?1:0;
        }
        slotDataAvailable(event.values,event.timestamp,event.accuracy,m_uniqueId);
    }

    public void onAccuracyChanged(Sensor sensor, int accuracy) {
    }

    public static native void slotDataAvailable(float data[],long timeEvent,
            int accuracy,int uniqueID);


}
