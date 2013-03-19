$(function () {
    "use strict";
    var $splashscreen, $overlay, removeSplashScreen;

    removeSplashScreen = function()  {
        $splashscreen.removeClass('show');
    }

    $splashscreen = $('.splashscreen').addClass('show');
    $overlay = $splashscreen.find('.overlay');

    $splashscreen.find('.close').on('click', function (evt) {
        evt.preventDefault();
        removeSplashScreen();
    });
    
    $overlay.on('click', function (evt) {
        evt.preventDefault();
        removeSplashScreen();
    });

});
