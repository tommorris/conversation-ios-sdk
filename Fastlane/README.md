fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

| Method                     | OS support                              | Description                                                                                                                           |
|----------------------------|-----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| [Homebrew](http://brew.sh) | macOS                                   | `brew cask install fastlane`                                                                                                          |
| Installer Script           | macOS                                   | [Download the zip file](https://download.fastlane.tools). Then double click on the `install` script (or run it in a terminal window). |
| RubyGems                   | macOS or Linux with Ruby 2.0.0 or above | `sudo gem install fastlane -NV`                                                                                                       |

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios code_coverage
```
fastlane ios code_coverage
```
Display test code coverage
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight
### ios doc
```
fastlane ios doc
```
Update SDK docs
### ios create_carthage
```
fastlane ios create_carthage
```
Create carthage
### ios tag_for_deploy
```
fastlane ios tag_for_deploy
```

### ios push_to_trunk
```
fastlane ios push_to_trunk
```
Push Cocoapods spec
### ios deploy
```
fastlane ios deploy
```
Package SDK to a framework

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).