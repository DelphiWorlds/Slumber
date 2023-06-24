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

* [SVGIconImageList](https://github.com/EtheaDev/SVGIconImageList)
* [Kastri](https://github.com/DelphiWorlds/Kastri)

Note: Although there is a dependency on SVGIconImageList, the project creates the required classes at run-time, so there is no need to install the SVGIconImageList components. See also [Project search paths](#project-search-paths) regarding the include file.

## Configuration

### Project search paths

The Slumber project options uses a search path based on environment variable user overrides, which appear as: `$(Variable)` where `Variable` is the name of the relevant variable in the `User Overrides` section of the IDE options (Tools|Options, IDE > Environment Variables). Each of the following variables are used:

* `Kastri` - needs to point to an instance of the Kastri repo
* `SVG` - needs to point to an instance of the SVGIconImageList repo.
* `Skia` - needs to point to the `Source` folder of [Skia 4.1.1](https://github.com/skia4delphi/skia4delphi/releases/tag/v4.1.1) (the latest version that SVGIconImageList supports). **This is required only if compiling for macOS.** 
  
**NOTE**: This project uses a *customised version* of the `SVGIconImageList.inc` file, which is located in the root of the project

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

### 24-Jun-2023

* Changed header kind combo to allow custom headers
* Added Skia search paths for macOS

**NOTE: I am currently unable to make the images appear on macOS**. Any help with this would be appreciated. 

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












