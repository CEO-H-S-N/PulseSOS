# 📱 Native OS Permissions Guide

PulseSOS requires specialized high-priority background tracking, location, audio buffering and notifications access. Paste these configurations into respective native directories before compiling.

---

## 🤖 Android Configuration

File location: `pulse_sos/android/app/src/main/AndroidManifest.xml`

### 1. Root manifest tags (Permissions block)
Insert these nodes inside the `<manifest>` tag, above `<application>`:

```xml
<!-- Internet & Network Connectivity -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- GPS Geolocation (Precise and Background tracking) -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

<!-- Background Services and Wakelocks -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<!-- Evidence Buffering & Capture -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />

<!-- High Priority Alerts Vibration -->
<uses-permission android:name="android.permission.VIBRATE" />
```

### 2. Application Node (Foreground Service tag)
Insert this service tag inside the `<application>` node to enable the foreground locator:

```xml
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="location"
    android:exported="false" />
```

---

## 🍎 iOS Configuration

File location: `pulse_sos/ios/Runner/Info.plist`

Insert these string nodes inside the main `<dict>` tag:

```xml
<!-- Geolocation Permissions -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>PulseSOS requires precise geolocation when open to map nearby emergencies and show safety networks.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>PulseSOS requires persistent always-on location to broadcast safety signals and track your route if an SOS is active.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>PulseSOS tracks background location to send coordinates to verified responders in active safety broadcasts.</string>

<!-- Background Services -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>

<!-- Audio & Camera Evidence Buffer -->
<key>NSMicrophoneUsageDescription</key>
<string>PulseSOS accesses the microphone to capture secure audio evidence buffer during active SOS events.</string>
<key>NSCameraUsageDescription</key>
<string>PulseSOS accesses the camera to capture high-priority video evidence streams during emergency activations.</string>
```
