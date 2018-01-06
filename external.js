function mobileTopNav(elem) {
    // toggle block display
    var x = document.getElementById("hideNav");
    if (x.className.indexOf("w3-bar-block") == -1) {
        x.className += " w3-bar-block ";
    } else { 
        x.className = x.className.replace(" w3-bar-block", "");
    }
    
    // toggle sidebar button
    var sidebarButton = document.getElementById("sidebar-btn")
    if (sidebarButton.className.indexOf("w3-hide") == -1) {
        sidebarButton.className += " w3-hide";
    } else { 
        sidebarButton.className = sidebarButton.className.replace(" w3-hide", "");
    }

    // toggle top navigation bar item
    for (let index = 0; index < x.children.length; index++) {
        var element = x.children[index];
        if (element.className.indexOf("w3-hide-small") == -1) {
            element.className += " w3-hide-small";
        } else { 
            element.className = element.className.replace(" w3-hide-small", "");
        }
    }

    // toggle top naviagtion shape
    if (elem.innerText == "\u25B2") {
        elem.innerText = "\u25BC"
    } else {
        elem.innerText = "\u25B2"
    }
}

function sidebarFunc() {
    var element = document.getElementById("sidebar");
    if (element.className.indexOf("w3-hide") == -1) {
        element.className += " w3-hide";
    } else { 
        element.className = element.className.replace(" w3-hide", "");
    }
}

function accFunc(name) {
    var x = document.getElementById(name);
    if (x.className.indexOf("w3-show") == -1) {
        x.className += " w3-show";
        x.previousElementSibling.className += " w3-light-blue";
    } else { 
        x.className = x.className.replace(" w3-show", "");
        x.previousElementSibling.className = 
        x.previousElementSibling.className.replace(" w3-light-blue", "");
    }
}
