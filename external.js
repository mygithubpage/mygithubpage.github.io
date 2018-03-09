// My Personal JavaScript


hideBarItems = document.querySelectorAll(".w3-hide-small");
sidebarBtn = document.querySelector("#sidebarBtn");
sidebar = document.querySelector("#sidebar");
topNavBtn = document.querySelector("#topNavBtn");
topNav = document.querySelector("#topNav"); 


function toggleTopNav(thisElem) {

    // toggle sidebar button
    if (sidebarBtn) { 
        sidebarBtn.classList.toggle("w3-hide");
        sidebar.classList.add("w3-hide"); 
    }

    // toggle top navigation bar item
    hideBarItems.forEach(element => {
        element.classList.toggle("w3-bar-block");
        element.classList.toggle("w3-hide-small");
    });

    // toggle top naviagtion shape
    if (thisElem.innerText == "\u25B2") {
        thisElem.innerText = "\u25BC";
    } else {
        thisElem.innerText = "\u25B2";
    }
}

function toggleAccordion(name) {
    var elem = document.getElementById(name);
    elem.classList.toggle("w3-show");
    elem.previousElementSibling.classList.toggle(color);
}

function highlight(thisElem) {
    // Hint: Use unchanged class name
    var elems = document.getElementsByClassName(thisElem.className.split(" ")[0]);

    for (let index = 0; index < elems.length; index++) {
        elems[index].classList.toggle(color);
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

function addHighlight() {
    var highlightElems = document.querySelectorAll("[class*='h-']");
    if(highlightElems) {
        highlightElems.forEach(element => {
            element.addEventListener('mouseover', function() {highlight(element)} );
            element.addEventListener('mouseout', function() {highlight(element)} );
          });
    }
}

function initialize() {

    document.querySelectorAll(".my-color").forEach(element => {
        element.classList.remove("my-color");
        element.classList.add(color);
    });

    document.querySelectorAll(".underline").forEach(element => {
        element.style.fontWeight = "bold"
    });

    document.querySelectorAll(".time").forEach(element => {
        element.classList.add("w3-hide")
    });
    
    // Add Top Navigation Button Click Event and Tag Click Event.
    topNavBtn.addEventListener('click', function () { toggleTopNav(topNavBtn) });

    addTagClick(document.querySelectorAll('.w3-tag'));
    addTagClick(document.querySelectorAll('a.w3-bar-item'));

    let sidebarItems = document.querySelectorAll("#sidebar > a");
    if(sidebarItems.length > 0) {
        sidebarItems.forEach(element => {
            let item = document.querySelector("#" + element.href.split("#")[1]);
            element.addEventListener('click', function () { 
                sidebar.classList.add("w3-hide");
                window.onscroll = function () { toggleFixed(item);}
            });
        });
    }

    if(sidebarBtn) { sidebarBtn.addEventListener('click', function () { sidebar.classList.toggle("w3-hide"); }); }
    window.onscroll = function () { toggleFixed(topNav);}
    
    removeLeadingWhiteSpace(); // Remove Leading WhiteSpace in pre tag.
    
}

initialize(); 