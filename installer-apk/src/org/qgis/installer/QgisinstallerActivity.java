package org.qgis.installer;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;
import java.net.URLConnection;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;

public class QgisinstallerActivity extends Activity {
	private static final int DOWNLOAD_DIALOG = 0;
	private static final int PROMPT_INSTALL_DIALOG = 1;
	private static final int NO_CONNECIVITY_DIALOG = 2;
	ProgressDialog mProgressDialog;
	String mUrlString = "http://android.qgis.org/Qgis-debug-latest.apk";
	String mFilePath = Environment.getExternalStorageDirectory() + "/download/qgis.apk";

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		if (isOnline()) {
			showDialog(PROMPT_INSTALL_DIALOG);
		} else {
			showDialog(NO_CONNECIVITY_DIALOG);
		}
	}

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case DOWNLOAD_DIALOG:
			mProgressDialog = new ProgressDialog(QgisinstallerActivity.this);
			mProgressDialog.setMessage("Downloading " + mUrlString);
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.setMax(100);
			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
			return mProgressDialog;

		case PROMPT_INSTALL_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle("Download QGIS package?")
					.setMessage(
							"This will download the latest stable version of QGIS. The download is larger than 70MB, do yo want to continue?")
					.setPositiveButton("Ok",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									new DownloadFile().execute(mUrlString);
								}
							})
					.setNegativeButton("Cancel",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									// Action for 'NO' Button
									QgisinstallerActivity.this.finish();
								}
							}).create();
		case NO_CONNECIVITY_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle("No data connectivity detected")
					.setMessage(
							"Check your connectivity settings and try again")
					.setPositiveButton("Close",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									QgisinstallerActivity.this.finish();
								}
							}).create();
		default:
			return null;
		}
	}

	private boolean isOnline() {
		ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo netInfo = cm.getActiveNetworkInfo();
		if (netInfo != null && netInfo.isConnected()) {
			return true;
		}
		return false;
	}

	private class DownloadFile extends AsyncTask<String, Integer, String> {
		@Override
		protected String doInBackground(String... mUrlString) {
			int count;
			try {
				URL url = new URL(mUrlString[0]);
				URLConnection conexion = url.openConnection();
				conexion.connect();
				// this will be useful so that you can show a tipical 0-100%
				// progress bar
				int lenghtOfFile = conexion.getContentLength();

				// download the file
				InputStream input = new BufferedInputStream(url.openStream());
				OutputStream output = new FileOutputStream(mFilePath);

				byte data[] = new byte[1024];

				long total = 0;

				while ((count = input.read(data)) != -1) {
					total += count;
					// publishing the progress....
					int progress = (int) (total * 100 / lenghtOfFile);
					publishProgress(progress);
					output.write(data, 0, count);
				}

				output.flush();
				output.close();
				input.close();
			} catch (Exception e) {
			}
			return null;
		}

		protected void onPreExecute(){
			showDialog(DOWNLOAD_DIALOG);
		}
		protected void onProgressUpdate(Integer... progress) {
			super.onProgressUpdate(progress);
			mProgressDialog.setProgress(progress[0]);
		}

		protected void onPostExecute(String result) {
			Intent intent = new Intent(Intent.ACTION_VIEW);
			intent.setDataAndType(Uri.fromFile(new File(mFilePath)),
					"application/vnd.android.package-archive");
			startActivity(intent);
			QgisinstallerActivity.this.finish();
		}

	}
}
