function addSound(link, parent) {
    var audio = createNode(["audio", {
        src: link
    }], parent)
    let imgLink = `${icons8}metro/20/${rgb2hex(bgColor)}/speaker.png`;
    createNode(["img", {
        src: imgLink,
        class: "w3-padding-small my-button"
    }], parent).onclick = () => audio.play();
}

function addWordModal(word, parent) {

    var wordDiv = createNode(["div", {
        class: "w3-left w3-col l2"
    }], parent);

    createNode(["div", {
        class: "w3-card-4 my-margin w3-padding-small w3-center w3-border w3-large my-button"
    }, `<b>${word.word}</b>`], wordDiv).onclick = () => {
        showWordModal(word)
    };
    setStyle();
}

function showWordModal(word) {

    var details = Object.keys(word)
    let parent = typeof testDiv != "undefined" ? testDiv : main;
    let modal = document.querySelector(`#${word.word}`)
    if (modal) {
        modal.style.display = "block";
        return;
    }
    modal = createNode(["div", {
        id: word.word,
        class: "w3-modal"
    }], parent);
    let modalContent = createNode(["div", {
        class: "w3-modal-content"
    }], modal);

    // title bar
    let bar = createNode(["div", {
        class: `${color} w3-bar w3-padding`
    }], modalContent);
    createNode(["span", {
        class: " "
    }, "Word Details"], bar);
    createNode(["span", {
        class: "w3-right my-button"
    }, "X"], bar).onclick = () => {
        closeModal(modal)
    };

    // word content div
    let div = createNode(["div", {
        class: "my-margin"
    }], modalContent);
    var termDiv = createNode(["div", {
        class: "w3-xlarge w3-center"
    }, `<b>${word.word}</b>`], div);

    addSound(word.sounds, termDiv);

    // details
    for (let i = 0; i < details.length; i++) {

        if ((/word|sound/).exec(details[i])) {
            continue
        }

        createNode(["button", {
            class: `${color} w3-btn my-margin-small w3-padding-small`,
            id: details[i]
        }, details[i]], div).onclick = (e) => {

            detailDiv.classList.add("w3-padding-small");
            detailDiv.innerHTML = word[e.target.innerText];

            // highlight word in example
            if (e.target.innerText == "examples") {
                detailDiv.querySelectorAll("p").forEach(sentence => {

                    sentence.innerText.split(" ").forEach(element => {

                        if (word.family.includes(`<li>${element}<`)) {
                            element = element.replace(/[,.]/, "")
                            sentence.innerHTML = sentence.innerHTML.replace(element, `<b>${element}</b>`)
                        }
                    });
                });
            } else if (e.target.innerText == "definition") {

            } else if (e.target.innerText == "synonyms") {

                detailDiv.querySelectorAll("div").forEach(div => {
                    div.classList.add("w3-section");
                    let link = div.className.match(/exs/) ? "https://en.oxforddictionaries.com/definition/us/" :
                        "https://www.thefreedictionary.com/"
                    div.innerHTML = div.innerHTML.replace(/(\w{3,})/g, `<a class="my-link" href="${link}$1">$1</a>`);
                });
            } else if (e.target.innerText == "family") {

                detailDiv.querySelectorAll("li").forEach(node => {
                    createNode(["a", {
                        class: "my-link",
                        href: ("https://en.oxforddictionaries.com/definition/us/" + node.childNodes[0].textContent)
                    }, node.childNodes[0].textContent], node, true);
                    node.childNodes[0].textContent = ""
                });
            } else if (e.target.innerText == "etymology") {
                detailDiv.querySelectorAll("a").forEach(a => {
                    let index = a.href.indexOf("/wiki/")
                    let string = a.href.substring(index, a.href.length)
                    a.href = "https://en.wiktionary.org" + string;
                });
            }
            setStyle();
        };

    }

    let detailDiv = createNode(["div", {
        class: "my-margin-small w3-padding-small"
    }], div);
    div.querySelector("#synonyms").click();

    createNode(["button", {
        class: `${color} w3-btn w3-bar w3-padding-small w3-section`
    }, "close"], div).onclick = () => {
        closeModal(modal)
    };
    setStyle();

    modal.style.display = "block";
}

function filterWord(value) {
    document.querySelector("#words").innerHTML = "";
    if (!value) return;
    sets.forEach(set => {
        set.words.forEach(word => {
            if (word.word.includes(value)) addWordModal(word, main.querySelector("#words"));
        });
    });
}

function createWordSets() {
    let div = createNode(["div", {
        class: "w3-bar"
    }], main);
    createNode(["button", {
        class: `${color} w3-btn w3-section w3-large my-padding-mobile w3-left `
    }, "Recite"], div).onclick = createWordTest;

    createSearchBtn(div, `${color} my-search`, filterWord).addEventListener("click", () => {
        setsDiv.querySelectorAll("button").forEach(element => element.classList.toggle("w3-hide"));
    });

    setsDiv = createNode(["div", {
        class: "w3-section w3-bar w3-row",
        id: "sets"
    }], main);

    sets.forEach(set => {

        var words = set.words;

        // put new word in the beginning
        var newWords;
        let newWord = document.querySelector("#" + set.name.replace(/ /g, "-").toLowerCase())
        if (newWord) { // if current vocabulary set has new words div
            newWords = newWord.innerText.split(" ");

            for (let i = 0; i < words.length; i++) {
                index = newWords.indexOf(words[i].word)
                if (index != -1) {
                    [words[i], words[index]] = [words[index], words[i]]
                }
            }
        }

        createNode(["button", {
            class: `${color} w3-btn my-margin-small`
        }, set.name], setsDiv).onclick = () => {
            wordsDiv.innerHTML = "";
            words.forEach(word => {
                addWordModal(word, wordsDiv);
            });
        }

    });

    wordsDiv = createNode(["div", {
        class: "w3-section w3-bar w3-row",
        id: "words"
    }], main);
    setStyle();
}

function createWordTest() {

    function showModal() {
        let modal = createNode(["div", {
            class: "w3-modal"
        }], testDiv);
        let modalContent = createNode(["div", {
            class: "w3-modal-content"
        }], modal);
        createNode(["div", {
            class: `${color} w3-padding`
        }, "Vocabulary Set"], modalContent);
        let p = createNode(["div"], modalContent);
        sets.forEach(set => {

            createNode(["button", {
                class: `${color} w3-btn my-margin`
            }, set.name], p).onclick = (e) => {
                modal.style.display = "none";
                testDiv.removeChild(testDiv.lastChild);
                showQuestion(sets.find(element => element.name == e.target.innerText));
            }

        });
        toggleElement();
        modal.style.display = "block";
    }

    // Confirm Action like "Exit"
    function showConfirmModal(type) {
        let modal = createNode(["div", {
            class: "w3-modal"
        }], testDiv);
        let modalContent = createNode(["div", {
            class: "w3-modal-content"
        }], modal);
        createNode(["div", {
            class: `${color} w3-padding`
        }, "Confirm " + type], modalContent);
        let p = createNode(["p", {
            class: "w3-padding w3-section"
        }], modalContent);

        // answering and correct rate
        p.innerHTML = `Do you really want to ${type}?`

        let buttonBar = createNode(["div", {
            class: "w3-bar",
            id: "buttonBar"
        }], modalContent);
        yesBtn = createNode(["button", {
            class: `${color} w3-btn w3-margin w3-left`
        }, "Yes"], buttonBar);
        noBtn = createNode(["button", {
            class: `${color} w3-btn w3-margin w3-right`
        }, "No"], buttonBar)
        yesBtn.onclick = () => {
            showReviewModal();
        }
        noBtn.onclick = () => {
            modal.style.display = "none";
        }

        modal.style.display = "block";
    }

    function showReviewModal() {
        let modal = createNode(["div", {
            class: "w3-modal"
        }], testDiv);
        let modalContent = createNode(["div", {
            class: "w3-modal-content"
        }], modal);
        createNode(["div", {
            class: `${color} w3-padding`
        }, "Review Test"], modalContent);
        let p = createNode(["p", {
            class: "w3-padding w3-section"
        }], modalContent);
        let div = createNode(["div", {
            class: "w3-padding-small"
        }], modalContent);

        // answering and correct rate
        p.innerHTML = `You have <b>answered ${wordCount * 2 - indexes.length}</b> of ${wordCount * 2} questions, <b>${wordCount * 2 - indexes.length - error} of ${wordCount * 2 - indexes.length}</b> answered questions are correct.`

        // forgotten words
        forgottenWords.forEach(word => {
            addWordModal(word, div);
        });


        modal.style.display = "block";
        createNode(["button", {
            class: `${color} w3-btn w3-padding w3-margin-top w3-bar`
        }, "Exit"], modalContent).onclick = () => {
            document.body.removeChild(document.body.lastChild);
            toggleElement();
        };
        setStyle();
    }

    function showQuestion(set) {

        /** 
         * create question index array "0,0","0,1", ... , "0, n-1", "1,0", ... , "1, n-1"
         * randomly pop item from array 
         * if no item left, show review
         * show current number of all number  
         */

        function getRandom(length) {
            return Math.floor(Math.random() * length);
        }

        function popRandom(array) {
            // randomly sway a element with the last one which will be pop soon.
            var random = getRandom(array.length);
            [array[random], array[array.length - 1]] = [array[array.length - 1], array[random]];
            return array.pop(); // pop last index object from indexes
        }

        // create question index array "0,0","0,1", ... , "0, n-1", "1,0", ... , "1, n-1"
        document.body.scrollTop = 0;
        var words = set.words;
        wordCount = words.length;
        if (!indexes) {
            indexes = new Array(wordCount * 2);
            for (let i = 0; i < wordCount; i++) {
                indexes[i] = {
                    word: words[i].word,
                    detail: "definitions"
                };
                indexes[i + wordCount] = {
                    word: words[i].word,
                    detail: "synonyms"
                };
            }
        }

        // randomly pop item from array
        if (indexes.length == 0) {
            showReviewModal(set);
            return;
        }

        var index = popRandom(indexes);
        var detail = index.detail;
        var word = words.find(element => element.word == index.word);


        // show current number of all number
        numberP.innerHTML = `<b>Questions ${(wordCount * 2) - indexes.length} of ${wordCount * 2}</b>`;

        // show detail
        detailDiv.innerHTML = `<b>${word.word}</b>`; // questions is word
        addSound(word.sounds, detailDiv);



        var optionsLength = 4;
        var paragraphs = [];
        options = new Array(optionsLength);
        answers = new Array(optionsLength);


        optionDiv.innerHTML = word[detail];
        optionDiv.querySelectorAll("p").forEach(p => paragraphs.push(p));
        var optionsCount = getRandom(optionsLength) + 1;

        // add random options from details
        for (let i = 0; i < optionsCount && paragraphs.length > 0; i++) {
            do {
                random = getRandom(options.length);
            } while (options[random])
            options[random] = paragraphs.pop();
            answers[random] = random;
        }

        // add rest options from other words
        let length = optionsLength - options.filter(o => o != "").length
        for (let i = 0; i < length; i++) {
            do {
                random = getRandom(words.length);
            } while (words[random].word == word.word)
            optionDiv.innerHTML = words[random][detail];
            let paras = optionDiv.querySelectorAll("p");
            do {
                random = getRandom(options.length);
            } while (options[random])
            options[random] = paras[getRandom(paras.length)];
        }

        // show options
        optionDiv.innerHTML = "";
        options.forEach(option => {
            createChoiceInput(optionDiv, "checkbox", option.innerHTML);
        });

        // add check-next button
        createNode(["button", {
            class: `${color} w3-btn w3-padding w3-section w3-bar`
        }, "Check"], optionDiv).onclick = (event) => {

            if (event.target.innerText == "Next") showQuestion(set);
            var labels = optionDiv.querySelectorAll(".my-label");
            for (let i = 0; i < labels.length; i++) {
                let label = labels[i];
                let input = label.querySelector("input");

                // add word and sound
                if (event.target.innerText == "Check" && answers[i] == null) {
                    let word = words.find(element => element[detail].includes(options[i].innerHTML))
                    createNode(["b", `  ${word.word}`], label)
                    addSound(word.sounds, label);
                }

                if (input.checked && answers[i] == null || !input.checked && answers[i] != null) {
                    // add forgotten word to array
                    if (!forgottenWords.includes(word)) {
                        forgottenWords.push(word);
                    }
                    flag = true;
                }
            }
            if (event.target.innerText == "Check" && flag) error++;
            event.target.innerText = "Next";
            setStyle();
        };

        createNode(["button", {
            class: `${color} w3-button w3-padding w3-bar`
        }, "Exit"], optionDiv).onclick = () => {
            showConfirmModal("Exit");
        }

        setStyle();
    }

    var testDiv = createNode(["div", {
        id: "testDiv",
        class: "w3-container"
    }], document.body);
    var numberDiv = createNode(["div", {
        class: "w3-section"
    }], testDiv);
    var numberP = createNode(["p", {
        class: "w3-large w3-center my-margin-small"
    }], numberDiv);
    var detailDiv = createNode(["div", {
        class: "show-article w3-section"
    }], testDiv);
    var optionDiv = createNode(["div", {
        class: " w3-section"
    }], testDiv);
    var indexes; // vocabulary set indexes for random selection (n-1,0)
    var wordCount; // word count in specific vocabulary set
    var error = 0; // error count
    var forgottenWords = []; // wrong word you select in the test and correct word you didn't select

    showModal();

}

function addWord() {
    let name = html.replace(/-verbal\d*.html/, "")
    let regexp = new RegExp(name.replace("-", " "), "i");
    words = sets.find(set => set.name.match(regexp));
    if (!words) return;
    else words = words.words
    main.querySelectorAll(".my-label span, .passage").forEach(content => {
        if (content.innerHTML) {
            content.innerHTML.match(/\w{3,}/g).forEach(regexp => {
                let word = words.find(word => {
                    if (word.family.includes(`<li>${regexp}<`)) {
                        return word.word
                    }
                });
                if (word) content.innerHTML = content.innerHTML.replace(regexp, `<b class="word">${regexp}</b>`)
            });
        }
    })

    main.querySelectorAll(".word").forEach(word => {
        word.onclick = (b) => {
            showWordModal(words.find(word => {
                if (word.family.includes(`<li>${b.target.innerText}<`)) {
                    return word.word
                }
            }))
        }
    })
}