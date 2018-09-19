// Tags Filter Functions
// Filter multiple tags
selectedTags = []; // Add element when a tag is selected in tag div. otherwise remove it.

function addFilterClick(selector, classes, parent) {

    parent = parent ? parent : document;
    document.querySelectorAll(selector).forEach(element => {
        element.addEventListener("click", () => {
            document.querySelectorAll(selector).forEach(element => {
                classes.forEach(c => {
                    element.classList.remove(c)
                    if (c == "my-highlight" && !selector.includes("#tagsDiv")) removeHighlight(element);
                });
            });
            classes.forEach(c => {
                element.classList.add(c)
            });
        });
    });
}

function createSearchBtn(parent, className, func, nodes) {
    let searchBtn = createNode(["button", {
        id: "searchBtn",
        class: className
    }, "Search"], parent);
    searchBtn.onclick = e => {
        // Unselected Tag
        filterSearch(e.target, func, nodes);
    }
    return searchBtn;
}

function createTag(innerHTML, parent, func) {
    createNode(["button", {
        class: "my-tag"
    }, innerHTML], parent).onclick = e => {
        // Unselected Tag
        func(e.target);
        e.target.classList.toggle("my-highlight");
        e.target.classList.toggle(color);
        e.target.classList.toggle("w3-text-white");
    }
    setStyle();
}

function toggleFilter(tagBtn) {
    // Add selected tag to array
    if (tagBtn.className.includes("my-highlight")) {
        selectedTags.push(tagBtn.innerText);
    } else {
        selectedTags.splice(selectedTags.indexOf(tagBtn.innerText), 1); // pop element by content
    }

    let entriesTagsArray = [];

    // if the entry do not contains selected tags, it is hidden.
    entries.forEach(entry => {

        // get the entries tag
        let entryTags = entry.querySelectorAll(".my-tag");
        let entryTagsArray = []; // one entry's tags.
        entry.classList.remove("w3-hide");

        // join the entry tag in one string
        entryTags.forEach(entryTag => {
            entryTagsArray.push(entryTag.innerText);
            if (entryTag.innerText === tagBtn.innerText) {
                entryTag.classList.toggle(color);
                entryTag.classList.toggle("w3-text-white");
            }
        });

        // if one selected tag is not in the entryTagsArray, the entry is hidden
        selectedTags.forEach(tag => {
            if (entryTagsArray.indexOf(tag) === -1) {
                entry.classList.add("w3-hide");
            }
        }); // End of selectedTags foreach  

        // if the entry is not hidden
        if (!entry.classList.contains("w3-hide")) {
            entryTagsArray.forEach(element => entriesTagsArray.push(element));
            tagBtns.forEach(tagBtn => {
                tagBtn.classList.remove("w3-hide");
                if (entriesTagsArray.indexOf(tagBtn.innerText) === -1) {
                    tagBtn.classList.add("w3-hide");
                }
            }); // End of tag Buttons forEach

        }
    }); // End of entries foreach

}

function filterNodes(value, nodes) {
    nodes = nodes ? nodes : tagsDiv.querySelectorAll(".my-tag");
    nodes.forEach(node => {
        if (!node.innerText.includes(value)) {
            node.classList.add("w3-hide");
        } else {
            node.classList.remove("w3-hide");
        }
    });
}

// Filter Tag enter by Search Input
function filterSearch(searchBtn, func, nodes) {
    let parent = searchBtn.parentNode;
    let tagsDiv = parent.nextElementSibling;
    let input = document.querySelector("#search");

    // Create Search Input
    if (!input) {
        let regexp = new RegExp(`${color}|w3-(button|btn)`, "g");
        let className = searchBtn.className.replace(regexp, "");
        input = createNode(["input", {
            class: className + " w3-hide w3-white w3-bar-item my-border",
            id: "search",
            autofocus: true
        }], parent);
    }
    input.classList.toggle("w3-hide");
    searchBtn.classList.toggle("my-border");
    document.querySelectorAll(".w3-bar-item").forEach(elem => elem.classList.toggle("w3-show"));

    if (input.className.includes("w3-hide")) {
        searchBtn.innerText = "Search"
        searchBtn.style.border = "none";
        input.value = "";
        tagsDiv.querySelectorAll(".my-tag").forEach(tag => tag.classList.remove("w3-hide"));
        if (main.querySelector("#words")) main.querySelector("#words").innerHTML = "";
    } else {
        searchBtn.innerText = "X"
    }

    setStyle();
    // Filter tags while inputting 
    input.oninput = () => {
        func(input.value, nodes);
    }
}

function addTags() {

    // Create Entry
    function createEntry(entry) {
        let div = createNode(["div", {
            class: "w3-card-4 w3-padding w3-left my-margin my-entry"
        }], document.querySelector("#entries"));
        let titleDiv = createNode(["div", {
            class: "w3-section"
        }], div);

        createNode(["a", {
            class: "my-highlight w3-large my-link",
            href: entry.href
        }, entry.tags[0]], titleDiv).style.padding = 0;

        let tagDiv = createNode(["div"], div);
        createNode(["span", {
            class: "my-highlight"
        }, "Tags:"], tagDiv);

        entry.tags.forEach(tag => {
            createTag(tag, tagDiv, toggleFilter);
        });
    }

    // Trigger tag click event
    function clickTag() {
        var tag = sessionStorage.getItem("tag");
        if (tag) {
            tagBtns.forEach(tagBtn => {
                if (tagBtn.innerText === tag) {
                    tagBtn.click();
                    sessionStorage.removeItem("tag");
                }
            });
        }
    }

    // If Article Tag or Top Bar Item is clicked, store the content of clicked tag in sessionStorage
    function addTagClick(tags) {
        for (let i = 0; i < tags.length; i++) {
            tags[i].onclick = () => sessionStorage.setItem("tag", tags[i].innerText);
        }
    }

    // create tagsDiv
    let div = document.querySelector("#tags");
    createNode(["div", {
        class: "w3-bar w3-padding-small w3-card w3-large my-color"
    }], div).innerHTML = `<span class="w3-bar-item my-padding-mobile">Tags</span>`;
    var tagsDiv = createNode(["div", {
        class: "w3-padding w3-card",
        id: "tagsDiv"
    }], div);

    var regexp = new RegExp("\\w+(?=\.html)");
    entries = entries[uri.match(regexp)]; // Get Entries Object from variable.js
    if (entries) {
        entries.forEach(entry => createEntry(entry)); // Create Entry Div
        entries = document.querySelectorAll(".my-entry"); // Get Created Entry
    }

    var tags = document.querySelectorAll("#entries .my-tag"); // All tags in all entries.
    var tagsArray = []; // All tags need to be show in tag div on load.

    // Create Search Button to Filter Tag
    createSearchBtn(tagsDiv.previousElementSibling, "w3-bar-item w3-button w3-right my-padding-mobile", filterNodes)

    // Create tags based on entries Tags
    tags.forEach(tag => {
        if (tagsArray.indexOf(tag.innerText) === -1) {
            tagsArray.push(tag.innerText);
            createTag(tag.innerText, tagsDiv, toggleFilter);
        }
    });

    // Add article tag in note.html
    tags.forEach(element => element.onclick = () => clickTag(element.innerText));

    // Add filter Event for tags in tag div. 
    tagBtns = tagsDiv.querySelectorAll("my-tag");
    // Filter Tag
    clickTag();

    // article tag
    addTagClick(document.querySelectorAll("a.my-tag"));

}