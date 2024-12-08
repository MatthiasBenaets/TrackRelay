# TrackRelay

Track and send live activity data from Garmin device to a remote server.
Works with [TrackRelay-Server](https://github.com/MatthiasBenaets/TrackRelay-Server).

## Payload

`Content-Type: application/json`

```json
{
  "type": "b696f2f3d48d55c34567e416018d7df98cf40840",
  "lat": 51.324,
  "lon": 5.89454,
  "alt": 26.5925,
  "time": 233144916,
  "dist": 51636.3,
  "spd": 9.19073,
  "cad": 170,
  "hr": 148,
  "pwr": 244,
  "avgp": 223,
  "asc": 230.179,
  "desc": 208.382,
  "cal": 1541,
  "grd": -1.0043
}
```

## Properties

- Enable / Disable Tracking
- Tracking Server API URL (https required)
- Server Authorization (optional)

## Disclaimer/Notice

- Requires a device that supports at least 2.4.0. Only tested and built for Enduro 2.
- Do not upload to ConnectIQ as public app!
- No support will be given, period! Especially not on different platforms/devices.
- Not endorsed by Garmin
- Do not use for any commercial purposes!
