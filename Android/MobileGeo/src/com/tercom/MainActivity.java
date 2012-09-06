package com.tercom;

import android.app.Activity;
import android.content.Context;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;

<<<<<<< HEAD
public class MainActivity extends Activity implements LocationListener {
    private Location lastLocation;
    private static final Criteria CRITERIA;

    static {
        CRITERIA = new Criteria();
        CRITERIA.setAccuracy(Criteria.ACCURACY_FINE);
    }
=======
import java.io.*;
import java.net.Socket;
import java.net.UnknownHostException;

public class MainActivity extends Activity {

    private static final String HOST = ".....";
    private static final int PORT = 00000;
>>>>>>> Added simple Tcp request.

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        final Button startButton = (Button) findViewById(R.id.startButton);
        final Button endButton = (Button) findViewById(R.id.endButton);
        SeekBar timeSeekBar = (SeekBar) findViewById(R.id.timeSeekBar);
        final TextView timeIntervalLabel = (TextView) findViewById(R.id.timeIntervalLabel);
        final TextView requestsCountLabel = (TextView) findViewById(R.id.requestsCountLabel);
        final TextView timeStartLabel = (TextView) findViewById(R.id.timeStartLabel);
        final TextView timeEndLabel = (TextView) findViewById(R.id.timeEndLabel);
        final TextView latitudeLabel = (TextView) findViewById(R.id.latitudeLabel);
        final TextView longitudeLabel = (TextView) findViewById(R.id.longitudeLabel);
        final TextView log = (TextView) findViewById(R.id.logLabel);

        timeIntervalLabel.setText(getString(R.string.TimeIntervalLabelFormat, timeSeekBar.getProgress() + 1));
        requestsCountLabel.setText(getString(R.string.RequestsCountLabelDefault));
        timeStartLabel.setText(getString(R.string.TimeStartLabelDefault));
        timeEndLabel.setText(getString(R.string.TimeEndLabelDefault));
        latitudeLabel.setText(getString(R.string.LatitudeLabelDefault));
        longitudeLabel.setText(getString(R.string.LongitudeLabelDefault));

        final LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
        final String provider = locationManager.getBestProvider(CRITERIA, true);
        locationManager.requestLocationUpdates(provider, timeSeekBar.getProgress() + 1, 0, this);

        timeSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                timeIntervalLabel.setText(getString(R.string.TimeIntervalLabelFormat, i + 1));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                // do nothing
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                // do nothing
            }
        });

        startButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                timeStartLabel.setText(getString(R.string.TimeStartFormat, System.currentTimeMillis()));
                timeEndLabel.setText(getString(R.string.TimeEndLabelDefault));
                startButton.setEnabled(false);
                endButton.setEnabled(true);
            }
        });

        endButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                timeEndLabel.setText(getString(R.string.TimeEndFormat, System.currentTimeMillis()));
                startButton.setEnabled(true);
                endButton.setEnabled(false);
            }
        });
        runTcpClient();
    }


    private void runTcpClient() {
        try {
            Socket s = new Socket(HOST, PORT);
            BufferedReader in = new BufferedReader(new InputStreamReader(s.getInputStream()));
            BufferedWriter out = new BufferedWriter(new OutputStreamWriter(s.getOutputStream()));
            //send output msg
            String outMsg = "TCP connecting to " + PORT + System.getProperty("line.separator");
            out.write(outMsg);
            out.flush();
            Log.i("TcpClient", "sent: " + outMsg);
            //accept server response
            String inMsg = in.readLine() + System.getProperty("line.separator");
            Log.i("TcpClient", "received: " + inMsg);
            //close connection
            s.close();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onLocationChanged(Location location) {
        lastLocation = location;
    }

    @Override
    public void onStatusChanged(String s, int i, Bundle bundle) {
        // do nothing
    }

    @Override
    public void onProviderEnabled(String s) {
        // do nothing
    }

    @Override
    public void onProviderDisabled(String s) {
        // do nothing
    }
}
