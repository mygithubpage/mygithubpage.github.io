function addHighlight(element) {
    element.style.color = bgColor;
    element.style.fontWeight = "bold";
    if (element.tagName === "u") element.style.textDecoration = `underline ${bgColor} solid`;
}

function removeHighlight(element) {
    element.style.color = "black";
    element.style.fontWeight = "normal";
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
        return ("0" + parseInt(x).toString(16)).slice(-2);
    }
    return hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
}

function closeModal(modal) {
    modal.style.display = "none";
    main.removeChild(main.lastChild);
}

function toggleElement() {
    topNav.hide();
    footer.hide();
    main.classList.toggle("w3-hide");
}

function createChoiceInput(parent, choiceType, innerHTML, name = choiceType) {
    let label = createNode(["label", {
        class: "my-label"
    }], parent);
    createNode(["span", innerHTML], label);
    createNode(["input", {
        name: name,
        type: choiceType
    }], label);
    createNode(["span", {
        class: "my-" + choiceType
    }], label);
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

function waitLoad(selector, func) {
    document.querySelector(selector).onload = () => {
        func();
    };
}