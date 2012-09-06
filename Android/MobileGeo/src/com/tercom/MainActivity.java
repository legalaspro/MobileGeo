package com.tercom;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;

public class MainActivity extends Activity {
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
        final TextView statusLabel = (TextView) findViewById(R.id.statusLabel);

        timeIntervalLabel.setText(getString(R.string.TimeIntervalLabelFormat, timeSeekBar.getProgress() + 1));
        requestsCountLabel.setText(getString(R.string.RequestsCountLabelDefault));
        timeStartLabel.setText(getString(R.string.TimeStartLabelDefault));
        timeEndLabel.setText(getString(R.string.TimeEndLabelDefault));
        latitudeLabel.setText(getString(R.string.LatitudeLabelDefault));
        longitudeLabel.setText(getString(R.string.LongitudeLabelDefault));
        statusLabel.setText(getString(R.string.StatusLabelDefault));

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
    }
}
