/**
 * my initialize javascript
 * comes before any other script 
 */

function createNode(tag, attributes) {
    /** element format
     * <tagName>, {[attributeName : attributeValue[, attributeName : attributeValue]...]}
     */

    var node = document.createElement(tag.match(/\w+/)[0]);

    for (let i = 0; i < Object.keys(attributes).length; i++) {
        node.setAttribute(Object.keys(attributes)[i], Object.values(attributes)[i]);
    }

    document.head.appendChild(node);
    return node;
}

/**
 * function createHtmlString(node) {
    let string = "";

    if (typeof node[1] == "object") {
        for (let i = 0; i < Object.keys(node[1]).length; i++) {
            string += `${Object.keys(node[1])[i]}="${Object.values(node[1])[i]}"`
        }
        string += `>${node[2] ? node[2] : ""}`
    } else if (typeof node[1] == "string") {
        string += `>${node[1]}`;
    }
    return `<${node[0]} ${string}</${node[0]}>`

}
 */

function getUri(uri) {
    let folders = uri.split("/")
    return {
        scheme: uri.match(/^.*(?=:\/\/)/)[0],
        //host: uri.match(/(?<=:\/\/).*?(?=[:\/])/)[0],
        //port: uri.match(/(?<=:)\d+/) != null ? uri.match(/(?<=:)\d+/)[0] : "",
        file: folders.slice(-1)[0].match(/.+\.?\w+(?=\??)/)[0],
        folders: folders.slice(3, folders.length - 1),
        query: uri.match(/\?.*#?/) != null ? uri.match(/\?.*(?=#?)/)[0] : "",
        fragment: uri.match(/#.*$/) != null ? uri.match(/#.*?$/)[0] : ""
    }
}

function waitLoad(selector, func) {
    document.querySelector(selector).onload = () => {
        func();
    };
}

function getRandom(max) {
    return Math.floor(Math.random() * Math.floor(max));
}

function addColor() {

    let cssNumber = getRandom(colors.length)
    let css = colors[cssNumber];
    let schemeNumber = getRandom(css.schemes.length)
    let scheme = css.schemes[schemeNumber]
    let colorNumber = getRandom(scheme.color.length)
    color = `${css.css}${scheme.scheme == "" ? "": "-"}${scheme.scheme}-` + scheme.color[colorNumber];

}

// Add <meta> <link> <script> element in head
function addHead() {

    $("<meta>", {
        charset: "utf-8"
    }).appendTo(head);

    // Mobile first
    $("<meta>", {
        name: "viewport",
        content: "width=device-width, initial-scale=1"
    }).appendTo(head);

    // CSS 
    let styles = ["w3", "w3-colors", "style"]
    $(styles).each(function () {
        $("<link>", {
            rel: "stylesheet",
            href: `${folder}/css/${this}.css`
        }).appendTo(head);
    });

    // Website Icon
    $("<link>", {
        rel: "icon",
        href: `${icons8}color/50/ffffff/external-link.png`,
        size: "16x16",
        type: "image/png"
    }).appendTo(head);

}

function addTopNav(color) {

    // Set Bar Item
    if (uri.includes("/toefl/")) {
        var test = "/toefl/"
        var barItems = ["TPO", "Essay", "OG", "PT", "EQ", "BE", "Cambridge", "Longman", "Notes"];
    } else if (uri.includes("/gre/")) {
        var test = "/gre/";
        var barItems = ["OG", "PQ", "PR", "Kap", "MP", "BE", "MH", "Grubers", "Notes"];
    } else {
        var test = "/"
        var barItems = ["Notes", "TOEFL", "GRE"];
    }


    topNav = $("<nav>", {
        class: `${color} w3-bar w3-card w3-center w3-margin-bottom`,
        id: "topNav"
    }).prependTo($("body"));

    let size = mobileFlag ? 16 : 18;
    let padding = mobileFlag ? "0 8px" : "4px 8px";
    $("<a>", {
        href: `${folder}/index.html`,
        class: "w3-bar-item w3-button",
        html: `<img src="${icons8}android/${size}/ffffff/home.png">`
    }).appendTo(topNav).css("padding", padding);

    // Add Bar Item
    $(barItems).each(function () {
        $("<a>", {
            href: folder + test + this.toLowerCase() + `/${this.toLowerCase()}.html`,
            class: "w3-bar-item w3-button my-padding",
            html: this
        }).appendTo(topNav);
    });

    // Add Top Nav Button
    $("<button>", {
        id: "topNavBtn",
        class: "w3-bar-item w3-button w3-right w3-hide-large w3-hide-medium w3-padding-small",
        html: "\u25BC"
    }).appendTo(topNav).click(function () {

        // toggle top navigation bar item
        hiddenNavItems.each(function () {
            $(this).toggleClass("w3-bar-block w3-hide-small");
        });

        // toggle top navigation shape
        if ($(this).html() == "\u25B2") {
            $(this).html("\u25BC");
        } else {
            $(this).html("\u25B2");
        }
    });


    $(window).scroll(() => {
        if (window.pageYOffset != $(topNav).offset().Top) {
            $(topNav).addClass("my-fixed")
        }
    });

}

function addFooter(color) {

    var icons = ["youtube", "twitter", "facebook", "instagram", "linkedin", "pinterest"]

    footer = $("<footer>", {
        class: `${color} w3-container w3-center w3-margin-top`
    }).appendTo($("body"));

    $("<p>", {
        html: "This is my social media."
    }).appendTo(footer);

    $(icons).each(function () {
        $("<img>", {
            src: `${icons8}metro/20/ffffff/${this}.png`,
            class: "my-margin-small"
        }).appendTo($("<a>", {
            href: `https://www.${this}.com`
        }).appendTo(footer));
    });

    $("<p>", {
        html: `Made by <a href="https://mygithubpage.github.io">GitHubPages</a>`
    }).appendTo(footer);
}

function addScripts() {
    var scripts = [{
        dir: "literals/",
        names: ["colors", "vocabulary", "notes", "bookmarks", "categories", "topics"]
    }, {
        dir: "",
        names: ["utility", "style", "filter", "test", "word", "svg", "external"]
    }, ]

    $(scripts).each(function () {
        let dir = this.dir
        $(this.names).each(function () {
            createNode("<script>", {
                id: `${this}`,
                src: `${folder}/js/${dir}${this}.js`
            }).async = false;
        })
    });
}
// Execute script after window load

mobileFlag = screen.width < 600 ? true : false;
html = getUri(uri).file;
icons8 = "https://png.icons8.com/";
bgColor = "";

window.addEventListener("load", () => {
    $(() => {
        head = $("head");
        main = $("main");
        sidebar = $("#sidebar");

        if ($("#questions").length) questions = $("#questions [id^='question']");
        else questions = $("#question > div");
        testFlag = questions.length || $("#question").length;
        addScripts();
        addHead();
        
        if (typeof colors != "undefined" && colors && typeof colors.length != "undefined") {
            addColor();
            addTopNav(color);
            addFooter(color);
            bgColor = window.getComputedStyle(topNav[0]).backgroundColor;
        } else {
            waitLoad("#colors", () => {
                addColor();
                addTopNav(color);
                addFooter(color);
            }); 
        }
        
    });
})