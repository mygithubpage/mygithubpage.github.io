greFlag = (/verbal|quantitative|reading\.|text|sentence|issue|argument/).exec(uri)
num = parseInt(uri.match(/\d(?=\.html)/));
setFlag = uri.match(/ing\d\.html/);
sections = [{
    "type": "Reading",
    "length": 3
}, {
    "type": "Listening",
    "length": 6
}, {
    "type": "Speaking",
    "length": 6
}, {
    "type": "Writing",
    "length": 2
}];


function setArticleHeight(height) {

    height = height ? height : screen.height / 3 + "px";
    if (typeof height == "object") {
        article = height;
        height = screen.height / 3 + "px";
    }
    if (typeof article == "undefined") return
    article.style.height = height;
    article.style.overflow = "scroll";
    article.classList.add("w3-section");
}

// Reading Question
function showSpecialQuestion(article, section) {
    question = section.querySelector(".question")
    article.querySelectorAll("span").forEach(elem => {
        if (elem.className.includes("question")) {
            removeHighlight(elem);
        }
    });

    let inputs = section.querySelectorAll(".my-label input");
    if (/aragraph \d/.exec(question.innerText)) {
        let para = /aragraph \d/.exec(question.innerText)[0].slice(-1);
        let paragraph = article.querySelectorAll("p")[para - 1];
        paragraph.scrollIntoView();
        //article.scrollTop -= 1;
    }

    // insert Text
    insertArea = article.querySelectorAll(".insert-area");
    insertArea.forEach(area => area.innerText = "");
    if (!section.querySelector(".choices > table") && section.querySelector(".choices > p").innerText.length < 3) {
        addHighlight(question);

        // Add A B C D in inserted area
        insertArea.forEach(area => {
            if (area.getAttribute("data-answer") == "A") {
                area.scrollIntoView();
            }
            article.scrollTop -= 10
            area.innerText = `[${area.getAttribute("data-answer")}] `
            addHighlight(area);
        });

        // Add text in inserted area
        for (let i = 0; i < inputs.length; i++) {
            inputs[i].onclick = () => {
                section.querySelectorAll(".my-label input");
                insertArea.forEach(area => {
                    area.innerText = `[${area.getAttribute("data-answer")}] `
                    addHighlight(area);
                });
                insertArea[i].innerText = question.innerText.replace(/\d{1,2}\./g, "")
            }
        }
    }


    // highlight
    let highlight = article.querySelector("." + id);
    if (highlight) {
        for (let i = 0; i < highlight.children.length; i++) {
            const element = highlight.children[i];
            element.style.color = bgColor;
        }
        addHighlight(highlight);
        highlight.scrollIntoView();
        article.scrollTop = article.scrollTop - (screen.height - section.offsetHeight) / 2 + 64
        index = parseInt(section.children[0].innerText.split(".")[0]) - 1;
        if (question.innerText.includes("best expresses the essential")) {
            highlight.querySelectorAll(".my-highlight").forEach(elem => addHighlight(elem));
            question.innerText = "";
            setArticleHeight(Math.max(highlight.offsetHeight, screen.height - section.offsetHeight) + "px")
            highlight.scrollIntoView();
        }
    }
}

function addTextarea(parent) {
    function getAllIndexes(arr, val) {
        var indexes = [],
            i = -1;
        while ((i = arr.indexOf(val, i + 1)) != -1) {
            indexes.push(i);
        }
        return indexes;
    }
    wordCountDiv = createNode(["div", {
        class: "w3-padding w3-section"
    }], parent);
    wordCount = createNode(["span", {
        class: "w3-large my-highlight"
    }, "Word Count: 0"], wordCountDiv);

    createNode(["span", {
        id: "time",
        class: "w3-large w3-right my-highlight"
    }], wordCountDiv);

    textarea = createNode(["textarea", {
        class: "my-border w3-padding w3-block"
    }], parent);
    textarea.oninput = e => wordCount.innerHTML = `Word Count: ${getAllIndexes(e.target.value, " ").length + 1}`;
    if (typeof article != "undefined") article.classList.toggle("w3-padding-small");
    if (typeof section != "undefined") section.classList.toggle("w3-padding-small");
    textarea.style.height = `${window.innerHeight}px`;

    return textarea;
}

function startTest() {

    let seconds = [
        ["45", "60", "60"],
        ["15", "30", "20"]
    ];

    let reading = document.querySelector("article.passage");

    let audio;
    let testDiv = createNode(["div", {
        id: "testDiv",
        class: "w3-container"
    }], document.body);
    let myAnswer = new Array(questions.length);


    function setTimer(second) {
        var time = document.querySelector("#time");
        var timer = second,
            min = 0,
            sec = 0;

        function startTimer(params) {
            min = parseInt(timer / 60);
            sec = parseInt(timer % 60);

            if (timer < 0) {
                return
            }
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
                if (!button) {
                    button = createNode(["button", {
                        class: `${color} w3-btn w3-block w3-section w3-hide`,
                        id: "playAudio"
                    }, "Play Audio"], testDiv, true);
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
        setTimeout(() => onTimeout(), second * 1000);
    }

    function endTest() {
        document.body.removeChild(document.body.lastChild);
        toggleElement();
    }

    function recordAudio() {
        let constraints = {
            audio: true
        };
        let data = [];

        let onFulfilled = stream => {
            mediaRecorder = new MediaRecorder(stream);

            mediaRecorder.onstop = e => {
                var audio = document.createElement('audio');
                audio.setAttribute('controls', 'controls');
                testDiv.appendChild(audio);

                var blob = new Blob(data, {
                    'type': 'audio/mp3'
                });
                audioURL = window.URL.createObjectURL(blob);
                audio.src = audioURL;
            }
            mediaRecorder.ondataavailable = event => data.push(event.data);
            return mediaRecorder;
        }
        navigator.mediaDevices.getUserMedia(constraints).then(onFulfilled);

    }

    function navigateQuestion(button) {
        let number = /\d+/.exec(id);
        index = Math.abs(button.innerText == "Next" ? parseInt(number) : parseInt(number - 2));
        setAnswer(number);

        if (index == questions.length) {
            showModal(uri);
        } else {
            showQuestion(index);
        }
    }

    function setAnswer(id) {

        answer = testDiv.querySelector(".explanation").getAttribute("data-answer");
        let flag;

        //if (!myAnswer[id - 1] || !myAnswer[id - 1].split("->")[0]) {}
        myAnswer[id - 1] = "";
        if (questions[id - 1].querySelector("table")) {
            let table = testDiv.querySelector("table");
            for (let i = 1; i < table.rows.length; i++) {
                const element = table.rows[i];
                let inputs = element.querySelectorAll("input");
                flag = false;
                for (let j = 0; j < inputs.length; j++) {
                    const element = inputs[j];
                    if (element.checked) {
                        myAnswer[id - 1] += String.fromCharCode(65 + j);
                        break
                    }
                    flag = true;
                }
                if (!flag) {
                    if (!myAnswer[id - 1]) {
                        myAnswer[id - 1] = ""
                    }
                    myAnswer[id - 1] += "N";
                }
            }
            if (uri.includes("reading")) {
                let category = answer.split("@");
                let keys = new Array(answer.length + 1);
                answer = ""
                for (let i = 0; i < category[0].length; i++) {
                    keys[category[0].charCodeAt(i) - 65] = "A"
                }
                for (let i = 0; i < category[1].length; i++) {
                    keys[category[1].charCodeAt(i) - 65] = "B"
                }
                for (let i = 0; i < keys.length; i++) {
                    if (keys[i] !== "A" && keys[i] !== "B") {
                        keys[i] = "N";
                    }
                    answer += keys[i];
                }
            }
        } else if (questions[id - 1].getAttribute("data-choice-type") == "select") {
            for (let i = 0; i < article.querySelectorAll(".sentence").length; i++) {
                const element = article.querySelectorAll(".sentence")[i];
                if (element.style.fontWeight !== "bold") {
                    myAnswer[id - 1] = `${i + 1}`;
                    break
                }
            }
        } else {
            for (let i = 0; i < inputs.length; i++) {
                if (inputs[i].checked) {
                    myAnswer[id - 1] += String.fromCharCode(65 + i);
                }
            }
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
            } else if (uri.includes("writing")) {
                let text = testDiv.querySelector("textarea").value.replace("\n", "</p><p>");
                text = `<p>${text}</p>`

                let blob = new Blob([text], {
                    type: 'text/plain'
                });
                downloadResponse(window.URL.createObjectURL(blob), html);
            } else {
                let text = testDiv.querySelector("table").outerHTML;

                let blob = new Blob([text], {
                    type: 'text/plain'
                });
                downloadResponse(window.URL.createObjectURL(blob), html);
            }
        }

        if ((/-speaking|-writing/).exec(uri)) {
            modal = createNode(["div", {
                class: "w3-modal"
            }], testDiv);
            modalContent = createNode(["div", {
                class: "w3-modal-content"
            }], modal);
            createNode(["div", {
                class: `${color} w3-container`
            }], modalContent);
            p = createNode(["p"], modalContent);
        } else {
            modal = reviewQuestions();

            modalContent = modal.children[0]

            let p = createNode(["p", {
                class: "w3-padding w3-section"
            }], modalContent, true);
            createNode(["div", {
                class: `${color} w3-padding`
            }, "Review Test"], modalContent, true);

            // answering and correct rate
            var error = modalContent.querySelectorAll("i").length

            p.innerHTML = `<b>${myAnswer.length - error} of ${myAnswer.length}</b> answered questions are correct.`;

        }
        let buttonBar = testDiv.querySelector("#buttonBar");
        if (!buttonBar) {
            let buttonBar = createNode(["div", {
                class: "w3-bar",
                id: "buttonBar"
            }], modalContent);
            exitBtn = createNode(["button", {
                class: `${color} w3-btn w3-margin w3-left`
            }, "Save and Exit"], buttonBar);
            cancelBtn = createNode(["button", {
                class: `${color} w3-btn w3-margin w3-right`
            }, "Cancel"], buttonBar);
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
        setStyle();
    }

    function reviewQuestions(id) {
        function checkAnswer(i) {
            let answer = questions[i].querySelector(".explanation").getAttribute("data-answer")
            let text = `<b>${answer}<b>`
            let report = myAnswer[i] == answer ? text : `<i>${myAnswer[i]}</i> -> ${text}`
            return id ? myAnswer[i] : report;
        }

        if (id) {
            setAnswer(id);
        }
        let modal = testDiv.querySelector(".w3-modal");
        if (!modal) {
            modal = createNode(["div", {
                class: "w3-modal"
            }], testDiv);
            modalContent = createNode(["div", {
                class: "w3-modal-content"
            }], modal);
            let table = createNode(["table", {
                class: "w3-table-all w3-padding-small"
            }], modalContent);
            let thead = createNode(["thead"], table);
            let tr = createNode(["tr", {
                class: color
            }], thead);
            createNode(["td", "Question"], tr);
            createNode(["td", "Option"], tr);

            let tbody = createNode(["tbody"], table);
            for (let i = 0; i < questions.length; i++) {

                let tr = createNode(["tr"], tbody);

                let td = createNode(["td", questions[i].querySelector(".question").innerText], tr);
                td.style.maxWidth = "240px";
                td.style.overflow = "hidden";
                td.style.textOverflow = "ellipsis";
                td.style.whiteSpace = "nowrap";

                if (myAnswer[i] == undefined) {
                    myAnswer[i] = ""
                }
                createNode(["td", checkAnswer(i)], tr);
                tr.onclick = () => {
                    showQuestion(i);
                    modal.style.display = "none";
                };
            }
        }
        modal.style.paddingTop = "10px";
        let tr = modal.querySelectorAll("tbody tr");
        for (let i = 0; i < tr.length; i++) {
            tr[i].children[1].innerHTML = checkAnswer(i);
        }

        if (id) {
            modal.style.display = "block";
        } else {
            return modal
        }
    }

    function showQuestion(index) {

        id = questions[index].id;

        section.innerHTML = questions[index].innerHTML;
        section.querySelector(".question").classList.add("w3-section");
        if (greFlag) {
            if (questions[index].getAttribute("data-passage")) {
                section.querySelector(".passage").classList.add("w3-hide");
                article.innerHTML = questions[index].querySelector(".passage").innerHTML;
            }
        } else {
            article.innerHTML = document.querySelector(".passage").innerHTML;
            article.querySelectorAll(".my-highlight").forEach(element => {
                element.classList.remove("my-highlight");
                removeHighlight(element);
            });
        }

        inputs = testDiv.querySelectorAll(".my-label input");


        // Previous and Next Button
        let div = createNode(["div", {
            class: "w3-bar my-margin-top-small w3-display-container w3-section "
        }], section);
        createNode(["button", {
            class: `${color} w3-btn w3-left`
        }, "Previous"], div);

        // Time Ticking 
        if (mobileFlag) {
            time.classList.add("w3-hide");
            timer = createNode(["span", {
                class: "w3-display-middle w3-xxlarge"
            }], div);

            // Callback function to execute when mutations are observed
            var callback = () => {
                timer.innerHTML = `<b>${time.innerText}</b>`;
                setStyle();
            };

            // Create an observer instance linked to the callback function
            var observer = new MutationObserver(callback);
            // Options for the observer (which mutations to observe)
            var options = {
                childList: true
            };
            // Start observing the target node for configured mutations
            observer.observe(time, options);
        }

        createNode(["button", {
            class: `${color} w3-btn w3-right`
        }, "Next"], div);

        // show current number of all number
        let numberDiv = createNode(["div", {
            class: "w3-section"
        }], section);
        let numberP = createNode(["p", {
            class: "w3-xlarge w3-center my-margin-small"
        }], numberDiv);
        numberP.innerHTML = `<b>Questions ${index + 1} of ${questions.length}</b>`;

        // Review Button
        let reviewBtn = testDiv.querySelector("#review");
        if (!reviewBtn) {
            reviewBtn = createNode(["button", {
                class: `${color} w3-btn w3-block`,
                id: "review"
            }, "Review Questions"], section);
        }
        reviewBtn.onclick = () => reviewQuestions(id.split("n")[1]);
        div.querySelectorAll("button").forEach(elem => {
            elem.onclick = e => navigateQuestion(e.target);
        });

        if (!questions[index].getAttribute("data-passage") && greFlag) { // Not Reading Comprehension
            if (!mobileFlag) {
                section.classList.remove("w3-half");
                article.classList.remove("w3-half");
            }
        } else { // Reading Comprehension

            if (mobileFlag) {
                section.style.borderTop = `3px solid ${bgColor}`;
                setArticleHeight(screen.height - section.offsetHeight + 40 + "px");

            } else {
                setArticleHeight("680px");
                section.classList.add("w3-padding");
                section.classList.add("w3-half");
                article.classList.add("w3-half");
            }
        }

        if (!greFlag) showSpecialQuestion(article, section);


        // select sentence question
        if (questions[index].getAttribute("data-choice-type") == "select") {

            // split sentence with span
            let passage = article.innerHTML.replace(". . . ", "&#8230; ")
            passage = passage.replace(/\s{2,}</g, "<")
            passage = passage.replace(/((\w{2,}|>?)[?!\.])\s{1}/g, "$1</span><span class=\"sentence\"> ")
            passage = passage.replace(/<p>/g, "<p><span class=\"sentence\"> ")
            passage = passage.replace(/<\/p>/g, "</span></p>")
            article.innerHTML = passage

            // Add sentence click event
            addFilterClick("article .sentence", ["my-highlight"]);
        }

        // click Options
        if (myAnswer[index] && myAnswer[index].split("->")[0]) {
            options = myAnswer[index].split("->")[0];
            if (myAnswer[index].includes(".")) {
                options = options.split(". ")[1]
            }
            if (!options) {
                return
            }

            for (let i = 0; i < options.split("").length; i++) {
                const element = options.split("")[i];
                if (options.length > 4) {
                    option = element.charCodeAt(0) - 65;
                    if (option !== 13) {
                        let elem = inputs[i * 2 + option].parentNode;
                        elem.querySelector(".my-checkbox").style.bgColor = bgColor;
                        elem.children[0].checked = true;
                    }
                } else {
                    if (questions[index].getAttribute("data-choice-type") == "select") {
                        article.querySelectorAll(".sentence")[element - 1].click()
                    } else {
                        inputs[element.charCodeAt(0) - 65].click();
                        if (!greFlag && section.children[1].innerText.length < 3) {
                            insertArea[element.charCodeAt(0) - 65].innerText = section.children[0].innerText.split(".")[1] + ". "
                        }
                    }
                }
            }
        }
        setStyle();
    }

    toggleElement();
    article = createNode(["article", {
        class: "show-article w3-half w3-section"
    }], testDiv);
    section = createNode(["section", {
        class: "show-question w3-half"
    }], testDiv);
    time = createNode(["p", {
        id: "time",
        class: "w3-xxlarge w3-center my-margin-small my-highlight"
    }], testDiv);
    if (greFlag) {

        if ((/issue|argument/).exec(uri)) {
            article.innerHTML = document.querySelector("#question").innerHTML
            addTextarea(section);
            waitTime(1800, showModal);
        } else {
            var countdown;
            if (questions.length > 20) countdown = 2100
            else if (questions.length > 15) countdown = 1800
            else countdown = 1500
            waitTime(countdown, showModal);
            showQuestion(0);
        }
    } else if (uri.includes("reading")) {

        waitTime(1200, showModal);
        showQuestion(0);

    } else if (uri.includes("listening")) {
        article.classList.toggle("w3-half");
        let button = createNode(["button", {
            class: `${color} w3-btn w3-block w3-section w3-hide`
        }, "Next"], testDiv);
        button.onclick = e => navigateQuestion(e.target);

        function showQuestion(index) {
            id = questions[index].id

            function playListening() {
                article.id = element.id;
                article.innerHTML = element.querySelector(".question").innerHTML
                button.classList.add("w3-hide");
                time.classList.add("w3-hide");
                playAudio(html.replace(".html", `-${element.id}.mp3`), () => {
                    article.innerHTML = element.innerHTML;
                    inputs = testDiv.querySelectorAll("input");
                    button.classList.remove("w3-hide");
                    time.classList.remove("w3-hide");
                    setStyle();
                });
            }

            const element = questions[index];
            if (element.className.includes("replay")) {
                article.innerHTML = "<p>Listen again to part of the lecture. Then answer the question.</p>"
                button.classList.add("w3-hide");
                time.classList.add("w3-hide");
                playAudio(html.replace(".html", `-${element.id}-replay.mp3`), () => playListening());
            } else {
                playListening();
            }

        }

        playAudio(html.replace(".html", ".mp3"), () => {
            setTimer(240);
            showQuestion(0);
        })

    } else if (uri.includes("speaking")) {
        if (uri.startsWith("file:/")) {
            mediaRecorder = recordAudio();
        }

        article.classList.toggle("w3-half");
        article.classList.toggle("w3-section");

        playListening = () => {
            article.classList.toggle("w3-hide");
            time.classList.toggle("w3-hide");
            playAudio(html.replace(".html", ".mp3"), playQuestion);
        }
        playQuestion = () => {
            article.innerHTML = main.querySelector("#question").innerHTML;
            article.classList.remove("w3-hide");
            playAudio(html.replace(".html", "-question.mp3"), startPreparation);
        }
        startPreparation = () => playAudio("../../speaking_beep_prepare.mp3", waitPreparation);
        waitPreparation = () => {
            time.classList.remove("w3-hide");
            waitTime(seconds[1][Math.ceil(num / 2) - 1], startSpeak);
        }
        startSpeak = () => playAudio("../../speaking_beep_answer.mp3", waitSpeak);
        waitSpeak = () => {
            if (uri.startsWith("file:/")) {
                mediaRecorder.start();
                waitTime(seconds[0][Math.ceil(num / 2) - 1], () => {
                    mediaRecorder.stop();
                    waitTime(1, showModal);
                });
            } else {
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

                navigator.mediaDevices.getUserMedia({
                    audio: true
                }).then(handleSuccess);
            }
        }

        if (num < 3) {
            playQuestion();
        } else if (num > 4) {
            playListening();
        } else {
            playAudio(html.replace(".html", "-reading.mp3"), () => {
                article.innerHTML = reading.innerHTML
                waitTime(45, playListening);
            });
        }
    } else if (uri.includes("writing")) {
        addTextarea(section);
        if (num == 1) {
            article.innerHTML = reading.innerHTML
            waitTime(180, endReading);

            function playListening() {
                playAudio(html.replace(".html", ".mp3"), waitWriting);
            }

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

        } else {
            article.innerHTML = main.querySelector("#question").innerHTML;
            waitTime(1800, showModal);
        }
    }
    setStyle();
}

function addDropDown(element, length, parent) {
    if (mobileFlag) {
        let dropdown = createNode(["div", {
            class: "w3-dropdown-click"
        }], parent);
        createNode(["button", {
            class: "w3-bar-item w3-button w3-padding-small my-color"
        }, element], dropdown);
        dropdownContent = createNode(["div", {
            class: "w3-dropdown-content w3-bar-block w3-card"
        }], dropdown);
    }
    for (let i = 1; i <= length; i++) {
        let href;
        if (uri.includes("essay")) {
            let count = 0;
            let index = topics.findIndex(topic => topic.name == element);
            for (let j = 0; j < index; j++) {
                count += topics[j].count;
            }
            href = `topic${index+1}-${count+i}.html`;
        } else {
            href = set + `-${element.toLowerCase() + i}.html`;
            href = !setFlag ? `${set}/${href}` : `${set.split("-")[0]}-${element.toLowerCase() + i}.html`;
        }

        if (mobileFlag) {
            dropdownContent.style.marginTop = "32px"
            innerHTML = uri.includes("essay") ? `<b>Essay ${i}</b>` : element + " " + i;
            createNode(["a", {
                class: "w3-bar-item w3-btn",
                href: href
            }, innerHTML], dropdownContent);
        } else {

            if (uri.includes("essay")) {
                innerHTML = `Essay ${i}`;
            } else {
                type = element.replace("ing", "").replace("Writ", "Write");
                innerHTML = type + " " + i
            }
            let a = createNode(["a", {
                class: `${color} w3-padding-small w3-button`,
                href: href
            }, innerHTML], parent);
            if (uri.includes("essay")) a.classList.add("my-margin-small")
        }
    }

    document.querySelectorAll(".w3-dropdown-click button").forEach(button => {
        button.onclick = e => {
            document.querySelectorAll(".w3-dropdown-content").forEach(element => element.classList.remove("w3-show"));
            e.target.nextElementSibling.classList.toggle("w3-show");
        };
    });

}

// Add Category Filter for test set page
function addCategoryFilter() {
    let length;

    if (setFlag) {
        length = 1;
    } else {
        let number = document.querySelector("#number");
        if (number) {
            length = parseInt(number.innerText);
        } else {
            length = 4;
        }
    }
    var sets = html.split(".")[0];

    //let before = html.includes("og") ? true : false;
    setsDiv = createNode(["div", {
        class: "",
        id: "setsDiv"
    }], main, true);

    // add sets
    for (let i = 1; i <= length; i++) {
        let number = (i < 10 && !html.includes("og") ? "0" + i : i);
        set = setFlag ? sets : sets + number;
        div = createNode(["div", {
            class: "w3-bar w3-section"
        }], setsDiv);
        if (!setFlag) {
            div.style.fontSize = "13px";
        }
        if (!mobileFlag) {
            div.style.fontSize = "14px";
        }
        if (!setFlag) {
            createNode(["span", {
                class: "w3-bar-item w3-btn w3-padding-small my-color"
            }, set.toUpperCase()], div);
        }

        sections.forEach(element => {
            addDropDown(element.type, element.length, div);
        });
    }



    if (setFlag) { // Add category Button
        categories[html.match(/\w+(?=\d\.html)/)[0]].forEach(category => {
            category.hrefs.forEach(href => {
                if (html.match(href)) {
                    tag = category.category;
                }
            });
        });
        href = `../${uri.split("/").slice(-3)[0]}.html`
        categoryBtn = createNode(["a", {
            class: `${color} w3-btn w3-section w3-left`,
            href: href
        }, `See ${tag} Questions`], div);

        if (testFlag) testBtn = createNode(["button", {
            class: `${color} w3-btn w3-section w3-right`,
            id: "test"
        }, "Test"], div);


        categoryBtn.onclick = () => {
            tag = {
                "tag": tag,
                "href": html
            }
            sessionStorage.setItem("tag", JSON.stringify(tag));
        }

    } else { // Add Category tags
        function filterSet(category) {

            // hide sets
            document.querySelectorAll("#setsDiv > div").forEach(element => element.classList.add("w3-hide"));

            let setDiv = document.querySelector("#setDiv");
            if (!setDiv) {
                setDiv = createNode(["div", {
                    class: "w3-section",
                    id: "setDiv"
                }], document.querySelector("#setsDiv"), true);
            }

            setDiv.classList.remove("w3-hide");
            setDiv.innerHTML = "";

            document.querySelectorAll("#setsDiv a").forEach(a => {
                if (category.hrefs.includes(a.href.split("/").splice(-1)[0])) {
                    innerText = a.href.split("/").slice(-2)[0].toUpperCase() + " " + a.innerText;
                    createNode(["a", {
                        class: `${color} w3-left w3-button w3-padding-small my-margin-small`,
                        href: a.href
                    }, innerText], setDiv);
                }
            })
        }

        categoryDiv = createNode(["div"], main, true);

        div = createNode(["div", {
            class: "w3-bar w3-card my-color"
        }], categoryDiv);
        if (mobileFlag) {
            categoryDiv.style.fontSize = "13px";
        }

        // sections category
        for (let i = 0; i < sections.length; i++) {
            button = createNode(["button", {
                class: "w3-bar-item w3-button w3-col l2 my-color w3-hide w3-show"
            }, sections[i].type], div);
            if (mobileFlag) {
                button.className = button.className.replace("l2", "w3-padding-small");
            }
            button.onclick = (btn) => {
                categoryDiv.innerHTML = "";
                categories[btn.target.innerText.toLowerCase()].forEach(category => {
                    createTag(category.category, categoryDiv, () => {
                        filterSet(category)
                    });
                });
                addFilterClick("#tagsDiv button", ["my-highlight", "w3-text-white", color], tagsDiv);
            };
        }

        let searchBtn = main.querySelector("#searchBtn");
        if (!searchBtn) searchBtn = createSearchBtn(div, "w3-bar-item w3-button w3-right w3-padding-small", filterNodes);

        categoryDiv = createNode(["div", {
            id: "tagsDiv",
            class: "w3-padding-small w3-card w3-white"
        }], categoryDiv);

        var tag = sessionStorage.tag;

        if (tag) {
            tag = JSON.parse(sessionStorage.tag);
            for (let i = 0; i < sections.length; i++) {
                const button = document.querySelectorAll("div .w3-bar-item.w3-button")[i];
                if (tag.href.includes(button.innerText.toLowerCase())) {
                    button.click();
                    for (let i = 0; i < categoryDiv.children.length; i++) {
                        const tagBtn = categoryDiv.children[i];
                        if (tag.tag === tagBtn.innerText) {
                            tagBtn.click();
                            sessionStorage.removeItem("tag");
                            break
                        }
                    }
                }
                if (!sessionStorage.tag) {
                    break
                }
            }
        }
    }

}

function updateQuestionUI() {

    function showQuestion(article) {
        document.querySelectorAll("#questions > div").forEach(element => {
            if (!element.className.includes("passage")) element.classList.add("w3-hide")
        });
        questionDiv = createNode(["div", {
            class: "w3-section",
            id: "question"
        }], main);
        if (article) {
            setArticleHeight(article);
            setArticleHeight(questionDiv);
        }
        pageBar = createNode(["div", {
            class: "w3-bar"
        }], questionDiv);
        questionDiv = createNode(["div", {
            class: "w3-display-container"
        }], questionDiv);
        for (let i = 0; i < questions.length; i++) {
            let button = createNode(["button", {
                class: `${color} w3-bar-item w3-button`
            }, i + 1], pageBar);
            if (mobileFlag) {
                button.style.padding = "5px";
            }
            button.onclick = btn => {
                id = "question" + btn.target.innerText
                questionDiv.innerHTML = questions[parseInt(btn.target.innerText) - 1].innerHTML


                let div = createNode(["div", {
                    class: "w3-bar"
                }], questionDiv) // this div is for button to display in block
                var answerBtn = createNode(["button", {
                    class: `${color} w3-btn`
                }, "Toggle Answer"], div);

                // toggle answer
                answerBtn.onclick = btn => {
                    let question = btn.target.parentElement.parentElement
                    let answer = question.querySelector("#answer")
                    if (!answer) answer = createNode(["div", {
                        class: "answer w3-hide",
                        id: "answer"
                    }], question);
                    answer.innerHTML = `<p>${question.querySelector(".explanation").getAttribute("data-answer")}</p>` + question.querySelector(".explanation").innerHTML;
                    toggleHighlight(answer.childNodes[0]);
                    answer.querySelectorAll("em").forEach(em => toggleHighlight(em));

                    // Click Choices
                    var answers = answer.childNodes[0].innerText;
                    if (/\d+/.exec(answers)) {
                        article = document.querySelector("#question .passage")
                        let passage = article.innerHTML.replace(". . . ", "&#8230; ")
                        passage = passage.replace(/\s{2,}</g, "<")
                        passage = passage.replace(/(\w{2,}[?!\.])\s{1}/g, "$1</span><span class=\"sentence\"> ")
                        passage = passage.replace(/<p>/g, "<p><span class=\"sentence\"> ")
                        passage = passage.replace(/<\/p>/g, "</span></p>")
                        article.innerHTML = passage
                        toggleHighlight(article.querySelectorAll(".sentence")[parseInt(answers) - 1]);
                    } else {
                        for (let i = 0; i < answers.split("").length; i++) {
                            const element = answers.split("")[i];
                            inputs = document.querySelectorAll("#question input");
                            inputs[element.charCodeAt(0) - 65].click();
                        }
                    }

                    answer.classList.toggle("w3-hide");
                    setStyle();

                }
                if (!greFlag) {
                    article.querySelectorAll(".my-highlight").forEach(element => toggleHighlight(element)); // remove highlight
                    showSpecialQuestion(article, questionDiv);
                }
                addWord();
                setStyle();

            }
        }
    }

    questions = main.querySelectorAll("#questions [id^='question']");
    if (main.querySelector("#questions")) { // Update Verbal Reasoning UI
        // Hide passage and choices
        if (uri.includes("verbal")) main.querySelectorAll(".passage").forEach(e => e.classList.add("w3-hide"));

        questions.forEach(question => {
            let choices = question.querySelectorAll(".choices") // Choices in one question
            if (choices[0] && choices[0].innerHTML.match(/table>/)) {
                return
            }
            let choiceType; // Radio Checkbox Select(reading comprehension select sentence)
            choicesDiv = createNode(["div"], question);

            // Decide choice type based on question type
            choiceType = question.getAttribute("data-choice-type");

            // Show reading comprehension question related passage
            if (question.getAttribute("data-passage")) {
                passageDiv = createNode(["div", {
                    class: "passage"
                }], question, true);
                passageDiv.innerHTML = document.querySelector("#" + question.getAttribute("data-passage")).innerHTML;
            }

            // Update choices
            for (let i = 0; i < choices.length; i++) {
                choice = choices[i]
                choice.classList.add("w3-hide");
                choiceDiv = createNode(["div", {
                    class: "w3-padding-small w3-left"
                }], choicesDiv);
                if (question.className.includes("text")) choiceDiv.className += " w3-left"

                for (let j = 0; j < choice.children.length; j++) {
                    createChoiceInput(choiceDiv, choiceType, choice.children[j].innerText, choiceType + i)
                }
            }
            if (!question.className.includes("passage")) question.querySelector(".explanation").classList.toggle("w3-hide");

        });

        // audio lyrics
        let audio = main.querySelector("audio");
        if (audio && uri.includes("listening")) {
            var timeSpan = main.querySelectorAll(".time");
            timeSpan.forEach(element => element.classList.add("w3-hide"));
            n = 0;
            let listening = main.querySelector("article.passage");
            setArticleHeight(listening, screen.height - audio.offsetTop - 160 + "px")

            if (timeSpan) {
                audio.ontimeupdate = e => {
                    let duration = parseFloat(timeSpan[n].getAttribute("data-times")) + parseFloat(timeSpan[n].getAttribute("data-time"));
                    if (parseFloat(e.target.currentTime.toFixed(2)) <= duration) {
                        listening.scrollTop = timeSpan[n].parentNode.offsetTop - 320;
                        addHighlight(timeSpan[n].parentNode);
                    } else {
                        removeHighlight(timeSpan[n].parentNode);
                        n++;
                    }
                };
            }
        }

        showQuestion(main.querySelector("article.passage"));


    } else { // Update Speaking and Writing
        let responses = main.querySelectorAll(".response")
        if (responses.length > 1) {
            //document.querySelector("#question").classList.toggle("w3-hide")
            div = createNode(["div"], main);
            pageBar = createNode(["div", {
                class: "w3-bar"
            }], div);
            responseDiv = createNode(["div", {
                id: "responseDiv"
            }], div);
            //setArticleHeight(div);
            for (let i = 0; i < responses.length; i++) {
                createNode(["button", {
                        class: `${color} w3-bar-item w3-button`
                    }, `${i+1}`], pageBar).onclick = () =>
                    responseDiv.innerHTML = responses[i].innerHTML;
            }
        }

        /**
         * response = document.querySelector("#response");
        question = document.querySelector("#question");
        setArticleHeight(response);

        if (response) {
            question.classList.toggle("w3-hide");
            questionDiv = createNode(["div"], response, true);
            questionDiv.innerHTML = question.innerHTML;
        }

        listening = document.querySelector("#listening-text");
        if (listening) {
            audio = document.querySelector("audio");
            newAudio = createNode(["audio", {
                controls: true
            }], listening, true);
            newAudio.outerHTML = audio.outerHTML;
            audio.classList.toggle("w3-hide");
        }
        setArticleHeight(listening);
        setArticleHeight(document.querySelector("#reading-text"));
         */
    }
}