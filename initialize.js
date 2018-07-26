/**
 * my initialize javascript
 * comes before any other script 
*/
folder = ""
function createNode (element, parent, before) {
    /** element format
     * <[><tagName>, {[attributeName : attributeValue[, attributeName : attributeValue]...]}, [textContent]<]>
     */
    
    if(!parent) { parent = document.head; }
    var node = document.createElement(element[0]);
    for (let index = 0; index < Object.keys(element[1]).length; index++) {
        node.setAttribute(Object.keys(element[1])[index], Object.values(element[1])[index]);
    }
    if(element[2]) {node.textContent = element[2];}
    if(!before) {parent.appendChild(node);}
    else {parent.insertBefore(node, parent.firstElementChild);}
    return node;
}

// Execute script after window load
window.addEventListener("load", function () { 
    
    addHead();
    addColor();
    addTopNav(color);
    addFooter(color);
    mobileFlag = screen.width < 600 ? true : false;
    uri = document.location.href;
    html = uri.split("/").slice(-1)[0];
    // 
});

function addColor() {
    
    function getRandomInt(max) {
        return Math.floor(Math.random() * Math.floor(max));
    }
    colors = ["w3-red", "w3-pink", "w3-purple", "w3-indigo", "w3-blue", "w3-teal", "w3-green", "w3-brown", "w3-deep-orange"];
    let random = getRandomInt(colors.length);
    color = colors[random];

}

// Add <meta> <link> <script> element in head
function addHead() {

    // UTF-8 charset
    createNode( ["meta", {charset : "utf-8"}] );
    
    // Mobile first
    createNode( ["meta", {name : "viewport", content : "width=device-width, initial-scale=1"}] );
    
    // My CSS
    createNode( ["link", {rel : "stylesheet", href : folder + "/style.css"}] );

    // W3Schools W3 CSS
    createNode( ["link", {rel : "stylesheet", href : folder + "/w3.css"}] );

    // Website Icon
    createNode( ["link", {
        rel : "icon", 
        href : "https://png.icons8.com/color/50/ffffff/external-link.png",
        size : "16x16",
        type : "image/png"
    }] );

    // jQuery
    createNode( ["script", {src : "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"}] );

    // My javascript
    createNode( ["script", {src : folder + "/variable.js"}] );
    createNode( ["script", {src : folder + "/external.js"}] );
    
}

function addFooter(color) {
    
    var icons = ["youtube", "twitter", "facebook", "instagram", "linkedin", "pinterest"]
    var a;
    var p;

    var footer = createNode( ["footer", {class : color + " w3-container w3-center w3-margin-top"}], document.body);

    createNode( ["p", {}, "This is my social media."], footer);

    icons.forEach(element => {
        a = createNode( ["a", {href : "https://www." + element + ".com"}], footer);
        createNode( ["img", {
            src : "https://png.icons8.com/metro/20/ffffff/" + element + ".png",
            class : "my-margin-small"
        }], a);
    });

    p = createNode( ["p", {}, ""], footer);
    createNode( ["span", {}, "Made by "], p);
    createNode( ["a", {href : "https://mygithubpage.github.io"}, "GitHubPages"], p);
}

function addTopNav(color) {
    if(document.location.href.includes("/gre/")) {
        var test = "/gre/";
        var barItems = ["OG", "PQ", "MH", "PR", "Kap", "Manhattan", "Barrons", "Mangoosh", "Grubers", "Notes"];
    }
    
    else {
        var test = "/toefl/"
        var barItems = ["TPO", "Essay", "OG", "EQ", "Barrons", "Cambridge", "Longman", "Notes"];
    }
    var nav = createNode( ["nav", {
        class : color + " w3-bar w3-card w3-center w3-margin-bottom", 
        id: "topNav"
    }], document.body, "before");
    
    for (let index = 0; index < barItems.length; index++) {
        const element = barItems[index];
        let suffix = "";
        if (document.location.href.includes("/gre/")) { if(index > 4) { suffix = " w3-hide-small" } }
        else { if(index > 2) { suffix = " w3-hide-small" } }
        createNode( ["a", {
            href : folder + test + element.toLowerCase() + "/" + element.toLowerCase() + ".html",
            class : "w3-bar-item w3-button" + suffix
        }, element], nav);

    }

    createNode( ["button", {
        id : "topNavBtn",
        class : "w3-bar-item w3-button w3-right w3-hide-large w3-hide-medium"
    }, "\u25BC"], nav);

}

function toggleFixed(element) {
    if (window.pageYOffset !== element.offsetTop) {
        element.classList.add("my-fixed")
    } else { // Remove "my-fixed" when you leave the scroll position
        element.classList.remove("my-fixed"); 
    }
}

function addSiderbarBtn() {
    createNode( ["button", { id : "sidebarBtn", class : "w3-button w3-left" }, "\u2630"], document.querySelector("#topNav"), "before");
}
