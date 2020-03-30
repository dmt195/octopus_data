# Octopus Data App 🐙

[![Codemagic build status](https://api.codemagic.io/apps/5e8227914b4d3247a2739c79/5e8227914b4d3247a2739c78/status_badge.svg)](https://codemagic.io/apps/5e8227914b4d3247a2739c79/5e8227914b4d3247a2739c78/latest_build)
  
A Flutter application to read tariff and consumption data for Agile Octopus tariffs. I made this as an experiment and wanted to make it better but don't have a great deal of time. Feel free to use and contribute as you see fit!
If you are considering going with Octopus then please use my referral code: https://share.octopus.energy/witty-hyena-591
  
## Building  it
So far only built and tested for iOS and Android. Not tested on macOS or the Web although I'd love to see PRs to support that!
The app should import well into Android Studio or VS Code with the Flutter plugin. 
See `https://flutter.dev/docs/get-started/install` to get the tools installed.

## Using the app
  
If this is the first time you've run the app, you will be taken to a settings page for your API key and account credentials. Note that these are stored in the clear in a key/value store (SharedPreferences on Android, NSUserDefaults on iOS). Please don't use if that makes you uncomfortable.

To determine these:  
- Go to `https://octopus.energy/dashboard/developer/` and login to your Octopus Energy account.  
- Copy and past 2 curl commands (as shown in the settings screen) into the fields
- The app captures the following credentials from those commands (which are presented when you click Save):
  
```
String API_KEY = "[KEY]";  
String ELECTRICITY_MPAN = "[MPAN VALUE]";  
String ELECTRICITY_SERIAL = "[SERIAL NUMBER OF METER]";  

String TARIFF_CODE_1 = "[eg AGILE-18-02-21]";  
String TARIFF_CODE_2 = "[eg E-1R-AGILE-18-02-21-L]";  
```


When you first see the main screen there will be no data stored. The floating action button is used to query the API and save data to the phone's database (Sqlite under the hood).

## How to contribute
Fork the repository, make changes, and submit a pull request. There's plenty that can be done. I only ask that PRs are kept small and focused.

Android Screenshot

![some early hours high usage!][screenshot]

[screenshot]: docs/android_debug.png

## Known issues /improvements
- I've started to move things into a Bloc pattern. This only covers part of the logic right now but I'd like it to control all of the flow.
- ~Hard coded creds.~ I have an onboarding flow to collect this information and store it in the shared preferences (settings page). An even nicer approach would be to use a webview to shadow the login process and retrieve the info directly. This hasn't happened yet!
- Data for wholesale prices is saved in the DB but actual prices (calculated via Octopus' algorithm) are calculated on the fly. I did have a plan to pull this into the DB too to make everything faster.
- Auto fetching data on launch.
