$("td a").each(function () {
    text = $(this).text()
    if (text.match(/lg/)) {
        $(this).attr("href", `https://www.lg.com/us/laptops/${text}-ultra-slim-laptop`)
    }
    else if (text.match(/ipad/)) { // Apple
        $(this).attr("href", `https://www.apple.com/${text}/specs/`)
    }
    else if (text.match(/i\d-\w+/)) { // Intel Core CPU
        $(this).attr("href", `https://www.intel.com/content/www/us/en/products/processors/core/${text.match(/i\d\b/)}-processors/${text}.html`)
    }
    else if (text.match(/\bS\d/)) { // Snapdragon CPU
        $(this).attr("href", `https://www.qualcomm.com/products/snapdragon-${text.match(/\d+/)}-mobile-platform`)
    }
    else if (text.match(/(Idea|Think)Pad/)) { // Lenovo
        $(this).attr("href", `https://www.lenovo.com/us/en/laptop/${$(this).attr("href")}`)
    }
    else if (text.match(/Surface/)) { // Surface
        $(this).attr("href", `https://www.microsoft.com/en-us/p/surface/${$(this).attr("href")}`)
    }
    else if (text.match(/(Zen|Vivo)Book/)) { // ASUS
        $(this).attr("href", `https://www.asus.com/us/Laptops/ASUS-${text}/specifications/`)
    }
    else if (text.match(/OnePlus/)) { // OnePlus
        $(this).attr("href", `https://www.oneplus.com${text.match(/\/\w+/)}/specs`)
    }
    
});