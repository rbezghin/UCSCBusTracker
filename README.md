# UCSC Bus Tracker App

Developed by: 
 - Radomyr Bezghin
 - Nathan Lakritz
 - Brian Thyfault
 - Rizzian Ciprian Tuazon

# Installation

On mac:

 1. Clone the git repository:
```
    git clone https://github.com/rbezghin/UCSCBusTracker.git
```
 2. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) to your mac
```
    $ sudo gem install cocoapods
```
 3. Install the Pods inside project directory
```
    pod install
```
 4. Open the newly created workspace "UCSCBus.xcworkspace" in the Xcode App

# Running on iPhone
### Getting project ready in project workspace:
 **1.** Click "UCSCBus" Project Header <br/>
 **2.** Under "Targets" select "UCSCBus" <br/>
 **3.** Go to "Signing & Capabilities" tab <br/>
 **4.** Change "Team" to your (Personal Team) in dropdown <br/>
 **5.** Create a unique "Bundle Identifier" by changing "co.rbezghin.**UCSCBus**" to anything you like. Ex "co.rbezghin.**MYBUSAPP**" <br/>
  ![Image Not Found](Getting_Project_Ready.png "Getting Project Ready") <br/>

### Running on your iPhone:
 **1.** Make sure your AppleID/iCloud account has been added to Xcode. Found at "Xcode"→"Preferences" under "Accounts" tab <br/>
 ![Image Not Found](AppleID_Accounts.png "Adding AppleID")  <br/>
 **2.** Connect your iPhone to mac with usb connector <br/>
 **3.** On your iPhone click "Trust" <br/>
  ![Image Not Found](Trust_Computer.png "Trust Computer") <br/>
 **4.** Click the play button to build and install app onto phone, make sure your phone is the selected target <br/>
  ![Image Not Found](Running.png "First Run") <br/>
 **5.** An error will appear in Xcode, Click "Ok" and grab your iPhone. <br/>
  ![Image Not Found](Could_Not_Launch.png "Could Not Launch") <br/>
 **6.** On iPhone, go to "Settings"→"Device Management"→"Apple Development:*(Your AppleID)*" <br/>
  ![Image Not Found](General_DM.png "Settings") <br/>
 **7.** Tap "Trust "Apple Development: *(Your AppleID)*"", Then "Trust" once more <br/>
  ![Image Not Found](Trust_Developer.png "Trust Developer") <br/>
 **8.** Finally, play & run the app on Xcode. It should install and open the app on the connected iPhone <br/>
  ![Image Not Found](First_Load.png "Allow Location") <br/>
 **9.** Done! <br/>
  ![Image Not Found](Completed.png "All set!") <br/>
