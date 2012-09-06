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

import java.io.*;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Timer;
import java.util.TimerTask;

public class MainActivity extends Activity implements LocationListener {
    private Location lastLocation;
    private static final Criteria CRITERIA;

    static {
        CRITERIA = new Criteria();
        CRITERIA.setAccuracy(Criteria.ACCURACY_FINE);
    }

    private static final String HOST = "....";
    private static final int PORT = 11111;
    private static Socket socket;
    private static Timer beatTimer = new Timer();
    private static Timer positionTimer = new Timer();
    private TextView log;


    private static enum MessageType {
        Beat,
        Position,
        Error
    }

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
        log = (TextView) findViewById(R.id.logLabel);

        timeIntervalLabel.setText(getString(R.string. TimeSecIntervalLabelFormat, timeSeekBar.getProgress() + 1));
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
                int seconds = i + 1;
                int minutes = seconds/60;
                int leftSeconds = seconds - minutes*60;
                if(seconds < 60) {
                    timeIntervalLabel.setText(getString(R.string.TimeSecIntervalLabelFormat, seconds));
                }  else {
                    timeIntervalLabel.setText(getString(R.string.TimeMinIntervalLabelFormat, minutes, leftSeconds));
                }
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
                if (!socket.isConnected()) {
                    connectTcpClient();
                }
                beatTimer.schedule(new TimerTask() {
                    @Override
                    public void run() {
                        //do nothing
                    }
                }, 0, 30 * 60 * 1000);
            }
        });

        endButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                timeEndLabel.setText(getString(R.string.TimeEndFormat, System.currentTimeMillis()));
                startButton.setEnabled(true);
                endButton.setEnabled(false);

                disconnectTcpClient();
            }
        });

        connectTcpClient();
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



    private void connectTcpClient() {
        try {
            socket = new Socket(HOST, PORT);

            if (socket.isConnected()) {
                log.setText("Connected to HOST " + socket.getInetAddress().getHostName() + "on PORT " + socket.getPort());
            }
        } catch (UnknownHostException e) {
            log.setText("Can't connect: " + e.getMessage());
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void disconnectTcpClient() {
        try {
            socket.close();
            if (socket.isClosed()) {
                log.setText("Disconnected");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void sendMessage(String message, MessageType type) {
        try {
            BufferedWriter out = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream()));
            //send output msg
            out.write(message);
            out.flush();
            Log.i("TcpClient", "sent: " + message);
            //accept server response
            if (type.equals(MessageType.Beat)) {
                BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                String inMsg = in.readLine() + System.getProperty("line.separator");
                log.setText(inMsg);
                Log.i("TcpClient", "received: " + inMsg);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
