// Tags Filter Functions
// Filter multiple tags
selectedTags = []; // Add element when a tag is selected in tag div. otherwise remove it.

function addFilterClick(selector, classes, parent) {

    parent = parent ? parent : document;
    
    $(selector).each(function () {
        $(this).on("click", () => {
            $(selector).each(function () {
                $(this).removeClass(classes.join(" "));
                if (classes.includes("my-highlight") && !selector.includes("#tagsDiv")) removeHighlight($(this));
            });

            $(this).addClass(classes.join(" "));
            setStyle();
        });
    });
}

function createSearchBtn(parent, className, func, nodes) {
    return $("<button>", {
        id: "searchBtn",
        class: className,
        html: "Search"
    }).appendTo(parent).click(function () {
        // Unselected Tag
        filterSearch($(this), func, nodes);
    });
}

function createTag(innerHTML, parent, func) {
    $("<button>", {
        class: "my-tag",
        html: innerHTML
    }).appendTo(parent).click(function () {
        // Unselected Tag
        func(this);
        this.toggleClass("my-highlight");
        this.toggleClass(color);
        this.toggleClass("w3-text-white");
    });
    setStyle();
}

function toggleFilter(tagBtn) {
    // Add selected tag to array
    if (tagBtn.className.includes("my-highlight")) {
        selectedTags.push(tagBtn.text());
    } else {
        selectedTags.splice(selectedTags.indexOf(tagBtn.text()), 1); // pop element by content
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
            entryTagsArray.push(entryTag.text());
            if (entryTag.text() === tagBtn.text()) {
                entryTag.toggleClass(color);
                entryTag.toggleClass("w3-text-white");
            }
        });

        // if one selected tag is not in the entryTagsArray, the entry is hidden
        selectedTags.forEach(tag => {
            if (entryTagsArray.indexOf(tag) === -1) {
                entry.addClass("w3-hide");
            }
        }); // End of selectedTags foreach  

        // if the entry is not hidden
        if (!entry.classList.contains("w3-hide")) {
            entryTagsArray.forEach(element => entriesTagsArray.push(element));
            tagBtns.forEach(tagBtn => {
                tagBtn.classList.remove("w3-hide");
                if (entriesTagsArray.indexOf(tagBtn.text()) === -1) {
                    tagBtn.addClass("w3-hide");
                }
            }); // End of tag Buttons forEach

        }
    }); // End of entries foreach

}

function filterNodes(value, nodes) {
    nodes = nodes ? nodes : $(".my-tag", tagsDiv);
    nodes.each(function () {
        if ($(this).html().includes(value)) {
            $(this).show();
        } else {
            $(this).hide();
        }
    });
}

// Filter Tag enter by Search Input
function filterSearch(searchBtn, func, nodes) {
    let parent = searchBtn.parent();
    let tagsDiv = parent.next();
    let input = $("#search");

    // Create Search Input
    if (!input.length) {
        let className = searchBtn.attr("class").replace(new RegExp(`${color}|w3-(button|btn)`, "g"), "");
        input = $("<input>", {
            class: `${className} w3-white w3-bar-item my-border`,
            id: "search",
            autofocus: true
        }).appendTo(parent).hide();
    }

    if (searchBtn.is(".my-border")) {
        searchBtn.html("Search").css("border", "none")
        input.val("");
        $(".my-tag", tagsDiv).show();
        if ($("#words").length) $("#words").html("");
    } else {
        searchBtn.html("X");
        input.css("border", `2px solid ${bgColor}`);
    }

    input.toggle();
    searchBtn.toggleClass("my-border");
    //$(".w3-bar-item", main).toggle();

    setStyle();
    // Filter tags while inputting 
    input.on("input", () => {
        func(input.val(), nodes);
    });
}

function addTags() {

    // Create Entry
    function createEntry(entry) {
        let div = $("<div>", {
            class: "w3-card-4 w3-padding w3-left my-margin my-entry"
        }).appendTo(document.querySelector("#entries"));
        let titleDiv = $("<div>", {
            class: "w3-section"
        }).appendTo(div);

        $("<a>", {
            class: "my-highlight w3-large my-link",
            href: entry.href,
            html: entry.tags[0]
        }).appendTo(titleDiv).style.padding = 0;

        let tagDiv = $("<div>").appendTo(div);
        $("<span>", {
            class: "my-highlight",
            html: "Tags:"
        }).appendTo(tagDiv);

        entry.tags.forEach(tag => {
            createTag(tag, tagDiv, toggleFilter);
        });
    }

    // Trigger tag click event
    function clickTag() {
        var tag = sessionStorage.getItem("tag");
        if (tag) {
            tagBtns.forEach(tagBtn => {
                if (tagBtn.text() === tag) {
                    tagBtn.click();
                    sessionStorage.removeItem("tag");
                }
            });
        }
    }

    // If Article Tag or Top Bar Item is clicked, store the content of clicked tag in sessionStorage
    function addTagClick(tags) {
        for (let i = 0; i < tags.length; i++) {
            tags[i].onclick = () => sessionStorage.setItem("tag", tags[i].text());
        }
    }

    // create tagsDiv
    let div = document.querySelector("#tags");
    $("<div>", {
        class: "w3-bar w3-padding-small w3-card w3-large my-color"
    }).appendTo(div).html(`<span class="w3-bar-item my-padding">Tags</span>`);
    var tagsDiv = $("<div>", {
        class: "w3-padding w3-card",
        id: "tagsDiv"
    }).appendTo(div);

    var regexp = new RegExp("\\w+(?=\.html)");
    entries = entries[uri.match(regexp)]; // Get Entries Object from variable.js
    if (entries) {
        entries.forEach(entry => createEntry(entry)); // Create Entry Div
        entries = document.querySelectorAll(".my-entry"); // Get Created Entry
    }

    var tags = document.querySelectorAll("#entries .my-tag"); // All tags in all entries.
    var tagsArray = []; // All tags need to be show in tag div on load.

    // Create Search Button to Filter Tag
    createSearchBtn(tagsDiv.previousElementSibling, "w3-bar-item w3-button w3-right my-padding", filterNodes)

    // Create tags based on entries Tags
    tags.forEach(tag => {
        if (tagsArray.indexOf(tag.text()) === -1) {
            tagsArray.push(tag.text());
            createTag(tag.text(), tagsDiv, toggleFilter);
        }
    });

    // Add article tag in note.html
    tags.forEach(element => element.onclick = () => clickTag(element.text()));

    // Add filter Event for tags in tag div. 
    tagBtns = tagsDiv.querySelectorAll("my-tag");
    // Filter Tag
    clickTag();

    // article tag
    addTagClick(document.querySelectorAll("a.my-tag"));

}