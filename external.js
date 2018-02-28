// My Personal JavaScript


// 
document.onload = function () {
    var hideNav = document.querySelector("#hideNav");
    var sidebarBtn = document.querySelector("#sidebarBtn");
    var sidebar = document.querySelector("#sidebar");
    var topNavBtn = document.querySelector("#topNavBtn");
    var topNav = document.querySelector("#topNav");
}

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
    
    hideNav.classList.toggle("w3-bar-block");

    // toggle sidebar button
    if (sidebarBtn) { 
        sidebarBtn.classList.toggle("w3-hide");
        sidebar.classList.add("w3-hide"); 
    }

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

function toggleFixed(element) {
    if (window.pageYOffset !== element.offsetTop) {
        topNav.classList.add("sticky")
    } else { // Remove "sticky" when you leave the scroll position
        topNav.classList.remove("sticky"); 
    }
}

// If Article Tag or Top Bar Item is clicked, store the content of clicked tag in sessionStorage
function addTagClick(tags) {
    for (let index = 0; index < tags.length; index++) {
        const element = tags[index];
        element.addEventListener('click', function () { sessionStorage.setItem("tag", element.textContent); })
    }
}

// Set Timer
function setTimer(second) {
    var timerBtn = document.querySelector("#timerBtn");
    var timeSpan = document.querySelector("#timeSpan");

    var timer = second, min = 0, sec = 0;

    function startTimer(params) {
        min = parseInt(timer / 60);
        sec = parseInt(timer % 60);

        if(timer < 0) { return }
        let secStr = sec < 10 ? "0" + sec.toString() : sec.toString()
        timeSpan.innerHTML = min.toString() + ":" + secStr;
        timer--;
        setTimeout(function () { startTimer(); }, 1000);
    }

    timerBtn.addEventListener("click", function () { startTimer(); });
}

// Remove Leading WhiteSpace in pre tag.
function removeLeadingWhiteSpace() {
    var pres = document.getElementsByTagName('pre');
    for (const pre of pres) {
      let lines = pre.innerHTML.split( '\n' );
      let length = lines[1].length - lines[1].trimLeft(' ').length // The Greatest WhiteSpace Length to be removed
      let innerHtml = "";
      
      for (let index = 0; index < lines.length; index++) {
        const element = lines[index];
        let newLine = "\n";

        // Remove first and last empty line
        if(index == 0 || index == lines.length - 2) { newLine = ""; }

        innerHtml += element.replace(' '.repeat(length)) + newLine;
        innerHtml = innerHtml.replace('undefined', "");
      }
      pre.innerHTML = innerHtml.trimLeft('\n').trimRight('\n');
    }
}

function initialize() {
    var highlightElems = document.querySelectorAll("[class*='h-']");
    if(highlightElems) {
        highlightElems.forEach(element => {
            element.addEventListener('mouseover', function() {highlight(element)} );
            element.addEventListener('mouseout', function() {highlight(element)} );
          });
    }

    // Add Top Navigation Button Click Event and Tag Click Event.
    topNavBtn.addEventListener('click', function () { toggleTopNav(topNavBtn) });

    addTagClick(document.querySelectorAll('.w3-tag'));
    addTagClick(document.querySelectorAll('a.w3-bar-item'));

    

    let sidebarItems = document.querySelectorAll("#sidebar > a");
    sidebarItems.forEach(element => {
        let item = document.querySelector("#" + element.href.split("#")[1]);
        element.addEventListener('click', function () { 
            sidebar.classList.add("w3-hide");
            topNav.classList.remove("sticky"); 
            window.onscroll = function () { toggleFixed(item);}
        });
    });

    if(sidebarBtn) {
        sidebarBtn.addEventListener('click', function () { sidebar.classList.toggle("w3-hide"); });
    }
    removeLeadingWhiteSpace(); // Remove Leading WhiteSpace in pre tag.

}
