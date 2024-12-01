import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Communications;
import Toybox.Position;

class TrackRelayView extends WatchUi.SimpleDataField {

    private var trackingStatus = "No Started";
    private const enableTracking = Application.Properties.getValue("EnableTracking") as Boolean;
    private const trackingServer = Application.Properties.getValue("TrackingServer") as String;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Tracking Status";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        // Check if activity is in progress.
        if (info.timerState == Activity.TIMER_STATE_ON && trackingServer != null && enableTracking) {
            // Trigger web request when activity is running
            sendTrackingUpdate(info);
            return trackingStatus;
        }
        return "Paused";
    }

    function sendTrackingUpdate(info as Activity.Info) {
        // Prepare payload
        var payload = {
            "type" => System.getDeviceSettings().uniqueIdentifier,
        };

        // Add location
        if (info has :currentLocation && info.currentLocation != null) {
            payload["lat"] = (info.currentLocation).toDegrees()[0];
            payload["lon"] = (info.currentLocation).toDegrees()[1];
        }

        // Add altitude
        if (info has :altitude && info.altitude != null) {
            payload["alt"] = info.altitude;
        }

        // Add elapsed time
        if (info has :elapsedTime && info.elapsedTime != null) {
            payload["time"] = info.elapsedTime;
        }

        // Add elapsed distance
        if (info has :elapsedDistance && info.elapsedDistance != null) {
            payload["dist"] = info.elapsedDistance;
        }

        // Add speed
        if (info has :currentSpeed && info.currentSpeed != null) {
            payload["spd"] = info.currentSpeed;
        }

        // Add cadence
        if (info has :currentCadence && info.currentCadence != null) {
            payload["cad"] = info.currentCadence;
        }

        // Add heartrate
        if (info has :currentHeartRate && info.currentHeartRate != null) {
            payload["hr"] = info.currentHeartRate;
        }

        // Add power
        if (info has :currentPower && info.currentPower != null) {
            payload["pwr"] = info.currentPower;
        }

        // Add total ascent
        if (info has :totalAscent && info.totalAscent != null) {
            payload["asc"] = info.totalAscent;
        }

        // Add total descent
        if (info has :totalDescent && info.totalDescent != null) {
            payload["dec"] = info.totalDescent;
        }

        // Add calories
        if (info has :calories && info.calories != null) {
            payload["cal"] = info.calories;
        }

        // Prepare options for JSON POST request
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
            }
        };

        // Make the web request
        Communications.makeWebRequest(
            trackingServer,
            payload,
            options,
            method(:onReceive)
        );
    }

    function onReceive(responseCode as Number, data as Dictionary or String or Null) as Void {
        if (responseCode == 200) {
            trackingStatus = "Tracking: OK";
        } else {
            trackingStatus = "Error: " + responseCode;
        }
    }

}