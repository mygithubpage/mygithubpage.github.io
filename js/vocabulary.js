function addSound(link, parent) {
    var audio = $("<audio>", {
        src: link
    }).appendTo(parent)

    $("<img>", {
        src: `${icons8}metro/20/${rgb2hex(bgColor)}/speaker.png`,
        class: "w3-padding-small my-button"
    }).appendTo(parent).click(function () {
        audio[0].play()
    });
}

function addWordModal(word, parent) {

    let wordDiv = $("<div>", {
        class: "w3-left w3-col l2"
    }).appendTo(parent);

    $("<div>", {
        class: "w3-card w3-center w3-border w3-large my-button",
        html: `<b>${word.word}</b>`
    }).appendTo(wordDiv).click(function () {
        showWordModal(word)
    });
    setStyle();
}

function showWordModal(word) {

    var details = Object.keys(word)
    var modal = createModal();

    // title bar
    let bar = $("<div>", {
        class: `${color} w3-bar`
    }).appendTo(modal);
    $("<span>", {
        class: "w3-left my-button my-padding",
        html: "Word Details"
    }).appendTo(bar).css("cursor", "initial");
    $("<span>", {
        class: "w3-right my-button my-padding",
        html: "X"
    }).appendTo(bar).click(function () {
        modal.parent().remove();
    });

    // word content div
    let div = $("<div>", {
        class: "my-margin"
    }).appendTo(modal);
    var termDiv = $("<div>", {
        class: "w3-xlarge w3-center",
        html: `<b>${word.word}</b>`
    }).appendTo(div);

    addSound(word.sounds, termDiv);

    // details
    $(details).filter(function () {
        return !(/word|sound/).exec(this)
    }).each(function () {

        $("<button>", {
            class: `${color} w3-btn my-margin-small w3-padding-small`,
            id: this,
            html: this
        }).appendTo(div).click(function () {

            detailDiv.addClass("w3-padding-small");
            detailDiv.html(word[$(this).text()])

            // highlight word in example
            if ($(this).text() == "examples") {
                $("p", detailDiv).each(function () {
                    var sentence = $(this)
                    $(sentence.text().split(" ")).each(function () {

                        if (word.family.includes(`<li>${this}<`)) {
                            element = this.replace(/[,.]/, "")
                            sentence.html(sentence.html().replace(element, `<b>${element}</b>`))
                        }
                    });
                });
            } else if ($(this).text() == "synonyms") {

                $("div", detailDiv).each(function () {
                    $(this).addClass("w3-section");
                    let link = this.className.match(/exs/) ? "https://en.oxforddictionaries.com/definition/us/" :
                        "https://www.thefreedictionary.com/"
                    $(this).html($(this).html().replace(/(\w{3,})/g, `<a class="my-link" href="${link}$1">$1</a>`))
                });
            } else if ($(this).text() == "family") {

                $("li", detailDiv).each(function () {
                    $("<a>", {
                        class: "my-link",
                        href: ("https://en.oxforddictionaries.com/definition/us/" + this.childNodes[0].textContent),
                        text: this.childNodes[0].textContent
                    }).prependTo($(this));
                    this.childNodes[1].textContent = ""
                });
            }
            /**
                       else if ($(this).text() == "etymology") {
                           $("a", detailDiv).each(function () {
                               let index = this.href.indexOf("/wiki/")
                               let string = this.href.substring(index, this.href.length)
                               this.href = "https://en.wiktionary.org" + string;
                           });
                       } */
            setStyle();
        });

    });

    let detailDiv = $("<div>", {
        class: "my-margin-small w3-padding-small"
    }).appendTo(div);
    $("#synonyms").click();

    $("<button>", {
        class: `${color} w3-btn w3-bar w3-padding-small w3-section`,
        html: "close"
    }).appendTo(div).click(function () {
        modal.parent().remove();
    });
    setStyle();

    modal.parent().show();
}

function filterWord(value) {
    $("#words").html("");
    if (!value) return;
    $(sets).each(function () {
        $(this.words).each(function () {
            let flag = false
            $($.parseHTML(this.synonyms)).each(function () {
                flag = $(this).text() && $(this).text().split(",").indexOf(value) > 0
                if (flag) return;
            })
            if (this.word.includes(value) || flag) addWordModal(this, $("#words"));
        });
    });
}

function createWordSets() {
    let div = $("<div>", {
        class: "w3-bar",
    }).appendTo(main);

    $("<button>", {
        class: `${color} w3-btn w3-section w3-large w3-padding w3-left `,
        html: `Recite`
    }).appendTo(div).click(createWordTest);


    createSearchBtn(div, `${color} my-search w3-padding`, filterWord).click(() => {
        $("button", setsDiv).toggle();
    });

    setsDiv = $("<div>", {
        class: "w3-section w3-bar w3-row",
        id: "sets"
    }).appendTo(main);

    $(sets).each(function () {

        var words = this.words;

        $("<button>", {
            class: `${color} w3-btn my-margin-small`,
            html: this.name
        }).appendTo(setsDiv).click(() => {
            wordsDiv.html("");
            $(words).each(function () {
                addWordModal(this, wordsDiv);
            });
        });
    });

    wordsDiv = $("<div>", {
        class: "w3-section w3-bar w3-row",
        id: "words"
    }).appendTo(main);
    setStyle();
}

function createWordTest() {

    function showModal() {
        var modal = createModal();
        $("<div>", {
            class: `${color} w3-padding`,
            html: "Vocabulary Set"
        }).appendTo(modal);
        let p = $("<div>", {
            class: `w3-padding-small`
        }).appendTo(modal);
        $(sets).each(function (i, element) {

            $("<button>", {
                class: `${color} w3-btn my-margin-small`,
                html: this.name
            }).appendTo(p).click(function () {
                modal.parent().remove();
                showQuestion(element);
            });

        });
        toggleElement();
        modal.parent().show();
    }

    // Confirm Action like "Exit"
    function showConfirmModal(type) {
        var modal = createModal();
        $("<div>", {
            class: `${color} w3-padding`,
            html: "Confirm " + type
        }).appendTo(modal);
        let p = $("<p>", {
            class: "w3-padding w3-section"
        }).appendTo(modal);

        // answering and correct rate
        p.html(`Do you really want to ${type}?`)

        let buttonBar = $("<div>", {
            class: "w3-bar",
            id: "buttonBar"
        }).appendTo(modal);
        yesBtn = $("<button>", {
            class: `${color} w3-btn w3-margin w3-left`,
            html: "Yes"
        }).appendTo(buttonBar);
        noBtn = $("<button>", {
            class: `${color} w3-btn w3-margin w3-right`,
            html: "No"
        }).appendTo(buttonBar)
        yesBtn.click(function () {
            showReviewModal();
        });
        noBtn.click(function () {
            modal.parent().remove();
        });

        modal.parent().show();
    }

    function showReviewModal() {
        var modal = createModal();
        $("<div>", {
            class: `${color} w3-padding`,
            html: "Review Test"
        }).appendTo(modal);
        let p = $("<p>", {
            class: "w3-padding w3-section"
        }).appendTo(modal);
        let div = $("<div>", {
            class: "w3-padding-small"
        }).appendTo(modal);

        // answering and correct rate
        p.html(`You have <b>answered ${wordCount * 2 - indexes.length}</b> of ${wordCount * 2} questions, <b>${wordCount * 2 - indexes.length - error} of ${wordCount * 2 - indexes.length}</b> answered questions are correct.`)

        // forgotten words
        $(forgottenWords).each(function () {
            addWordModal(this, div);
        });

        modal.parent().show();
        $("<button>", {
            class: `${color} w3-btn w3-padding w3-margin-top w3-bar`,
            html: "Exit"
        }).appendTo(modal).click(function () {
            modal.parent().remove();
            toggleElement();
            $("#testDiv").remove();
        });
        setStyle();
    }

    function showQuestion(set) {

        /** 
         * create question index array "0,0","0,1", ... , "0, n-1", "1,0", ... , "1, n-1"
         * randomly pop item from array 
         * if no item left, show review
         * show current number of all number  
         */

        function popRandom(array) {
            // randomly sway a element with the last one which will be pop soon.
            var random = getRandom(array.length);
            [array[random], array[array.length - 1]] = [array[array.length - 1], array[random]];
            return array.pop(); // pop last index object from indexes
        }

        // create question index array "0,0","0,1", ... , "0, n-1", "1,0", ... , "1, n-1"
        $("body").scrollTop(0);
        var words = set.words;
        wordCount = words.length;
        if (!indexes) {
            indexes = new Array(wordCount * 2);
            indexes = $(indexes).map((i) => {
                detail = i < wordCount ? "definitions" : "synonyms";
                return {
                    word: words[i % wordCount].word,
                    detail: detail
                }
            }).get();
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
        numberP.html(`<b>Questions ${(wordCount * 2) - indexes.length} of ${wordCount * 2}</b>`)

        // show detail
        detailDiv.html(`<b>${word.word}</b>`) // questions is word)
        addSound(word.sounds, detailDiv);

        var optionsLength = 4;
        var paragraphs = [];
        options = new Array(optionsLength);
        answers = new Array(optionsLength);


        optionDiv.html(word[detail])
        optionDiv.children().each(function () {
            paragraphs.push(this)
        });

        // add random options from details
        $(options).each( () => {
            if (paragraphs.length) {
                do {
                    random = getRandom(options.length);
                } while (options[random])
                options[random] = paragraphs.pop();
                answers[random] = random;
            } else {
                do {
                    random = getRandom(words.length);
                } while (words[random].word == word.word)
                let choices = $.parseHTML(words[random][detail]);
                do {
                    random = getRandom(choices.length);
                } while (options.includes(choices[random]))
                options[options.findIndex(e => { return typeof e == "undefined"})] = choices[random];
            }
        })

        // show options
        optionDiv.html("")
        $(options).each(function () {
            createChoiceInput(optionDiv, "checkbox", $(this).html());
        });

        // add check-next button
        $("<button>", {
            class: `${color} w3-btn w3-padding w3-section w3-bar`,
            html: "Check"
        }).appendTo(optionDiv).click(function () {
            let btn = $(this)
            if ($(this).text() == "Next") showQuestion(set);
            var labels = $(".my-label", optionDiv);
            labels.each(function (i) {
                let input = $("input:checked", $(this));

                // add word and sound
                if (btn.text() == "Check" && answers[i] == null) {
                    let word = words.find(element => element[detail].includes($(options[i]).html()))
                    $("<b>", {
                        html: ` [${word.word}]`
                    }).appendTo($(this)).click(function () {
                        showWordModal(word)
                    });
                }

                if (input.length && answers[i] == null || !input.length && answers[i] != null) {
                    // add forgotten word to array
                    if (!forgottenWords.includes(word)) {
                        forgottenWords.push(word);
                    }
                    flag = true;
                }
            });
            if ($(this).text() == "Check" && flag) error++;
            $(this).text("Next");
            setStyle();
        });

        $("<button>", {
            class: `${color} w3-button w3-padding w3-bar`,
            html: "Exit"
        }).appendTo(optionDiv).click(function () {
            showConfirmModal("Exit");
        });

        setStyle();
    }

    var testDiv = $("<div>", {
        id: "testDiv",
        class: "w3-container"
    }).appendTo($("body"));
    var numberDiv = $("<div>", {
        class: "w3-section"
    }).appendTo(testDiv);
    var numberP = $("<p>", {
        class: "w3-large w3-center my-margin-small"
    }).appendTo(numberDiv);
    var detailDiv = $("<div>", {
        class: "show-article w3-section"
    }).appendTo(testDiv);
    var optionDiv = $("<div>", {
        class: " w3-section"
    }).appendTo(testDiv);
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
    $(".my-label span, .passage", main).each(function () {
        let content = $(this);
        $(content.html().match(/\w{3,}/g)).each(function () {
            let word = words.find(word => {
                if (word.family.includes(`<li>${this}<`)) {
                    return word.word
                }
            });
            if (word) content.html(content.html().replace(this, `<b class="word">${this}</b>`))
        });
    })

    $(".word", main).each(function () {
        $(this).click(function () {
            showWordModal(words.find(word => {
                if (word.family.includes(`<li>${$(this).text()}<`)) {
                    return word.word
                }
            }));
        });
    });
}