/**
 * FirstRunActivity.java - class needed to copy files from assets to getFilesDir() before starting QtActivity
 * @author  Marco Bernasocchi - <marco@bernawebdesign.ch>
 * @version 0.2
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

package org.kde.necessitas.origo;

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
import android.os.Environment;
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
import java.util.Enumeration;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;

public class FirstRunActivity extends Activity {
	public static final String QtTAG = "FirstRun JAVA"; // string used for Log.x
	// START ASYNC PROGRESSBAR
	static final int PROGRESS_DIALOG = 0;
	static final int QUIT_MESSAGE_DIALOG = 1;
	ProgressThread progressThread;
	ProgressDialog progressDialog;
	String currentFile = "";

	/** Called when the activity is first created. */
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		showDialog(PROGRESS_DIALOG);
		if (null == getLastNonConfigurationInstance()) {
			DisplayMetrics metrics = new DisplayMetrics();
			getWindowManager().getDefaultDisplay().getMetrics(metrics);
			/*
			 * QtApplication.setApplicationDisplayMetrics(metrics.widthPixels,
			 * metrics.heightPixels, metrics.widthPixels, metrics.heightPixels,
			 * metrics.xdpi, metrics.ydpi);
			 */
		}
		requestWindowFeature(Window.FEATURE_NO_TITLE);
	}

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case PROGRESS_DIALOG:
			progressDialog = new ProgressDialog(FirstRunActivity.this);
			progressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			// progressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
			return progressDialog;
		case QUIT_MESSAGE_DIALOG:
			String aliasPath = getFilesDir() + "/storage";
			String storagePath = Environment.getExternalStorageDirectory()
					.getAbsolutePath();

			boolean externalStorageAvailable = false;
			boolean externalStorageWriteable = false;
			String state = Environment.getExternalStorageState();
			if (Environment.MEDIA_MOUNTED.equals(state)) {
				externalStorageAvailable = externalStorageWriteable = true;
			} else if (Environment.MEDIA_MOUNTED_READ_ONLY.equals(state)) {
				externalStorageAvailable = true;
				externalStorageWriteable = false;
			} else {
				externalStorageAvailable = externalStorageWriteable = false;
			}

			try {
				File alias = new File(aliasPath);
				if (externalStorageAvailable && !alias.exists()) {
					if (!externalStorageWriteable) {
						aliasPath = aliasPath + "ReadOnly";
					}
					try {
						String str = "ln -s " + storagePath + " " + aliasPath;
						Process process = Runtime.getRuntime().exec(str);
						Log.i(QtTAG, "Symlinked '" + storagePath + " to "
								+ aliasPath + "'");
					} catch (IOException e) {
						Log.i(QtTAG, "Can't symlink '" + storagePath + " to "
								+ aliasPath + "'", e);
					}
				}
			} catch (SecurityException e) {
				Log.i(QtTAG, "Can't load '" + aliasPath + "'", e);
			}

			return new AlertDialog.Builder(FirstRunActivity.this)
					.setTitle(
							"Done unpacking, you can now start QGIS using its launcher.")
					.setPositiveButton(getString(android.R.string.ok),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									PackageManager pm = getApplicationContext()
											.getPackageManager();

									// remove first run launcher
									pm.setComponentEnabledSetting(
											getComponentName(),
											PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
											0);

									// Intent intent = new Intent();
									// intent.setClass(FirstRunActivity.this,
									// QtActivity.class);
									// startActivity(intent);
									// quit first start
									FirstRunActivity.this.finish();
								}
							}).create();
		default:
			return null;
		}
	}

	@Override
	protected void onPrepareDialog(int id, Dialog dialog) {
		switch (id) {
		case PROGRESS_DIALOG:
			progressDialog.setProgress(0);
			progressThread = new ProgressThread(handler);
			progressThread.start();
		}
	}

	// Define the Handler that receives messages from the thread and update the
	// progress
	final Handler handler = new Handler() {
		public void handleMessage(Message msg) {
			// int total = msg.arg1;
			// progressDialog.setProgress(total);
			if (msg.arg1 == 1) {
				dismissDialog(PROGRESS_DIALOG);
				progressThread.setState(ProgressThread.STATE_DONE);
				showDialog(QUIT_MESSAGE_DIALOG);
				/*
				 * Intent startQtActivity = new Intent(FirstRunActivity.this,
				 * QtActivity.class); startActivity(startQtActivity);
				 */
			} else {
				progressDialog
						.setMessage("Unpacking post install data. This might take a long time.\nUnpacking:\n"
								+ msg.getData().getString("filepath"));
			}
		}
	};

	/** Nested class that performs progress calculations (counting) */
	private class ProgressThread extends Thread {
		Handler mHandler;
		AssetManager assetManager = getAssets();
		final static int STATE_DONE = 0;
		final static int STATE_RUNNING = 1;
		int mState;
		// int total;
		int currentProgress = 0;
		int foldersCount = 0;

		ProgressThread(Handler h) {
			mHandler = h;
		}

		public void run() {
			mState = STATE_RUNNING;
			// total = 0;
			String[] assetDirs = { "share" };
			while (mState == STATE_RUNNING) {
				// TODO update more often
				// extract assets folder to app data directory
				String destFilepath = getFilesDir() + "/share.zip";
				try {
					InputStream in = null;
					OutputStream out = null;
					in = assetManager.open("share.zip");
					out = new FileOutputStream(destFilepath);
					copyFile(in, out);
					in.close();
					in = null;
					out.flush();
					out.close();
					out = null;
					Message msg = mHandler.obtainMessage();
					msg.arg1 = 1;
					mHandler.sendMessage(msg);

				} catch (Exception e) {
					Log.e(QtTAG, "Problem while copying share.zip to "
							+ destFilepath);
					e.printStackTrace();
				}

				// copyAssets(assetDirs);
				// String destFilepath = getFilesDir() + "/" + filepath;
				extractFolder(destFilepath);
				File file = new File(destFilepath);
				file.delete();
			}
		}

		/*
		 * sets the current state for the thread, used to stop the thread
		 */
		public void setState(int state) {
			mState = state;
		}

				 /**
		 * copies a file in a apk dir to a system dir
		 *
		 * @param InputStream
		 * @param OutputStream
		 * @return void
		 */
		 private void copyFile(InputStream in, OutputStream out)
		 throws IOException {
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

		private void extractFolder(String zipFile) {
			try {
				System.out.println(zipFile);
				int BUFFER = 2048;
				File file = new File(zipFile);

				ZipFile zip = new ZipFile(file);
				String newPath = zipFile.substring(0, zipFile.length() - 4);

				new File(newPath).mkdir();
				Enumeration zipFileEntries = zip.entries();

				// Process each entry
				while (zipFileEntries.hasMoreElements()) {
					// grab a zip file entry
					ZipEntry entry = (ZipEntry) zipFileEntries.nextElement();
					String currentEntry = entry.getName();
					File destFile = new File(newPath, currentEntry);
					// destFile = new File(newPath, destFile.getName());
					File destinationParent = destFile.getParentFile();

					// create the parent directory structure if needed
					destinationParent.mkdirs();

					if (!entry.isDirectory()) {
						BufferedInputStream is = new BufferedInputStream(
								zip.getInputStream(entry));
						int currentByte;
						// establish buffer for writing file
						byte data[] = new byte[BUFFER];

						// write the current file to disk
						FileOutputStream fos = new FileOutputStream(destFile);
						BufferedOutputStream dest = new BufferedOutputStream(
								fos, BUFFER);

						// read and write until last byte is encountered
						while ((currentByte = is.read(data, 0, BUFFER)) != -1) {
							dest.write(data, 0, currentByte);
						}
						dest.flush();
						dest.close();
						is.close();
					}

					if (currentEntry.endsWith(".zip")) {
						// found a zip file, try to open
						extractFolder(destFile.getAbsolutePath());
					}
				}
			} catch (IOException e) {
				// Print out the exception that occurred
				System.out.println("Unable to unzip " + zipFile + ": "
						+ e.getMessage());
			}
		}
	}
}
