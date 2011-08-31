/**
* PreStartActivity.java - class needed to copy files from assets to getFilesDir() before starting QtActivity
* @author  Marco Bernasocchi - <marco@bernawebdesign.ch>
* @version 0.1
*/
/*
    Copyright (c) 2011, Marco Bernasocchi <marco@bernawebdesign.ch>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
        * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
        * Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.
        * Neither the name of the  Marco Bernasocchi <marco@bernawebdesign.ch> nor the
        names of its contributors may be used to endorse or promote products
        derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY Marco Bernasocchi <marco@bernawebdesign.ch> ''AS IS'' AND ANY
    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL Marco Bernasocchi <marco@bernawebdesign.ch> BE LIABLE FOR ANY
    DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
    (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package eu.licentia.necessitas.industrius;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.text.method.MetaKeyKeyListener;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;

//needed for createLibsAliases()
import java.io.BufferedOutputStream;
import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.Runtime;
import java.lang.Process;


public class PreStartActivity extends Activity {
	public static final String QtTAG = "PreStart JAVA"; // string used for Log.x
	//START ASYNC PROGRESSBAR
    static final int PROGRESS_DIALOG = 0;
    ProgressThread progressThread;
    ProgressDialog progressDialog;
   
    /** Called when the activity is first created. */
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        
        
        showDialog(PROGRESS_DIALOG);
        
        
        if (null == getLastNonConfigurationInstance())
        {
            DisplayMetrics metrics = new DisplayMetrics();
            getWindowManager().getDefaultDisplay().getMetrics(metrics);
            QtApplication.setApplicationDisplayMetrics(metrics.widthPixels, metrics.heightPixels,
                            metrics.widthPixels, metrics.heightPixels,
                            metrics.xdpi, metrics.ydpi);
        }
        requestWindowFeature(Window.FEATURE_NO_TITLE);
    }
   

    protected Dialog onCreateDialog(int id) {
        switch(id) {
        case PROGRESS_DIALOG:
            progressDialog = new ProgressDialog(PreStartActivity.this);
            progressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
            progressDialog.setMessage("Unpacking post install data. This might a long time.");
            return progressDialog;
        default:
            return null;
        }
    }

    @Override
    protected void onPrepareDialog(int id, Dialog dialog) {
        switch(id) {
        case PROGRESS_DIALOG:
            progressDialog.setProgress(0);
            progressThread = new ProgressThread(handler);
            progressThread.start();
        }
    }

    // Define the Handler that receives messages from the thread and update the progress
    final Handler handler = new Handler() {
        public void handleMessage(Message msg) {
            int total = msg.arg1;
            progressDialog.setProgress(total);
            if (total >= 10){
                dismissDialog(PROGRESS_DIALOG);
                progressThread.setState(ProgressThread.STATE_DONE);
                Intent startQtActivity = new Intent(PreStartActivity.this, QtActivity.class);
                startActivity(startQtActivity);
                finish();//close PreStartActivity
            }
        }
    };

    /** Nested class that performs progress calculations (counting) */
    private class ProgressThread extends Thread {
        Handler mHandler;
        final static int STATE_DONE = 0;
        final static int STATE_RUNNING = 1;
        int mState;
        int total;
       
        ProgressThread(Handler h) {
            mHandler = h;
        }
       
        public void run() {
            mState = STATE_RUNNING;   
            total = 0;
            AssetManager assetManager = getAssets();
            String[] assetDirs = {"share", "test", "test1", "test2"};
            while (mState == STATE_RUNNING) {
            	//TODO update more often
            	// extract assets folder to app data directory
        		for (int i = 0; i < assetDirs.length; i++) {
        			if(newerAssetsVersion(assetManager, assetDirs[i])){
        				copyDir(assetManager, assetDirs[i]);
        			}
        			Message msg = mHandler.obtainMessage();
        			total = 100/assetDirs.length*(i+1);
        			Log.d(QtApplication.QtTAG, "Sending " + total);
                    msg.arg1 = total;
                    mHandler.sendMessage(msg);
        		}
            }
        }
        
        /* sets the current state for the thread,
         * used to stop the thread */
        public void setState(int state) {
            mState = state;
        }
    }
    //END ASYNC PROGRESSBAR
    
    /**
	 * Recursively copies the given top level assets folders to the getFilesDir() directory 
	 * for example maps APK/assets/share/subdir to getFilesDir()/share/subdir
	 * @param dirs      name of the needed top level asset/dir to be copied
	 */
	private void copyAssets(String[] dirs) {
		AssetManager assetManager = getAssets();
		for (String dir : dirs) {
			if(newerAssetsVersion(assetManager, dir)){
				copyDir(assetManager, dir);
			}
		}
	}
    
    /**
	 * copies all files in a apk dir to a system dir
	 * @param AssetManager
	 * @param path
	 * @return void
	 */
	private void copyDir(AssetManager assetManager, String path) {
		//create the needed dir in FilesDir
		File dir = new File(getFilesDir() + "/" + path);
		if (!dir.exists()) {
			dir.mkdirs();
			Log.d(QtApplication.QtTAG, dir.getAbsolutePath() + " folder created");
		} else {
			Log.d(QtApplication.QtTAG, dir.getAbsolutePath() + " folder exists");
		}
		
		//iterate over File list
		String[] files = null;
		try {
			files = assetManager.list(path);
		} catch (IOException e) {
			Log.e(QtTAG, "Asset manager problem: " + e.getMessage());
		}
		for (String filename : files) {
			String filepath = path + "/" + filename;
			String destFilepath = getFilesDir() + "/" + filepath;
			Log.d(QtTAG, "copying " + filepath + " to " + destFilepath);

			if (hasChildren(assetManager, filepath)) {
				Log.d(QtTAG, "DIR FOUND at: " + filepath);
				copyDir(assetManager, filepath);
			} else {
				Log.d(QtTAG, "FILE FOUND at: " + filepath);
				try {
					InputStream in = null;
					OutputStream out = null;
					in = assetManager.open(filepath);
					out = new FileOutputStream(destFilepath);
					copyFile(in, out);
					in.close();
					in = null;
					out.flush();
					out.close();
					out = null;
					
				} catch (Exception e) {
					Log.e(QtTAG, "Problem while copying: " + filepath + " to "
							+ destFilepath);
					e.printStackTrace();
				}
			}
		}
	}

	/**
	 * copies a file in a apk dir to a system dir
	 * @param InputStream
	 * @param OutputStream
	 * @return void
	 */
	private void copyFile(InputStream in, OutputStream out) throws IOException {
		BufferedOutputStream outBuff = new BufferedOutputStream(out);
		BufferedInputStream inBuff = new BufferedInputStream(in);
		byte[] buff = new byte[32 * 1024];
		int len;
		while ((len = inBuff.read(buff)) > 0) {
			outBuff.write(buff, 0, len);
		}
		outBuff.flush();
		outBuff.close();
	}

	private boolean newerAssetsVersion(AssetManager assetManager, String dir) {
		try {
			String versionFilePath = dir + "/version.txt";
			InputStream assetsVersionStream = assetManager.open(versionFilePath);
			String assetsVersion = readTextFile(assetsVersionStream);
			Log.i(QtApplication.QtTAG, "Latest " + dir + " files version: " + assetsVersion);
			
			InputStream installedVersionStream = new FileInputStream(new File(getFilesDir() + "/" + versionFilePath));
			String installedVersion = readTextFile(installedVersionStream);
			Log.i(QtApplication.QtTAG, "Installed " + dir + " files version: " + installedVersion);
			
			if (installedVersion.equals(assetsVersion)){
				Log.i(QtApplication.QtTAG, "No need to copy files from APK to getFilesDir");
				return false;
			}
		} catch (IOException e) {
		    Log.w(QtApplication.QtTAG, e.getMessage());
		        }
		Log.i(QtApplication.QtTAG, "Copying files from APK to getFilesDir");
		return true;
	}
	
	/**
	 * This method reads simple text file
	 * @param inputStream
	 * @return data from file
	 */
	private String readTextFile(InputStream inputStream) {
	    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
	    byte buf[] = new byte[1024];
	    int len;
	    try {
	        while ((len = inputStream.read(buf)) != -1) {
	            outputStream.write(buf, 0, len);
	        }
	        outputStream.close();
	        inputStream.close();
	    } catch (IOException e) {
	    }
	    return outputStream.toString();
	}
	
	/**
	 * Returns if a path has children or not (files and empty directory return false 
	 * @param assetManager      The AssetManager object
	 * @param path              The path to be checked for children
	 * @return                  if has children or not
	 */
	private boolean hasChildren(AssetManager assetManager, String path)
	{
		try {
			if (assetManager.list(path).length > 0){
				return true;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return false;
	}
}
