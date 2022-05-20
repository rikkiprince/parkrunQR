import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Communications;
import Toybox.Application.Storage;
import Toybox.Application.Properties;

class parkrunQRView extends WatchUi.View {
    var image;
    var responseCode;

    function initialize() {
        View.initialize();
    }

    function handleResponse(responseCode as Number, data as BitmapResource?) {
        responseCode = responseCode;
        System.print("Response code: ");
        System.println(responseCode);
        if(responseCode == 200) {
            image = data;
            WatchUi.requestUpdate();
            Storage.setValue("QRcode", image);
        } else {
            image = null;
        }
    }

    function initiateQRCodeRequest(textContent as String, size as Number) {
        var url = Lang.format("https://api.qrserver.com/v1/create-qr-code/?size=$2$x$2$&data=$1$", [textContent, size]);
        var parameters = null;
        var options = {                                         // set the options
            :palette => [ Graphics.COLOR_BLACK,                // set the palette
                          Graphics.COLOR_WHITE ],
            :maxWidth => size,                                   // set the max width
            :maxHeight => size,                                  // set the max height
            :dithering => Communications.IMAGE_DITHERING_NONE   // set the dithering
        };
        Communications.makeImageRequest(url, parameters, options, method(:handleResponse));
    }

    function determineSizes() {
        // Calc biggest square to fit
        var deviceSettings = System.getDeviceSettings();
        var shape = deviceSettings.screenShape; // SCREEN_SHAPE_ROUND, SCREEN_SHAPE_RECTANGLE, etc
        var width = deviceSettings.screenWidth;
        var height = deviceSettings.screenHeight;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        determineSizes();

        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void { 
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
        
        var parkrunBarcodeNumber = Properties.getValue("parkrunBarcodeNumber");
        var lastRetrievedForBarcodeNumber = Storage.getValue("lastRetrievedForBarcodeNumber");
        System.println(parkrunBarcodeNumber+" == "+lastRetrievedForBarcodeNumber);
        image = Storage.getValue("QRcode");
        if(image == null or parkrunBarcodeNumber != lastRetrievedForBarcodeNumber) {
            initiateQRCodeRequest(parkrunBarcodeNumber, 170);
            Storage.setValue("lastRetrievedForBarcodeNumber", parkrunBarcodeNumber);
        }

        // Render QR Code when it is available
        if(image != null) {
            dc.drawBitmap(35,35,image);
        } else {
            System.println("image is null");
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
