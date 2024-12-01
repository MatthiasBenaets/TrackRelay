import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Communications;
import Toybox.Position;

class TrackRelayView extends WatchUi.SimpleDataField {

    private var trackingStatus = "No Started";
    private const trackingServer = "";

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
        if (info.timerState == Activity.TIMER_STATE_ON) {
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