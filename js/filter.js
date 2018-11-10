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
        func($(this));
        $(this).toggleClass(`${color} my-highlight w3-text-white`);
    });
    setStyle();
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

function toggleFilter(tagBtn) {
    // Add selected tag to array
    if (tagBtn.hasClass("my-highlight")) {
        selectedTags.push(tagBtn.text());
    } else {
        selectedTags.splice(selectedTags.indexOf(tagBtn.text()), 1); // pop element by content
    }

    let entriesTagsArray = [];

    // if the entry do not contains selected tags, it is hidden.
    entries.each(function () {
        entry = $(this);
        // get the entries tag
        let entryTags = $(".my-tag", entry);
        let entryTagsArray = []; // one entry's tags.
        entry.show();

        // join the entry tag in one string
        entryTags.each(function () {
            entryTagsArray.push($(this).text());
            if ($(this).text() == tagBtn.text() && tagBtn.parent().attr("id") == "tagsDiv") {
                $(this).toggleClass(`w3-text-white ${color}` );
            }
        });

        // if one selected tag is not in the entryTagsArray, the entry is hidden
        $(selectedTags).each(function () {
            if (entryTagsArray.indexOf(this.toString()) == -1) {
                entry.hide();
            }
        }); 

        // if the entry is not hidden
        if ($(this).css("display") != "none") {
            $(entryTagsArray).each(function () {entriesTagsArray.push(this.toString())});
            $(".my-tag", tagsDiv).each(function () {
                $(this).show();
                if (entriesTagsArray.indexOf($(this).text()) == -1) {
                    $(this).hide();
                }
                if ($(this).text() == tagBtn.text() && tagBtn.parent().attr("id") != "tagsDiv") {
                    $(this).toggleClass(`w3-text-white ${color}` );
                }
            }); 
        }

        
    }); 

}

function addTags() {
    
    // Create Entry
    function createEntry(entry) {

        function getTitle() {
            let title;
            if (entry.tags.includes("Products")) title = entry.tags[0] + " Products";
            else if (!entry.href.match("wikipedia")) title = entry.tags[0];
            else title = entry.href.split("/").splice(-1)[0].replace(/_/g," ").replace(/.* of /,"");
            return title;
        }

        function getLink() {
            let href;
            if (entry.tags.includes("Products")) href = `products/${entry.href}`;
            else href = entry.href
            return href;
        }

        let div = $("<div>", {
            class: "w3-card-4 w3-padding w3-left my-margin my-entry"
        }).appendTo($("#entries"));
        let titleDiv = $("<div>", {
            class: "w3-section"
        }).appendTo(div);

        $("<a>", {
            class: "my-highlight w3-large my-link",
            href: getLink(),
            html: getTitle()
        }).appendTo(titleDiv).css("padding",0);

        let tagDiv = $("<div>").appendTo(div);
        $("<span>", {
            class: "my-highlight",
            html: "Tags:"
        }).appendTo(tagDiv);

        $(entry.tags).each(function () {
            createTag(this, tagDiv, toggleFilter);
        });
    }

    // create tagsDiv
    let div = $("#tags");
    $("<div>", {
        class: "w3-bar w3-padding-small w3-card w3-large my-color"
    }).appendTo(div).html(`<span class="w3-bar-item my-padding">Tags</span>`);
    var tagsDiv = $("<div>", {
        class: "w3-padding w3-card",
        id: "tagsDiv"
    }).appendTo(div);

    // Get Entries Object
    var regexp = new RegExp("\\w+(?=\.html)");
    if (uri.match(regexp) == "bookmarks") { entries = bookmarks}
    else if (uri.match(regexp) == "notes") { entries = notes}

    if (entries) {
        $(entries).each(function () { createEntry(this) }); // Create Entry Div
        entries = $(".my-entry"); // Get Created Entry
    }


    var tagsArray = []; // All tags need to be show in tag div on load.

    // Create Search Button to Filter Tag
    createSearchBtn(tagsDiv.prev(), "w3-bar-item w3-button w3-right my-padding", filterNodes)

    // Create tags based on entries Tags
    $("#entries .my-tag").each(function () {
        let tag = this.innerHTML;
        let length = $("#entries .my-tag").filter( function () {
            return $(this).text() == tag
        }).length
        if (tagsArray.indexOf($(this).text()) == -1 && length > 1) {
            tagsArray.push($(this).text());
            createTag($(this).text(), tagsDiv, toggleFilter);
        }
    });

    // article tag
    $("a.my-tag").each(function () { this.onclick = () => sessionStorage.setItem("tag", this.text()) })
}