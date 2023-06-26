# Slumber

## Description

App for testing HTTP calls, particularly REST. 

As an FMX project, the intended targets are Windows and macOS.

Shamelessly borrows ideas from [Insomnia](https://insomnia.rest) 

**NOTE:** As this is work in progress, there may be **substantial refactoring** as the project progresses

## Contributors

* Dave Nottage (DPN)

If you wish to join, please post in the discussions section or in the Delphi Worlds Slack workspace. If you need to register, [please visit this self-invite link](https://slack.delphiworlds.com)

## Dependencies

* [Skia v6.0.0](https://github.com/skia4delphi/skia4delphi/releases/tag/v6.0.0-beta2)
* [Kastri](https://github.com/DelphiWorlds/Kastri)

Note: For Windows builds (Win32 or Win64), you will need to ensure that `sk4d.dll` is in the Windows library path. The dll for the respective platform is under the `Lib` folder.

## Configuration

### Project search paths

The Slumber project options uses a search path based on environment variable user overrides, which appear as: `$(Variable)` where `Variable` is the name of the relevant variable in the `User Overrides` section of the IDE options (Tools|Options, IDE > Environment Variables). Each of the following variables are used:

* `Kastri` - needs to point to an instance of the Kastri repo
* `Skia` - needs to point to the `Source` folder of [Skia](https://github.com/skia4delphi/skia4delphi/releases/tag/v6.0.0-beta2)

### Styles

**Style files are copyrighted, so they cannot be distributed with this source**

As per the `Styles\Styles.Default.rc` and `Styles\Styles.macOS.rc` files, if you wish to use a style, you will need to create a `.style` file, usually from a `.vsf` file that you can install using the GetIt package manager of Delphi, and replace the filename for the resource named `StyleBook` in the `.rc` file (e.g. `UbuntuClearFantasy.Default.style`) with the filename of your exported `.style` file. If you wish to use styles for both Windows and macOS, remember to export a `.style` file for each platform.

You will also need to create or update the `.json` file for the resource named `Style`. The `.json` file contains style information related to the style being used. Presently the only value is `ButtonColor`, which relates to the color of the buttons used in Slumber, e.g.:

```
{
  "ButtonColor" : "$FFE4643C"
}
```

The color value should be a value that matches the style being used.

## Near term goals

* Very basic implementation of sending HTTP requests and presenting the response

## Longer term goals

* Implement collections like Postman and Insomnia etc

## Status

### 26-Jun-2023

* Removed dependency on SVGIconImageList, however the image loading is now based on [Skia v6.0.0](https://github.com/skia4delphi/skia4delphi/releases/tag/v6.0.0-beta2)
* Pressing enter in the URL edit now sends the request
* Added Headers to the response area

The switch to using Skia (and no Img32 code from SVGIconImageList) means that the Windows version is now dependent on the Skia DLLs (Win32 or Win64). These are in the `Lib` folder.

### 24-Jun-2023

* Changed header kind combo to allow custom headers
* Added Skia search paths for macOS

~~**NOTE: I am currently unable to make the images appear on macOS**~~ This has been fixed in the 26-Jun-2023 changes

### 19-Mar-2023

* Added "instant" saving of changes using Ctrl-S
* Added "auto-select" of first request found when loading a profile
* Fixed a bunch of issues
  
### 04-Mar-2023

* Now supports loading/saving of "profiles" (in JSON format). May not be 100% complete
* Fixed a bunch of issues

### 01-Mar-2023

* Work in progress update
* Added support for using SVGs as button images
* Profile, Folder and Request classes have been created

Known issues:

* The buttons do not show on macOS as yet
* A bunch of stuff is yet to be implemented

### 02-Feb-2023

* Initial check-in of work in progress












