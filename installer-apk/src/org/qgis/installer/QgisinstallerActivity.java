/**
 * @author  Marco Bernasocchi - <marco@bernawebdesign.ch>
 * @version 0.5
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

package org.qgis.installer;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.InvocationTargetException;
import java.math.BigInteger;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.security.MessageDigest;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

public class QgisinstallerActivity extends Activity {
	private static final int PROGRESS_DIALOG = 0;
	private static final int PROMPT_INSTALL_DIALOG = 1;
	private static final int NO_CONNECIVITY_DIALOG = 2;
	private static final int ABOUT_DIALOG = 3;
	private static final int DOWNLOAD_ERROR_DIALOG = 4;
	private static final int LATEST_IS_INSTALLED_DIALOG = 5;
	private static final int LOADING_INFO_DIALOG = 6;
	private static final int BYTE_TO_MEGABYTE = 1024 * 1024;

	protected DownloadApkTask mDownloadApkTask;
	protected DownloadVersionInfoTask mDownloadVersionInfoTask;
	protected ProgressDialog mProgressDialog;

	protected int mSize;
	protected String mMD5;
	protected int mVersion;
	protected String mVersionName;
	protected String mABI;
	protected String mApkFileName;
	protected String mApkUrl;
	protected String mFilePath;
	private String mFilePathBase;
	private String mLastMethod;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		final Button aboutButton = (Button) findViewById(R.id.aboutButton);
		aboutButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				about();
			}
		});

		final Button donateButton = (Button) findViewById(R.id.donateButton);
		donateButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				donate();
			}
		});

		final Button quitButton = (Button) findViewById(R.id.quitButton);
		quitButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				finish();
			}
		});

		final Button installButton = (Button) findViewById(R.id.installButton);
		installButton.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				run();
			}
		});
	}

	private void run() {
		if (isOnline("run")) {
			initVars();
			mDownloadVersionInfoTask = null;
			mDownloadVersionInfoTask = new DownloadVersionInfoTask();
			mDownloadVersionInfoTask.execute();
		}
	}

	private void downloadApk() {
		if (isOnline("downloadApk")) {
			mDownloadApkTask = null;
			mDownloadApkTask = new DownloadApkTask();
			mDownloadApkTask.execute(mApkUrl);
		}
	}

	private boolean latestIsInstalled() {
		Version v = getVersion("org.qgis.qgis");
		if (v == null) {
			Log.i("VERSION", "No org.qgis.qgis package found on device");
			Log.i("VERSION", "Installable org.qgis.qgis package version: "
					+ Integer.toString(mVersion));
			return false;
		} else {
			if (v.value >= mVersion) {
				Log.i("VERSION", "NO NEW org.qgis.qgis package available.");
				Log.i("VERSION", "Installed org.qgis.qgis package version: "
						+ Integer.toString(v.value));
				Log.i("VERSION", "Latest org.qgis.qgis package version: "
						+ Integer.toString(mVersion));
				return true;
			} else {
				Log.i("VERSION", "NEW org.qgis.qgis package available.");
				Log.i("VERSION", "Installable org.qgis.qgis package version: "
						+ Integer.toString(mVersion));
				Log.i("VERSION", "Installed org.qgis.qgis package version: "
						+ Integer.toString(v.value));
				return false;
			}
		}
	}

	private void donate() {
		if (isOnline("donate")) {
			String url = "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WPQHFA6UP3PS8";
			Intent i = new Intent(Intent.ACTION_VIEW);
			i.setData(Uri.parse(url));
			startActivity(i);
		}
	}

	private void about() {
		showDialog(ABOUT_DIALOG);
	}

	private void visitOpenGis() {
		if (isOnline("visitOpenGis")) {
			String url = "http://www.opengis.ch/android-gis/";
			Intent i = new Intent(Intent.ACTION_VIEW);
			i.setData(Uri.parse(url));
			startActivity(i);
		}
	}

	private void retryLastMethod() {
		// use reflection to recall the last method
		java.lang.reflect.Method method = null;
		try {
			method = this.getClass().getDeclaredMethod(mLastMethod);
		} catch (SecurityException e) {
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			e.printStackTrace();
		}
		try {
			method.invoke(this);
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			e.printStackTrace();
		}
	}

	private boolean isOnline(String callerMethod) {
		mLastMethod = callerMethod;
		ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo netInfo = cm.getActiveNetworkInfo();
		if (netInfo != null && netInfo.isConnected()) {
			return true;
		}
		showDialog(NO_CONNECIVITY_DIALOG);
		return false;
	}

	private void initVars() {
		Version v = getVersion("org.qgis.installer");
		mVersion = v.value;
		mVersionName = v.name;
		mABI = "armeabi"; // TODO: use android.os.Build.CPU_ABI;

		mApkFileName = "qgis-" + mVersion + "-" + mABI + ".apk";
		mApkUrl = "http://android.qgis.org/download/apk/" + mApkFileName;
		mFilePathBase = getExternalFilesDir(null) + "/downloaded_apk/";
		mFilePath = mFilePathBase + mApkFileName;
		new File(mFilePathBase).mkdir();
		Log.i("QGIS Downloader", "Downloading to " + mFilePath);
	}

	private Version getVersion(String packageName) {
		try {
			PackageInfo pi = getPackageManager().getPackageInfo(packageName, 0);
			Version version = new Version(pi.versionName, pi.versionCode);
			return version;
		} catch (NameNotFoundException e) {
			Log.i("VERSION", "Package " + packageName + " NOT FOUND");
		}
		return null;
	}

	private class Version {
		private String name;
		private int value;

		public Version(String name, int value) {
			this.name = name;
			this.value = value;
		}
	}

	private final static String getMD5(File f) throws Exception {
		MessageDigest m = MessageDigest.getInstance("MD5");

		byte[] buf = new byte[65536];
		int num_read;

		InputStream in = new BufferedInputStream(new FileInputStream(f));

		while ((num_read = in.read(buf)) != -1) {
			m.update(buf, 0, num_read);
		}

		String result = new BigInteger(1, m.digest()).toString(16);

		// pad with zeros if until it's 32 chars long.
		if (result.length() < 32) {
			StringBuffer padding = new StringBuffer();
			int paddingSize = 32 - result.length();
			for (int i = 0; i < paddingSize; i++)
				padding.append("0");

			result = padding.toString() + result;
		}

		return result;
	}

	public void onDestroy() {
		super.onDestroy();
		if (mDownloadVersionInfoTask != null) {
			mDownloadVersionInfoTask.cancel(true);
		}
		if (mDownloadApkTask != null) {
			mDownloadApkTask.cancel(true);
		}
	}

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case PROGRESS_DIALOG:
			mProgressDialog = new ProgressDialog(QgisinstallerActivity.this);
			mProgressDialog
					.setMessage(getString(R.string.downloading_dialog_message)
							+ ": " + mApkUrl);
			// add cancel button
			mProgressDialog.setCancelable(true);
			mProgressDialog.setButton(DialogInterface.BUTTON_NEGATIVE,
					getString(android.R.string.cancel),
					new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int id) {
							dialog.cancel();
						}
					});
			// cancel download task oncancel (back button and cancel button)
			mProgressDialog
					.setOnCancelListener(new DialogInterface.OnCancelListener() {
						public void onCancel(DialogInterface dialog) {
							mDownloadApkTask.cancel(true);
						}
					});

			mProgressDialog.setIndeterminate(false);
			mProgressDialog.setMax(mSize);
			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
			return mProgressDialog;

		case PROMPT_INSTALL_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle(getString(R.string.install_dialog_title))
					.setMessage(
							String.format(
									getString(R.string.install_dialog_message),
									mVersionName, mVersion,
									Math.round(mSize / BYTE_TO_MEGABYTE)))
					.setPositiveButton(getString(android.R.string.yes),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									downloadApk();
								}
							})
					.setNegativeButton(getString(R.string.quit),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									// Action for 'NO' Button
									finish();
								}
							})
					.setNeutralButton(getString(android.R.string.no),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									// Action for 'NO' Button
									dialog.cancel();
								}
							}).create();
		case LOADING_INFO_DIALOG:
			ProgressDialog d;
			d = new ProgressDialog(QgisinstallerActivity.this);
			d.setTitle(getString(R.string.please_wait) );
			d.setMessage(getString(R.string.loading_info_dialog_message) );
			d.setIndeterminate(false);
			d.setProgressStyle(ProgressDialog.STYLE_SPINNER);
			return d;

		case NO_CONNECIVITY_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle(getString(R.string.no_connectivity_dialog_title))
					.setMessage(
							getString(R.string.no_connectivity_dialog_message))
					.setPositiveButton(R.string.retry,
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									removeDialog(NO_CONNECIVITY_DIALOG);
									retryLastMethod();
								}
							})
					.setNegativeButton(getString(android.R.string.cancel),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									dialog.cancel();
								}
							})
					.setNeutralButton(getString(R.string.wifi_settings),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									Intent openWirelessSettings = new Intent(
											"android.settings.WIFI_SETTINGS");
									startActivity(openWirelessSettings);
								}
							}).create();

		case ABOUT_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle(getString(R.string.app_name))
					.setMessage(getString(R.string.about_dialog_message))
					.setNegativeButton(getString(android.R.string.cancel),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									dialog.cancel();
								}
							})
					.setNeutralButton(getString(R.string.visit_dev),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									visitOpenGis();
								}
							}).create();

		case DOWNLOAD_ERROR_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle(getString(R.string.app_name))
					.setMessage(getString(R.string.md5_error))
					// getString(R.string.about_dialog_message))
					.setPositiveButton(R.string.retry,
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									removeDialog(DOWNLOAD_ERROR_DIALOG);
									downloadApk();
								}
							})
					.setNegativeButton(getString(android.R.string.cancel),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									dialog.cancel();
								}
							}).create();

		case LATEST_IS_INSTALLED_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle(getString(R.string.app_name))
					.setMessage(
							getString(R.string.latest_is_already_installed_dialog_message))
					.setNegativeButton(getString(android.R.string.cancel),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									dialog.cancel();
								}
							})
					.setNeutralButton(getString(R.string.start_qgis),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									Intent LaunchQGIS = getPackageManager()
											.getLaunchIntentForPackage(
													"org.qgis.qgis");
									startActivity(LaunchQGIS);
								}
							}).create();
		default:
			return null;
		}
	}

	private class DownloadVersionInfoTask extends
			AsyncTask<Void, Integer, String> {
		protected String doInBackground(Void... unused) {
			try {
				URL apkUrl = new URL(mApkUrl);
				URLConnection akpConnection = apkUrl.openConnection();
				akpConnection.connect();
				mSize = akpConnection.getContentLength();
				Log.i("QGIS Downloader", "APK is " + String.valueOf(mSize)
						+ " bytes");

				URL md5Url = new URL(mApkUrl + ".md5");
				URLConnection md5Connection = md5Url.openConnection();
				md5Connection.connect();

				// download the info file
				BufferedReader in = new BufferedReader(new InputStreamReader(
						md5Url.openStream()));
				String str;
				while ((str = in.readLine()) != null) {
					mMD5 = str.substring(0, 32);
				}

				in.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		protected void onPreExecute() {
			showDialog(LOADING_INFO_DIALOG);
		}

		protected void onPostExecute(String result) {
			removeDialog(LOADING_INFO_DIALOG);
			if (latestIsInstalled()) {
				showDialog(LATEST_IS_INSTALLED_DIALOG);
			} else {
				showDialog(PROMPT_INSTALL_DIALOG);
			}
		}
	}

	private class DownloadApkTask extends AsyncTask<String, Integer, String> {
		private String mDigest;
		private String mLastModified;

		@Override
		protected String doInBackground(String... mUrlBaseString) {
			try {
				int downloaded = 0;
				URL url = new URL(mUrlBaseString[0]);
				HttpURLConnection connection = (HttpURLConnection) url
						.openConnection();

				connection.setDoInput(true);
				connection.setDoOutput(true);

				File file = new File(mFilePath);
				if (file.exists()) {
					downloaded = (int) file.length();
					connection.setRequestProperty("Range", "bytes="
							+ downloaded + "-");

					connection.setRequestProperty("If-Range", mLastModified);
					Log.d("AsyncDownloadFile", "new download seek: "
							+ downloaded + "; lengthFile: " + mSize);
				}

				Map<String, List<String>> map = connection.getHeaderFields();
				Log.d("AsyncDownloadFile", "header fields: " + map.toString());

				BufferedInputStream in = new BufferedInputStream(
						connection.getInputStream());
				FileOutputStream fos = (downloaded == 0) ? new FileOutputStream(
						mFilePath) : new FileOutputStream(mFilePath, true);
				BufferedOutputStream output = new BufferedOutputStream(fos,
						1024);
				byte data[] = new byte[1024];

				int count;
				while (!isCancelled() && (count = in.read(data)) != -1) {
					downloaded += count;
					// publishing the progress....
					publishProgress(downloaded);
					output.write(data, 0, count);
				}
				output.flush();
				output.close();
				in.close();
			} catch (IOException e) {
				e.printStackTrace();
			}

			return null;
		}

		protected void onPreExecute() {
			showDialog(PROGRESS_DIALOG);
		}

		protected void onProgressUpdate(Integer... progress) {
			super.onProgressUpdate(progress);
			mProgressDialog.setProgress(progress[0]);
		}

		protected void onPostExecute(String result) {
			removeDialog(PROGRESS_DIALOG);
			try {
				mDigest = getMD5(new File(mFilePath));
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			Log.i("MD5 check", "correct MD5: " + mMD5);
			Log.i("MD5 check", "calculated MD5: " + mDigest);
			if (mMD5.equals(mDigest)) {
				Intent intent = new Intent(Intent.ACTION_VIEW);
				intent.setDataAndType(Uri.fromFile(new File(mFilePath)),
						"application/vnd.android.package-archive");
				startActivity(intent);
			} else {
				showDialog(DOWNLOAD_ERROR_DIALOG);
			}
		}
	}
}
