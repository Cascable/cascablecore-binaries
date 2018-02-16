[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Cocoapods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat)](https://cocoapods.org)

## CascableCore Releases

This repo contains releases of the CascableCore framework. CascableCore is a framework for connecting to and working with Wi-Fi enabled cameras from Canon, Fujifilm, Nikon, Olympus, Panasonic, and Sony.

## CascableCore Information

This repository is for distributing CascableCore to our users. Want to find out more?

- For more information on the CascableCore product, including getting a trial license, see the [Cascable Developer Portal](https://developer.cascable.se/).

- You can see CascableCore in action by checking out the [CascableCore Demo Project](https://github.com/Cascable/cascablecore-demo). You'll need a trial license for it to do anything useful!

- You can find a discussion about the CascableCore APIs and some more advanced usage over in our [Getting Started With CascableCore](Getting%20Started%20With%20CascableCore.md) document.

- You can find release notes in the [CHANGELOG](CHANGELOG.md) document.

## Adding CascableCore to your Project

CascableCore is distributed as a framework bundle alongside its dependency `StopKit`. On iOS, the build includes both simulator and device architectures - if you don't choose to use a dependency manager, you'll need to strip the simulator architectures from `CascableCore.framework` and `StopKit.framework` before you can upload your app to the App Store. See the [App Store Preparation](#app-store-preparation-ios-only) section below for details. 

### Adding CascableCore to your Project Option 1: Carthage

CascableCore supports [Carthage](https://github.com/Carthage/Carthage). Simply add a line similar to the following to your `Cartfile`:

`github "cascable/cascablecore-binaries" ~> 5.0`

### Adding CascableCore to your Project Option 2: CocoaPods

CascableCore supports [CocoaPods](https://cocoapods.org). Simply add the `CascableCore/iOS` or `CascableCore/Mac` pod to your `Podfile` as appropriate.

For iOS apps, include the following in your `Podfile`:

```
target 'MyApp' do
  pod 'CascableCore/iOS', '~> 5.0'
end
```

For Mac apps, include the following in your `Podfile`:

```
target 'MyApp' do
  pod 'CascableCore/Mac', '~> 5.0'
end
```

### Adding CascableCore to your Project Option 3: Manually

To manually add `CascableCore` to your project, you can either download the binaries from the [Releases](https://github.com/Cascable/cascablecore-binaries/releases) page and place them where you'd like, or add this repository as a submodule of your project's repository.

**Important:** If you add `CascableCore` as a submodule, make sure you have `git-lfs` installed and configured on your development system(s).

## Setting Your Build Settings

Once you have `CascableCore.framework` and `StopKit.framework`them in a sensible location in your project's structure, drag it into your Xcode project.

Next, navigate to your target's **General** settings and ensure `CascableCore.framework` and `StopKit.framework` are listed in both the **Embedded Binaries** and **Linked Frameworks and Libraries** section.

<img src="Documentation%20Images/setup-general.png" width="947">

Next, navigate to **Build Settings** and set the **Enable Bitcode** setting to **No**. Due to our build process, CascableCore does not have a Bitcode slice. 

Next, **only if your project only contains Objective-C**, navigate to **Build Settings** and ensure that **Always Embed Swift Standard Libraries** is set to **Yes**. If your project contains Swift code or depends on Swift libraries, there's no need to perform this step.

Finally, navigate to **Build Phases** and add a new **Copy Files** build phase, with the destination set to **Frameworks**. Ensure that `CascableCore.framework` and `StopKit.framework` are listed in this phase. 

<img src="Documentation%20Images/setup-copyframeworks.png" width="932">

## App Transport Security

If your app is limited by App Transport Security, you need to allow CascableCore to talk to the cameras on your local network.

On iOS 10 and macOS 10.12 and above, set `NSAllowsLocalNetworking` to `YES` in your App Transport Security settings.

<img src="Documentation%20Images/ats.png" width="562">

On iOS 9 and macOS 10.11 or lower, you need to disable App Transport Security entirely, by setting `NSAllowsArbitraryLoads` to `YES`. If you do this, you may need to describe why to Apple in order to pass App Review. A paragraph similar to this may suffice:

> App Transport Security has been disabled for this app on iOS 9 and lower. This is because the app needs to communicate with cameras discovered on the local network, and App Transport Security  provides no way to whitelist the local network or IP address ranges on iOS 9 or lower.

If you support iOS 10/macOS 10.12 and lower you can set both `NSAllowsLocalNetworking` to `YES` _and_ `NSAllowsArbitraryLoads` to `YES` to disable App Transport Security on older OS versions, but use the more secure local networking exemption on newer OS versions. For more information on this, see [this thread on the Apple Developer Forums](https://forums.developer.apple.com/thread/6767).

CascableCore makes no attempt to communicate with the outside world via the Internet, so no domain-specific App Transport Security exemptions are needed.

## App Store Preparation (iOS Only)

The `CascableCore.framework` and `StopKit.framework` iOS binaries contain both simulator and device architectures, allowing you to work both in the iOS Simulator and on iOS devices. Unfortunately, iTunes Connect will refuse to accept binaries that contain simulator architectures. 

If you already have a solution for this problem for other dependencies, that solution should work with CascableCore as well. Otherwise, this build phase script will look through all of your built application's embedded frameworks and strip out architectures not being used for that build.

**Note:** If you're using Carthage and their recommended `/usr/local/bin/carthage copy-frameworks` method of embedding frameworks, you don't need to perform this step — Carthage does it for you.

To use it, create a new **Run Script** build phase at the **end** of your existing build phases, set the shell to `/bin/sh` and enter the following script:

```sh
if [ "${CONFIGURATION}" = "Debug" ]; then
    echo "Debug build, skipping framework architecture stripping"
    exit 0
fi

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
    FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
    FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
    echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

    EXTRACTED_ARCHS=()

    for ARCH in $ARCHS
    do
        echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
        lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
        EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
    done

    echo "Merging extracted architectures: ${ARCHS}"
    lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
    rm "${EXTRACTED_ARCHS[@]}"

    echo "Replacing original executable with thinned version"
    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

done
```

