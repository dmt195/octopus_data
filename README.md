# Octopus Data App 🐙
  
A Flutter application to read tariff and consumption data for agile octopus tariffs. I made this as an experiment and wanted to make it better but don't have a great deal of time. Feel free to use and contribute as you see fit!
  
## Building  it
  
Currently API and account credentials are hard coded into the app. To determine these:  
- Go to `https://octopus.energy/dashboard/developer/` and login to your Octopus Energy account.  
- Create a `private_consts.dart` file in the `lib` directory and include the following fields:  
  
```
String API_KEY = "[KEY]";  
String ELECTRICITY_MPAN = "[MPAN VALUE]";  
String ELECTRICITY_SERIAL = "[SERIAL NUMBER OF METER]";  

String TARIFF_CODE_1 = "AGILE-18-02-21";  
String TARIFF_CODE_2 = "E-1R-AGILE-18-02-21-L";  
```
  
The Tariff codes can be derived from the example at the bottom of your developer page. For example, mine is:  
`https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-AGILE-18-02-21-L/standard-unit-rates/`
or more generally:
`https://api.octopus.energy/v1/products/{{TARIFF_CODE_1}}/electricity-tariffs/{{TARIFF_CODE_2}}/standard-unit-rates/`

...then create either iOS or Android apps...

## Using the app
When you first run the app there will be no data stored. The floating action button is used to query the API and save data to the phone's database (Sqlite).
This is a bit clunky and does affect performance (particularly the first time you run it) - see known issues / improvements!.

## How to contribute
Send me a message and let me know what you want to change. I will only accept PRs that I believe to be in keeping with my vision of the app so best to check first. I'll most likely say yes! Of course you can always fork the repo and do whatever.

## Known issues /improvements
- DB writing (this seems to happen on the main thread with the library I'm using (moor). Ideally, I'd use an isolate to make sure this happens in the background. Related to this, the view is reactive so refreshing with every DB entry. A simple fix would be to make the views less coupled to the DB (it seemed elegant at first!).
- Hard coded creds. I was aiming to have an onboarding flow to collect this information and store it in the shared preferences. An even nicer approach would be to use a webview to shadown the login process and retrieve the info directly. This hasn't happened yet!
- Data for wholesale prices is saved in the DB but actual prices are calculated on the fly. I did have a plan to pull this into the DB too to make everything faster.
- Auto fetching data on launch.

#License (MIT) 

Copyright (c) 2020 David Taylor

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
