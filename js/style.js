function updateCharacter() {
    main.innerHTML = main.innerHTML.replace(/\u00E2\u20AC\u201D/g, "\u2013")
    main.innerHTML = main.innerHTML.replace(/\u00E2\u20AC\u201C/g, "\u2014")
    main.innerHTML = main.innerHTML.replace(/\u00E2\u20Ac\u2122/g, "\u2019")
    main.innerHTML = main.innerHTML.replace(/\u00E2\u20AC\u0153/g, "\u201C")
    main.innerHTML = main.innerHTML.replace(/\u00E2\u20AC\u009D/g, "\u201D")
    main.innerHTML = main.innerHTML.replace(/\u00E2\u20AC\u00A6/g, "\u2026")
}

function addInputColor() {
    let inputs = document.querySelectorAll("input");

    document.querySelectorAll(".my-label").forEach(label => label.onclick = () => {
        if (label.querySelector("input").getAttribute("type") === "radio") {
            let name = label.querySelector("input").getAttribute("name");

            for (let i = 0; i < inputs.length; i++) {
                const node = inputs[i].parentNode;
                if (inputs[i].getAttribute("name") !== name) {
                    continue
                }
                node.querySelector(".my-radio").style.backgroundColor = "lightgray";
            }
            label.querySelector(".my-radio").style.backgroundColor = bgColor;
        } else if (label.parentNode.tagName == "td") {
            if (element.children[0].checked) {
                element.querySelector(".my-checkbox").style.backgroundColor = "lightgray";
                element.children[0].checked = false;
                return
            }

            let name = element.querySelector("input").getAttribute("name");

            for (let i = 0; i < inputs.length; i++) {
                const node = inputs[i].parentNode;
                if (inputs[i].getAttribute("name") !== name) {
                    continue
                }
                node.querySelector(".my-checkbox").style.backgroundColor = "lightgray";
                if (node.children[0].checked) {
                    node.children[0].checked = false;
                }
            }
            element.querySelector(".my-checkbox").style.backgroundColor = bgColor;
            element.children[0].checked = true;
        } else {
            if (label.querySelector("input").checked) {
                label.querySelector(".my-checkbox").style.backgroundColor = bgColor;
            } else {
                label.querySelector(".my-checkbox").style.backgroundColor = "lightgray";
            }
        }
    });
}

function renameTitle() {
    function titleCase(str) {
        var splitStr = str.toLowerCase().split(' ');
        for (var i = 0; i < splitStr.length; i++) {
            // You do not need to check if i is larger than splitStr length, as your for does that for you
            // Assign it back to the array
            splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);
        }
        // Directly return the joined string
        return splitStr.join(' ');
    }

    title = html.split(".")[0].replace(/-/g, ' ');
    title = title.replace("og ", "Official Guide ");
    title = title.replace("pq ", "Practice Questions ");
    title = title.replace("mh ", "McGraw-Hill ");
    title = title.replace("kap ", "Kaplan ");
    title = title.replace("pr ", "Princeton Review ");
    title = title.replace("mp ", "Manhattan Prep ");
    title = title.replace(" es", " Exercise Set");
    title = title.replace(" ps", " Practice Set");
    if (!document.title) document.title = titleCase(title);
    document.title = document.title.replace("Mcgraw-hill ", "McGraw-Hill ");

}

function setListStyle() {
    var selector = ""
    icons = ["material/9/,/filled-circle", "material/9/,/circled", "material-sharp/9/,/unchecked-checkbox", "windows/9/,/unchecked-checkbox"]
    for (let i = 0; i < 4; i++) {
        const element = icons[i].split(",");
        selector += ">ul>li";
        if (i == 0) selector = "ul>li"
        document.querySelectorAll(selector).forEach(li => li.style.listStyle = `url('${icons8}${element[0]}${rgb2hex(bgColor)}${element[1]}')`)
    }

    document.querySelectorAll("ol>ol").forEach(ol => ol.style.listStyle = "lower-alpha");
}

function removeLeadingWhiteSpace() {
    var pres = document.querySelectorAll("pre");
    if (!pres) return
    for (const pre of pres) {
        let lines = pre.innerHTML.split("\n");
        if (lines[1]) {
            let length = lines[1].length - lines[1].trimLeft(" ").length // The Greatest WhiteSpace Length to be removed
            let innerHTML = "";

            for (let index = 0; index < lines.length; index++) {
                const element = lines[index];
                let newLine = "\n";

                // Remove first and last empty line
                if (index == 0 || index == lines.length - 2) {
                    newLine = "";
                }

                innerHTML += element.replace(" ".repeat(length)) + newLine;
                innerHTML = innerHTML.replace("undefined", "");
            }
            pre.innerHTML = innerHTML.trimLeft("\n").trimRight("\n");
        }
    }
}

function setStyle() {


    document.querySelectorAll(".my-color").forEach(element => element.className = element.className.replace("my-color", color));
    document.querySelectorAll(".my-search").forEach(element => {
        element.className = element.className.replace(/my\-search/, "w3-btn w3-section w3-large my-padding-mobile w3-right");
    })

    document.querySelectorAll(".my-tag").forEach(element => {
        element.className = element.className.replace(/^my\-tag$/, "my-tag w3-btn w3-padding-small my-margin-small my-highlight my-border");
    })
    document.querySelectorAll(".my-border, hr").forEach(element => {
        element.style.border = `2px solid ${bgColor}`
    });
    document.querySelectorAll(".my-code").forEach(element => {
        element.className = element.className.replace("my-code", "w3-code w3-panel w3-card w3-light-gray");
        element.style.borderLeft = `2px solid ${bgColor}`
    })
    document.querySelectorAll(".my-highlight, h1, h2, h3, h4, h5, h6, b, u, em").forEach(element => addHighlight(element));

    renameTitle();
    addInputColor();
    setListStyle();
    hideNavItems();
}

function addTOC() {

    function addHeading(level, section, parent) {
        if (level > 6 || section.querySelectorAll("h" + level).length < 1) return;
        let parentId = "";
        if (level > 2) parentId = parent.lastChild.children[1].id.split("#h")[1]
        let div = createNode(["div", {
            class: "w3-hide",
            id: (level > 2 ? "s" + parentId : "")
        }], parent);
        if (level == 2) div.classList.remove("w3-hide");

        for (let i = 0; i < section.querySelectorAll("h" + level).length; i++) {
            let heading = section.querySelectorAll("h" + level)[i];

            //heading.parentNode.querySelectorAll(i+1);
            heading.id = "h" + (level > 2 ? parentId : "") + level + i
            let headingDiv = createNode(["div", {
                class: "w3-padding-small",
            }], div);

            let btn = createNode(["span", {
                class: "w3-padding-small my-button"
            }, "\u23F5"], headingDiv)
            btn.onclick = (btn) => {
                if (btn.target.innerText == "\u23F5") {
                    btn.target.innerText = "\u23F7";
                } else if (btn.target.innerText == "\u23F7") {
                    btn.target.innerText = "\u23F5";
                }
                sidebar.querySelectorAll("#s" + heading.id.match(/\d+/)).forEach(element => element.classList.toggle("w3-hide"))
            };


            let a = createNode(["a", {
                class: "w3-padding-small my-link my-button",
                id: "#" + heading.id
            }, heading.innerText], headingDiv);
            a.onclick = (a) => {
                sidebar.classList.toggle("w3-hide");
                main.querySelector(a.target.id).scrollIntoView();
                window.scrollBy(0, -40);
            };
            a.style.whiteSpace = "nowrap";

            headingDiv.childNodes.forEach(e => addHighlight(e));
            headingDiv.style.textIndent = (level - 2) * 20 + "px"
            addHeading(level + 1, heading.parentNode, div)
        }
    }

    sidebar.className = "w3-sidebar w3-card w3-hide w3-light-gray";
    // Create Search Button
    sidebarBtn = createNode(["button", {
        class: "w3-button w3-left my-padding-mobile",
        id: "sidebarBtn"
    }, "\u2630"], topNav[0], true);

    sidebarBtn.onclick = () => sidebar.classList.toggle("w3-hide");

    // Create Search Input
    let div = createNode(["div", {
        class: "w3-padding-small w3-bar",
    }], sidebar);

    for (i = 2; i < 7; i++) {
        if (document.querySelectorAll(`h${i}`).length > 2) break
    }
    addHeading(i, main, sidebar)
    sidebar.querySelectorAll("a").forEach(a => {
        if (!sidebar.querySelector("#s" + a.id.split("#h")[1])) a.previousElementSibling.innerText = "\u2003"
    })
    createSearchBtn(div, `${color} my-search`, filterNodes, sidebar.querySelectorAll(".my-link")).addEventListener("click", () => {
        sidebar.querySelectorAll(".my-button").forEach(e => e.classList.toggle("w3-hide"));
        sidebar.querySelectorAll("div").forEach(e => {
            e.classList.remove("w3-hide");
            e.classList.remove("w3-padding-small");
        });
    });
}