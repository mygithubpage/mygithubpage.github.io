// My Personal JavaScript


hideBarItems = document.querySelectorAll(".w3-hide-small");
sidebarBtn = document.querySelector("#sidebarBtn");
sidebar = document.querySelector("#sidebar");
topNavBtn = document.querySelector("#topNavBtn");
topNav = document.querySelector("#topNav"); 
backgroundColor = window.getComputedStyle(document.querySelector("footer")).backgroundColor;
mobileFlag = screen.width < 600 ? true : false;
uri = document.location.href;
html = uri.split("/").slice(-1)[0];

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
        element.addEventListener("click", function () { sessionStorage.setItem("tag", element.textContent); })
    }
}

// Set Timer
function setTimer(second) {
    //var timerBtn = document.querySelector("#timerBtn");
    var time = document.querySelector("#time");

    var timer = second, min = 0, sec = 0;

    function startTimer(params) {
        min = parseInt(timer / 60);
        sec = parseInt(timer % 60);

        if (timer < 0) { return }
        let secStr = sec < 10 ? "0" + sec.toString() : sec.toString()
        time.innerHTML = min.toString() + ":" + secStr;
        timer--;
        setTimeout(function () { startTimer(); }, 1000);
    }
    startTimer();
}

function startTest( ) {
    
    let num = parseInt(html.substr(html.indexOf(".") - 1, 1));
    let seconds = [["45", "60", "60"], ["15", "30", "20"]];
    let questionText = document.querySelector("#question p").innerText;
    let reading = document.querySelector("#reading-text article");
    let questions = document.querySelectorAll("#question div");
    let audio;
    let testDiv = createNode( ["div", {id:"testDiv", class:"w3-container"}, ""], document.body);
    let time = createNode( ["p", {id:"time", class:"w3-center w3-jumbo my-margin-small"}, ""], testDiv);
    let myAnswer = new Array(questions.length);
    
    time.style.color = backgroundColor;
    time.style.fontWeight = "bold";
    
    function playAudio(audio, onEnd) {
        audio = new Audio(audio);
        audio.play();
        audio.addEventListener("ended", function() { onEnd(); });
    }
    
    function waitTime(second, onTimeout) {
        setTimer(second);
        setTimeout(function () { onTimeout(); }, second * 1000);
    }
    
    function endTest() {
        
        document.body.removeChild(document.body.lastChild);
        document.querySelector("nav").classList.toggle("w3-hide");        
        document.querySelector("main").classList.toggle("w3-hide")
        document.querySelector("footer").classList.toggle("w3-hide")
    }
    
    function navigateQuestion (thisElem) {
        if(uri.indexOf("listening") > 0) { id = thisElem.previousElementSibling.id; }
        index = (thisElem.innerText === "Previous" ? parseInt(id.split("n")[1] - 2) : parseInt(id.split("n")[1]));
        checkAnswer(id.split("n")[1]);

        if (index === questions.length) { 
            showModal(uri);
        }
        else { 
            if(uri.indexOf("reading") > 0) {
                if(index >= 0) {showQuestion(index);}
            }
            else { showQuestion(index); }
        }
    }

    function checkAnswer(id) {
        
        let labels = testDiv.querySelectorAll(".my-label input");
        let answer = testDiv.querySelector(".my-answer").innerText;
        let flag;
        if (answer.length < 2) {
            for (let index = 0; index < labels.length; index++) {
                const element = labels[index];
                if (!element.checked) { continue }
                let question = questions[id-1].querySelectorAll(".my-label input")[index];
                if(!question.checked) { question.click(); }
                myAnswer[id-1] = String.fromCharCode(65 + index);
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
                    if(!myAnswer[id-1]) { myAnswer[id-1] = "" }
                    myAnswer[id-1] += String.fromCharCode(65 + j);
                    flag = true;
                }
                if(!flag) {
                    if(!myAnswer[id-1]) { myAnswer[id-1] = "" }
                    myAnswer[id-1] += "N";
                }                
            }
            if(uri.indexOf("reading") > 0) {
                let category = answer.split("@")
                let keys = new Array(answer.length + 1)
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
            for (let index = 0; index < labels.length; index++) {
                const element = labels[index];
                if (!element.checked) { continue }
                let question = questions[id-1].querySelectorAll(".my-label input")[index];
                if(!question.checked) { question.click(); }
                if(!myAnswer[id-1]) { myAnswer[id-1] = "" }
                myAnswer[id-1] += String.fromCharCode(65 + index);
            }
            if (myAnswer[id-1] !== answer) { myAnswer[id-1] += "->" + answer };
        }
    }

    function showModal() {
        let modal = createNode( ["div", {class:"w3-modal"}, ""], testDiv);
        let modalContent = createNode( ["div", {class:"w3-modal-content"}, ""], modal);
        let header = createNode( ["div", {class:"w3-container " + color}, ""], modalContent);
        createNode( ["p", {}, "Confirm"], header);
        for (let i = 0; i < myAnswer.length; i++) { myAnswer[i] = " " + (i + 1) + ". " + myAnswer[i] }
        let p = createNode( ["p", {class:"w3-padding "}, myAnswer], modalContent);
        let div = createNode( ["div", {class:"w3-bar"}, ""], modalContent);
        let exitBtn = createNode( ["button", {class:"w3-btn w3-margin w3-left " + color}, "Save and Exit"], div);
        let cancelBtn = createNode( ["button", {class:"w3-btn w3-margin w3-right " + color}, "Cancel"], div);
        if (uri.indexOf("speaking") > 0) {
            p.innerHTML = testDiv.querySelector("audio").outerHTML
        }
        exitBtn.onclick = function () {
            saveExit();
            endTest();
        }
        cancelBtn.onclick = function () {modal.style.display = "none";}
        modal.style.display = "block"
        function saveExit() {
            function downloadResponse(url, fileName) {
                let download = document.createElement('a');
                download.href = url;
                download.download = fileName;
                testDiv.appendChild(download);
                download.click();
            }

            if (uri.indexOf("speaking") > 0) {
                downloadResponse(audioURL, html.replace(".html", "-record.mp3"));
            }
            else if ( uri.indexOf("writing") > 0) {
                let text = testDiv.querySelector("textarea").value.replace("\n", "</p><p>");
                text = "<p>" + text + "</p>"

                let blob = new Blob([text], {type:'text/plain'});
                downloadResponse(window.URL.createObjectURL(blob), html);
            }
        }
    }

    function recordAudio() {
        let constraints = { audio: true };
        let data = [];
    
        let onFulfilled = function (stream) {
            mediaRecorder = new MediaRecorder(stream);
            
            mediaRecorder.onstop = function (e) {
                var audio = document.createElement('audio');
                audio.setAttribute('controls', 'controls');
                testDiv.appendChild(audio);
    
                var blob = new Blob(data, { 'type': 'audio/mp3' });
                audioURL = window.URL.createObjectURL(blob);
                audio.src = audioURL;
            }
            mediaRecorder.ondataavailable = event => data.push(event.data);
        }
        navigator.mediaDevices.getUserMedia(constraints).then(onFulfilled);
    }

    function addInputColor() {
        var addColor = function(element) {    
            if (element.querySelector("input").getAttribute("type") === "radio") {
                let name = element.querySelector("input").getAttribute("name");
                let inputs = testDiv.getElementsByTagName("input");
                
                for (let index = 0; index < inputs.length; index++) {
                    const node = inputs[index].parentNode;
                    if(inputs[index].getAttribute("name") !== name ) { continue }
                    node.querySelector(".my-radio").style.backgroundColor = "lightgray";
                }
                element.querySelector(".my-radio").style.backgroundColor = backgroundColor;
            }
            else if (element.parentNode.tagName == "TD") {
                let name = element.querySelector("input").getAttribute("name");
                let inputs = testDiv.getElementsByTagName("input");
                
                for (let index = 0; index < inputs.length; index++) {
                    const node = inputs[index].parentNode;
                    if(inputs[index].getAttribute("name") !== name ) { continue }
                    node.querySelector(".my-checkbox").style.backgroundColor = "lightgray";
                    if(node.children[0].checked) { node.children[0].click(); }
                }
                element.querySelector(".my-checkbox").style.backgroundColor = backgroundColor;
                if(element.children[0].checked) {
                    //element.children[0].click();
                }
                else {
                    
                }
            }
            else {
                if (element.querySelector("input").checked) {
                    element.querySelector(".my-checkbox").style.backgroundColor = backgroundColor;
                }
                else { element.querySelector(".my-checkbox").style.backgroundColor = "lightgray"; }
            }
        }

        document.querySelectorAll(".my-label").forEach(element => {
            element.addEventListener("click", function () { addColor(element); })
        });
    }

    document.querySelector("nav").classList.toggle("w3-hide");
    document.querySelector("main").classList.toggle("w3-hide");
    document.querySelector("footer").classList.toggle("w3-hide");
    let article = createNode( ["article", {class:"show-article w3-half"}, ""], testDiv);
    

    if (uri.indexOf("speaking") > 0) {
        article.classList.toggle("w3-margin-top")
        if (!navigator.mediaDevices.getUserMedia) { endTest(); }
        recordAudio();
        
        playListening = function () { 
            article.classList.toggle("w3-hide");
            time.classList.toggle("w3-hide");
            playAudio(html.replace(".html", ".mp3"), playQuestion); 
        }
        playQuestion = function () {  
            article.innerText = questionText
            article.classList.remove("w3-hide");
            playAudio(html.replace(".html", "-question.mp3"), startPreparation); 
        }
        startPreparation = function () { playAudio("/toefl/speaking_beep_prepare.mp3", waitPreparation) }
        waitPreparation = function () { 
            time.classList.remove("w3-hide");
            waitTime(seconds[1][Math.ceil(num / 2) - 1], startSpeak); }
        startSpeak = function () { playAudio("/toefl/speaking_beep_answer.mp3", waitSpeak); }
        waitSpeak = function () { 
            mediaRecorder.start();
            waitTime(seconds[0][Math.ceil(num / 2) - 1], function() { mediaRecorder.stop(); waitTime(1,showModal);}) 
        }

        if (num < 3) {
            playQuestion();    
        }
        else if (num > 4) {
            playListening();
        }
        else {
            playAudio(html.replace(".html", "-reading.mp3"), function () { 
                article.innerHTML = reading.innerHTML
                waitTime(45, playListening); 
            });
        }
    }
    else if (uri.indexOf("writing") > 0) {
        function addTextarea() {
            function getAllIndexes(arr, val) {
                var indexes = [], i = -1;
                while ((i = arr.indexOf(val, i+1)) != -1){ indexes.push(i); }
                return indexes;
            }

            let wordCount = createNode( ["span", {class:"w3-padding w3-half"}, "Word Count: 0"], testDiv);
            wordCount.style.color = backgroundColor;
            wordCount.style.fontWeight = "bold";

            let textarea = createNode( ["textarea", {class:"w3-margin-top w3-half"}, ""], testDiv);
            textarea.oninput = function () {
                wordCount.innerText = "Word Count: " + (getAllIndexes(textarea.value, " ").length + 1)
            }
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
                textarea.style.width = "none";
            }
        }
        if (num == 1) {
            article.innerText = reading.innerText

            waitTime(180, endReading);
            function playListening() { playAudio(html.replace(".html", ".mp3"), waitWriting); }
            function endReading() {
                time.classList.toggle("w3-hide");
                article.classList.toggle("w3-hide");
                playListening();
            }

            function waitWriting() {
                time.classList.toggle("w3-hide");
                article.classList.toggle("w3-hide");
                addTextarea();
                waitTime(1200, showModal);
            }
            
        }
        else {
            article.innerText = questionText
            addTextarea();
            waitTime(1800, showModal);
        }
    }
    else if (uri.indexOf("listening") > 0) {

        let button = createNode( ["button", {class:"w3-btn w3-block w3-margin-top " + color}, "Next"], testDiv);
        button.addEventListener("click", function(e) { navigateQuestion (e.target); });

        
        function showQuestion(index) {
            button.classList.toggle("w3-hide");
            const element = questions[index];
            if (element.className.indexOf("replay") >= 0) {
                article.innerText = "Listen again to part of the lecture. Then answer the question."
                playAudio(html.replace(".html", "-" + element.id + "-replay.mp3"), function() { playListening(); } );
            }
            else { playListening(); }

            function playListening() {
                article.id = element.id;
                article.innerText = element.firstElementChild.innerText
                playAudio(html.replace(".html", "-" + element.id + ".mp3"), function() {
                    article.innerHTML = element.innerHTML;
                    article.lastElementChild.classList.add("w3-hide");
                    button.classList.toggle("w3-hide");
                    addInputColor();
                });
            }
        }
        button.classList.add("w3-hide");
        playAudio(html.replace(".html", ".mp3"), function() { 
            setTimer(180); 
            button.classList.remove("w3-hide");
            showQuestion(0);
        });

    }
    else {
        document.querySelectorAll(".underline").forEach(element => {
            element.style.fontWeight = "normal"
        });
        
        let section = createNode( ["section", {class:"show-question w3-half"}, ""], testDiv);

        showQuestion(0);
        
        function showQuestion(index) {
            

            id = questions[index].id;
            section.innerHTML = questions[index].innerHTML;
            if(questions[index].innerText.indexOf("highlighted sentence") > 0) { 
                section.children[0].innerText = "highlighted sentence in the passage?"
            }
            section.children[0].innerHTML = parseInt(id.split("n")[1]) + ". " + section.children[0].innerHTML;
            section.lastElementChild.classList.add("w3-hide");
            article.innerHTML = reading.innerHTML;
            
            article.querySelectorAll(".highlight").forEach(element => {
                element.style.color = "black";
                element.style.fontWeight = "normal";
            });

            testDiv.querySelector(".show-article h4").style.color = backgroundColor;

            for (let i = 0; i < questions[index].querySelectorAll(".my-label input").length; i++) {
                const element = questions[index].querySelectorAll(".my-label input")[i];
                if(element.checked) { section.children[i+1].click(); }
            }

            let regEx = /aragraph ./
            if(regEx.exec(section.children[0].innerText)){
                let para = regEx.exec(section.children[0].innerText)[0].slice(-1);
                article.querySelectorAll("p")[para - 1].scrollIntoView();
            }


            if(section.children[1].innerText.length < 5) {
                section.children[0].style.color = backgroundColor;
                section.children[0].style.fontWeight = "bold";
                let insertArea = article.querySelectorAll(".insert-area");
                insertArea.forEach( elem => { 
                    if(elem.getAttribute("data-answer") == "A") { elem.scrollIntoView(); }
                    elem.innerText = "[" + elem.getAttribute("data-answer") + "] "
                    elem.style.color = backgroundColor;
                    elem.style.fontWeight = "bold";
                });
                for (let index = 0; index < section.querySelectorAll(".my-label").length; index++) {
                    const element = section.querySelectorAll(".my-label")[index];
                    element.addEventListener("click", function () { 
                        insertArea.forEach(elem => {
                            elem.innerText = "[" + elem.getAttribute("data-answer") + "] "
                            elem.style.color = backgroundColor;
                            elem.style.fontWeight = "bold";
                        });
                        insertArea[index].innerText = section.children[0].innerText.split(".")[1] + ". "
                    })
                }
            }

            // highlight
            let highlight = article.querySelector("." + id)
            if(highlight) {
                //if(highlight.children[0]) {highlight.children[0].style.color = backgroundColor;}
                for (let i = 0; i < highlight.children.length; i++) {
                    const element = highlight.children[i];
                    element.style.color = backgroundColor;
                }
                highlight.style.color = backgroundColor;
                highlight.style.fontWeight = "bold";
                highlight.querySelectorAll(".highlight").forEach( elem => { elem.style.fontWeight = "bold"; })
                highlight.scrollIntoView();
                article.scrollTop = article.scrollTop - (screen.height - section.offsetHeight) / 2
                if(questions[index].innerText.indexOf("highlighted sentence") > 0) {
                    highlight.scrollIntoView();
                }
            }
            addInputColor();
            
            let div = createNode( ["div", {class:"w3-bar my-margin-top-small"}, ""], section);
            createNode( ["button", {class:"w3-btn w3-left " + color}, "Previous"], div);
            createNode( ["button", {class:"w3-btn w3-right " + color}, "Next"], div);
            div.querySelectorAll("button").forEach( elem => { elem.onclick = function(e) { navigateQuestion (e.target); }});
            if(mobileFlag) {
                section.style.borderTop= "3px solid " + backgroundColor;
                article.style.height = screen.height - section.offsetHeight - 96 + "px";
                article.style.overflow = "scroll";
                //section.classList.add("w3-small");
            }
            else{
                article.style.height = "680px";
                article.style.overflow = "scroll";
                section.classList.add("w3-padding");
            }
            
        }
    }


}


// Remove Leading WhiteSpace in pre tag.
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

function addHighlight() {
    var highlightElems = document.querySelectorAll("[class*='h-']");
    if (highlightElems) {
        highlightElems.forEach(element => {
            element.addEventListener("mouseover", function() {highlight(element)} );
            element.addEventListener("mouseout", function() {highlight(element)} );
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

    let timeSpan = document.querySelectorAll(".time");
    timeSpan.forEach(element => {
        element.classList.add("w3-hide")
    });
    
    document.querySelectorAll(".highlight").forEach(element => {
        element.style.color = backgroundColor;
        element.style.fontWeight = "bold";
    });

    testBtn = document.querySelector("#test");
    if(testBtn) {
        if(mobileFlag) { testBtn.className += " w3-block w3-margin"; }
    }

    if(!mobileFlag) {
        let nav = document.querySelector("#" + html.split("-")[0]);
        nav.classList.add("w3-hide");
        let div = createNode( ["div", {class:"w3-bar w3-margin-bottom"}, ""], document.body.children[1], "before");
        nav.querySelectorAll("a").forEach(elem => {
            let innerText = elem.innerText.replace("ing", "").replace("Writ","Write");
            createNode( ["a", {class:"w3-btn w3-padding-small w3-small " + color, href: elem.href}, innerText], div);
        });
        createNode( ["button", {class:"w3-btn w3-right " + color, id:"test"}, "Test"], div);
    }
    
    let audio = document.querySelector("audio");
    if(audio) {
        n = 0;
        let listening = document.querySelector("#listening-text article");
        listening.style.overflow = "scroll";
        listening.style.height = screen.height - audio.offsetTop - 160 + "px";
        audio.addEventListener("timeupdate", function (e) {
            let duration = parseFloat(timeSpan[n].getAttribute("data-times")) + parseFloat(timeSpan[n].getAttribute("data-time"));
            if(parseFloat(e.target.currentTime.toFixed(2)) <= duration) {
                listening.scrollTop = timeSpan[n].parentNode.offsetTop - 256;
                timeSpan[n].parentNode.style.color = backgroundColor;
                timeSpan[n].parentNode.style.fontWeight = "bold";
            }
            else {
                timeSpan[n].parentNode.style.color = "black";
                timeSpan[n].parentNode.style.fontWeight = "normal";
                n++;
            }
        });
    }

    // Add Top Navigation Button Click Event and Tag Click Event.
    topNavBtn.addEventListener("click", function () { toggleTopNav(topNavBtn) });
    var testBtn = document.querySelector("#test");
    if (testBtn) { testBtn.addEventListener("click", function () { startTest() }); }

    addTagClick(document.querySelectorAll(".w3-tag"));
    addTagClick(document.querySelectorAll("a.w3-bar-item"));

    let sidebarItems = document.querySelectorAll("#sidebar > a");
    if (sidebarItems.length > 0) {
        sidebarItems.forEach(element => {
            let item = document.querySelector("#" + element.href.split("#")[1]);
            element.addEventListener("click", function () { 
                sidebar.classList.add("w3-hide");
                window.onscroll = function () { toggleFixed(item);}
            });
        });
    }

    if (sidebarBtn) { sidebarBtn.addEventListener("click", function () { sidebar.classList.toggle("w3-hide"); }); }
    window.onscroll = function () { toggleFixed(topNav);}
    
    removeLeadingWhiteSpace(); // Remove Leading WhiteSpace in pre tag.
    
}

initialize();