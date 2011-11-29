/**
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
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;

public class QgisinstallerActivity extends Activity {
	private static final int DOWNLOAD_DIALOG = 0;
	private static final int PROMPT_INSTALL_DIALOG = 1;
	private static final int NO_CONNECIVITY_DIALOG = 2;
	protected DownloadTask mDownloadTask = new DownloadTask();
	protected ProgressDialog mProgressDialog;
	protected String mUrlString = "http://android.qgis.org/download/";
	protected String mFilePath = Environment.getExternalStorageDirectory()
			+ "/download/";
	protected String mVersion = "nightly";

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		final Spinner spinner = (Spinner) findViewById(R.id.spinner);
		ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(
				this, R.array.versions_array,
				android.R.layout.simple_spinner_item);
		adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		spinner.setAdapter(adapter);

		Button installButton = (Button) this.findViewById(R.id.install);
		installButton.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				mVersion = spinner.getSelectedItem().toString();
				String fileName = "qgis-" + mVersion + ".apk";
				mUrlString = mUrlString + fileName;
				mFilePath = mFilePath + fileName;
				if (isOnline()) {
					showDialog(PROMPT_INSTALL_DIALOG);
				} else {
					showDialog(NO_CONNECIVITY_DIALOG);
				}
			}
		});
	}

	public void onDestroy() {
		super.onDestroy();
		mDownloadTask.cancel(true);
	}

	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case DOWNLOAD_DIALOG:
			mProgressDialog = new ProgressDialog(QgisinstallerActivity.this);
			mProgressDialog.setMessage(getString(R.string.downloading_dialog_message) + ": " + mUrlString);
			mProgressDialog.setIndeterminate(false);
			mProgressDialog.setMax(100);
			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
			return mProgressDialog;

		case PROMPT_INSTALL_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle(getString(R.string.install_dialog_title))
					.setMessage(String.format(getString(R.string.install_dialog_message), mVersion))
					.setPositiveButton(getString(android.R.string.ok),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int whichButton) {
									mDownloadTask.execute(mUrlString);
								}
							})
					.setNegativeButton(getString(android.R.string.cancel),
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int id) {
									// Action for 'NO' Button
									dialog.cancel();
								}
							}).create();
		case NO_CONNECIVITY_DIALOG:
			return new AlertDialog.Builder(QgisinstallerActivity.this)
					.setTitle(getString(R.string.no_connectivity_dialog_title))
					.setMessage(getString(R.string.no_connectivity_dialog_message))
					.setPositiveButton(getString(R.string.quit),
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

	private class DownloadTask extends AsyncTask<String, Integer, String> {
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

				while (!isCancelled() && (count = input.read(data)) != -1) {
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

		protected void onPreExecute() {
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
