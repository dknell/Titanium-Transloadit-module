### Appcelerator Titanium Transloadit Module for iOS 

This is a Transloadit module for iOS originally developed by David Knell (not affiliated with Transloadit). The 
module currently supports files referenced by path (String) or TiBlob (as returned by Titanium's 
Ti.Media.openPhotoGallery or Ti.Media.showCamera). It also has a method to open a generic photo gallery 
to allow the user to select a photo to upload.

[Transloadit](http://www.transloadit.com/) is a one-stop-shop for all file upload and encoding tasks. By utilizing 
templates, Transloadit provides an extremely powerful and flexible "robotic assembly line" for media. The templates 
also make it very convenient to make changes to your conversion tasks without updating you app code - it's all done 
on their servers!

- - -

## Accessing the transloadit Module

Add the module to the tiapp.xml file:

	<modules>
        <module platform="iphone" version="0.1">ti.transloadit</module>
    </modules>

To access this module from JavaScript, you would do the following:

	var transloadit = require("ti.transloadit").createClient({
		authkey: "<<YOUR_AUTH_KEY>>",
		authsecret: "<<YOUR_AUTH_SECRET>>"
	});

The transloadit variable is a reference to the TiTransloaditClient object. This will be used for all subsequent API calls.

## Reference

### transloadit.createClient()

#### Arguments

Takes one argument, an object that contains the following parameters:

* **authkey** *			(string) Your Auth Key from the [credentials](https://transloadit.com/accounts/credentials) page

* **authsecret** *		(string) Your Auth Secret from the [credentials](https://transloadit.com/accounts/credentials) page
	
(* = REQUIRED)

#### Returns

This returns a client object that will be used for all subsequent API calls. See app.js for an example...
	
### transloadit.uploadFile()

#### Arguments

Takes one argument, an object that contains the following parameters:

* **file** *			(string | TiBlob) A path or TiBlob to be uploaded

* **filename** *		(string) The filename for the uplaoded file

* **type** *			(string) The MIME type (ie. image/jpeg)

* **templateId** *		(string) The Template ID from the [templates](https://transloadit.com/templates) page

* **params** 			(object) Allows you to pass in additional assembly logic - see the [passing fields and variables](https://transloadit.com/docs/passing-fields-and-variables-into-templates) page

* **onload** 			(function) The callback function that is called when upload is complete

* **onerror** 			(function) The callback function that is called if error occurs

* **onsendstream** 		(function) The callback function that is called during upload stream

(* = REQUIRED)

### transloadit.uploadFromGallery()

#### Arguments

Takes one argument, an object that contains the following parameters:

* **templateId** *		(string) The Template ID from the [templates](https://transloadit.com/templates) page

* **params** 			(object) Allows you to pass in additional assembly logic - see the [passing fields and variables](https://transloadit.com/docs/passing-fields-and-variables-into-templates) page

* **onload** 			(function) The callback function that is called when upload is complete

* **onerror** 			(function) The callback function that is called if error occurs

* **onsendstream** 		(function) The callback function that is called during upload stream

(* = REQUIRED)

## Usage

See the included example app.js

## Author

David Knell (Twitter: dknell)

## License

Apache Public License 2.0
