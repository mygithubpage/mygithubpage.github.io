function addHighlight(element) {
    element.css({
        color: bgColor,
        fontWeight: "bold"
    });
    if (element[0].tagName === "u") 
    element.css({
        textDecoration: `underline ${bgColor} solid`
    });
}

function removeHighlight(element) {
    element.css({
        color: "black",
        fontWeight: "normal"
    });
}

function toggleHighlight(element) {
    if (element.style.color !== bgColor) {
        addHighlight(element);
    } else {
        removeHighlight(element);
    }
}

function rgb2hex(rgb) {
    rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);

    function hex(x) {
        return `${("0" + (+x).toString(16)).slice(-2)}`;
    }
    return hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
}
function createModal() {
    let parent = typeof testDiv != "undefined" ? testDiv : main;
    return $("<div>", {
        class: "w3-modal-content"
    }).appendTo($("<div>", {
        class: "w3-modal"
    }).appendTo(parent));
    
}

function toggleElement() {
    topNav.toggle();
    footer.toggle();
    main.toggle();
}

function createChoiceInput(parent, type, innerHTML, name = type) {

    let label = $("<label>", {
        class: "my-label"
    }).appendTo(parent).click(function () {
        $("input:checked").next().css("backgroundColor", bgColor);
        $("input:not(:checked)").next().css("backgroundColor", "lightgray");
    });;

    $("<span>", {
        html: innerHTML
    }).appendTo(label);

    $("<input>", {
        name: name,
        type: type
    }).appendTo(label);

    $("<span>", {
        class: `my-${type}` 
    }).appendTo(label);

    return label
}

function hideNavItems() {
    let width = 0;

    topNav.children().each(function () {
        width += this.offsetWidth
        if (width > $(window).width() - 16 && $(this).attr("id") !== "topNavBtn")
            $(this).addClass("w3-hide-small");
    });
    hiddenNavItems = $(".w3-hide-small");
}
