# CascableCore 5.1

### Support for Sony a7R III, a9, etc

CascableCore now supports newer Sony cameras that don't support the "Smart Remote Control" on-camera app, including the a7R III, a9, etc. Unfortunately, these cameras are missing a number of properties compared to other Sony cameras and don't support access to the camera's storage. [CBC-145]


### Support for decoding camera-generated QR codes.

The new `CBLCameraQRDecoding` class contains logic for decoding the strings contained in Sony, Olympus and Panasonic QR codes. [CBL-862]


### Bug Fixes

- Improvements to `CBLCameraDiscovery` to improve reliability. [CBC-142]

- Fixed an issue that could cause Shot Preview deliveries to fail on Canon cameras with multiple in-use storage slots. [CBC-146]

- Fixed an issue that would cause `validSettableValuesForProperty:` to incorrectly return no valid values for `CBLPropertyIdentifierAperture` on Fuji cameras. [CBC-143]

- Internal work to live view streaming in Fuji cameras to try to prevent memory corruption issues in certain conditions. [CBC-138]


# CascableCore 5.0.2

### Bug Fixes

- Fixed an issue that would cause Fuji cameras to freeze when switching from `CBLCameraAvailableCommandCategoryFilesystemAccess` to `CBLCameraAvailableCommandCategoryRemoteShooting` when live view was never enabled in the previous `CBLCameraAvailableCommandCategoryRemoteShooting`  period. [CBC-144]


# CascableCore 5.0.1

### Bug Fixes

- Fixed an issue that could cause Nikon cameras to deliver `nil` frames to the live view frame delivery callback. [CBC-141]


# CascableCore 5.0

### New Live View API

The API for working with Live View has changed for all cameras. The new API is designed to allow greater flexibility and better behaviour when processing live view image frames, particularly in situations where the camera is delivering frames faster than your image processing pipeline can deal with them. [CBC-115]

The new API will provide live view frames on the queue you pass, allowing you to process frames on background queue. The supplied completion callback signals that you're ready for the next frame, and can be called from any queue — you can process the frames in the background, render them on the main queue, then call the completion handler to get the next frame.

The new API also removes `CBLCameraLiveViewUpdateFrequency` and the `liveViewUpdateFrequency` property, which only had an effect on Canon and Nikon cameras. If you wish to throttle live view frames for performance reasons, you can simply defer calling a frame delivery's completion handler. This works for all cameras, and allows you to tailor the frame rate for your application.

To start live view, make sure the camera has the `CBLCameraAvailableCommandCategoryRemoteShooting` command category available, then enable as so:

```
CBLCameraLiveViewFrameDelivery delivery = ^(id<CBLCameraLiveViewFrame> frame, dispatch_block_t completionHandler) {
    // This will be called for each frame being delivered.
    [self processAndDisplayFrame:frame];

    // The completion handler *must* be called in order to get the next frame.
    completionHandler();
};

[self.camera beginLiveViewStreamWithDelivery:delivery
                               deliveryQueue:dispatch_get_main_queue()
                          terminationHandler:^(CBLCameraLiveViewTerminationReason reason, NSError *error) {

    // This will be called when live view ends either normally or because of an error.
    if (reason == CBLCameraLiveViewTerminationReasonFailed) {
        [self displayLiveViewFailedDialogWithError:error];
    }
}];
```

To end live view:

```
// This will cause the termination handler given to beginLiveViewStream… to be called with the termination
// reason of CBLCameraLiveViewTerminationReasonEndedNormally.
[self.camera endLiveViewStream];
```

### Direct Focus Manipulation

Added `driveFocusByAmount:inDirection:completionCallback:` to `id <CBLCamera>`. Requires the `CBLCameraDirectFocusManipulationFunctionality` functionality flag, which is currently only available on Canon and Nikon cameras due to protocol limitations on the other manufacturers. [CBC-136]

Using `driveFocusByAmount:inDirection:completionCallback:` allows you to move the focus point of the connected lens towards the camera or towards infinity by a small, medium, or large amount. This API requires that live view is active, and that the camera's focus mode is NOT set to MF.

When triggering the shutter after using this API, ensure you don't trigger autofocus to undo the user's work.

### Power Off On Disconnect

Added `disconnectWithFlags:completionCallback:callbackQueue:` to `id <CBLCamera>`. If you pass the flag `CBLDisconnectionFlagPowerOffCamera` set to `YES` and the camera supports the functionality `CBLCameraPowerOffOnDisconnectFunctionality`, the camera will power down as part of the disconnection procedure. [CBC-1]

`CBLDisconnectionFlagPowerOffCamera` is currently only supported on Olympus cameras.

### Other Additions

 Fujifilm, Olympus, and Panasonic cameras now all support `CBLCameraHalfShutterPressFunctionality`, and you can call `engageAutoFocus:` and `disengageAutoFocus:` on them. For cameras that don't support "half press shutter" commands, `CascableCore` will fall back to using `touchAFAtPoint:callback:` with either the last point passed to `touchAFAtPoint:callback:`, or the centre of the frame. [CBC-49]

If you were previously checking for `CBLCameraHalfShutterPressFunctionality` and either performing `engageAutoFocus:` or `touchAFAtPoint:callback:` depending on the result, you should now be able to remove that check and exclusively use `engageAutoFocus:`/`disengageAutoFocus:`  unless you have a particular point you wish to focus on.

### Bug Fixes

New instances of `id <CBLPropertyProxy>` no longer return `nil` for the `localizedDisplayValue` property for certain property identifiers on Fujifilm and Panasonic cameras. [CBC-137]

Sony cameras no longer permanently set their `storageDevices` property to `nil` when encountering a timeout or other transient error when switching to `CBLCameraAvailableCommandCategoryFilesystemAccess`. Additionally, timeouts for these switches have been increased. [CBC-133]


# CascableCore 4.2.1

### Changes

- Moved `StopKit` to an external dependency.


# CascableCore 4.2

### Licensing Changes

CascableCore licenses are no longer baked into your binary. Instead, CascableCore releases can be downloaded from the [CascableCore Binaries](https://github.com/Cascable/cascablecore-binaries) repo on GitHub, and your license is applied at runtime. You can download your license from the [Cascable Developer Portal](https://developer.cascable.se/). [CBC-103]

### Bug Fixes

- Extra hardening against a rare crash related to cameras that use PTP. [CBC-110]


# CascableCore 4.1.2

### Additions

Added a new notification: `CBLWiFiConnectivityDidChangeNotificationName`, which will always be delivered on the main queue. This notification will be posted when device WiFi reachability changes (like the standard reachability code supplied by Apple), but also when the device changes WiFi networks without triggering a reachability change - for example, when a camera is turned off and the device falls back to another available network.

### Bug Fixes

- Fixed a crash caused by Reachability. [CBC-129, CBC-131]

- Fixes for various reported crashes. [CBC-130, CBC-127, CBC-126, CBC-122, CBC-121, CBC-119, CBC-113, CBC-112, CBC-111, CBC-110]


# CascableCore 4.1.1

### Bug Fixes

- Explicitly support the Canon EOS M100 (no real code changes from 4.1.0). [CBC-113]

- Fixed a minor model name parsing issue with the Olympus E-M10 III. [CBC-116]


# CascableCore 4.1.0

### Additions

Added a new functionality flag: `CBLCameraLimitedRemoteControlWithoutLiveViewFunctionality`, which is currently only used for the Canon EOS 1300D. Cameras that contain this functionality flag will only guarantee that they are able to take "simple" shots while live view is disabled. [CBC-100]

Cameras that use this flag have *some* control functionality while live view is disabled, but not enough for them to be considered by CascableCore as fully controllable. In the case of the 1300D:

- `engageAutoFocus:` and `disengageAutoFocus:` will throw errors.
- Bulb exposures are not supported.
- Values for some properties may become read-only.

Cameras may change the values of their `supportedFunctionality` properties when live view is disabled to reflect this reduced functionality state. It's important to react accordingly for the best user experience — apps may, for example, remove autofocus UI from view when cameras remove their `CBLCameraHalfShutterPressFunctionality` functionality flag when live view is disabled.

### Bug Fixes

- Fixed a number of crashes triggered when parsing malformed data. [CBC-106, CBC-105, CBC-104]

- Sony cameras will no longer appear multiple times in the `cameras` property of `CBLCameraDiscovery`. [CBC-108]

- CascableCore will now correctly fail to connect (with error code `CBLErrorCodeCameraNeedsSoftwareUpdate`) to newer Sony cameras that don't have Smart Remote Control installed. Previously, the connection would succeed but live view would fail to start. [CBC-109]


# CascableCore 4.0.2

### Bug Fixes

- Improvements to the internal class `CBLPTPIPQueue` to reduce crashes. [CBC-101]


# CascableCore 4.0.1

### Bug Fixes

- Shot previews no longer require storage folders to be loaded to fire correctly on Canon and Nikon cameras. [CBL-677]

- `-invokeOneShotShutterExplicitlyEngagingAutoFocus:completionCallback:` now works correctly when passing `YES` to the `triggerAutoFocus` parameter. [CBC-96]

- Fixed a connection failure that would occur when the `CBLConnectionFlagSyncCameraClockToSystemClock` connection flag was set to `YES` on a small number of Canon cameras (mainly EOS M models). [CBC-95]


# CascableCore 4.0

### API Changes

- Added a `clientName` parameter to `id <CBLCamera>`'s connection method:
    - `-connectWithClientName:completionCallback:userInterventionCallback:`

- Added an optional `connectionFlags:` parameter to `id <CBLCamera>`'s connection method. You can pass the value `@YES` for the `CBLConnectionFlagSyncCameraClockToSystemClock` key to have CascableCore attempt to sync the camera's clock to the system clock on connection.
    -  `-connectWithClientName:connectionFlags:completionCallback:userInterventionCallback:`

- Added `CBLCameraConnectionWarningCategoryMisc`, `CBLCameraConnectionWarningTypeClockSyncFailed`, and `CBLCameraConnectionWarningTypeClockSyncNotSupported` values to the connection warning system. If you pass the value `@YES` for the `CBLConnectionFlagSyncCameraClockToSystemClock` connection flag and the camera doesn't support camera clock sync, or does but fails to do so, a connection warning will be generated with these values.

- Renamed properties on `id <CBLCameraDiscoveryService>` to bring them in line with `id <CBLDeviceInfo>`:
    - `modelName` is now `model`.
    - `cameraSerialNumber` is now `serialNumber`.

- `CBLPropertyProxy` is now a protocol (`id <CBLPropertyProxy>`) instead of an empty base class.

- Added the following values to `CBLAFSytem`:
    - `CBLAFSystemSinglePoint`
    - `CBLAFSystemSinglePointTracking`
    - `CBLAFSystemPanasonicCustomMultipleAreas`

- Added the following values to `CBLFocusMode`: 
    - `CBLFocusModeSingleAFWithRefocusing`

- Added the following values to `CBLWhiteBalance`:
    - `CBLWhiteBalanceCustom4`

- Replaced the Sony-specific fluorescent white balance in favour of generic equivalents:
    - `CBLWhiteBalanceSonyFluorescentWarm` -> `CBLWhiteBalanceFluorescentWarm`
    - `CBLWhiteBalanceSonyFluorescentWhite`, -> `CBLWhiteBalanceFluorescentWhite`
    - `CBLWhiteBalanceSonyFluorescentDaylight ` -> `CBLWhiteBalanceFluorescentDaylight`

- Added the following values to `CBLColorTone`:
    - `CBLColorToneNone`
    - `CBLColorToneSepia`
    - `CBLColorToneSoftPortrait`
    - `CBLColorToneMonotoneYellowFilter`
    - `CBLColorToneMonotoneRedFilter`
    - `CBLColorToneMonotoneGreenFilter`
    - `CBLColorToneFujiClassicChrome`

- Added `CBLExifHelpers` and `CBLImageManipulationHelpers`.

- Added `+[CBLNetworkConfigurationHelper ssidOfInterface:]`.

- `CBLPropertyIdentifierEVFOutputDevice` and `CBLEVFDestination` have been removed. Use the `liveViewEnabled` property on `id <CBLCamera>` to determine live view status.

- `-[id <CBLCamera> setLiveViewEnabled:displayOnDeviceScreen:callback:]` has been renamed to `-[id <CBLCamera> setLiveViewEnabled:callback:]`.

- Added `-[id <CBLCamera> updateClockTo:callback:]` for setting the system clock on supported cameras.

- Added `-[id <CBLCamera> setLiveViewZoomLevel:callback:]` for setting the camera's live view zoom level on supported cameras.

- Added `CBLCameraUpdateClockFunctionality` and `CBLCameraZoomableLiveViewFunctionality` functionality flags.

- Improved some legacy APIs on `id <CBLCameraLiveViewFrame>` and improved documentation on others.

- The filesystem observation API has changed. When adding an observer to an `id <CBLFileStorage>` object, a token is returned. That token is then used to remove the observer with the new `-removeFileSystemObserverWithToken:` method. `-removeFileSystemObserver:` has been removed. 

- Observation of camera properties and valid settable values has changed in the same way as filesystem observation.

- Observation of shot previews has changed in the same way as filesystem observation.

- Added `removalRemovesPairedItems` to `id <CBLFileSystemItem>`. If this property returns `YES`, deleting the filesystem item may have other side effects, such as deleting the other half of a RAW+JPEG pair.

- Added `hasInaccessibleImages` to `id <CBLFileSystemItem>`. If this property returns `YES`, the storage item contains images that are inaccessible to CascableCore. For example, some older Panasonic models list RAW files but can't transfer them. CascableCore ignores these items and sets this property to `YES`.

- Added `+automaticAperture` to `CBLApertureValue`. This operates the same as automatic shutter speeds, in that you can't perform stop maths on these values.

# CascableCore 3.2.6

- Fixed a bug that would cause CascableCore to not correctly detect Sony cameras where the device name was changed from the default.

# CascableCore 3.2.5

- Added support for the Canon EOS 77D, EOS 800D and EOS M6. [CBC-64]

*Note:* As of this version the Sony RX100 V, Sony RX10 III and a6500 are supported. However, no code changes were needed.

# CascableCore 3.2.4

- Fixed a bug that would cause an invalid live view orientation to be reported on Canon cameras that don't supply this information. The orientation is new reported as landscape. [CBL-731]

# CascableCore 3.2.3

- Added support for the Canon EOS 1DX II. [CBC-28]

# CascableCore 3.2.2

- `-[id <CBLCamera> friendlyDisplayName]` will no return an empty string on some Canon models.

- `-[id <CBLCamera> supportedFunctionality]` will return the correct values for the Canon EOS 5D Mark III.

This release makes the 5D Mark III + WFT-E7 a supported camera.

# CascableCore 3.2.1

- Fixed crash that would occur when encountering an Olympus thumbnail image that was both invalid and in an orientation other than upright landscape. 

- CascableCore should no longer detect Sony TVs as cameras.


# CascableCore 3.2

- Added support for the Olympus OM-D E-M1 Mark II. [CBC-2, CBC-3]

- `CBLFileStreamChunkDelivery` callbacks are coalesced internally in some cases. [CBC-5] 

The behaviour of file streaming has changed slightly from previous releases. Some cameras deliver chunks of data in small amounts very frequently, which in some circumstances could lead to `CBLFileStreamChunkDelivery` callbacks being delivered at upwards of 100 times per second. From version 3.2, CascableCore enforces a minimum delivery size, which reduces the frequency of delivery callbacks to a manageable level.

Additionally, the behaviour of battery readings for cameras whose `cameraFamily` is `CBLCameraFamilyOlympus` has changed slightly. Previously, the value of the `CBLPropertyIdentifierBatteryLevel` property was `CBLBatteryPowerLevelFull` until a valid battery reading could be taken from the live view event stream. To better reflect reality, the value is now `CBLBatteryPowerLevelUnknown` until a battery reading is taken.


# CascableCore 3.1

### New Features

- Added `CBLRAWImageDescription`, a helper class for parsing the headers of RAW files, including extracting the JPEG previews from such files.

- Added `CBLImageMetadataWritingHelpers`, a helper class for writing metadata into image files.


# CascableCore 3.0.1

### Bug Fixes

- Fixed a bug that would cause a crash when using `-[CBLNetworkConfigurationHelper suggestedInterfaceForCameraCommunication]` on Mac machines that contain network interfaces with BSD names longer than 9 characters.


# CascableCore 3.0

### New Features

- Complete audit on all public APIs for use in Swift projects, including nullability annotations, naming changes, and the removal of the CBL prefix as per Swift naming guidelines. As a result of this, breaking changes were made to the API in both Swift and Objective-C which in turn required a new breaking version number.

- Added `CBLNetworkConfigurationHelper` to the public API, allowing client applications to perform network interface work with the same logic as CascableCore.

- Added support for the Canon EOS 7D Mark II, the Canon EOS 5DS and 5DSR, and the Canon EOS 5D Mark IV.

### Behaviour Changes

- Olympus cameras with "Mark" in the official name (such as the Olympus E-M5 Mark II) have more friendly display names. In this instance, "E-M5MarkII" becomes "E-M5 II".

### Bug Fixes

- CascableCore will no longer unnecessarily output to the console log when connecting to Olympus cameras.


# CascableCore 2.1
### New Features

Added two new properties: `CBLPropertyIdentifierLightMeterReading` and `CBLPropertyIdentifierLightMeterStatus`, which are supported on all camera families except Sony. 

- `CBLPropertyIdentifierLightMeterReading`  returns values of type `CBLExposureCompensation`. It is read-only.

- `CBLPropertyIdentifierLightMeterStatus` returns values of the new type `CBLLightMeterStatus`. It is also read-only.

Use these properties together to implement a light meter, which is useful when cameras are being used in manual exposure mode. Indeed,  typically the light meter is only active when the camera is set to `CBLAutoExposureModeManual` or `CBLAutoExposureModeBulbManual`.

Cameras don't always have their light meters active. When the value of `CBLPropertyIdentifierLightMeterStatus` is `CBLLightMeterStatusNotInUse`, the value for `CBLPropertyIdentifierLightMeterReading` is undefined and should not be used. When the value is `CBLLightMeterStatusReadingBeyondBounds`, the current exposure settings are so far away from a 'normal' exposure that the light meter cannot accurately give a reading. In this case, the camera itself will typically blink the light meter to show that it's invalid. In this case, you should hide your UI, or blink it, or otherwise inform the user of the situation.

### Behaviour Changes

- Canon, Nikon: When calling `-loadChildren` on an instance of `id <CBLFileSystemFolderItem>` that has already been loaded, the library will no longer create new instances for children that existed before the method was called, resusing the previous instances instead.

### Bug Fixes

- Olympus: Fixed a problem in which `validSettableValues` for exposure properties could be missing values when the drive mode is set to Manual.

- Canon: Fixed a problem in which the camera's `autoexposureResult` could be missing values.

- All: Improved the reliability of shot preview, particularly when multiple shots are taken in a short amount of time.

- All: Improved the reliability of camera discovery, particularly on iOS between app suspensions and on iOS 10.
