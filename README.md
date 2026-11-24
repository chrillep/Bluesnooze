# Bluesnooze (fork)

[Download the latest release.][download-latest]

See what has been changed in this fork in the [changelog](CHANGELOG.md) and release notes.

## About

**Bluesnooze prevents your sleeping Mac from connecting to Bluetooth accessories.**

If you pair Bluetooth headphones or speakers with both your phone & Mac it can be frustrating when your sleeping Mac connects intermittently and disrupts the audio.

With Bluesnooze the Bluetooth connection is switched off when your Mac sleeps, and switched on when your Mac wakes.

Bluesnooze can also manage the Wi-Fi connection in the same way (disabled by default).

In the Bluetooth menu, choose either **Turn off Bluetooth** or **Disconnect selected devices** for sleep. Selecting one automatically disables the other.

![Screenshot showing Bluesnooze in the status bar](images/screenshot.png)

## Installation

The downloadable release requires macOS 12 or later and supports Intel and Apple Silicon Macs. It is ad-hoc signed, not Developer ID signed or notarized, so macOS may require approval in System Settings > Privacy & Security. Only approve downloads you trust. Older upstream releases have different system requirements.

1. Download `Bluesnooze.zip` from the [latest release][download-latest].
1. In Finder, open `Bluesnooze.zip` in your `Downloads` directory.
1. Drag `Bluesnooze.app` to your `Applications` directory.
1. Launch `Bluesnooze`.
1. If macOS asks for Bluetooth access, allow it so Bluesnooze can manage Bluetooth connections.
1. *Optional*: Configure <kbd>Wi-Fi</kbd> behavior.
1. *Optional*: Configure <kbd>Launch at login</kbd>.

## Caveats

- The app has an option to hide the icon from the status bar. To show the icon again simply launch the application a second time.
- Please note this app is not compatible with the “Allow your Apple Watch to unlock your Mac” feature.
- Unfortunately this app can't be distributed via the App Store because it uses a private API to switch Bluetooth on/off.

## Development

Install Xcode and select it as the active developer directory before building. Run `make` for a list of commands:

```shell
make build        # Build a Release app in .build/DerivedData/Build/Products/Release
make install      # Build and copy to /Applications (quit Bluesnooze first)
make run          # Build, install, and launch the installed app
make lint         # Run strict SwiftLint (install the version pinned below)
make clean        # Clean build products; leave the installed app untouched
```

For a per-user installation, use `make run INSTALL_DIR="$HOME/Applications"`. Override `CONFIGURATION=Debug` for a debug build or `DEPLOYMENT_TARGET` to select another SDK-supported minimum. The default local build uses macOS 12 for compatibility with recent Xcode SDKs and is ad-hoc signed, not notarized. Installation requires write access to the destination; the Makefile never runs `sudo`. Allow Bluetooth access when prompted.

GitHub Actions runs the version in `.swiftlint-version` in strict mode on pull requests and pushes to `main`. To run the same check locally with that SwiftLint version:

```shell
swiftlint lint --config .swiftlint.yml --strict
```

Existing violations are recorded in `.swiftlint-baseline.json`; new warnings or errors fail the check. Remove baseline entries as existing issues are fixed. Length violations can reappear when a file or type grows; review those changes before updating the affected baseline entries.

Workflow checks run actionlint and zizmor on pull requests and pushes to `main`, avoiding duplicate feature-branch push runs. Zizmor uses annotations with Advanced Security disabled, so findings fail the check without requiring `security-events: write`.

GitHub Actions also builds the app on pull requests and pushes to `main`. The CI build overrides the deployment target to macOS 12 because recent Xcode SDKs cannot build for the project's 10.13 target; this does not change the project's minimum version.

Successful build runs provide an unsigned `Bluesnooze-unsigned.zip` artifact, which is not a signed or notarized release. The Xcode build log and result bundle are also uploaded when available, including after build failures.

### Releases

Update the app's `MARKETING_VERSION` in both Xcode configurations and add a dated changelog entry in a PR. The release workflow validates universal Release packaging on PRs that change the app or release workflow. Merge after checks pass, tag that commit as `v<MARKETING_VERSION>`, and publish a GitHub release with the changelog entry as its notes.

Publishing triggers the release workflow, which checks that the tag matches the app version, verifies both CPU architectures and the ad-hoc signature, then attaches `Bluesnooze.zip` and `Bluesnooze.zip.sha256`. Asset publishing uses a SHA-pinned `softprops/action-gh-release`; only that job has write permission. Assets appear after the workflow succeeds. Releases must remain mutable until assets are attached; this published-event workflow does not support immutable releases.

Verify a download with `shasum -a 256 -c Bluesnooze.zip.sha256` from the directory containing both files. The universal release targets macOS 12; the project's older deployment setting is unchanged.

### Dependency updates

Dependabot checks GitHub Actions and Xcode-managed Swift packages weekly. Renovate checks supported dependencies, including GitHub Actions and the pinned SwiftLint version, on a weekly schedule; both bots may propose the same update. Renovate's Swift manager requires a `Package.swift` and does not currently support this Xcode project's package declarations. LaunchAtLogin follows a branch rather than a versioned release, so verify its resolved revision separately.

To enable Renovate, install the [Renovate GitHub App](https://github.com/apps/renovate) and explicitly select this repository, including if it is a fork.

Renovate is configured to automerge minor and patch updates after checks pass, with a 14-day minimum release age where supported. Protect `main` and require both the build and SwiftLint checks so GitHub enforces them before any merge. The build check does not exercise app behavior.

## Settings

The application settings can be modified using the `defaults` command.

```shell
# read settings:
defaults read com.oliverpeate.Bluesnooze disableBluetoothOnPowerDown
defaults read com.oliverpeate.Bluesnooze disconnectBluetoothDevicesOnPowerDown
defaults read com.oliverpeate.Bluesnooze bluetoothDevicesToDisconnectOnPowerDown
defaults read com.oliverpeate.Bluesnooze bluetoothActionOnScreenUnlock
defaults read com.oliverpeate.Bluesnooze disableWifiOnPowerDown
defaults read com.oliverpeate.Bluesnooze wifiActionOnScreenUnlock
defaults read com.oliverpeate.Bluesnooze hideIcon

# update settings:
defaults write com.oliverpeate.Bluesnooze disableBluetoothOnPowerDown -bool false
defaults write com.oliverpeate.Bluesnooze disconnectBluetoothDevicesOnPowerDown -bool true
defaults write com.oliverpeate.Bluesnooze bluetoothDevicesToDisconnectOnPowerDown -array '00-ba-e7-15-6a-f0' '6e-1f-62-6c-2a-bc'
defaults write com.oliverpeate.Bluesnooze bluetoothActionOnScreenUnlock -string enable
defaults write com.oliverpeate.Bluesnooze disableWifiOnPowerDown -bool true
defaults write com.oliverpeate.Bluesnooze wifiActionOnScreenUnlock -string restore
defaults write com.oliverpeate.Bluesnooze hideIcon -bool true

# delete settings: (this resets everything to defaults)
defaults delete com.oliverpeate.Bluesnooze
```

[download-latest]: https://github.com/chrillep/Bluesnooze/releases/latest
