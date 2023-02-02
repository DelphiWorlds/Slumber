# Slumber

## Description

App for testing HTTP calls, particularly REST. 

As an FMX project, the intended targets are Windows and macOS.

Shamelessly borrows from [Insomnia](https://insomnia.rest) 

## Contributors

* Dave Nottage (DPN)

If you wish to join, please post in the discussions section or in the Delphi Worlds Slack workspace. If you need to register, [please visit this self-invite link](https://slack.delphiworlds.com)

## Dependencies

* [Kastri](https://github.com/DelphiWorlds/Kastri)

## Configuration

The Slumber project options uses a search path based on environment variable user overrides, which appear as: `$(Variable)` where `Variable` is the name of the relevant variable in the `User Overrides` section of the IDE options (Tools|Options, IDE > Environment Variables). Each of the following variables are used:

* `Kastri`

Each variable points to the root of the respective repo unless otherwise indicated

## Near term goals

* Very basic implementation of sending HTTP requests and presenting the response

## Longer term goals

* Implement collections like Postman and Insomnia etc

## Status

### 02-Feb-2023

* Initial check-in of work in progress












