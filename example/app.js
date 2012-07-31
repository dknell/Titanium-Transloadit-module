// this sets the background color of the master UIView (when there are no windows/tab groups on it)
Titanium.UI.setBackgroundColor('#000');

// CHANGE THESE
var myAuthKey = "<<YOUR_AUTH_KEY>>";
var myAuthSecret = "<<YOUR_AUTH_SECRET>>";
var myTemplateId = '<<YOUR_TEMPLATE_ID>>'; // in a real app, you would probably have multiple templates for different upload scenarios; ie photos, movies, etc.

// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel({text: "Transloadit Module", color: "#000", top: 10});
win.add(label);
win.open();

var progressBar=Titanium.UI.createProgressBar({
	bottom: 20,
	width: 240,
	height: 30,
	min: 0,
	max: 1,
	value: 0,
	color:'#333',
	message:'Uploading...',
	font:{fontSize:12, fontWeight:'bold'},
	style:Titanium.UI.iPhone.ProgressBarStyle.PLAIN,
});
win.add(progressBar);
progressBar.hide();

var TransloaditModule = require('ti.transloadit');
Ti.API.info("module is => " + TransloaditModule);

// Initialize the transloadit module
var transloadit = TransloaditModule.createClient({
	authkey: myAuthKey,
	authsecret: myAuthSecret
});

//////////////////////////////////////////////////////////////////////////////////////////////////////
// DEMO: Upload a local file
//////////////////////////////////////////////////////////////////////////////////////////////////////
var imgView = Ti.UI.createView({
	backgroundImage: 'honey-badger.jpg',
	top: 40,
	width: 200,
	height: 150
});
var imgViewLabel = Ti.UI.createLabel({font: {fontSize:12}, text: "(click on this image to upload)", color: "#333", top: imgView.top + imgView.height, height: 16});
win.add(imgView);
win.add(imgViewLabel);

imgView.addEventListener('click', function (e) {
	progressBar.message = "Uploading from local file...";
	progressBar.show();
	//
	// Get the file from the filesystem
	// file.nativePath doesn't work because the string is urlencoded and the OS won't resolve it
	//
	var file = Ti.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, e.source.backgroundImage);
	Ti.API.debug('file: ' + file);
	transloadit.uploadFile({
		file: file,
		filename: 'rawFileTest.jpg',
		type: 'image/jpeg',
		templateId: myTemplateId,
		onload: function (e) {
			Ti.API.debug('LOADED: ' + JSON.stringify(e));
			progressBar.hide();
		},
		onerror: function (e) {
			Ti.API.debug('ERROR: ' + JSON.stringify(e));
			progressBar.hide();
		},
		onsendstream: function (e) {
			Ti.API.debug('PROGRESS: ' + e.progress);
			progressBar.value = e.progress;
		}
	});
});
//////////////////////////////////////////////////////////////////////////////////////////////////////
// END DEMO: Upload a local file
//////////////////////////////////////////////////////////////////////////////////////////////////////

// seperator
var sep1 = Ti.UI.createView({
	backgroundColor: '#666',
	height:4,
	width: Ti.Platform.displayCaps.platformWidth,
	top: imgViewLabel.top + imgViewLabel.height + 12
});
win.add(sep1);

//////////////////////////////////////////////////////////////////////////////////////////////////////
// DEMO: Upload from generic gallery
//////////////////////////////////////////////////////////////////////////////////////////////////////
var genGalButton = Ti.UI.createButton({
	title: "Upload from generic gallery",
	width: 220,
	height: 40,
	top: sep1.top + sep1.height + 20
});
win.add(genGalButton);
genGalButton.addEventListener('click', function (e) {
	progressBar.message = "Uploading from generic gallery...";
	progressBar.show();
	//
	// Get the file from a generic gallery (no editing)
	// This uploads immediately after the image is selected
	//
	transloadit.uploadFromGallery({
		templateId: myTemplateId,
		onload: function (e) {
			Ti.API.debug('LOADED: ' + JSON.stringify(e));
			progressBar.hide();
		},
		onerror: function (e) {
			Ti.API.debug('ERROR: ' + JSON.stringify(e));
			progressBar.hide();
		},
		onsendstream: function (e) {
			Ti.API.debug('PROGRESS: ' + e.progress);
			progressBar.value = e.progress;
		},
		oncancel: function (e) {
			Ti.API.debug('CANCELLED');
			progressBar.hide();
		}
	});
});
//////////////////////////////////////////////////////////////////////////////////////////////////////
// END DEMO: Upload from generic gallery
//////////////////////////////////////////////////////////////////////////////////////////////////////

// seperator
var sep2 = Ti.UI.createView({
	backgroundColor: '#666',
	height:4,
	width: Ti.Platform.displayCaps.platformWidth,
	top: genGalButton.top + genGalButton.height + 20
});
win.add(sep2);

//////////////////////////////////////////////////////////////////////////////////////////////////////
// DEMO: Upload from Ti.Media.openPhotoGallery
//////////////////////////////////////////////////////////////////////////////////////////////////////
var tiGalButton = Ti.UI.createButton({
	title: "Upload from Titanium gallery",
	width: 230,
	height: 40,
	top: sep2.top + sep2.height + 22
});
win.add(tiGalButton);
tiGalButton.addEventListener('click', function (e) {
	progressBar.message = "Uploading from Titanium gallery...";
	progressBar.show();
	//
	// Get the file from the Titanium camera roll
	//
	Ti.Media.openPhotoGallery({
		success: function(event) {
			media = event.media;
			Ti.API.debug('event: ' + JSON.stringify(event));
			if (event.mediaType === Ti.Media.MEDIA_TYPE_PHOTO) {
				transloadit.uploadFile({
					file: media,
					filename: 'cameraRollPhotoTest.jpg',
					type: 'image/jpeg',
					templateId: myTemplateId,
					onload: function (e) {
						Ti.API.debug('LOADED: ' + JSON.stringify(e));
						progressBar.hide();
					},
					onerror: function (e) {
						Ti.API.debug('ERROR: ' + JSON.stringify(e));
						progressBar.hide();
					},
					onsendstream: function (e) {
						Ti.API.debug('PROGRESS: ' + e.progress);
						progressBar.value = e.progress;
					}
				});
			} else if (event.mediaType === Ti.Media.MEDIA_TYPE_VIDEO) {
				transloadit.uploadFile({
					file: media,
					filename: 'cameraRollVideoTest.mov',
					type: 'video/quicktime',
					templateId: myTemplateId,
					onload: function (e) {
						Ti.API.debug('LOADED: ' + JSON.stringify(e));
						progressBar.hide();
					},
					onerror: function (e) {
						Ti.API.debug('ERROR: ' + JSON.stringify(e));
						progressBar.hide();
					},
					onsendstream: function (e) {
						Ti.API.debug('PROGRESS: ' + e.progress);
						progressBar.value = e.progress;
					}
				});
			}
		},
		cancel: function() {
			Ti.API.debug('CANCELLED');
			progressBar.hide();
		},
		error: function(error) {
			Ti.API.error("openPhotoGallery ERROR: " + JSON.stringify(error));
			xp.ui.alert("Camera Roll", "There was a problem getting the photo/video from the camera roll. Please try again.");
		},
		animated: false,
		allowEditing: true,
		videoMaximumDuration: 15000, // 15 seconds
		videoQuality: Ti.Media.QUALITY_LOW,
		mediaTypes: [Ti.Media.MEDIA_TYPE_PHOTO, Ti.Media.MEDIA_TYPE_VIDEO]
	});
});
//////////////////////////////////////////////////////////////////////////////////////////////////////
// END DEMO: Upload from Ti.Media.openPhotoGallery
//////////////////////////////////////////////////////////////////////////////////////////////////////

// seperator
var sep3 = Ti.UI.createView({
	backgroundColor: '#666',
	height:4,
	width: Ti.Platform.displayCaps.platformWidth,
	top: tiGalButton.top + tiGalButton.height + 20
});
win.add(sep3);



