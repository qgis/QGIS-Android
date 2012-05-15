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

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;

public class FirstRunActivity extends Activity {
	public static final String QtTAG = "FirstRun JAVA"; // string used for Log.x
	private static final int PROGRESS_DIALOG = 0;
	private static final int DONE_DIALOG = 1;
	protected UnzipTask mUnzipTask = new UnzipTask();
	protected ProgressDialog mProgressDialog;


	/** Called when the activity is first created. */
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		mUnzipTask.execute("assets/share.zip");
	}

	public void onDestroy() {
		super.onDestroy();
		mUnzipTask.cancel(true);
	}

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case PROGRESS_DIALOG:
			mProgressDialog = new ProgressDialog(FirstRunActivity.this);
			mProgressDialog.setMessage("Unpacking post install data. This might take a long time.");
//			mProgressDialog.setIndeterminate(false);
//			mProgressDialog.setMax(100);
//			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			return mProgressDialog;

		case DONE_DIALOG:
			return new AlertDialog.Builder(FirstRunActivity.this)
					.setTitle(
							"Done unpacking, you can now start QGIS using its launcher.")
					.setPositiveButton(getString(android.R.string.ok),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {

									Intent intent = new Intent();
									intent.setClass(FirstRunActivity.this, QtActivity.class);
									startActivity(intent);
									// quit first start
									// remove first run launcher
									getApplicationContext().getPackageManager().setComponentEnabledSetting(
											getComponentName(),
											PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
											0);
									FirstRunActivity.this.finish();

								}
							}).create();
		default:
			return null;
		}
	}

	private class UnzipTask extends AsyncTask<String, Integer, String> {
		protected String doInBackground(String... urlString) {
			try {
				String apkFile = getApplicationContext().getPackageManager().getApplicationInfo(getApplicationContext()
						.getPackageName(), 0).sourceDir;
				extractFolder(apkFile);
//				ZipEntry entry = zipFile.getEntry(urlString[0]);
//				InputStream myInput = zipFile.getInputStream(entry);
//				File file = null;
//				FileOutputStream myOutput = new FileOutputStream(file);
//				byte[] buffer = new byte[1024 * 4];
//				int length;
//				int total = 0;
//				int counter = 1;
//				while ((length = myInput.read(buffer)) > 0) {
//					total += length;
//					counter++;
//					if (counter % 32 == 0) {
//						publishProgress(total);
//					}
//					myOutput.write(buffer, 0, length);
//				}
//
			} catch (Exception e) {
			}
			
			return null;
		}
		
		private void extractFolder(String zipFile) {
			try {
				int BUFFER = 2048;

				ZipFile zip = new ZipFile(zipFile);
				String newPath = getFilesDir().toString(); //+ "/" + zipFile.substring(0, zipFile.length() - 4);

				new File(newPath).mkdir();
				Enumeration zipFileEntries = zip.entries();

				// Process each entry
				while (zipFileEntries.hasMoreElements()) {
					// grab a zip file entry
					ZipEntry entry = (ZipEntry) zipFileEntries.nextElement();
					String currentEntry = entry.getName();
					if (currentEntry.startsWith("share/", 0) || currentEntry.equals("assets/share.zip") ){
						File destFile = new File(newPath, currentEntry);
						Log.i("UNZIPPING", currentEntry);
						Log.i("TO", destFile.getAbsolutePath());
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
					else{
						Log.i("SKIPPING", currentEntry);
					}
				}
			} catch (IOException e) {
				// Print out the exception that occurred
				System.out.println("Unable to unzip " + zipFile + ": "
						+ e.getMessage());
			}
		}

		protected void onPreExecute() {
			showDialog(PROGRESS_DIALOG);
			// create symlink
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
						String cmd = "ln -s " + storagePath + " " + aliasPath;
						Process process = Runtime.getRuntime().exec(cmd);
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
		}

		protected void onProgressUpdate(Integer... progress) {
			super.onProgressUpdate(progress);
			mProgressDialog.setProgress(progress[0]);
		}

		protected void onPostExecute(String result) {
			showDialog(DONE_DIALOG);
		}

	}
}
