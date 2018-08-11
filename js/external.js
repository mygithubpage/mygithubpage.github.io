// My Personal JavaScript


greFlag = (/verbal|quantitative|reading-|text|sentence|issue|argument/).exec(uri)
hideBarItems = document.querySelectorAll(".w3-hide-small");
sidebarBtn = document.querySelector("#sidebarBtn");
sidebar = document.querySelector("#sidebar");
topNavBtn = document.querySelector("#topNavBtn");
topNav = document.querySelector("#topNav"); 
main = document.querySelector("main"); 
backgroundColor = window.getComputedStyle(document.querySelector("footer")).backgroundColor;
if(greFlag && document.querySelector("#questions")) questions = document.querySelector("#questions").querySelectorAll("[id^='question']");
else questions = document.querySelectorAll("#question > div");
testFlag = questions.length > 0 || document.querySelector("#question");

num = parseInt(html.substr(html.indexOf(".") - 1, 1));
setFlag = html.includes("-");


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

    // toggle top navigation shape
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

function addHighlight(element) {
    if(element) {
        element.style.color = backgroundColor;
        element.style.fontWeight = "bold";
        if(element.tagName === "BUTTON") element.style.border = "1px solid " + backgroundColor;
        if(element.tagName === "U") element.style.textDecoration = "underline " + backgroundColor + " solid";
    }
}

function toggleHighlight(element, remove) {
    if(element.style.color !== backgroundColor && !remove) {
        element.style.color = backgroundColor;
        element.style.fontWeight = "bold";
    }
    else {
        element.style.color = "black";
        element.style.fontWeight = "normal";
    }
}

function addInputColor() {
    let inputs = document.getElementsByTagName("input");

    var addColor = element => {    

        if (element.querySelector("input").getAttribute("type") === "radio") {
            let name = element.querySelector("input").getAttribute("name");
            
            for (let index = 0; index < inputs.length; index++) {
                const node = inputs[index].parentNode;
                if(inputs[index].getAttribute("name") !== name ) { continue }
                node.querySelector(".my-radio").style.backgroundColor = "lightgray";
            }
            element.querySelector(".my-radio").style.backgroundColor = backgroundColor;
        }
        else if (element.parentNode.tagName == "TD") {
            if(element.children[0].checked) { 
                element.querySelector(".my-checkbox").style.backgroundColor = "lightgray";
                element.children[0].checked = false;
                return
            }
                //element.children[0].click(); return}
            let name = element.querySelector("input").getAttribute("name");
            
            for (let index = 0; index < inputs.length; index++) {
                const node = inputs[index].parentNode;
                if(inputs[index].getAttribute("name") !== name ) { continue }
                node.querySelector(".my-checkbox").style.backgroundColor = "lightgray";
                if(node.children[0].checked) { node.children[0].checked = false; }
            }
            element.querySelector(".my-checkbox").style.backgroundColor = backgroundColor;
            element.children[0].checked = true;
        }
        else {
            if (element.querySelector("input").checked) {
                element.querySelector(".my-checkbox").style.backgroundColor = backgroundColor;
            }
            else { element.querySelector(".my-checkbox").style.backgroundColor = "lightgray"; }
        }

    }

    document.querySelectorAll(".my-label").forEach(element => element.onclick = () => addColor(element));
}

function toggleElement() {
    document.querySelector("nav").classList.toggle("w3-hide");        
    main.classList.toggle("w3-hide");
    document.querySelector("footer").classList.toggle("w3-hide");
}

// Reading Question
function showSpecialQuestion(article, section) {
    article.querySelectorAll("span").forEach( elem => { 
        if(elem.className.includes("question")) { toggleHighlight(elem, true); }
    });

    let inputs = section.querySelectorAll(".my-label input");
    let regEx = /aragraph ./
    if(regEx.exec(section.children[0].children[0].innerText)){
        let para = regEx.exec(section.children[0].children[0].innerText)[0].slice(-1);
        article.querySelectorAll("p")[para - 1].scrollIntoView();
    }

    // insert Text

    insertArea = article.querySelectorAll(".insert-area");
    insertArea.forEach(elem =>  elem.innerText = "" );
    if(section.children[0].children[1].innerText.length < 3) {
        addHighlight(section.children[0].children[0]);
        
        insertArea.forEach( elem => { 
            if(elem.getAttribute("data-answer") == "A") { elem.scrollIntoView(); }
            article.scrollTop = article.scrollTop - 6
            elem.innerText = "[" + elem.getAttribute("data-answer") + "] "
            addHighlight(elem);
        });
        for (let index = 0; index < inputs.length; index++) {
            const element = inputs[index];
            element.onclick = () => { 
                let inputs = section.querySelectorAll(".my-label input");
                insertArea.forEach(elem => {
                    elem.innerText = "[" + elem.getAttribute("data-answer") + "] "
                    addHighlight(elem);
                });
                insertArea[index].innerText = section.children[0].innerText.split(".")[1] + ". "
            }
        }
    }


    // highlight
    let highlight = article.querySelector("." + id);
    if(highlight) {
        for (let i = 0; i < highlight.children.length; i++) {
            const element = highlight.children[i];
            element.style.color = backgroundColor;
        }
        addHighlight(highlight);
        highlight.scrollIntoView();
        article.scrollTop = article.scrollTop - (screen.height - section.offsetHeight) / 2 + 64
        index = parseInt(section.children[0].innerText.split(".")[0]) - 1;
        if(questions[index].innerText.includes("highlighted sentence")) {
            highlight.querySelectorAll(".highlight").forEach( elem => addHighlight(elem));
            section.children[0].children[0].innerText = "";
            article.style.height = Math.max(highlight.offsetHeight, screen.height - section.offsetHeight) + "px";
            highlight.scrollIntoView();
        }
    }
}

function filterTag(e) {
    let parent = e.target.parentNode;
    let tagDiv = parent.nextElementSibling;
    let input = document.querySelector("#filter");

    if(!input) { input = createNode(["input", {class:"w3-bar-item w3-hide w3-right", id:"filter", autofocus:true}, ""], parent); }
    input.classList.toggle("w3-show");
    if(mobileFlag) { input.style.width = "224px"; }

    if(input.className.includes("w3-show")) {
        parent.classList.add("w3-padding-small");
        e.target.innerText = "Close"
        document.querySelectorAll("div .w3-bar-item.w3-button").forEach(elem => elem.classList.add("w3-hide"));
        e.target.classList.remove("w3-hide");
        e.target.classList.toggle("w3-padding-small");
        if((/\/notes|\/blog/).exec(uri)) { 
            parent.children[0].classList.toggle("w3-hide");
        }
    }
    else {
        document.querySelectorAll(".w3-bar-item.w3-button").forEach(elem => elem.classList.remove("w3-hide"));
        e.target.innerText = "Search"
        e.target.classList.toggle("w3-padding-small");
        if((/\/notes|\/blog/).exec(uri)) { 
            parent.children[0].classList.toggle("w3-hide");
        }
        else {
            parent.classList.remove("w3-padding-small");
        }
        input.value = "";
        tagDiv.querySelectorAll(".tag").forEach(elem => elem.classList.remove("w3-hide"));
    }
    
    
    input.oninput = e => {
        tagDiv.querySelectorAll(".tag").forEach(elem => { 
            if(!elem.textContent.includes(e.target.value)) { elem.classList.add("w3-hide");}
            else { elem.classList.remove("w3-hide"); }
        });
    }
}

function updateNav() {
    let length;
    sections = ["Reading:3", "Listening:6", "Speaking:6", "Writing:2"];
    document.querySelectorAll(".w3-dropdown-content").forEach(element => element.style.minWidth = "auto");
    if(setFlag) { 
        length = 1; 
        sets = html.split("-")[0];
    }
    else { 
        let number = document.querySelector("#number");
        if(number) {
            addHighlight(number);
            length = parseInt(number.textContent); 
        }
        else {
            length = 4;
        }
        sets = html.split(".")[0]; 
    }
    
    //let before = html.includes("og") ? true : false;
    setsDiv = createNode(["div", {class:"", id:"setsDiv"}, ""], main, true);

    for (let i = 1; i <= length; i++) {
        let number = (i < 10  && !html.includes("og") ? "0" + i : i);
        let set = setFlag ? sets : sets + number;
        div = createNode(["div", {class:"w3-bar w3-section"}, ""], setsDiv);
        if(!setFlag) { div.style.fontSize = "13px"; }
        if(!mobileFlag) { div.style.fontSize = "14px"; }
        if(!setFlag) { createNode(["span", {class:"w3-bar-item w3-btn w3-padding-small my-color"}, set.toUpperCase()], div); }

        sections.forEach( element => {
            let section = element.split(":")[0];
            if(mobileFlag) {
                let dropdown = createNode(["div", {class:"w3-dropdown-click"}, ""], div);
                let button = createNode(["button", {class:"w3-bar-item w3-button w3-padding-small my-color"}, section], dropdown);
                dropdownContent = createNode(["div", {class:"w3-dropdown-content w3-bar-block"}, ""], dropdown);
            }
            for (let index = 1; index <= parseInt(element.split(":")[1]); index++) {
                let href = set + "-" + section.toLowerCase() + index + ".html";
                href = !setFlag ? set + "/" + href : href;
                if(mobileFlag) {
                    let a = createNode(["a", {class:"w3-bar-item w3-btn", href: href}, section + " " + index], dropdownContent);
                }
                else {
                    type = element.split(":")[0].replace("ing", "").replace("Writ","Write");
                    let a = createNode(["a", {class:"w3-padding-small w3-button " + color, href: href}, type + " " + index], div);
                }
            }
        });
    }

    if(mobileFlag) {
        document.querySelectorAll(".w3-dropdown-click button").forEach(elem => { 
            elem.onclick = e => e.target.nextElementSibling.classList.toggle("w3-show") 
        });
    }

    if(setFlag) { 
        href = "../" + uri.split("/").slice(-3)[0] + ".html"
        categoryBtn = createNode(["a", {class:"w3-btn w3-left w3-section w3-large " + color, href:href}, "See Same Category Questions"], div); 
        if(testFlag) testBtn = createNode(["button", {class:"w3-btn w3-right w3-section w3-large " + color, id:"test"}, "Test"], div); 
        if(mobileFlag) { 
            testBtn.className += " w3-block"; 
            categoryBtn.className += " w3-block"; 
        }

        categoryBtn.onclick = () =>  {
            categoryString.split("&").forEach(element => { 
                if(element.includes(html)) {
                    element.split(";").forEach(elem => {
                        if(elem.includes(html)) { tag = elem.split(":")[0]; }
                    });
                }
            });
            sessionStorage.setItem("tag", tag + ":" + html);
        }

    }
    else {

        function filterSet(element) {

            document.querySelector("#description").classList.add("w3-hide");
            document.querySelectorAll("#setsDiv > div").forEach( element => element.classList.add("w3-hide"));

            let setDiv = document.querySelector("#setDiv");
            if(!setDiv) {
                setDiv = createNode(["div", {class:"w3-section", id:"setDiv"}, ""], document.querySelector("#setsDiv"), true);
            }
            setDiv.classList.remove("w3-hide");
            setDiv.innerHTML = "";

            document.querySelectorAll("#setsDiv a").forEach( elem => {
                if(element.split(":")[1].includes(elem.href.split("/").splice(-1)[0])) {
                    innerText = elem.href.split("/").slice(-2)[0].toUpperCase() + " " + elem.innerText;
                    createNode(["a", {class:"w3-left w3-button w3-padding-small my-margin-small " + color, href:elem.href}, innerText], setDiv);
                }
            }) 
        }

        categoryDiv = createNode(["div", {}, ""], main, true);
        div = createNode(["div", {class:"w3-bar w3-card my-color"}, ""], categoryDiv);
        if(mobileFlag) { categoryDiv.style.fontSize = "13px"; }
        for (let i = 0; i < 4; i++) {
            button = createNode(["button", {class:"w3-bar-item w3-button w3-col l2"}, sections[i].split(":")[0]], div);
            if(mobileFlag) { button.className = button.className.replace("w3-col l2", "w3-padding-small"); }
            button.onclick = () => {
                categroyDiv.innerHTML = "";
                categoryString.split("&")[i].split(";").forEach( element => {
                    let tag = element.split(":")[0];
                    button = createNode(["button", {class:"tag w3-btn w3-padding-small my-margin-small highlight"}, tag], categroyDiv);
                    document.querySelectorAll(".highlight").forEach(element => addHighlight(element));
                    button.onclick = e => {  
                        categroyDiv.querySelectorAll("button").forEach(elem => elem.classList.remove(color));
                        e.target.classList.toggle(color);
                        filterSet(element); }
                });
            };
        }
        
        let search = createNode(["button", {class:"w3-bar-item w3-button w3-right"}, "Search"], div);
        search.onclick = e => filterTag(e);
        
        if(mobileFlag) { search.classList.toggle("w3-padding-small") }
        categroyDiv = createNode(["div", {class:"w3-padding-small w3-card w3-white"}, ""], categoryDiv);

        var tag = sessionStorage.getItem("tag");

        if (tag) { 
            for (let i = 0; i < 4; i++) {
                const element = document.querySelectorAll("div .w3-bar-item.w3-button")[i];
                if(tag.includes(element.textContent.toLowerCase())) { 
                    element.click(); 
                    for (let i = 0; i < categroyDiv.children.length; i++) {
                        const elem = categroyDiv.children[i];
                        if(tag.split(":")[0] === elem.textContent) { 
                            elem.click(); 
                            sessionStorage.removeItem("tag");
                            break
                        }
                    }
                }
                if(!sessionStorage.getItem("tag")) { break }
            }
        }
    }
    
    
}

function updateNotes() {
    
    entries = uri.includes("blog") ? blogEntries : noteEntries;

    var entriesString = "";
    entries.forEach(element => entriesString += element[0] + "," + element[1] + ";");

    function createEntry(entries) {
        let entriesDiv = document.querySelector("#entries");
        entries.forEach(element => {
            let div = createNode(["div", {class : "w3-card w3-padding w3-left my-margin w3-white my-entry"}, ""], entriesDiv);
            let section = createNode(["section", {}, ""], div);
            let h3 = createNode(["h3", {}, ""], section);
            let a = createNode(["a", {class:"w3-button w3-white", href:element[0]}, ""], h3);
            let b = createNode(["b", {class:"highlight"}, element[1]], a);
            if(element[2]) { 
                let p = createNode(["p", {}, ""], section); 
                p.innerHTML = element[2];
            }

            let tagDiv = createNode(["div", {class:"w3-white w3-section"}, ""], div);
            createNode(["span", {}, "Tags:"], tagDiv);
            element[1].split(" ").forEach( tag => {
                if(tag.length < 3) { return }
                createNode(["button", {class:"tag w3-btn w3-padding-small my-margin-small highlight"}, tag], tagDiv);
            });
        });
    }
    createEntry(entries);
    entries = document.querySelectorAll(".my-entry");

    var barItems = document.querySelectorAll("a.w3-bar-item");
    var tags = document.querySelectorAll("button.tag"); // All tags in all entries.
    var tagsDiv = document.querySelector("#tagsDiv"); // Place to add tags
    var tagsArray = []; // All tags need to be show in tag div on load.
    var selectedTags = []; // Add element when a tag is selected in tag div. otherwise remove it.  
    if(document.querySelector("#tagDiv")) {
        let search = createNode(["button", {class:"w3-bar-item w3-button w3-right w3-padding-small"}, "Search"], document.querySelector("#tagDiv").children[0]);
        search.onclick = e => filterTag(e);
    }
    

    // Filter multiple tags
    function toggleFilter(thisElem) {

      // Add selected tag to array
      if (thisElem.className.includes("highlight")) {
        selectedTags.push(thisElem.textContent);
      } else {
        selectedTags.splice(selectedTags.indexOf(thisElem.textContent), 1);
      }

      // Unselected Tag is light gray, selected tag is black
      thisElem.classList.toggle("highlight");
      thisElem.classList.toggle(color);
      thisElem.classList.toggle("w3-border");
      let entriesTagsArray = [];

      // if the entry do not contains selected tags, it is hidden.
      entries.forEach(entry => {
        
        // get the entries tag
        let entryTags = entry.querySelectorAll("button.tag");
        let entryTagsArray = []; // one entry's tags.
        entry.classList.remove("w3-hide");

        // join the entry tag in one string
        entryTags.forEach(element => { 
          entryTagsArray.push(element.textContent);
          if(element.textContent === thisElem.textContent) {
            element.classList.toggle("highlight");
            element.classList.toggle(color);
            element.classList.toggle("w3-border");
          }
        });

        // if one selected tag is not in the entryTagsArray, the entry is hidden
        selectedTags.forEach( tag => {
          if(entryTagsArray.indexOf(tag) === -1) { 
            entry.classList.add("w3-hide"); 
          } 
        }); // End of selectedTags foreach  

        // if the entry is not hidden
        if (!entry.classList.contains("w3-hide")) {
          entryTagsArray.forEach(element => entriesTagsArray.push(element) );
          tagBtns.forEach(element => {
              element.classList.remove("w3-hide");
            if (entriesTagsArray.indexOf(element.textContent) === -1) {
              element.classList.add("w3-hide");
            }
          }); // End of tag Buttons forEach

        }
      }); // End of entries foreach

    }

    // Trigger tag click event
    function clickTag() {
        var tag = sessionStorage.getItem("tag");
        if (tag) { 
            tagBtns.forEach(element => {
                if(element.textContent === tag) {  
                    element.click(); 
                    sessionStorage.removeItem("tag");
                }
            }); 
        }
    }

    // If Article Tag or Top Bar Item is clicked, store the content of clicked tag in sessionStorage
    function addTagClick(tags) {
        for (let index = 0; index < tags.length; index++) {
            const element = tags[index];
            element.onclick = () => sessionStorage.setItem("tag", element.textContent);
        }
    }

    entries.forEach(entry => entry.querySelector("a").style.padding = 0);
    
    // Show tags
    if(tagsDiv) {
        tags.forEach(tag => {
            element = tag.textContent;
            if(tagsArray.indexOf(element) === -1){
              tagsArray.push(element);
              var btn = document.createElement("button");
              btn.className = "tag w3-btn w3-padding-small my-margin-small highlight";
              
              btn.textContent = element;
              tagsDiv.appendChild(btn);
            }
          });
    }
    
    document.querySelectorAll(".highlight").forEach(element => addHighlight(element));
    document.querySelectorAll("b").forEach(element => { 
        addHighlight(element); 
        element.style.whiteSpace = "normal";
    });

    entriesString.split(";").forEach(element => { 
        if(element.split(",")[0] && html.includes(element.split(",")[0])) {
            title = element.split(",")[1];
            return
        }}
    );

    if(!(/\/notes\.html|\/blog\.html/).exec(uri)) {
        
        let div = createNode(["div", {class:"w3-card w3-white w3-padding w3-section"}, ""], main, true);
        createNode(["span", {}, "Tags: "], div);
        document.title = title;
        title.split(" ").forEach( tag => {
            if(tag.length < 3) { return }
            let classes = "tag w3-btn w3-padding-small my-margin-small " + color;
            let href = uri.split("/").slice(-2)[0] + ".html";
            createNode(["a", {class:classes, href:href}, tag], div);
        });

    }
    if((/\/reading-notes\.html|\/listening-notes\.html/).exec(uri)) {
        questions = document.querySelectorAll("div.w3-padding li");
        
        sections = document.querySelectorAll(".questions section");
        for (let i = 0; i < questions.length; i++) {
            const element = questions[i];
            element.onclick = e => {
                sections[i].parentNode.classList.remove("w3-hide");
                sections.forEach(element => element.classList.add("w3-hide")); 
                sections[i].classList.remove("w3-hide");
            }
            element.onmouseover = e => {
                questions.forEach(element => toggleHighlight(element, true));
                addHighlight(e.target);
                e.target.style.cursor = "pointer";
            }
        }
    }

    // Add filter Event for tags in tag div. 
    tagBtns = document.querySelectorAll("#tagsDiv > button.tag");
    tagBtns.forEach(element => element.onclick = () => toggleFilter(element) );
    

    // Add top bar item tag.
    //barItems.forEach(element => element.onclick = () => clickTag(element.textContent));

    // Add article tag.
    tags.forEach(element => element.onclick = () => clickTag(element.textContent));
    
    // Filter Tag
    clickTag();
  
    addTagClick(document.querySelectorAll("a.tag"));

}

function setHeight(article) {
    if(!article) {return}
    article.style.height = screen.height / 3 + "px";
    article.style.overflowY = "scroll";
    article.classList.add("w3-section");
}

function startTest() {
    
    let seconds = [["45", "60", "60"], ["15", "30", "20"]];
    if(document.querySelector("#question p")) questionText = document.querySelector("#question p").innerText;
    
    let reading = document.querySelector("#reading-text article");
    
    let audio;
    let testDiv = createNode(["div", {id:"testDiv", class:"w3-container"}, ""], document.body);
    let myAnswer = new Array(questions.length);


    function setTimer(second) {
        var time = document.querySelector("#time");
        var timer = second, min = 0, sec = 0;
    
        function startTimer(params) {
            min = parseInt(timer / 60);
            sec = parseInt(timer % 60);
    
            if (timer < 0) { return }
            let secStr = sec < 10 ? "0" + sec.toString() : sec.toString();
            time.innerHTML = min.toString() + ":" + secStr;
            timer--;
            setTimeout(() => startTimer(), 1000);
        }
        startTimer();
    }
    
    function playAudio(link, onEnd) {
        audio = new Audio(link);
        //audio = document.createElement('audio');
        //audio.src = link;
        //testDiv.appendChild(audio);
        let promise = audio.play();
        
        if (promise !== undefined) {
            promise.catch(error => {
                // Auto-play was prevented
                // Show a UI element to let the user manually start playback
                article.classList.toggle("w3-hide");
                let button = testDiv.querySelector("#playAudio");
                if(!button) {
                    button = createNode(["button", {class:"w3-btn w3-block w3-section w3-hide "+color, id:"playAudio"}, "Play Audio"], testDiv, true);
                }
                button.classList.toggle("w3-hide");
                button.onclick = () => { 
                    audio.play();
                    article.classList.toggle("w3-hide");
                    button.classList.toggle("w3-hide");
                    audio.onended = () => onEnd();
                };
            }).then(() => audio.onended = () => onEnd());
        }
    }
    
    function waitTime(second, onTimeout) {
        setTimer(second);
        setTimeout( () => onTimeout(), second * 1000);
    }
    
    function endTest() {
        document.body.removeChild(document.body.lastChild);
        toggleElement();
    }
    
    function recordAudio() {
        let constraints = { audio: true };
        let data = [];
    
        let onFulfilled = stream => {
            mediaRecorder = new MediaRecorder(stream);
            
            mediaRecorder.onstop = e => {
                var audio = document.createElement('audio');
                audio.setAttribute('controls', 'controls');
                testDiv.appendChild(audio);
    
                var blob = new Blob(data, { 'type': 'audio/mp3' });
                audioURL = window.URL.createObjectURL(blob);
                audio.src = audioURL;
            }
            mediaRecorder.ondataavailable = event => data.push(event.data);
            return mediaRecorder;
        }
        navigator.mediaDevices.getUserMedia(constraints).then(onFulfilled);
        
    }

    function navigateQuestion (thisElem) {
        if(uri.includes("listening")) { id = thisElem.previousElementSibling.id; }
        index = (thisElem.innerText === "Previous" ? parseInt(id.split("n")[1] - 2) : parseInt(id.split("n")[1]));
        checkAnswer(id.split("n")[1]);

        if (index === questions.length) { 
            showModal(uri);
        }
        else { 
            if(uri.includes("reading")) {
                if(index >= 0) {showQuestion(index);}
            }
            else { showQuestion(index); }
        }
    }

    function checkAnswer(id) {

        if(greFlag) var answer = testDiv.querySelector(".answer").getAttribute("data-answer");
        else var answer = testDiv.querySelector(".answer").innerText;

        let flag;
        
        if (!myAnswer[id-1] || !myAnswer[id-1].split("->")[0]) {  } 
        myAnswer[id-1] = "";
        if (answer.length < 2 || questions[id-1].getAttribute("data-choice-type") == "select") {
            for (let index = 0; index < inputs.length; index++) {
                const element = inputs[index];
                if (!element.checked) { continue }
                myAnswer[id-1] = String.fromCharCode(65 + index);
            } 
            
            if (questions[id-1].getAttribute("data-choice-type") == "select") {
                for (let index = 0; index < article.querySelectorAll(".sentence").length; index++) {
                    const element = article.querySelectorAll(".sentence")[index];
                    if (element.style.fontWeight !== "bold") { continue }
                    myAnswer[id-1] = index + 1 + "";
                }
            }
            if (myAnswer[id-1] !== answer) { myAnswer[id-1] += "->" + answer };
        }
        else if (questions[id-1].querySelector("table")) {
            let table = testDiv.querySelector("table");
            for (let i = 1; i < table.rows.length; i++) {
                const element = table.rows[i];
                let inputs = element.querySelectorAll("input");
                flag = false;
                for (let j = 0; j < inputs.length; j++) {
                    const element = inputs[j];
                    if (!element.checked) { continue }
                    myAnswer[id-1] += String.fromCharCode(65 + j);
                    flag = true;
                }
                if(!flag) {
                    if(!myAnswer[id-1]) { myAnswer[id-1] = "" }
                    myAnswer[id-1] += "N";
                }                
            }
            if(uri.includes("reading")) {
                let category = answer.split("@");
                let keys = new Array(answer.length + 1);
                answer = ""
                for (let i = 0; i < category[0].length; i++) { keys[category[0].charCodeAt(i) - 65] = "A" }
                for (let i = 0; i < category[1].length; i++) { keys[category[1].charCodeAt(i) - 65] = "B" }
                for (let i = 0; i < keys.length; i++) { 
                    if (keys[i] !== "A" && keys[i] !== "B") { keys[i] = "N";} 
                    answer += keys[i];
                }
            }
            if (myAnswer[id-1] !== answer) { myAnswer[id-1] += "->" + answer };
        }
        else {
            for (let index = 0; index < inputs.length; index++) {
                const element = inputs[index];
                if (!element.checked) { continue }
                myAnswer[id-1] += String.fromCharCode(65 + index);
            }
            if (myAnswer[id-1] !== answer) { myAnswer[id-1] += "->" + answer };
        }
    }

    function showModal() {

        function saveExit() {

            function downloadResponse(url, fileName) {
                let download = document.createElement('a');
                download.href = url;
                download.download = fileName;
                testDiv.appendChild(download);
                download.click();
            }

            if (uri.includes("speaking")) {
                downloadResponse(audioURL, html.replace(".html", "-recording.mp3"));
            }
            else if ( uri.includes("writing")) {
                let text = testDiv.querySelector("textarea").value.replace("\n", "</p><p>");
                text = "<p>" + text + "</p>"

                let blob = new Blob([text], {type:'text/plain'});
                downloadResponse(window.URL.createObjectURL(blob), html);
            }
            else {
                let text = testDiv.querySelector("table").outerHTML;

                let blob = new Blob([text], {type:'text/plain'});
                downloadResponse(window.URL.createObjectURL(blob), html);
            }
        }

        if((/-speaking|-writing/).exec(uri)) {
            modal = createNode(["div", {class:"w3-modal"}, ""], testDiv);
            modalContent = createNode(["div", {class:"w3-modal-content"}, ""], modal);
            createNode(["div", {class:"w3-container " + color}, ""], modalContent);
            p = createNode(["p", {}, ""], modalContent);
        }
        else {
            modal = reviewQuestions();
           
            modalContent = modal.children[0]
            let tr = modalContent.querySelectorAll("tbody tr");
            for (let i = 0; i < tr.length; i++) { 
                tr[i].children[1].innerText = myAnswer[i]; 
            }
            
            let p = createNode(["p", {class:"w3-padding w3-section"}, ""], modalContent, true);
            createNode(["div", {class:"w3-padding " + color}, "Review Test"], modalContent, true);

            // answering and correct rate
            var error = 0;
            myAnswer.forEach(answer => { if (answer.includes("->") || !answer) { error++ }});
            p.innerHTML = "<b>" + (myAnswer.length - error) + " of " + myAnswer.length + "</b> answered questions are correct.";
            addHighlight(p.children[0]);
        }
        let buttonBar = testDiv.querySelector("#buttonBar");
        if (!buttonBar) { 
            let buttonBar = createNode(["div", {class:"w3-bar", id:"buttonBar"}, ""], modalContent);
            exitBtn = createNode(["button", {class:"w3-btn w3-margin w3-left " + color}, "Save and Exit"], buttonBar);
            cancelBtn = createNode(["button", {class:"w3-btn w3-margin w3-right " + color}, "Cancel"], buttonBar);
        }
        if (uri.includes("speaking")) {
            p.innerHTML = testDiv.querySelector("audio").outerHTML
        }
        exitBtn.onclick = () => {
            saveExit();
            endTest();
        }
        cancelBtn.onclick = () => modal.style.display = "none";
        modal.style.display = "block";
        
    }

    function reviewQuestions(id) {
        if(id) { checkAnswer(id); }
        let modal = testDiv.querySelector(".w3-modal");
        if (!modal) {
            modal = createNode(["div", {class:"w3-modal"}, ""], testDiv);
            modalContent = createNode(["div", {class:"w3-modal-content"}, ""], modal);
            let table = createNode(["table", {class:"w3-table-all w3-padding-small"}, ""], modalContent);
            let thead = createNode(["thead", {}, ""], table);
            let tr = createNode(["tr", {class: color}, ""], thead);
            createNode(["td", {}, "Question"], tr);
            createNode(["td", {}, "Option"], tr);

            let tbody = createNode(["tbody", {}, ""], table);
            for (let i = 0; i < questions.length; i++) {
                const element = questions[i];
                let tr = createNode(["tr", {}, ""], tbody);
                
                let td = createNode(["td", {}, element.children[0].children[0].innerText], tr);
                td.style.maxWidth = "280px";
                td.style.overflow = "hidden";
                td.style.textOverflow = "ellipsis";
                td.style.whiteSpace = "nowrap";

                if(myAnswer[i]===undefined) { myAnswer[i] = "" }
                createNode(["td", {}, myAnswer[i].split("->")[0]], tr);
                tr.onclick = () => {
                    showQuestion(i);
                    modal.style.display = "none";
                };
            }
        }
        modal.style.paddingTop = "10px";
        let tr = modal.querySelectorAll("tbody tr");
        for (let i = 0; i < tr.length; i++) { 
            tr[i].children[1].innerText = myAnswer[i].split("->")[0]; 
        }
        
        if(id) { modal.style.display = "block"; }
        else { return modal }
    }

    function showQuestion(index) {

        id = questions[index].id;
        
        section.innerHTML = questions[index].innerHTML;
        section.querySelector(".question").classList.add("w3-section");
        if(greFlag) {
            if(questions[index].getAttribute("data-passage")) {
                section.querySelector(".passage").classList.add("w3-hide");
                article.innerHTML = questions[index].querySelector(".passage").innerHTML;
            }
        }
        else {
            section.lastElementChild.classList.add("w3-hide");
            article.innerHTML = reading.innerHTML;
            article.querySelectorAll(".highlight").forEach(element => {
                element.style.color = "black";
                element.style.fontWeight = "normal";
            });
            testDiv.querySelector(".show-article h4").style.color = backgroundColor;
        }
        
        inputs = testDiv.querySelectorAll(".my-label input");
        let labels = section.querySelectorAll(".my-label");
        if(mobileFlag) {
            section.children[0].style.margin = "8px";
            labels.forEach(elem => elem.style.marginBottom = "4px");
        }        
        addInputColor();
        
        // Previous and Next Button
        let div = createNode(["div", {class:"w3-bar my-margin-top-small w3-display-container w3-section "}, ""], section);
        createNode(["button", {class:"w3-btn w3-left " + color}, "Previous"], div);
        
        // Time Ticking 
        if (mobileFlag) {
            time.classList.add("w3-hide");
            timer = createNode(["span", {class:"w3-display-middle w3-xxlarge"}, ""], div);

            // Callback function to execute when mutations are observed
            var callback = () => {
                timer.innerText = time.innerText;
                addHighlight(timer);
            };

            // Create an observer instance linked to the callback function
            var observer = new MutationObserver(callback);
            // Options for the observer (which mutations to observe)
            var options = { childList: true };
            // Start observing the target node for configured mutations
            observer.observe(time, options);
        }

        addHighlight(time);
        createNode(["button", {class:"w3-btn w3-right " + color}, "Next"], div);

        // Review Button
        let reviewBtn = testDiv.querySelector("#review");
        if (!reviewBtn) {
            reviewBtn = createNode(["button", {class:"w3-btn w3-block w3-half " + color, id:"review"}, "Review Questions"], testDiv);
        }
        reviewBtn.onclick = () => reviewQuestions(id.split("n")[1]);
        div.querySelectorAll("button").forEach( elem => { 
            if(mobileFlag) { elem.classList.toggle("w3-padding-small"); }
            elem.onclick = e => navigateQuestion (e.target);
        });

        // show current number of all number
        let numberDiv = createNode(["div", {class:"w3-section"}, ""], section);
        let numberP = createNode(["p", {class:"w3-xlarge w3-center my-margin-small"}, ""], numberDiv);
        numberP.innerHTML = "Questions " + (index + 1) + " of " + questions.length;
        addHighlight(numberP);

        if(!questions[index].getAttribute("data-passage")) {
            article.style.height = "0px";
            if(!mobileFlag) {
                section.classList.remove("w3-half");
                article.classList.remove("w3-half");
                reviewBtn.classList.remove("w3-half");
            }
        }
        else {
            if(mobileFlag) {
                section.style.borderTop= "3px solid " + backgroundColor;
                article.style.height = screen.height - section.offsetHeight + 40 + "px";
                article.style.overflowY = "scroll";
            }
            else{
                article.style.height = "680px";
                article.style.overflowY = "scroll";
                section.classList.add("w3-padding");
                section.classList.add("w3-half");
                article.classList.add("w3-half");
                reviewBtn.classList.add("w3-half");
            }
        }

        if(!greFlag) showSpecialQuestion(article, section);

        
        // select sentence question
        if(questions[index].getAttribute("data-choice-type") == "select") {

            // split sentence with span
            let passage = article.innerHTML.replace(". . . ", "&#8230; ")
            passage = passage.replace(/\s{2,}</g, "<")
            passage = passage.replace(/(\w{2,}[?!\.])\s{1}/g, "$1</span><span class=\"sentence\"> ")
            passage = passage.replace(/<p>/g, "<p><span class=\"sentence\"> ")
            passage = passage.replace(/<\/p>/g, "</span></p>")
            article.innerHTML = passage

            // Add sentence click event
            article.querySelectorAll(".sentence").forEach(sentence => {
                sentence.onclick = e => {
                    article.querySelectorAll(".sentence").forEach(element => toggleHighlight(element, true))
                    addHighlight(e.target);
                }
            });
        }

        // click Options
        if(myAnswer[index] && myAnswer[index].split("->")[0]) { 
            options = myAnswer[index].split("->")[0];
            if(myAnswer[index].includes(".")) { options = options.split(". ")[1] }
            if(!options) { return }
            
            for (let i = 0; i < options.split("").length; i++) {
                const element = options.split("")[i];
                if(options.length > 4) {
                    option = element.charCodeAt(0) - 65;
                    if(option !== 13) { 
                        let elem = inputs[i * 2 + option].parentNode;
                        elem.querySelector(".my-checkbox").style.backgroundColor = backgroundColor;
                        elem.children[0].checked = true;
                    }
                } 
                else {
                    if(questions[index].getAttribute("data-choice-type") == "select") {
                        article.querySelectorAll(".sentence")[element - 1].click()
                    }
                    else {
                        inputs[element.charCodeAt(0) - 65].click(); 
                        if(!greFlag && section.children[1].innerText.length < 3) { 
                            insertArea[element.charCodeAt(0) - 65].innerText = section.children[0].innerText.split(".")[1] + ". "
                        }
                    }
                }
            }
        }
    }
        
    function addTextarea(note) {
        function getAllIndexes(arr, val) {
            var indexes = [], i = -1;
            while ((i = arr.indexOf(val, i+1)) != -1){ indexes.push(i); }
            return indexes;
        }
        wordCountDiv = createNode(["div", {class:"w3-half w3-padding w3-section"}, ""], testDiv);
        wordCount = createNode(["span", {class:"w3-large"}, "Word Count: 0"], wordCountDiv);
        toggleHighlight(wordCount);
        let time = createNode(["span", {id:"time", class:"w3-large w3-right"}, ""], wordCountDiv);
        toggleHighlight(time);
        textarea = createNode(["textarea", {class:"w3-half"}, ""], testDiv);
        textarea.oninput = e => wordCount.innerText = "Word Count: " + (getAllIndexes(e.target.value, " ").length + 1);

        textarea.style.resize = "none";
        textarea.style.border = "2px solid " + backgroundColor;
        textarea.style.height = screen.height - textarea.offsetTop - 192 + "px";
        textarea.style.height = "-webkit-fill-available";

        if(mobileFlag) {
            textarea.style.width = "-webkit-fill-available";
            textarea.style.width = "-moz-available";
        }
        else {
            article.classList.add("w3-padding");
            textarea.style.width = note ? "-webkit-fill-available" : "none";
        }
    }

    toggleElement();
    article = createNode(["article", {class:"show-article w3-half w3-section"}, ""], testDiv);
    if (greFlag) {
        
        if((/issue|argument/).exec(uri)) {
            article.innerHTML = document.querySelector("#question").innerHTML
            addTextarea();
            waitTime(1800, showModal);
        }
        else {
            var countdown;
            var section = createNode(["section", {class:"show-question w3-half"}, ""], testDiv);
            time = createNode(["p", {id:"time", class:"w3-xxlarge w3-center my-margin-small"}, ""], testDiv);
            if (questions.length > 20) countdown = 2100
            else if (questions.length > 15) countdown = 1800
            else countdown = 1500
            waitTime(countdown, showModal);
            showQuestion(0);
        }
    }
    else if (uri.includes("reading")) {
        var section = createNode(["section", {class:"show-question w3-half"}, ""], testDiv);
        time = createNode(["p", {id:"time", class:"w3-jumbo w3-center w3-half"}, ""], testDiv);
        waitTime(1200, showModal);
        showQuestion(0);

    }
    else if (uri.includes("listening")) {
        article.classList.toggle("w3-half");
        let button = createNode(["button", {class:"w3-btn w3-block w3-section w3-hide "+color}, "Next"], testDiv);
        button.onclick = e => navigateQuestion(e.target);
        time = createNode(["p", {id:"time", class:"w3-xxlarge w3-center my-margin-small"}, ""], testDiv);

        function showQuestion(index) {

            function playListening() {
                article.id = element.id;
                article.innerHTML = element.children[0].children[0].outerHTML
                button.classList.add("w3-hide");
                time.classList.add("w3-hide");        
                playAudio(html.replace(".html", "-" + element.id + ".mp3"), () => {
                    article.innerHTML = element.innerHTML;
                    inputs = testDiv.querySelectorAll(".my-label input");
                    article.lastElementChild.classList.add("w3-hide");
                    button.classList.remove("w3-hide");
                    time.classList.remove("w3-hide");
                    addInputColor();
                });  
            }
            
            const element = questions[index];
            if (element.children[0].className.includes("replay")) {
                article.innerText = "Listen again to part of the lecture. Then answer the question."
                button.classList.add("w3-hide");
                time.classList.add("w3-hide");
                playAudio(html.replace(".html", "-" + element.id + "-replay.mp3"), () => playListening() );
            }
            else { playListening(); }
            
        }
        
        playAudio(html.replace("html", "mp3"), () => {
            setTimer(240);
            addHighlight(time);
            showQuestion(0);
        })

    }
    else if (uri.includes("speaking")) {
        if(uri.startsWith("file:/")) { mediaRecorder = recordAudio(); }

        time = createNode(["p", {id:"time", class:"w3-xxlarge w3-center my-margin-small"}, ""], testDiv);
        addHighlight(time);
        article.classList.toggle("w3-half");
        article.classList.toggle("w3-section");

        playListening = () =>  { 
            article.classList.toggle("w3-hide");
            time.classList.toggle("w3-hide");
            playAudio(html.replace(".html", ".mp3"), playQuestion); 
        }
        playQuestion = () =>  {  
            article.innerText = questionText
            article.classList.remove("w3-hide");
            playAudio(html.replace(".html", "-question.mp3"), startPreparation); 
        }
        startPreparation = () =>  playAudio("../../speaking_beep_prepare.mp3", waitPreparation);
        waitPreparation = () =>  { 
            time.classList.remove("w3-hide");
            waitTime(seconds[1][Math.ceil(num / 2) - 1], startSpeak); }
        startSpeak = () =>  playAudio("../../speaking_beep_answer.mp3", waitSpeak);
        waitSpeak = () =>  {
            if(uri.startsWith("file:/")) { 
                mediaRecorder.start();
                waitTime(seconds[0][Math.ceil(num / 2) - 1], () => { 
                    mediaRecorder.stop(); 
                    waitTime(1,showModal);
                });
            }
            else {
                var handleSuccess = stream => {
                    var audio = document.createElement('audio');
                    if (window.URL) {
                        audio.src = window.URL.createObjectURL(stream);
                    } else {
                        audio.src = stream;
                    }
                    audio.setAttribute('controls', 'controls');
                    testDiv.appendChild(audio);
                };
                
                navigator.mediaDevices.getUserMedia({ audio: true }).then(handleSuccess);
            }
        }

        if (num < 3) {
            playQuestion();    
        }
        else if (num > 4) {
            playListening();
        }
        else {
            playAudio(html.replace(".html", "-reading.mp3"), () => { 
                article.innerHTML = reading.innerHTML
                waitTime(45, playListening); 
            });
        }
    }
    else if (uri.includes("writing")) {
        if (num == 1) {
            article.innerText = reading.innerText
            addTextarea();
            waitTime(180, endReading);
            function playListening() { playAudio(html.replace(".html", ".mp3"), waitWriting); }
            function endReading() {
                wordCountDiv.classList.toggle("w3-hide");
                article.classList.toggle("w3-hide");
                playListening();
            }

            function waitWriting() {
                article.classList.toggle("w3-hide");      
                wordCountDiv.classList.toggle("w3-hide");         
                waitTime(1200, showModal);
            }
            
        }
        else {
            article.innerText = questionText
            addTextarea();
            waitTime(1800, showModal);
        }
    }
}

function updateUI() {
    if(!setFlag) {return}

    function showQuestion(article) {
        if(article) setHeight(article);
        questions.forEach(element => { if (!element.className.includes("passage")) element.classList.toggle("w3-hide")});
        questionDiv = createNode(["div", {class:"w3-section", id:"question"}, ""], main);
        if(article) { 
            questionDiv.style.height = screen.height / 3 + "px";
            questionDiv.style.overflowY = "scroll";
        }
        pageBar = createNode(["div", {class:"w3-bar"}, ""], questionDiv);
        questionDiv = createNode(["div", {class:"w3-display-container"}, ""], questionDiv);
        for (let i = 0; i < questions.length; i++) {
            let button = createNode(["button", {class:"w3-bar-item w3-button " + color}, i + 1], pageBar);
            if (uri.includes("reading") && mobileFlag) { button.style.padding = "5px"; }
            button.onclick = e => {
                id = "question" + e.target.textContent
                questionDiv.innerHTML = questions[parseInt(e.target.textContent) - 1].innerHTML
                questionDiv.querySelector(".question").classList.add("w3-section");
                // Verbal reasoning
                if(greFlag) {
                    let div = createNode(["div", {class:"w3-bar"}, ""], questionDiv) // this div is for button to display in block
                    var btn = createNode(["button", {class:"w3-btn " + color}, "Toggle Answer"], div);
                    btn.onclick = e => {
                        let question = e.target.parentElement.parentElement
                        let answer = question.querySelector("#answer")
                        if(!answer) answer = createNode(["div", {class:"answer w3-hide", id:"answer"}, ""], question);
                        answer.innerHTML = "<p>" + question.querySelector(".answer").getAttribute("data-answer") + "</p>" + question.querySelector(".answer").innerHTML;
                        answer.classList.toggle("w3-hide");
                        
                    }
                }
                else {
                    article.querySelectorAll(".highlight").forEach(element => addHighlight(element));
                    article.querySelectorAll(".highlight").forEach(element => toggleHighlight(element));
                    showSpecialQuestion(article, questionDiv);
                }
                addInputColor();
            }
        }
    }
    if(greFlag) { // Update Verbal Reasoning UI
        // Hide passage and choices
        document.querySelectorAll(".passage").forEach(element => element.classList.add("w3-hide"));
        document.querySelectorAll(".choices > p").forEach(element => element.classList.add("w3-hide"));
        
        questions.forEach(question => { 
            let choices = question.querySelectorAll(".choices") // Choices in one question
            let choiceType; // Radio Checkbox Select(reading comprehension select sentence)
            choicesDiv = createNode(["div", {}, ""], question);

            // Decide choice type based on question type
            choiceType = question.getAttribute("data-choice-type");
            if ( question.getAttribute("data-passage")) {
                // Show reading comprehension question related passage
                passageDiv = createNode(["div", {class:"passage"}, ""], question, true);
                passageDiv.innerHTML = document.querySelector("#" +question.getAttribute("data-passage")).innerHTML;
            }

            // Update choices
            for (let i = 0; i < choices.length; i++) {
                choice = choices[i]
                choiceDiv = createNode(["div", {class:"w3-padding-small w3-left"}, ""], choicesDiv);
                if(question.className.includes("text")) choiceDiv.className += " w3-left"

                for (let j = 0; j < choice.children.length; j++) {
                    let label = createNode(["label", {class:"my-label"}, ""], choiceDiv);
                    createNode(["span", {}, choice.children[j].innerText], label);
                    createNode(["input", {name:choiceType + i, type:choiceType}, ""], label);
                    createNode(["span", {class:"my-" + choiceType}, ""], label);
                }
            }
            if(!question.className.includes("passage")) question.querySelector(".answer").classList.toggle("w3-hide");
            
        });
        
        showQuestion();
    }
    else if(uri.includes("reading")) {
        let article = document.querySelector("#reading-text");
        showQuestion(article);
        
    }
    else if(uri.includes("listening")) {
        let article = document.querySelector("#listening-text");
        article.children[0].classList.toggle("w3-hide");
        showQuestion(article);
    }
    else { // Update Speaking and Writing
        response = document.querySelector("#responses");
        question = document.querySelector("#question");
        setHeight(response);
        
        if(response) {
            question.classList.toggle("w3-hide");
            questionDiv = createNode(["div", {}, ""], response, true);
            questionDiv.innerHTML = question.innerHTML;
        }
        
        listening = document.querySelector("#listening-text");
        if(listening) {
            audio = document.querySelector("audio");
            newAudio = createNode(["audio", {controls:true}, ""], listening, true);
            newAudio.outerHTML = audio.outerHTML;
            audio.classList.toggle("w3-hide");
        }
        setHeight(listening);
        setHeight(document.querySelector("#reading-text"));
    }
}

function initialize() {
    document.querySelectorAll(".highlight, h1, h2, h3, h4, h5, h6, b, u").forEach(element => addHighlight(element));
    document.querySelectorAll(".my-color").forEach(element => element.className = element.className.replace("my-color", color));
    renameTitle();
    if(uri.includes("blog")) { document.querySelector("nav").classList.toggle("w3-hide"); }
    addInputColor();
    setListStyle();
    if((/blog|notes/).exec(uri)) { 
        if(!(/gre/).exec(uri)) updateNotes(); 
    } 
    
    if((/toefl\/og\/|tpo\//).exec(uri)) { 
        updateNav();
        updateUI(); 
    } 
    
    if((/practice|sample/).exec(uri) && !greFlag) { 
        updateUI(); 
        if(testFlag) createNode(["button", {class:"w3-btn w3-right " + color, id:"test"}, "Test"], main.children[0]); 
    }

    if(greFlag) {
        updateUI();
        if(testFlag) createNode(["button", {class:"w3-btn w3-right w3-margin " + color, id:"test"}, "Test"], main, true);
    }

    if((/toefl/).exec(uri)) { 
        createNode( ["a", {href:"/gre/og/og.html",class:"w3-bar-item w3-button w3-hide-small"}, "GRE"], topNav); 
    }
    else if((/gre/).exec(uri)) { 
        createNode( ["a", {href:"/toefl/og/og.html",class:"w3-bar-item w3-button w3-hide-small"}, "TOEFL"], topNav);
    }
    hideBarItems = document.querySelectorAll(".w3-hide-small");

    if(uri.includes("vocabulary")) {
        createWordSets();
        createNode(["button", {class:"w3-bar w3-btn w3-right w3-padding w3-section " + color}, "Recite"], main.children[0]).onclick = createWordTest;
    }

    document.querySelectorAll("b").forEach(element=>{ 
        if(element.getAttribute("data-link")) { 
            element.style.cursor = "pointer";
            element.onclick = () => {
                document.querySelector("#" + element.getAttribute("data-link")).scrollIntoView();
                document.body.scrollTop -= 48;
            }
        }
    });

    // Add Top Navigation Button Click Event and Tag Click Event.
    topNavBtn.onclick = () => toggleTopNav(topNavBtn);
    var testBtn = document.querySelector("#test");
    if (testBtn) testBtn.onclick = () => startTest(); 

    let sidebarItems = document.querySelectorAll("#sidebar > a");
    if (sidebarItems.length > 0) {
        sidebarItems.forEach(element => {
            let item = document.querySelector("#" + element.href.split("#")[1]);
            element.onclick = () => { 
                sidebar.classList.add("w3-hide");
                window.onscroll = () => toggleFixed(item);
            }
        });
    }

    if (sidebarBtn) { sidebarBtn.onclick = () => sidebar.classList.toggle("w3-hide"); }
    window.onscroll = () => toggleFixed(topNav);

    let questions = document.querySelector("#question");
    if(questions && questions.children.length > 4) {
        for (let i = 0; i < questions.children.length; i++) {
            const element = questions.children[i];
            element.children[0].children[0].innerHTML = element.id.split("n")[1] + ". " + element.children[0].children[0].innerHTML;
        }
    }

    let audio = document.querySelector("audio");
    if(audio && uri.includes("listening")) {
        var timeSpan = document.querySelectorAll(".time");
        timeSpan.forEach(element => element.classList.add("w3-hide"));
        n = 0;
        let listening = document.querySelector("#listening-text");
        listening.style.overflowY = "scroll";
        listening.style.height = screen.height - audio.offsetTop - 160 + "px";
        if(timeSpan) {
            audio.ontimeupdate = e => {
                let duration = parseFloat(timeSpan[n].getAttribute("data-times")) + parseFloat(timeSpan[n].getAttribute("data-time"));
                if(parseFloat(e.target.currentTime.toFixed(2)) <= duration) {
                    listening.scrollTop = timeSpan[n].parentNode.offsetTop - 320;
                    addHighlight(timeSpan[n].parentNode, true);
                }
                else {
                    toggleHighlight(timeSpan[n].parentNode);
                    n++;
                }
            };
        }
        
    }
    if(uri.includes("topic")) {
        question = document.querySelector("section");
        article = document.querySelector("article");
        article.classList.toggle("w3-section");
        question.classList.toggle("w3-hide");
        questionDiv = createNode(["div", {}, ""], article, true);
        questionDiv.innerHTML = question.innerHTML;
        var textarea = addTextarea(true, main, true);
        textarea.style.height = screen.height / 4 - 96 + "px";
        article.style.height = screen.height / 2 - 96 + "px";
        article.style.overflowY = "scroll";
        
    }

    if(html.includes("essay")) {
        let input = document.querySelector("#sidebar input");
        input.style.width = "100%";
        
        input.oninput = e => {
            document.querySelectorAll("#sidebar button").forEach(elem => { 
                if(!elem.textContent.includes(e.target.value)) { elem.classList.add("w3-hide");}
                else { elem.classList.remove("w3-hide"); }
            });
        }
    }

    if(document.querySelectorAll(".response").length > 0) {
        //document.querySelector("#question").classList.toggle("w3-hide")
        div = createNode(["div", {}, ""], main);
        pageBar = createNode(["div", {class:"w3-bar"}, ""], div);
        div = createNode(["div", {}, ""], div);
        setHeight(div);
        for (let i = 0; i < document.querySelectorAll(".response").length; i++) {
            const element = document.querySelectorAll(".response")[i];
            let button = createNode(["button", {class:"w3-bar-item w3-button " + color}, 5 - i], pageBar);
            button.onclick = () => div.innerHTML = element.innerHTML;
        }
    }
    
    if(uri.includes("blog")) removeLeadingWhiteSpace() // Remove Leading WhiteSpace in pre tag.
    
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
    title = title.replace("og ", "Official Guide");
    title = title.replace("pq ", "Practice Questions");
    title = title.replace("mh ", "McGraw-Hill ");
    title = title.replace("kap ", "Kaplan ");
    title = title.replace(" es", " Exercise Set");
    title = title.replace(" ps", " Practice Set");
    if(!document.title) document.title = titleCase(title);
    document.title = document.title.replace("Mcgraw-hill ", "McGraw-Hill ");

}

// #region Word Set
function rgb2hex(rgb) {
    rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
    function hex(x) {
        return ("0" + parseInt(x).toString(16)).slice(-2);
    }
    return hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3]);
}

function setListStyle () {
    var selector = ""
    icons = ["material/9/,/filled-circle", "material/9/,/circled", "material-sharp/9/,/unchecked-checkbox","windows/9/,/unchecked-checkbox"]
    for (let i = 0; i < 4; i++) {
        const element = icons[i].split(",");
        selector += ">ul>li";
        if(i == 0) selector = "ul>li"
        document.querySelectorAll(selector).forEach(li => li.style.listStyle = "url('https://png.icons8.com/"+element[0]+rgb2hex(backgroundColor)+element[1]+"')")
    }
}

function addSound(link, parent) {
    var audio = createNode(["audio",{src:link},""], parent)
    let imgLink = "https://png.icons8.com/metro/20/"+rgb2hex(backgroundColor)+ "/speaker.png";
    createNode(["img",{src:imgLink,class:"w3-padding-small"},""], parent).onclick = () => audio.play();
}

function createWordSets() {

    function showWordModal(word) {
        var details = Object.keys(word)
        let modal = createNode(["div", {class:"w3-modal"}, ""], main);
        let modalContent = createNode(["div", {class:"w3-modal-content"}, ""], modal);
        createNode(["div", {class:"w3-padding "+color}, "Word Details"], modalContent);
        let div = createNode(["div", {class:"my-margin"}, ""], modalContent);
        var termDiv = createNode(["div",{class:"w3-xlarge w3-center"},word.word], div);
        addHighlight(termDiv);
        addSound(word.sounds, termDiv);
        for (let i = 0; i < details.length; i++) {
        
            if ((/word|sound/).exec(details[i])) { continue }
            let button = createNode(["button", {class:"w3-btn my-margin-small w3-padding-small " + color, id:details[i]}, details[i]], div);
            button.onclick = (e) => { 
                detailDiv.classList.add("w3-padding-small");
                detailDiv.innerHTML = word[e.target.textContent];

                // highlight word in example
                if (e.target.textContent == "examples") {
                    detailDiv.querySelectorAll("p").forEach( sentence => {
                        
                        sentence.innerText.split(" ").forEach(element => {
                            if (element.length >= word.word.length && word.word.includes(element.substring(0, element.length - 3))) { 
                                element = element.replace(/[,.]/, "")
                                sentence.innerHTML = sentence.innerHTML.replace(element, "<b>"+element+"</b>")
                            }
                        });
                        addHighlight(sentence.children[0]);
                    });
                }
                else if (e.target.textContent == "definition") {
                    detailDiv.querySelectorAll("b").forEach(node => { addHighlight(node); });
                    
                }
                else if (e.target.textContent == "synonyms") {
                    selectors = [".sds-list",".illustration", "i", ".Ant", "b", ".runseg"]
                    selectors.forEach(selector => {
                        detailDiv.querySelectorAll(selector).forEach( element => element.classList.add("w3-hide"));
                    });
                    
                    detailDiv.querySelectorAll(".Syn").forEach( element => {
                        element.innerHTML = "<p>" + element.innerHTML.replace(",", "<span>,</span>") + "</p>"
                        element.querySelectorAll("a").forEach( link => { 
                            if(/(.*\s.*|.*-.*)/.exec(link.innerText)) {
                                link.classList.add("w3-hide");
                            }
                            else {
                                link.classList.add("my-link");
                                link.href = "https://www.thefreedictionary.com/" + link.href.split("/").slice(-1) 
                            }
                        });
                        element.querySelectorAll(".w3-hide").forEach( node => { if(node.nextSibling) node.nextSibling.textContent = ""});
                    });
                    detailDiv.innerHTML = detailDiv.innerHTML.replace(/<br>/g, "")
                    detailDiv.querySelectorAll("b.w3-hide").forEach( node => { if(node.innerText == "Quotations")node.parentNode.classList.add("w3-hide") });
                    detailDiv.querySelectorAll(".exs").forEach( element => {
                        let synonyms = element.innerText.split(", ")
                        for (let index = 0; index < synonyms.length; index++) {
                            if ((/.*\s.*|.*-.*/).exec(synonyms[index])) continue;
                            // create link for each synonyms
                            let synonym = synonyms[index];
                            let href = "https://en.oxforddictionaries.com/definition/us/"+ synonym
                            let a = createNode(["a", {class:"my-link", href: href}, synonym], detailDiv);

                            // first word highlight and last word don't add delimiter ", "
                            if (index == 0) addHighlight(a)
                            if (index != synonyms.length - 1) createNode(["span", {}, ", "], detailDiv);
                        }

                        createNode(["p", {}, ""], detailDiv);
                        element.classList.add("w3-hide")
                    });
                }

                else if (e.target.textContent == "family") {
                    setListStyle();
                    detailDiv.querySelectorAll("li").forEach(node => {
                        createNode(["a", {class:"my-link", href: ("https://en.oxforddictionaries.com/definition/us/"+node.childNodes[0].textContent)}, node.childNodes[0].textContent], node, true);
                        node.childNodes[0].textContent = ""
                    });
                }
                else if (e.target.textContent == "etymology") {
                    detailDiv.querySelectorAll("a").forEach(node => {
                        index = node.href.indexOf("/wiki/")
                        string = node.href.substring(index, node.href.length)
                        node.href = "https://en.wiktionary.org" + string;
                    });
                }
            }
            
        }
        let detailDiv = createNode(["div", {class:"my-margin-small w3-padding-small"}, ""], div);
        div.querySelector("#synonyms").click();

        createNode(["button", {class:"w3-btn w3-bar w3-padding-small w3-section " + color}, "close"], div).onclick = () => { 
            modal.style.display = "none";
            main.removeChild(main.lastChild);
        };
        
        modal.style.display = "block";
    }

    sets.forEach(set => {
        
        var words = set.words;

        // put new word in the beginning
        var newWords;
        let newWord = document.querySelector("#"+set.name.replace(/ /g, "-").toLowerCase()) 
        if (newWord) { // if current vocabulary set has new words div
            newWords = newWord.innerText.split(" ");

            for (let i = 0; i < words.length; i++) {
                index = newWords.indexOf(words[i].word)
                if(index != -1) { [words[i], words[index]] = [words[index], words[i]]}
            }
        }

        var button = createNode(["button", {class:"w3-btn my-margin-small " + color}, set.name], main);
        
        button.onclick = () => {
            var div = document.querySelector("#words");
            if(!div) {div = createNode(["div",{class:"w3-section w3-bar w3-row", id:"words"},""], main);}
            div.innerHTML = "";
            words.forEach(word => {
                
                var wordDiv = createNode(["div", {class:"w3-left w3-col l2"}, ""], div);
                var buttonDiv = createNode(["div", {class:"w3-card my-margin w3-padding-small w3-center w3-border w3-large"}, word.word], wordDiv);               
                addHighlight(buttonDiv);
                
                buttonDiv.onclick = () => { showWordModal(word) }
                
            });
        }
    });
}

function createWordTest() {
    toggleElement();
    var testDiv = createNode(["div", {id:"testDiv", class:"w3-container"}, ""], document.body);
    var numberDiv = createNode(["div", {class:"w3-section"}, ""], testDiv);
    var numberP = createNode(["p", {class:"w3-large w3-center my-margin-small"}, ""], numberDiv);
    var detailDiv = createNode(["div", {class:"show-article w3-section"}, ""], testDiv);
    var optionDiv = createNode(["div", {class:" w3-section"}, ""], testDiv);
    var details = [];
    var indexes; // vocabulary set indexes for random selection (n-1,0)
    var wordCount; // word count in specific vocabulary set
    var error = 0; // error count
    var forgottenWords = []; // wrong word you select in the test and correct word you didn't select

    function showModal() {
        let modal = createNode(["div", {class:"w3-modal"}, ""], testDiv);
        let modalContent = createNode(["div", {class:"w3-modal-content"}, ""], modal);
        createNode(["div", {class:"w3-padding "+color}, "Vocabulary Set"], modalContent);
        let p = createNode(["div", {}, ""], modalContent);
        sets.forEach(set => {

            var button = createNode(["button", {class:"w3-btn my-margin " + color}, set.name], p);
            button.onclick = (e) => {
                modal.style.display = "none";
                testDiv.removeChild(testDiv.lastChild);
                showQuestion(sets.find(element => element.name == e.target.textContent));
            }

        });        
        modal.style.display = "block";
    }

    function showConfirmModal(type, set) {
        let modal = createNode(["div", {class:"w3-modal"}, ""], testDiv);
        let modalContent = createNode(["div", {class:"w3-modal-content"}, ""], modal);
        createNode(["div", {class:"w3-padding " + color}, "Confirm " + type], modalContent);
        let p = createNode(["p", {class:"w3-padding w3-section"}, ""], modalContent);
    
        // answering and correct rate
        p.innerHTML = "Do you really want to " + type + "?"
    
        let buttonBar = createNode(["div", {class:"w3-bar", id:"buttonBar"}, ""], modalContent);
        yesBtn = createNode(["button", {class:"w3-btn w3-margin w3-left " + color}, "Yes"], buttonBar);
        noBtn = createNode(["button", {class:"w3-btn w3-margin w3-right " + color}, "No"], buttonBar)
        yesBtn.onclick = () => { showReviewModal(setNumber); }
        noBtn.onclick = () => { modal.style.display = "none"; }
    
        modal.style.display = "block";
    }
    
    function showReviewModal(set) {
        var buttons = ["example", "definition", "synonyms"];
        let modal = createNode(["div", {class:"w3-modal"}, ""], testDiv);
        let modalContent = createNode(["div", {class:"w3-modal-content"}, ""], modal);
        createNode(["div", {class:"w3-padding " + color}, "Review Test"], modalContent);
        let p = createNode(["p", {class:"w3-padding w3-section"}, ""], modalContent);
        let div = createNode(["div", {class:"w3-padding-small"}, ""], modalContent);

        // answering and correct rate
        p.innerHTML = "You have <b>answered " + ((wordCount * 2) - indexes.length) + "</b> of " + (wordCount * 2) + " questions, <b>" + ((wordCount * 2) - indexes.length - error) + " of " + ((wordCount * 2) - indexes.length) + "</b> answered questions are correct."
        for (let i = 0; i < p.children.length; i++) {
            addHighlight(p.children[i]) ;
        }

        // forgotten words
        forgottenWords.forEach(word => {

            var index = vocabularySets[setNumber][1].indexOf(word);
            for (let i = 0; i < vocabularySets[setNumber][1].length; i++) {
                if(vocabularySets[setNumber][1][i][0] == word) index = i; 
            }
            let element = vocabularySets[setNumber][1][index];
            var wordDiv = createNode(["div", {class:"w3-left w3-col l3"}, ""], div);
            var buttonDiv = createNode(["div", {class:"my-margin-small w3-padding-small w3-center"}, ""], wordDiv);
            var detailDiv = createNode(["div", {class:"my-margin-small"}, ""], wordDiv);
                            
            var termDiv = createNode(["div",{class:"highlight w3-large"},word], buttonDiv);
            addHighlight(termDiv);

            // Detail div
            for (let i = 0; i < 3; i++) {
                
                let button = createNode(["button", {class:"w3-btn my-margin-small w3-padding-small " + color}, buttons[i]], buttonDiv);
                button.onclick = (e) => { 
                    detailDiv.classList.add("w3-padding-small");
                    detailDiv.innerHTML = element[1][buttons.indexOf(e.target.textContent)];

                    // button hide
                    createNode(["button", {class:"w3-btn w3-bar w3-padding-small my-margin-top-small " + color}, "hide"], detailDiv).onclick = () => { 
                        detailDiv.innerHTML = "";
                        detailDiv.classList.remove("w3-padding-small");
                    };
                    document.querySelectorAll(".illustration").forEach(element => {element.classList.add("w3-hide")})
                }
            }

            // add pronunciation
            for (let index = 0; index < element[1][element[1].length - 1].split(",").length; index++) {
                const sound = element[1][element[1].length - 1].split(",")[index];
                addSound(sound, termDiv);
            }

        });


        modal.style.display = "block";
        createNode(["button", {class:"w3-btn w3-padding w3-margin-top w3-bar " + color}, "Exit"], modalContent).onclick = () => {
            document.body.removeChild(document.body.lastChild);
            toggleElement();
        };
    }

    function showQuestion(set) {

        /** 
         * create question index array "0,0","0,1", ... , "0, n-1", "1,0", ... , "1, n-1"
         * randomly pop item from array 
         * if no item left, show review
         * show current number of all number  
         */
        
        // create question index array "0,0","0,1", ... , "0, n-1", "1,0", ... , "1, n-1"
        document.body.scrollTop = 0;
        var words = set.words;
        wordCount = words.length;
        if(!indexes) {
            indexes = new Array(wordCount * 2);
            for (let i = 0; i < wordCount; i++) {
                indexes[i] = { index:i, detail:"definitions"};
                indexes[i + wordCount] = { index:i, detail:"synonyms"};
            }
        }
        
        // randomly pop item from array
        if (indexes.length == 0) { 
            showReviewModal(set); 
            return;
        }

        let random = Math.floor(Math.random() * indexes.length);
        [indexes[random], indexes[indexes.length - 1]] = [indexes[indexes.length - 1], indexes[random]]
        let index = indexes.pop();
        var detail = index.detail;
        index = index.index;
        let word = words[index];
        let classes = {definitions:".ind", synonyms:".exs"};
        var answer = [];

        // show current number of all number
        numberP.innerHTML = "Questions " + ((wordCount * 2) - indexes.length) + " of " + (wordCount * 2);
        addHighlight(numberP);
        
        // show detail
        detailDiv.innerHTML = word.word; // questions is word
        addHighlight(detailDiv);
        addSound(word.sounds, detailDiv);
 
        //detailDiv.innerHTML = wordStructure[1][detailNumber]; // questions is detail
        if(details.includes(detailDiv.innerHTML) || detailDiv.innerHTML == "") { 
            showQuestion(set); 
            return;
        }
        details.push(detailDiv.innerHTML);
        detailDiv.querySelectorAll(".illustration").forEach(element => element.classList.add("w3-hide"));
        

        var options = new Array(4); 
        var wordNumbers = new Array(options.length);
        optionDiv.innerHTML = word[detail];
        answers = optionDiv.querySelectorAll(classes[detail]);
        for (let i = 0; i < answers.length; i++) {
            var optionNumber;
            do {
                optionNumber = Math.floor(Math.random() * options.length);
            } while (answer.includes(optionNumber) && answer.length < options.length)

            options[optionNumber] = answers[i];
            answer.push(optionNumber);
        }
        answer.sort();

        // select options randomly
        for (let i = 0; i < options.length; i++) {
            let spans;
            if(options[i]) { 
                wordNumbers[i] = words.indexOf(word);
                continue; 
            }

            do {
                var wordNumber = Math.floor(Math.random() * words.length);
            } while (wordNumbers.includes(wordNumber) && words.indexOf(word) != wordNumber)
            wordNumbers[i] = wordNumber;
            optionDiv.innerHTML = words[wordNumbers[i]][detail];
            spans = optionDiv.querySelectorAll(classes[detail]);
            if(spans.length == 0) spans = optionDiv.querySelectorAll(".Syn");
            options[i] = spans[Math.floor(Math.random() * spans.length)];
            if(!options[i])
            spans = optionDiv.querySelectorAll(".Syn");
            // exclude same option
            /**
             * while(options.includes(option)) {
                wordNumber = Math.floor(Math.random() * vocabularySets[setNumber][1].length);
                optionDiv.innerHTML = set[wordNumber][1][detailNumber];
                spans = optionDiv.querySelectorAll(classes[detailNumber]);
                options[i] = spans[Math.floor(Math.random() * spans.length)];
                wordNumbers[i] = wordNumber;
            }
             */
        }
        /**
         * // option is whole detail
        var answer = wordStructure[0];
        var wordNumbers = new Array(options.length);
        options[0] = answer;
        wordNumbers[0] = wordNumber;
        for (let i = 1; i < options.length; i++) {
            var wordNumber = Math.floor(Math.random() * vocabularySets[setNumber][1].length);
            wordNumbers[i] = wordNumber;
            let option = set[wordNumber][0];

            // exclude same option
            while(options.includes(option)) {
                wordNumber = Math.floor(Math.random() * vocabularySets[setNumber][1].length);
                wordNumbers[i] = wordNumber;
                option = set[wordNumber][0];
            }
            options[i] = option;
        }
        let randomIndex = Math.floor(Math.random() * (options.length - 1)) + 1;

        [options[0], options[randomIndex]] = [options[randomIndex], options[0]];
        [wordNumbers[0], wordNumbers[randomIndex]] = [wordNumbers[randomIndex], wordNumbers[0]];
         */

        // show options
        optionDiv.innerHTML = "";
        options.forEach(option => {
            let label = createNode(["label", {class:"my-label"}, ""], optionDiv);
            // createNode(["span", {}, option.split(",")[0]], label); // option is word 

            
            let detail = createNode(["span", {}, ""], label);
            detail.innerHTML = option.innerHTML;
            /**
             * // option is whole detail
            let index = wordNumbers[options.indexOf(option)];
            detail.innerHTML = set[index][1][detailNumber];
             */

            // option is part detail

            createNode(["input", {name:"checkbox", type:"checkbox"}], label);

            // play audio when click word
            /*
                let audio = createNode(["audio",{src:vocabularySets[setNumber][1][option.split(",")[1]][1][3].split(",")[0]},""], testDiv);
                input.onclick = (e) => audio.play();    
            */

            createNode(["span", {class:"my-checkbox"}], label);
            
        });
        addInputColor();

        // add check-next button
        var labels = optionDiv.querySelectorAll(".my-label");
        labels.forEach(element => toggleHighlight(element, true));
        createNode(["button", {class:"w3-btn w3-padding w3-section w3-bar " + color}, "Check"], optionDiv).onclick = (event) => {
            if(event.target.textContent == "Next") showQuestion(set);
            for (let i = 0; i < labels.length; i++) {
                let label = labels[i];
                let wordNumber = wordNumbers[i]
                
                if (event.target.textContent == "Check" && !answer.includes(i)) {
                    
                    //var flag = true;
                    let innerHTML = label.innerHTML;

                    label.innerHTML = "<span>"+words[wordNumber].word+"</span>";
                    addHighlight(label.children[0]);
                    let audio = createNode(["audio",{src:words[wordNumber].sound},""], label);
                    label.onclick = () => audio.play();

                    addSound(words[wordNumber].sound, label);
                    label.innerHTML = label.innerHTML + innerHTML;
                    // add toggle detail in wrong option
                    /**
                     * createNode(["button", {class:"w3-btn w3-padding-small w3-margin-left w3-right " + color}, "Toggle Detail"], element).onclick = (event) => {
                        
                        options.forEach(option => { 
                            if(option.split(",")[0] != event.target.parentNode.children[0].textContent) {return}
                                
                            if(flag) {
                                detailDiv.innerHTML = "<p>"+element.children[0].textContent+"</p>" + vocabularySets[setNumber][1][option.split(",")[1]][1][detailNumber];
                                flag = false;
                            }
                            else {
                                detailDiv.innerHTML = innerHTML;
                                flag = true;
                            }
                        });
                    };
                     */
                }
                
                if (label.children[1].checked && !answer.includes(i) || !label.children[1].checked && answer.includes(i)) {
                    // add forgotten word to array
                    if (!forgottenWords.includes(word)) { forgottenWords.push(word); }
                    var flag = true;
                }
            }
            if (flag) error++;
            event.target.textContent = "Next";
            
        };
        createNode(["button", {class:"w3-btn w3-padding w3-bar "+color}, "Exit"], optionDiv).onclick = () => {
            showConfirmModal("Exit", set);
        }
    }

    showModal();
    
}
// #endregion

function removeLeadingWhiteSpace() {
    var pres = document.getElementsByTagName("pre");
    for (const pre of pres) {
      let lines = pre.innerHTML.split( "\n" );
      let length = lines[1].length - lines[1].trimLeft(" ").length // The Greatest WhiteSpace Length to be removed
      let innerHTML = "";
      
      for (let index = 0; index < lines.length; index++) {
        const element = lines[index];
        let newLine = "\n";

        // Remove first and last empty line
        if (index == 0 || index == lines.length - 2) { newLine = ""; }

        innerHTML += element.replace(" ".repeat(length)) + newLine;
        innerHTML = innerHTML.replace("undefined", "");
      }
      pre.innerHTML = innerHTML.trimLeft("\n").trimRight("\n");
    }
}

initialize();

/*
function highlight(thisElem) {
    // Hint: Use unchanged class name
    var elems = document.getElementsByClassName(thisElem.className.split(" ")[0]);

    for (let index = 0; index < elems.length; index++) {
        elems[index].classList.toggle(color);
    }
}

    let highlightElems = document.querySelectorAll("span[class*='h-']");
    if (highlightElems) {
        highlightElems.forEach(element => {
            element.onmouseover = () => highlight(element);
            element.onmouseoout = () => highlight(element);
        });
    }
*/