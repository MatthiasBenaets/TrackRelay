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
    private const serverAuthorization = Application.Properties.getValue("ServerAuthorization") as String;
    var startElevation = null as Number;
    var startDistance = 0 as Number;
    var lastCalculatedGrade = 0 as Number;

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
            // Set starting altitude
            if (startElevation == null ) {
                startElevation = info.altitude;
            }
            // Send tracking data
            sendTrackingUpdate(info);
            return trackingStatus;
        }
        return "Paused";
    }

    // Computer the current grade
    function computeGrade(info) as Number {
        var currentElevation = info.altitude;
        var currentDistance = info.elapsedDistance;

        // Subtract starting elevation/distance from current elevation/distance
        // By dividing the elevation change with the distance change, the grade is calculated
        if (startDistance != null && currentDistance != null) {
            var distanceChange = currentDistance - startDistance;

            // Check grade every 100 meters
            if (distanceChange >= 100) {
                var elevationChange = currentElevation - startElevation;

                startDistance = currentDistance;
                startElevation = currentElevation;
                lastCalculatedGrade = elevationChange;

                return (elevationChange / distanceChange) * 100;
            }
        }

        // Return last known grade if no update
        return lastCalculatedGrade;
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

        // Add average power
        if (info has :averagePower && info.averagePower != null) {
            payload["avgp"] = info.averagePower;
        }

        // Add total ascent
        if (info has :totalAscent && info.totalAscent != null) {
            payload["asc"] = info.totalAscent;
        }

        // Add total descent
        if (info has :totalDescent && info.totalDescent != null) {
            payload["desc"] = info.totalDescent;
        }

        // Add calories
        if (info has :calories && info.calories != null) {
            payload["cal"] = info.calories;
        }

        // Add grade
        if (info has :altitude && info has :elapsedDistance && info.altitude != null && info.elapsedDistance != null) {
            payload["grd"] = computeGrade(info);
        }

        // Prepare options for JSON POST request
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
                "Authorization" => serverAuthorization
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