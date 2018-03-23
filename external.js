// My Personal JavaScript

ogCategoryString = "Politics:og1-reading1.html;Psychology:og1-reading2.html;Geography:og1-reading3.html,og2-reading3.html;Biology:og2-reading1.html;Art:og2-reading2.html;Sociology:og3-reading1.html;Ecology:og3-reading2.html,og3-reading3.html&Teacher And Student Discussion:og1-listening1.html,og2-listening1.html,og3-listening4.html;Environmental Science:og1-listening2.html,og3-listening2.html;Philosophy:og1-listening3.html;Course Inquiry:og1-listening4.html,og2-listening4.html,og3-listening1.html;Botany:og1-listening5.html;Business:og1-listening6.html;History:og2-listening2.html,og3-listening3.html;Biology:og2-listening3.html;Astronomy:og2-listening5.html,og3-listening6.html;Art Category:og2-listening6.html,og3-listening5.html&Location:og1-speaking1.html;Learn:og1-speaking2.html,og3-speaking2.html;Logistics Services:og1-speaking3.html,og3-speaking3.html;Sociology:og1-speaking4.html;Time Conflict:og1-speaking5.html,og3-speaking5.html;Business:og1-speaking6.html,og3-speaking6.html;Life:og2-speaking1.html;Friend:og2-speaking2.html;Infrastructure Construction:og2-speaking3.html;Psychology:og2-speaking4.html,og2-speaking6.html,og3-speaking4.html;Dilemma Choice:og2-speaking5.html;Feature:og3-speaking1.html&Biology:og1-writing1.html;Family:og1-writing2.html;Education:og2-writing1.html;Lifestyle:og2-writing2.html;Art:og3-writing1.html;Friend:og3-writing2.html"

localStorage.setItem("category", ogCategoryString);
hideBarItems = document.querySelectorAll(".w3-hide-small");
sidebarBtn = document.querySelector("#sidebarBtn");
sidebar = document.querySelector("#sidebar");
topNavBtn = document.querySelector("#topNavBtn");
topNav = document.querySelector("#topNav"); 
main = document.querySelector("main"); 
backgroundColor = window.getComputedStyle(document.querySelector("footer")).backgroundColor;

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

function addHighlight(element) {
    let highlightElems = document.querySelectorAll("[class*='h-']");
    if (highlightElems) {
        highlightElems.forEach(element => {
            element.addEventListener("mouseover", function() {highlight(element)} );
            element.addEventListener("mouseout", function() {highlight(element)} );
        });
    }
    if(element) {
        element.style.color = backgroundColor;
        element.style.fontWeight = "bold";
    }
}

function toggleHighlight(element) {
    if(element.style.color !== backgroundColor) {
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

    var addColor = function(element) {    

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

    document.querySelectorAll(".my-label").forEach(element => {
        element.addEventListener("click", function () { addColor(element); })
    });
}

function addTextarea(note, parent, before) {
    function getAllIndexes(arr, val) {
        var indexes = [], i = -1;
        while ((i = arr.indexOf(val, i+1)) != -1){ indexes.push(i); }
        return indexes;
    }

    if(!note) {
        wordCountDiv = createNode( ["div", {class:"w3-half w3-padding"}, ""], testDiv);
        wordCount = createNode( ["span", {class:"w3-large"}, "Word Count: 0"], wordCountDiv);
        toggleHighlight(wordCount);
        let time = createNode( ["span", {id:"time", class:"w3-large w3-right"}, ""], wordCountDiv);
        toggleHighlight(time);
        textarea = createNode( ["textarea", {class:"w3-half"}, ""], testDiv);
    }
    else {
        if(parent) { textarea = createNode( ["textarea", {class:"w3-section", autofocus:"autofocus"}, ""], parent, before); }
        else { textarea = createNode( ["textarea", {class:"w3-section", autofocus:"autofocus"}, ""], testDiv); }
    }

    if(!note) {
        textarea.oninput = function (e) {
            wordCount.innerText = "Word Count: " + (getAllIndexes(e.target.value, " ").length + 1)
        }
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
        textarea.style.width = note ? "-webkit-fill-available" : "none";
    }
    return textarea;
}

function startTest() {
    
    let num = parseInt(html.substr(html.indexOf(".") - 1, 1));
    let seconds = [["45", "60", "60"], ["15", "30", "20"]];
    let questionText = document.querySelector("#question p").innerText;
    let reading = document.querySelector("#reading-text article");
    let questions = document.querySelectorAll("#question div");
    
    let audio;
    let testDiv = createNode( ["div", {id:"testDiv", class:"w3-container"}, ""], document.body);
    let myAnswer = new Array(questions.length);
    

    function setTimer(second) {
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
                button.onclick = function() { 
                    audio.play();
                    article.classList.toggle("w3-hide");
                    button.classList.toggle("w3-hide");
                    audio.addEventListener("ended", function() { onEnd(); });
                };
            }).then(() => {
                // Auto-play started
                audio.addEventListener("ended", function() { onEnd(); });
            });
        }
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

        let answer = testDiv.querySelector(".my-answer").innerText;
        let flag;
        let selection;
        if (!myAnswer[id-1] || !myAnswer[id-1].split("->")[0]) {  } 
        myAnswer[id-1] = "";
        if (answer.length < 2) {
            for (let index = 0; index < inputs.length; index++) {
                const element = inputs[index];
                if (!element.checked) { continue }
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
                    myAnswer[id-1] += String.fromCharCode(65 + j);
                    flag = true;
                }
                if(!flag) {
                    if(!myAnswer[id-1]) { myAnswer[id-1] = "" }
                    myAnswer[id-1] += "N";
                }                
            }
            if(uri.includes("reading")) {
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
                downloadResponse(audioURL, html.replace(".html", "-record.mp3"));
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

        if(uri.includes("speaking") || uri.includes("writing")) {
            modal = createNode( ["div", {class:"w3-modal"}, ""], testDiv);
            modalContent = createNode( ["div", {class:"w3-modal-content"}, ""], modal);
            let header = createNode( ["div", {class:"w3-container " + color}, ""], modalContent);
            p = createNode( ["p", {}, ""], modalContent);
        }
        else {
            modal = reviewQuestions();
            modalContent = modal.children[0]
            let tr = modalContent.querySelectorAll("tbody tr");
            for (let i = 0; i < tr.length; i++) { 
                tr[i].children[1].innerText = myAnswer[i]; 
            }
        }
        let buttonBar = testDiv.querySelector("#buttonBar");
        if (!buttonBar) { 
            let buttonBar = createNode( ["div", {class:"w3-bar", id:"buttonBar"}, ""], modalContent);
            exitBtn = createNode( ["button", {class:"w3-btn w3-margin w3-left " + color}, "Save and Exit"], buttonBar);
            cancelBtn = createNode( ["button", {class:"w3-btn w3-margin w3-right " + color}, "Cancel"], buttonBar);
        }
        if (uri.includes("speaking")) {
            p.innerHTML = testDiv.querySelector("audio").outerHTML
        }
        exitBtn.onclick = function () {
            saveExit();
            endTest();
        }
        cancelBtn.onclick = function () {modal.style.display = "none";}
        modal.style.display = "block";
        
    }

    function reviewQuestions(id) {
        if(id) { checkAnswer(id); }
        let modal = testDiv.querySelector(".w3-modal");
        if (!modal) {
            modal = createNode( ["div", {class:"w3-modal"}, ""], testDiv);
            modalContent = createNode( ["div", {class:"w3-modal-content"}, ""], modal);
            let table = createNode( ["table", {class:"w3-table-all w3-padding-small"}, ""], modalContent);
            let thead = createNode( ["thead", {}, ""], table);
            let tr = createNode( ["tr", {class: color}, ""], thead);
            createNode( ["td", {}, "Question"], tr);
            createNode( ["td", {}, "Option"], tr);

            let tbody = createNode( ["tbody", {}, ""], table);
            for (let i = 0; i < questions.length; i++) {
                const element = questions[i];
                innerText = element.children[0].innerText
                let tr = createNode( ["tr", {}, ""], tbody);
                
                let td = createNode( ["td", {}, element.children[0].innerText], tr);
                td.style.maxWidth = "280px";
                td.style.overflow = "hidden";
                td.style.textOverflow = "ellipsis";
                td.style.whiteSpace = "nowrap";

                if(myAnswer[i]===undefined) { myAnswer[i] = "" }
                createNode( ["td", {}, myAnswer[i].split("->")[0]], tr);
                tr.onclick = function() {
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

    document.querySelector("nav").classList.toggle("w3-hide");
    document.querySelector("main").classList.toggle("w3-hide");
    document.querySelector("footer").classList.toggle("w3-hide");
    article = createNode( ["article", {class:"show-article w3-half"}, ""], testDiv);
    
    if (uri.includes("reading")) {
         
        function showQuestion(index) {

            id = questions[index].id;
            
            section.innerHTML = questions[index].innerHTML;
            section.lastElementChild.classList.add("w3-hide");

            article.innerHTML = reading.innerHTML;
            
            article.querySelectorAll(".highlight").forEach(element => {
                element.style.color = "black";
                element.style.fontWeight = "normal";
            });
            insertArea = article.querySelectorAll(".insert-area");

            inputs = testDiv.querySelectorAll(".my-label input");    
            let labels = section.querySelectorAll(".my-label");
            if(mobileFlag) {
                section.children[0].style.margin = "8px";
                labels.forEach(elem => { elem.style.marginBottom = "4px"; });
            }        
            testDiv.querySelector(".show-article h4").style.color = backgroundColor;
            addInputColor();
            
            let div = createNode( ["div", {class:"w3-bar my-margin-top-small w3-display-container w3-section "}, ""], section);
            let previouBtn = createNode( ["button", {class:"w3-btn w3-left " + color}, "Previous"], div);
            
            if (mobileFlag) {
                time.classList.add("w3-hide");
                timer = createNode( ["span", {class:"w3-display-middle w3-xxlarge"}, ""], div);
                time.addEventListener('DOMSubtreeModified', function () {
                    timer.innerText = time.innerText;
                    addHighlight(timer);
                });
            }
            addHighlight(time);
            let nextBtn = createNode( ["button", {class:"w3-btn w3-right " + color}, "Next"], div);
            let reviewBtn = testDiv.querySelector("#review");
            if (!reviewBtn) {
                reviewBtn = createNode(["button", {class:"w3-btn w3-block w3-half " + color, id:"review"}, "Review Questions"], testDiv);
            }

            reviewBtn.addEventListener("click", function () { reviewQuestions(id.split("n")[1]); });
            div.querySelectorAll("button").forEach( elem => { 
                if(mobileFlag) { elem.classList.toggle("w3-padding-small"); }
                elem.onclick = function(e) { navigateQuestion (e.target); }
            });

            if(mobileFlag) {
                section.style.borderTop= "3px solid " + backgroundColor;
                article.style.height = screen.height - section.offsetHeight - 80 + "px";
                article.style.overflow = "scroll";
            }
            else{
                article.style.height = "680px";
                article.style.overflow = "scroll";
                section.classList.add("w3-padding");
            }
            
            let regEx = /aragraph ./
            if(regEx.exec(section.children[0].innerText)){
                let para = regEx.exec(section.children[0].innerText)[0].slice(-1);
                article.querySelectorAll("p")[para - 1].scrollIntoView();
            }

            // insert Text
            if(section.children[1].innerText.length < 5) {
                toggleHighlight(section.children[0]);
                
                insertArea.forEach( elem => { 
                    if(elem.getAttribute("data-answer") == "A") { elem.scrollIntoView(); }
                    article.scrollTop = article.scrollTop - 6
                    elem.innerText = "[" + elem.getAttribute("data-answer") + "] "
                    toggleHighlight(elem);
                });
                for (let index = 0; index < inputs.length; index++) {
                    const element = inputs[index];
                    element.addEventListener("click", function () { 
                        insertArea.forEach(elem => {
                            elem.innerText = "[" + elem.getAttribute("data-answer") + "] "
                            addHighlight(elem);
                        });
                        insertArea[index].innerText = section.children[0].innerText.split(".")[1] + ". "
                    })
                }
            }

            // highlight
            let highlight = article.querySelector("." + id)
            if(highlight) {
                for (let i = 0; i < highlight.children.length; i++) {
                    const element = highlight.children[i];
                    element.style.color = backgroundColor;
                }
                toggleHighlight(highlight);
                highlight.querySelectorAll(".highlight").forEach( elem => { addHighlight(elem); })
                highlight.scrollIntoView();
                article.scrollTop = article.scrollTop - (screen.height - section.offsetHeight) / 2
                if(questions[index].innerText.includes("highlighted sentence")) {
                    //highlight.querySelectorAll(".highlight").forEach( elem => { elem.style.fontWeight = "bold"; })
                    section.children[0].innerText = "";
                    article.style.height = Math.max(highlight.offsetHeight, screen.height - section.offsetHeight) + "px";
                    highlight.scrollIntoView();
                }
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
                        inputs[element.charCodeAt(0) - 65].click(); 
                        if(section.children[1].innerText.length < 3) { 
                            insertArea[element.charCodeAt(0) - 65].innerText = section.children[0].innerText.split(".")[1] + ". "
                        }
                    }
                }
            }
        }

        let section = createNode( ["section", {class:"show-question w3-half"}, ""], testDiv);
        time = createNode( ["p", {id:"time", class:"w3-jumbo w3-center w3-half"}, ""], testDiv);
        second = 1200
        setTimer(second);
        showQuestion(0);

    }
    else if (uri.includes("listening")) {
        article.classList.toggle("w3-half");
        let button = createNode( ["button", {class:"w3-btn w3-block w3-section w3-hide "+color}, "Next"], testDiv);
        button.addEventListener("click", function(e) { navigateQuestion (e.target); });
        time = createNode( ["p", {id:"time", class:"w3-xxlarge w3-center my-margin-small"}, ""], testDiv);
        addTextarea("note");

        function showQuestion(index) {
            inputs = testDiv.querySelectorAll(".my-label input");
            
            const element = questions[index];
            if (element.className.includes("replay")) {
                article.innerText = "Listen again to part of the lecture. Then answer the question."
                playAudio(html.replace(".html", "-" + element.id + "-replay.mp3"), function() { playListening(); } );
            }
            else { playListening(); }

            function playListening() {
                article.id = element.id;
                article.innerHTML = element.children[0].outerHTML
                button.classList.add("w3-hide");
                time.classList.add("w3-hide");
                playAudio(html.replace(".html", "-" + element.id + ".mp3"), function() {
                    article.innerHTML = element.innerHTML;
                    article.lastElementChild.classList.add("w3-hide");
                    button.classList.remove("w3-hide");
                    time.classList.remove("w3-hide");
                    addInputColor();
                });
            }
        }
        
        playAudio(html.replace(".html", ".mp3"), function() {
            second = 180
            setTimer(second);
            addHighlight(time);
            showQuestion(0);
        });

    }
    else if (uri.includes("speaking")) {
        if(uri.startsWith("file:/")) { mediaRecorder = recordAudio(); }

        time = createNode( ["p", {id:"time", class:"w3-xxlarge w3-center my-margin-small"}, ""], testDiv);
        addHighlight(time);
        article.classList.toggle("w3-half");
        article.classList.toggle("w3-section")
        addTextarea(true);

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
        startPreparation = function () { playAudio("../../speaking_beep_prepare.mp3", waitPreparation) }
        waitPreparation = function () { 
            time.classList.remove("w3-hide");
            waitTime(seconds[1][Math.ceil(num / 2) - 1], startSpeak); }
        startSpeak = function () { playAudio("../../speaking_beep_answer.mp3", waitSpeak); }
        waitSpeak = function () {
            if(uri.startsWith("file:/")) { 
                mediaRecorder.start();
                waitTime(seconds[0][Math.ceil(num / 2) - 1], function() { 
                    mediaRecorder.stop(); 
                    waitTime(1,showModal);
                });
            }
            else {
                var handleSuccess = function(stream) {
                    var audio = document.createElement('audio');
                    if (window.URL) {
                        audio.src = window.URL.createObjectURL(stream);
                    } else {
                        audio.src = stream;
                    }
                    audio.setAttribute('controls', 'controls');
                    testDiv.appendChild(audio);
                };
                
                navigator.mediaDevices.getUserMedia({ audio: true })
                    .then(handleSuccess);
            }
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

function updateNav() {
    let length;
    let setFlag = html.includes("-");
    sections = ["Reading:3", "Listening:6", "Speaking:6", "Writing:2"];
    document.querySelectorAll(".w3-dropdown-content").forEach(element => {
        element.style.minWidth = "auto";
    });
    if(uri.includes("notes") || uri.includes("blog") || uri.includes("essay")) { return }
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
            length = 3;
        }
        sets = html.split(".")[0]; 
    }
    
    if(mobileFlag) {
        for (let i = 1; i <= length; i++) {
            let number = (i < 10  && !html.includes("og") ? "0" + i : i);
            let set = setFlag ? sets : sets + number;
            let before = setFlag || html.includes("og") ? true : false;
            div = createNode( ["div", {class:"w3-bar w3-section"}, ""], main, before);
            if(!setFlag) { div.style.fontSize = "13px"; }
            if(!setFlag) { createNode( ["span", {class:"w3-bar-item w3-btn w3-padding-small my-color"}, set.toUpperCase()], div); }
            sections.forEach( element => {
                let section = element.split(":")[0];
                let dropdown = createNode( ["div", {class:"w3-dropdown-click"}, ""], div);
                let button = createNode( ["button", {class:"w3-bar-item w3-button w3-padding-small my-color"}, section], dropdown);
                let dropdownContent = createNode( ["div", {class:"w3-dropdown-content w3-bar-block"}, ""], dropdown);
                for (let index = 1; index <= parseInt(element.split(":")[1]); index++) {
                    let href = set + "-" + section.toLowerCase() + index + ".html";
                    href = !setFlag ? set + "/" + href : href;
                    let a = createNode( ["a", {class:"w3-bar-item w3-btn", href: href}, section + " " + index], dropdownContent);
                }
            });
        }
        document.querySelectorAll(".w3-dropdown-click button").forEach(elem => { 
            elem.onclick = function (e) {e.target.nextElementSibling.classList.toggle("w3-show")}; 
        });
    }
    else {
        for (let i = 1; i <= length; i++) {
            let number = (i < 10  && !html.includes("og") ? "0" + i : i);
            let set = setFlag ? sets : sets + number;
            let before = setFlag && html.includes("og") ? true : false;
            div = createNode( ["div", {class:"w3-bar w3-section"}, ""], main, before);
            div.style.fontSize = "14px";
            if(!setFlag) { createNode( ["span", {class:"w3-bar-item w3-btn w3-padding-small my-color"}, set.toUpperCase()], div); }
            sections.forEach( element => {
                let section = element.split(":")[0];
                for (let index = 1; index <= parseInt(element.split(":")[1]); index++) {
                    let href = set + "-" + section.toLowerCase() + index + ".html";
                    href = !setFlag ? set + "/" + href : href;
                    type = element.split(":")[0].replace("ing", "").replace("Writ","Write");
                    let a = createNode( ["a", {class:"w3-padding-small w3-button " + color, href: href}, type + " " + index], div);
                }
            });
        }
    }

    if(setFlag) { 
        href = "../" + uri.split("/").slice(-3)[0] + ".html"
        categoryBtn = createNode( ["a", {class:"w3-btn w3-left w3-section w3-large " + color, href:href}, "See Same Category Passage"], div); 
        testBtn = createNode( ["button", {class:"w3-btn w3-right w3-section w3-large " + color, id:"test"}, "Test"], div); 
        if(mobileFlag) { 
            testBtn.className += " w3-block"; 
            categoryBtn.className += " w3-block"; 
        }

        categoryBtn.onclick = function () {
            ogCategoryString.split("&").forEach(element => { 
                if(element.includes(html)) {
                    element.split(";").forEach(elem => {
                        if(elem.includes(html)) { tag = elem.split(":")[0]; }
                    })
                }
            })
            sessionStorage.setItem("tag", tag + ":" + html);
        }

    }
    else {
        function filterTag(element) {
            selector = ".w3-bar.w3-section " + (mobileFlag ? "> div" : "a" );
            document.querySelectorAll(selector).forEach( elem => {
                
                if(mobileFlag) {
                    elem.children[0].style.display = "none";
                    elem.children[1].style.display = "block";
                    for (let i = 0; i < elem.children[1].children.length; i++) {
                        const e = elem.children[1].children[i];
                        e.style.display = "none";
                        if(element.split(":")[1].includes(e.href.split("/").splice(-1)[0])) {      
                            e.style.display = "inline-block";     
                            e.className = e.className.replace("w3-bar-item ",color + " w3-padding-small ");
                        }
                    }
                }
                else {
                    elem.style.display = "none";
                    if(element.split(":")[1].includes(elem.href.split("/").splice(-1)[0])) { elem.style.display = "table-cell"; }
                }
            }) 
        }

        categoryDiv = createNode( ["div", {}, ""], main, true);
        div = createNode( ["div", {class:"w3-bar w3-card my-color"}, ""], categoryDiv);
        if(mobileFlag) { categoryDiv.style.fontSize = "13px"; }
        for (let i = 0; i < 4; i++) {
            button = createNode( ["button", {class:"w3-bar-Item w3-button w3-col l2"}, sections[i].split(":")[0]], div);
            if(mobileFlag) { button.className = button.className.replace("w3-col l2", "w3-padding-small"); }
            button.onclick = function() {
                categroyDiv.innerHTML = "";
                ogCategoryString.split("&")[i].split(";").forEach( element => {
                    let tag = element.split(":")[0];
                    a = createNode(["button", {class:"tag w3-btn w3-padding-small my-margin-small " + color}, tag], categroyDiv);
                    
                    a.onclick = function() { filterTag(element); }
                })
            };
        }
        let search = createNode( ["button", {class:"w3-bar-Item w3-button w3-right"}, "Search"], div);

        if(mobileFlag) { search.classList.toggle("w3-padding-small") 
        }
        categroyDiv = createNode( ["div", {class:"w3-padding-small w3-card w3-white"}, ""], categoryDiv);

        var tag = sessionStorage.getItem("tag");

        if (tag) { 
            document.querySelectorAll(".w3-bar-Item.w3-button").forEach(element => {
                if(tag.includes(element.textContent.toLowerCase())) { 
                    element.click(); 
                    for (let i = 0; i < categroyDiv.children.length; i++) {
                        const elem = categroyDiv.children[i];
                        if(tag.split(":")[0] === elem.textContent) { 
                            elem.click(); 
                            sessionStorage.removeItem("tag");
                        }
                    }
                }
            }); 
        }
    }
    
    
}

function updateNotes() {
    if(!uri.includes("blog") && !uri.includes("notes")) { return }
    if(uri.includes("blog")) {
        entries = [
            ["javascript.html", "JavaScript"],
            ["powershell.html", "PowerShell"],
            ["css.html","CSS"]
        ];
    }
    else {
        entries = [
            ["og-example-writing2.html", "Example Independent Writing Trait", 
            "Do you agree or disagree with the following statement?<br/><b>Always telling the truth is the most important consideration in any relationship.</b><br/>Use specific reasons and examples to support your answer."],
    
            ["sample-question-writing2.html", "Sample Independent Writing Comparative",
            "Do you agree or disagree with the following statement?<br/><b>A teacher's ability to relate well with students is more important than excellent knowledge of the subject being taught.</b><br/>Use specific reasons and examples to support your answer."],
    
            ["og-example-writing1.html","Example Integrated Writing"],
            ["sample-question-writing1.html", "Sample Integrated Writing"],
            ["performance-feedback.html", "Performance"],
            ["scoring-rubric.html", "Scoring"]
        ];
    }
    var entriesString = "";
    entries.forEach(element => { entriesString += element[0] + "," + element[1] + ";"});
    localStorage.setItem("tags", entriesString);

    function createEntry(entries) {
        let entriesDiv = document.querySelector("#entries")
        entries.forEach(element => {
            let div = createNode(["div", {class : "w3-card w3-padding w3-section w3-white my-entry"}, ""], entriesDiv);
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
                createNode(["a", {class:"tag w3-btn w3-padding-small my-margin-small w3-border highlight"}, tag], tagDiv);
            });
        });
    }
    createEntry(entries);
    entries = document.querySelectorAll(".my-entry");

    var barItems = document.querySelectorAll("a.w3-bar-item");
    var tags = document.querySelectorAll("a.tag"); // All tags in all entries.
    var tagsDiv = document.querySelector("#tagsDiv"); // Place to add tags
    var tagsArray = []; // All tags need to be show in tag div on load.
    var selectedTags = []; // Add element when a tag is selected in tag div. otherwise remove it.    
    

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
        let entryTags = entry.querySelectorAll("a.tag");
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
          entryTagsArray.forEach(element => { entriesTagsArray.push(element) } );
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
    function clickTag(tagBtns) {
        var tag = sessionStorage.getItem("tag");
        if (tag) { 
            tagBtns.forEach(element => {
            if(element.textContent === tag) {  element.click(); }
            }); 
        }
    }

    // If Article Tag or Top Bar Item is clicked, store the content of clicked tag in sessionStorage
    function addTagClick(tags) {
        for (let index = 0; index < tags.length; index++) {
            const element = tags[index];
            element.addEventListener("click", function () { sessionStorage.setItem("tag", element.textContent); })
        }
    }

    entries.forEach(entry => { entry.querySelector("a").style.padding = 0; });
    
    // Show tags
    if(tagsDiv) {
        tags.forEach(tag => {
            element = tag.textContent;
            if(tagsArray.indexOf(element) === -1){
              tagsArray.push(element);
              var btn = document.createElement("button");
              btn.className = "tag w3-btn w3-padding-small my-margin-small highlight w3-border";
              
              btn.textContent = element;
              tagsDiv.appendChild(btn);
            }
          });
    }
    
    document.querySelectorAll(".highlight").forEach(element => { addHighlight(element); });
    document.querySelectorAll("b").forEach(element => { 
        addHighlight(element); 
        element.style.whiteSpace = "normal";
    });

    localStorage.getItem("tags").split(";").forEach(element => { if(element.split(",")[0] === html) {
        title = element.split(",")[1];
        return
    }});

    if(!uri.includes("notes.html") && !uri.includes("blog.html") && title) {
        document.title = title;
        uri.split("/").slice(-2)
        let tagDiv = document.querySelector("#tags");
        title.split(" ").forEach( tag => {
            let classes = "tag w3-btn w3-padding-small my-margin-small " + color;
            let href = uri.split("/").slice(-2)[0] + ".html";
            createNode(["a", {class:classes, href:href}, tag], tagDiv);
        });
    }
    
    // Add filter Event for tags in tag div. 
    var tagBtns = document.querySelectorAll("#tagsDiv > button.tag");
    tagBtns.forEach(element => {
      element.addEventListener("click", function() { toggleFilter(element); });
    });

    // Add top bar item tag.
    barItems.forEach(element => {
      element.addEventListener("click", function() {clickTag(element.textContent)} );
    });

    // Add article tag.
    tags.forEach(element => {
      element.addEventListener("click", function() {clickTag(element.textContent)} );
    });
    
    // Filter Tag
    clickTag(tagBtns)
  
    addTagClick(document.querySelectorAll(".tag"));
    addTagClick(document.querySelectorAll("a.w3-bar-item"));

    // Add Sidebar Button and Click Event
    /*window.addEventListener("load", function() { 
      addSiderbarBtn();
      sidebar.innerHTML = tagsDiv.innerHTML;
      sidebarItems = document.querySelectorAll("#sidebar > button");
      sidebarItems.forEach(element => {
        element.addEventListener("click", function() {
          toggleFilter(element);
        });
      });
    });*/

}

function initialize() {

    document.querySelectorAll(".highlight").forEach(element => { toggleHighlight(element); });

    updateNav();
    addInputColor();
    updateNotes();
    document.querySelectorAll(".my-color").forEach(element => {
        element.classList.remove("my-color");
        element.classList.add(color);
    });
    // Add Top Navigation Button Click Event and Tag Click Event.
    topNavBtn.addEventListener("click", function () { toggleTopNav(topNavBtn) });
    var testBtn = document.querySelector("#test");
    if (testBtn) { testBtn.addEventListener("click", function () { startTest() }); }

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
    
    

    let questions = document.querySelector("#question");
    if(questions && questions.children.length > 4) {
        for (let i = 0; i < questions.children.length; i++) {
            const element = questions.children[i];
            element.children[0].innerText = element.id.split("n")[1] + ". " + element.children[0].innerText
        }
    }

    let timeSpan = document.querySelectorAll(".time");
    timeSpan.forEach(element => {
        element.classList.add("w3-hide")
    });

    let audio = document.querySelector("audio");
    if(audio && uri.includes("listening")) {
        n = 0;
        let listening = document.querySelector("#listening-text article");
        listening.style.overflow = "scroll";
        listening.style.height = screen.height - audio.offsetTop - 160 + "px";
        audio.addEventListener("timeupdate", function (e) {
            let duration = parseFloat(timeSpan[n].getAttribute("data-times")) + parseFloat(timeSpan[n].getAttribute("data-time"));
            if(parseFloat(e.target.currentTime.toFixed(2)) <= duration) {
                listening.scrollTop = timeSpan[n].parentNode.offsetTop - 256;
                addHighlight(timeSpan[n].parentNode, true);
            }
            else {
                toggleHighlight(timeSpan[n].parentNode);
                n++;
            }
        });
    }
    if(uri.includes("topic")) {
        addHighlight(document.querySelector("h3"));
        document.querySelector("div.w3-bar").classList.toggle("w3-hide");
        article = document.querySelector("article");
        var textarea = addTextarea(true, document.querySelector("main"), true);
        textarea.style.height = screen.height / 2 - 96 + "px";
        article.style.height = screen.height / 2 - 96 + "px";
        article.style.overflow = "scroll";
        article.classList.toggle("w3-section")
    }

    if(uri.includes("blog")) { removeLeadingWhiteSpace(); } // Remove Leading WhiteSpace in pre tag.
    
}

initialize();