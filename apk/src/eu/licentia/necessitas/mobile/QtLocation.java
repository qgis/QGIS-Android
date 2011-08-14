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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import eu.licentia.necessitas.industrius.QtApplication;

import android.app.Activity;
import android.hardware.GeomagneticField;
import android.location.GpsSatellite;
import android.location.GpsStatus;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.location.LocationProvider;
import android.os.Bundle;
import android.util.Log;

class QtSatInfo
{
    @SuppressWarnings("unused")
    private int m_prnNumber;
    @SuppressWarnings("unused")
    private float m_signalStrength;
    @SuppressWarnings("unused")
    private float m_elevation;
    @SuppressWarnings("unused")
    private float m_azimuth;

    public QtSatInfo (int prnNumber,float signalStength,float elevation,float azimuth)
    {
        m_prnNumber=prnNumber;
        m_signalStrength=signalStength;
        m_elevation=elevation;
        m_azimuth=azimuth;
    }
}

public class QtLocation implements LocationListener ,GpsStatus.Listener
{
    private LocationManager m_locationManager;
    private long m_getMinTime;
    private LocationListener m_myself;
    private GpsStatus m_status;
    private static final String GPS=LocationManager.GPS_PROVIDER;
    private static final String NETWORK=LocationManager.NETWORK_PROVIDER;
    private ArrayList<String> m_providerChossenList=new ArrayList<String>();

    public QtLocation ()
    {
        // Get the location manager
        m_locationManager = (LocationManager) QtApplication.mainActivity().getSystemService(Activity.LOCATION_SERVICE);
        m_status = m_locationManager.getGpsStatus(null);
        m_providerChossenList.add(GPS);
        m_providerChossenList.add(NETWORK);
        m_myself=this;
    }

    public double[] lastKnownPosition(int fromSatellitePositioningMethodsOnly)
    {
        double[] getData=new double[7];
        Location location=null;
        Location networkLastLocation=null;
        Location gpsLastLocation=null;
        try
        {
            networkLastLocation=m_locationManager.getLastKnownLocation(GPS);
            gpsLastLocation=m_locationManager.getLastKnownLocation(NETWORK);
            if(fromSatellitePositioningMethodsOnly == 1)
            {
                location=gpsLastLocation;
            }
            else
            {
                location=(networkLastLocation.getTime()>gpsLastLocation.getTime())
                                                    ?networkLastLocation:gpsLastLocation;
            }

            GeomagneticField geomagneticField = new GeomagneticField((float)location.getLatitude(),
                    (float)location.getLongitude(), (float)location.getAltitude(),location.getTime());

            getData[0]=location.getAltitude();
            getData[1]=location.getLatitude();
            getData[2]=location.getLongitude();
            getData[3]=location.getTime();
            getData[4]=geomagneticField.getDeclination();
            getData[5]=location.getSpeed();
            getData[6]=location.getBearing();
        }
        catch(Exception e)
        {
            Log.i("QtLocation","LastknownLocation not available");
        }

        return getData;
    }

    public long supportedPositiongMethods ()
    {
        long supportedPositioningMethods=0;
        List<String> providers=null;
        providers=m_locationManager.getProviders(false);
        Iterator<String> it=providers.iterator();
        while(it.hasNext())
        {
            supportedPositioningMethods|=positioningMethods(it.next());
        }
        return supportedPositioningMethods;
    }

    private long positioningMethods (String provider)
    {
        long positioningMethod=0;
        LocationProvider providerInfo=m_locationManager.getProvider(provider);
        if(providerInfo.requiresSatellite())
        {
            positioningMethod=0x000000ff;//Satellite-based positioning methods such as GPS
        }
        if(providerInfo.requiresCell()||providerInfo.requiresNetwork())
        {
            //0xffffff00 is for other-based positioning methods
            //0xffffffff is for all methods
            positioningMethod|= 0xffffff00;
        }
        return positioningMethod;
    }

    public void requestUpdates(long minTime)
    {
        m_getMinTime=minTime;
        QtApplication.mainActivity().runOnUiThread(new Runnable() {

            public void run() {
                // TODO Auto-generated method stub
                m_locationManager.requestLocationUpdates(GPS, m_getMinTime, 0,m_myself);
                m_locationManager.requestLocationUpdates(NETWORK,m_getMinTime, 0,m_myself);
            }
        });

    }

    public void requestSatelliteUpdates()
    {
        QtApplication.mainActivity().runOnUiThread(new Runnable() {

            public void run() {
                // TODO Auto-generated method stub
                m_locationManager.addGpsStatusListener((GpsStatus.Listener) m_myself);
            }
        });

    }

    public void disableUpdates()
    {
        m_locationManager.removeUpdates(this);
    }

    public void disableSatelliteUpdates ()
    {
        m_locationManager.removeGpsStatusListener(this);
    }

    public void onLocationChanged(Location location)
    {
        // TODO Auto-generated method stub
        double[] getData=new double[8];
        GeomagneticField geomagneticField = new GeomagneticField((float)location.getLatitude(),
                (float)location.getLongitude(), (float)location.getAltitude(),location.getTime());

        getData[0]=location.getLatitude();
        getData[1]=location.getLongitude();
        getData[2]=location.getAltitude();
        getData[3]=location.getTime();
        //these are for attributes
        getData[4]=location.getBearing();//bearing
        getData[5]=location.getSpeed();//ground speed
        getData[6]=geomagneticField.getDeclination();//magnetic dip
        getData[7]=location.getAccuracy();//vertical and horizontal accuracy

        locationDataUpdated(getData,location.getProvider());
    }

    public void onProviderDisabled(String provider) {
    }

    public void onProviderEnabled(String provider) {
    }

    public void onStatusChanged(String provider, int status, Bundle extras) {
    }


    public void onGpsStatusChanged(int event) {

        switch(event)
        {
            case GpsStatus.GPS_EVENT_SATELLITE_STATUS:
                m_locationManager.getGpsStatus(m_status);
                Iterable<GpsSatellite> iSatellite=m_status.getSatellites();
                Iterator<GpsSatellite> iterator=iSatellite.iterator();
                ArrayList<QtSatInfo> satInfo=new ArrayList<QtSatInfo>();
                int index=0;
                while(iterator.hasNext())
                {
                    GpsSatellite gpsSat=iterator.next();

                    satInfo.add(new QtSatInfo(gpsSat.getPrn(),gpsSat.getSnr(),
                            gpsSat.getElevation(), gpsSat.getAzimuth()));
                    index++;
                }

                if(0!=index)
                    gpsSatelliteDataUpdated(satInfo.toArray());
                break;
        }

    }

    public static native void locationDataUpdated(double getData[],String providerName);

    public static native void gpsSatelliteDataUpdated(Object satinfo[]);
}
