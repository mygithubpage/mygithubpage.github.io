/* 

my initialize javascript
comes before any other script 

*/

// Execute script after window load
window.addEventListener("load", function () { 
    
    addHead();
    addColor();
    addTopNav(color);
    addFooter(color);
});

function addColor() {
    colors = { 
        blog : "w3-black",
        notes : "w3-black",  
        essay : "w3-brown",
        tpo : "my-crimson",
        og : "my-dark-blue",
        barrons : "w3-green"
    };
    var path = location.pathname.split("/");
    color = colors[path[path.length - 2]];
    
    if(!color) { 
        if(path[path.length - 1].startsWith("tpo")) { color = colors.tpo }
        if(path[path.length - 1].startsWith("index")) { color = colors.barrons; }
        if(path[path.length - 1].startsWith("toefl")) { color = colors.og; }
    }
}

// Add <meta> <link> <script> element in head
function addHead() {

    var meta;
    var link;
    var script;

    // UTF-8 charset
    meta = document.createElement("meta");
    meta.setAttribute("charset", "utf-8");
    document.head.appendChild(meta);

    // Mobile first
    meta = document.createElement("meta");
    meta.name = "viewport";
    meta.content = "width=device-width, initial-scale=1";
    document.head.appendChild(meta);

    
    // My CSS
    link = document.createElement("link");
    link.setAttribute("rel", "stylesheet");
    link.href = "/style.css";
    document.head.appendChild(link);

    // W3Schools W3 CSS
    link = document.createElement("link");
    link.setAttribute("rel", "stylesheet");
    link.href = "https://www.w3schools.com/w3css/4/w3.css";
    document.head.appendChild(link);

    // Website Icon
    link = document.createElement("link");
    link.setAttribute("rel", "icon");
    link.setAttribute("sizes", "16x16");
    link.type = "image/png";
    link.href = "https://png.icons8.com/color/50/ffffff/external-link.png"; // from icons8.com
    document.head.appendChild(link);

    // jQuery
    script = document.createElement("script")
    script.src = "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.3.1.js"
    document.head.appendChild(script);

    // My javascript
    script = document.createElement("script")
    script.src = "/external.js"
    document.head.appendChild(script);
}


function addFooter(color) {
    
    var icons = ["youtube", "twitter", "facebook", "instagram", "linkedin", "pinterest"]
    var span = document.createElement("span");
    var a = document.createElement("a");
    var p = document.createElement("p");
    var footer = document.createElement("footer");

    span.textContent = "Powered by ";

    a.href = "https://mygithubpage.github.io"
    a.textContent = "GitHubPages"

    p.textContent = "Find me on social media."
    footer.appendChild(p);

    icons.forEach(element => {
        var img = document.createElement("img");
        img.src = "https://png.icons8.com/metro/20/ffffff/" + element + ".png";
        img.className = "w3-padding-small"
        footer.appendChild(img);
    });

    p = document.createElement("p");
    p.appendChild(span);
    p.appendChild(a);
    footer.appendChild(p);

    footer.className = color + " w3-container w3-center w3-margin-top";
    document.body.appendChild(footer);
}


function addTopNav(color) {
    var barItems = ["TPO", "Notes", "Essay", "OG", "Barrons", "Cambridge", "Longman"]
    
    var button = document.createElement("button");
    var nav = document.createElement("nav");

    for (let index = 0; index < barItems.length; index++) {
        const element = barItems[index];
        let a = document.createElement("a");
        a.href = "/toefl/" + element.toLowerCase() + "/" + element.toLowerCase() + ".html";
        a.className = "w3-bar-item w3-button";
        a.textContent = element;
        if(index > 3) { a.className += " w3-hide-small" }
        nav.appendChild(a);
    }
    button.className = "w3-bar-item w3-button w3-right w3-hide-large w3-hide-medium";
    button.id = "topNavBtn";
    button.textContent = "\u25BC";
    nav.appendChild(button);

    nav.className = color + " w3-bar w3-card w3-center w3-margin-bottom";
    nav.id = "topNav";
    document.body.insertBefore(nav, document.body.firstElementChild);
}

function toggleFixed(element) {
    if (window.pageYOffset !== element.offsetTop) {
        topNav.classList.add("my-fixed")
    } else { // Remove "my-fixed" when you leave the scroll position
        topNav.classList.remove("my-fixed"); 
    }
}

function addSiderbarBtn() {
    var button = document.createElement("button");
    button.className = "w3-button w3-left";
    button.id = "sidebarBtn";
    button.textContent = "\u2630";

    document.querySelector("#topNav").insertBefore(button, document.querySelector("#topNav").firstElementChild);
}
