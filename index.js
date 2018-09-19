prefix = "https://cdnjs.cloudflare.com/ajax/libs/";

scripts = [
    "/js/initialize.js", 
    "jquery/3.3.1/jquery.min.js"
];

uri = document.location.href;

if (uri.includes("C:/")) folder = "/github"; // Windows
else if (uri.includes("/storage"))  folder = "/storage/sdcard1/github"; // Android
else ""; // Web

scripts.forEach(element => {
    var head = document.getElementsByTagName('head').item(0);
    var script = document.createElement('script');
    if (!element.match(/js\/initialize.js/)) element = prefix + element // CDN
    else element = folder + element  // Local
    script.setAttribute('src', element);
    head.appendChild(script);
});