// My Personal JavaScript

// Toggle to add or remove classes
function toggleByClass(elem, toggleClass) {
    for (let i = 0; i < elem.length; i++) {
        // if the element has the class, remove it; otherwise add the class to the element
        if (elem[i].className.indexOf(toggleClass[i]) !== -1) {
            elem[i].className = elem[i].className.replace(" " + toggleClass[i], "");
        } else {
            elem[i].className += " " + toggleClass[i];
        }
    }
}

function toggleTopNav(thisElem) {
    // toggle block display
    var hideNav = document.getElementById("hideNav");
    hideNav.classList.toggle("w3-bar-block");

    // toggle sidebar button
    var sidebarButton = document.getElementById("sidebar-btn");
    if (sidebarButton) { sidebarButton.classList.toggle("w3-hide"); }

    // toggle top navigation bar item
    for (let index = 0; index < hideNav.children.length; index++) {
        hideNav.children[index].classList.toggle("w3-hide-small");
    }

    // toggle top naviagtion shape
    if (thisElem.innerText == "\u25B2") {
        thisElem.innerText = "\u25BC";
    } else {
        thisElem.innerText = "\u25B2";
    }
}


function toggleSidebar() {
    document.getElementById("sidebar").classList.toggle("w3-hide");
}

function toggleAccordion(name) {
    var elem = document.getElementById(name);
    var color = document.getElementsByTagName("footer")[0].className.split(" ")[1];
    elem.classList.toggle("w3-show");
    elem.classList.toggle(color);
    //toggleByClass([elem, elem.previousElementSibling], ["w3-show", color]);
}

function highlight(thisElem) {
    // Hint: Use unchanged class name
    var elems = document.getElementsByClassName(thisElem.className.split(" ")[0]);
    var color = document.getElementsByTagName("footer")[0].className.split(" ")[1];

    for (let index = 0; index < elems.length; index++) {
        elems[index].classList.toggle(color);
    }
}

function setTag() {
    var topNavBtn = document.querySelector('#topNavBtn');
    topNavBtn.addEventListener('click', function () { toggleTopNav(topNavBtn) });

    addTagClick(document.querySelectorAll('.w3-tag'));
    addTagClick(document.querySelectorAll('a.w3-bar-item'));
}

function addTagClick(tags) {
    for (let index = 0; index < tags.length; index++) {
        const element = tags[index];
        element.addEventListener('click', function () { sessionStorage.setItem("tag", element.textContent); })
    }
}

function removeLeadingWhiteSpace() {
    var pres = document.getElementsByTagName('pre');
    for (const pre of pres) {
      let lines = pre.innerHTML.split( '\n' );
      let length = lines[1].length - lines[1].trimLeft(' ').length
      let innerHtml = "";
      
      for (let index = 0; index < lines.length; index++) {
        const element = lines[index];
        let newLine = "\n";

        if(index == 0 || index == lines.length - 2) { newLine = ""; }
        innerHtml += element.replace(' '.repeat(length)) + newLine;
        innerHtml = innerHtml.replace('undefined', "");
      }
      pre.innerHTML = innerHtml.trimLeft('\n').trimRight('\n');
    }
}