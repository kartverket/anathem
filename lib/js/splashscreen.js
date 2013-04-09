$(function () {
    "use strict";
    var $splashscreen, $overlay, removeSplashScreen;

    removeSplashScreen = function()  {
        $splashscreen.removeClass('show');
    }

    if (!!window.location && (typeof window.location.hash !== 'string' || window.location.hash === '' || window.location.hash === '#5/378604/7226208/+land')) {
        $splashscreen = $('.splashscreen').addClass('show');
        $overlay = $splashscreen.find('.overlay');

        $splashscreen.find('.close, .use-beta-button').on('click', function (evt) {
            removeSplashScreen();
        });
        
        $overlay.on('click', function (evt) {
            evt.preventDefault();
            removeSplashScreen();
        });
    }
});
