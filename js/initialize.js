/**
 * my initialize javascript
 * comes before any other script 
 */

function createNode(element, parent, before) {
    /** element format
     * <[><tagName>, {[attributeName : attributeValue[, attributeName : attributeValue]...]}, [innerHTML]<]>
     */

    if (!parent) {
        parent = document.head;
    }

    var node = document.createElement(element[0]);

    if (typeof element[1] == "object") {
        for (let index = 0; index < Object.keys(element[1]).length; index++) {
            node.setAttribute(Object.keys(element[1])[index], Object.values(element[1])[index]);
        }
        node.innerHTML = element[2] ? element[2] : "";
    } else if (typeof element[1] == "string") {
        node.innerHTML = element[1];
    }

    if (!before) {
        parent.appendChild(node);
    } else {
        parent.insertBefore(node, parent.firstElementChild);
    }
    return node;
}

function createHtmlString(node) {
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

function addColor() {

    function getRandomInt(max) {
        return Math.floor(Math.random() * Math.floor(max));
    }

    let colors = [{
        "css": "w3",
        "schemes": [{
                "scheme": "",
                "color": ["red", "pink", "purple", "indigo", "blue", "teal", "green", "brown", "deep-orange"]
            },
            {
                "scheme": "flat",
                "color": ["turquoise", "green-sea", "emerald", "nephritis", "peter-river", "belize-hole", "amethyst", "wisteria", "orange", "carrot", "pumpkin", "alizarin", "pomegranate"]
            },
            {
                "scheme": "metro",
                "color": ["light-green", "green", "dark-green", "magenta", "light-purple", "purple", "dark-purple", "teal", "blue", "dark-blue", "dark-orange", "red", "dark-red"]
            }
        ]
    }]

    let cssNumber = getRandomInt(colors.length)
    let css = colors[cssNumber];
    let schemeNumber = getRandomInt(css.schemes.length)
    let scheme = css.schemes[schemeNumber]
    let colorNumber = getRandomInt(scheme.color.length)
    color = `${css.css}${scheme.scheme == "" ? "": "-"}${scheme.scheme}-` + scheme.color[colorNumber];
}

// Add <meta> <link> <script> element in head
function addHead() {

    if (uri.includes("quantitative")) {
        scripts = [
            "mathjax/2.7.5/MathJax.js",
            "jsxgraph/1.3.5/jsxgraphcore.js"
        ]
        scripts.forEach(script => {
            $(createHtmlString(["script", {
                src: `${prefix}${script}`
            }])).appendTo(head);
        });
    }

    $(createHtmlString(["meta", {
        charset: "utf-8"
    }])).appendTo(head);

    // Mobile first
    $(createHtmlString(["meta", {
        name: "viewport",
        content: "width=device-width, initial-scale=1"
    }])).appendTo(head);


    // Website Icon
    $(createHtmlString(["link", {
        rel: "icon",
        href: `${icons8}color/50/ffffff/external-link.png`,
        size: "16x16",
        type: "image/png"
    }])).appendTo(head);

    // CSS 
    let styles = ["w3", "w3-colors", "style", "hljs"]
    styles.forEach(css => {
        $(createHtmlString(["link", {
            rel: "stylesheet",
            href:  `${folder}/css/${css}.css`
        }])).appendTo(head);
    });

    // My javascript
    scripts = [{
        folder: "",
        scripts: ["vocabulary", "category", "variable", "utility", "style", "filter", "test", "word", "svg", "external"]
    }, ]
    scripts.forEach(dir => {
        dir.scripts.forEach(script => {
            createNode(["script", {
                id: `${script}`,
                src:  `${folder}/js/${dir.folder}${script}.js`
            }]);
        });
    });

    if (document.querySelector("pre")) {
        $(createHtmlString(["script", {
            src: `${prefix}highlight.js/9.12.0/highlight.min.js`
        }])).appendTo(head);
        languages = ["apache", "bash", "cs", "cpp", "css", "coffeescript", "diff", "xml", "http", "ini", "json", "java", "js", "makefile", "markdown", "nginx", "objectivec", "php", "perl", "python", "ruby", "sql", "shell"]
        document.querySelectorAll("code").forEach(code => {
            let language = code.className.split(" ")[0];
            if (language && !languages.includes(language) && !language.includes("-")) {
                languages.push(language);
                if (language == "ps") language = "powershell"
                $(createHtmlString(["script", {
                    src: `${prefix}highlight.js/9.12.0/languages/${language}.min.js`
                }])).appendTo(head);
            }
        });
    }

}

function addTopNav(color) {

    // Set Bar Item
    if (uri.includes("/toefl/")) {
        var test = "/toefl/"
        var barItems = ["TPO", "Essay", "OG", "PT", "EQ", "Barrons", "Cambridge", "Longman", "Notes"];
    } else if (uri.includes("/gre/")) {
        var test = "/gre/";
        var barItems = ["OG", "PQ", "PR", "Kap", "MP", "Barrons", "MH", "Mangoosh", "Grubers", "Notes"];
    } else {
        var test = "/"
        var barItems = ["Notes", "TOEFL", "GRE"];
    }


    topNav = $(createHtmlString(["nav", {
        class:  `${color} w3-bar w3-card w3-center w3-margin-bottom`,
        id: "topNav"
    }])).prependTo($("body"));

    let size = mobileFlag ? 16 : 18;
    let padding = mobileFlag ? "0 8px" : "4px 8px";
    $(createHtmlString(["a", {
        href:  `${folder}/index.html`,
        class: "w3-bar-item w3-button"
    }, `<img src="${icons8}android/${size}/ffffff/home.png">`])).appendTo(topNav).css("padding", padding);
    // Add Bar Item
    for (let i = 0; i < barItems.length; i++) {
        const element = barItems[i];

        $(createHtmlString(["a", {
            href: folder + test + element.toLowerCase() + `/${element.toLowerCase()}.html`,
            class: "w3-bar-item w3-button my-padding-mobile"
        }, element])).appendTo(topNav);

    }

    // Add Top Nav Button
    $(createHtmlString(["button", {
        id: "topNavBtn",
        class: "w3-bar-item w3-button w3-right w3-hide-large w3-hide-medium w3-padding-small"
    }, "\u25BC"])).appendTo(topNav).click(btn => {

        let topNavBtn = $(btn.target)
        // toggle top navigation bar item
        hiddenNavItems.each(function () {
            $(this).toggleClass("w3-bar-block");
            $(this).toggleClass("w3-hide-small");
        });

        // toggle top navigation shape
        if (topNavBtn.text() == "\u25B2") {
            topNavBtn.text("\u25BC");
        } else {
            topNavBtn.text("\u25B2");
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

    footer = $(createHtmlString(["footer", {
        class: `${color} w3-container w3-center w3-margin-top`
    }])).appendTo($("body"));

    $(createHtmlString(["p", "This is my social media."])).appendTo(footer);

    icons.forEach(element => {
        let a = $(createHtmlString(["a", {
            href: `https://www.${element}.com`
        }])).appendTo(footer);
        $(createHtmlString(["img", {
            src: `${icons8}metro/20/ffffff/${element}.png`,
            class: "my-margin-small"
        }])).appendTo(a);
    });
    let p = $(createHtmlString(["p"])).appendTo(footer);

    $(createHtmlString(["span", "Made by "])).appendTo(p);
    $(createHtmlString(["a", {
        href: "https://mygithubpage.github.io"
    }, "GitHubPages"])).appendTo(p);
}

// Execute script after window load

mobileFlag = screen.width < 600 ? true : false;
html = uri.split("/").slice(-1)[0];
icons8 = "https://png.icons8.com/";


window.addEventListener("load", () => {
    $(() => {
        head = $("head");
        addHead();
        addColor();
        addTopNav(color);
        addFooter(color);
    });
})