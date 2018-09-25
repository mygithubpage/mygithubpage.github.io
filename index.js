prefix = "https://cdnjs.cloudflare.com/ajax/libs/";

var scripts = [
    "/js/initialize.js", 
    "jquery/3.3.1/jquery.min.js"
];

uri = document.location.href;

if (uri.includes("//C:")) folder = "/github"; // Windows
else if (uri.includes("//storage"))  folder = "/storage/sdcard1/github"; // Android
else folder = ""; // Web

scripts.forEach(element => {
    if (!element.match(/js\/initialize.js/)) element = prefix + element // CDN
    else element = folder + element  // Local

    var script = document.createElement('script');
    script.src = element;
    script.async = false;
    document.querySelector('head').appendChild(script);
});