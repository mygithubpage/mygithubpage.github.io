function initialize() {

    main = document.querySelector("main");
    bgColor = window.getComputedStyle(document.querySelector("footer")).backgroundColor;
    updateCharacter();
    
    if (uri.match(/toefl(\/(tpo|og)){2}\.html/)) {
        addCategoryFilter();
    }

    if (testFlag) {

        updateQuestionUI(questions);

        if (uri.match(/ing\d\.html/)) {
            addCategoryFilter();
        } else {
            testBtn = createNode(["button", {
                class: `${color} w3-button w3-right w3-section my-bar-small`,
                id: "test"
            }, "Test"], main, true);
        }

        testBtn.onclick = () => startTest();
    }

    if (document.querySelector("#tags")) {
        addTags();
    }

    // Create Recite Button for vocabulary
    if (uri.includes("vocabulary")) {
        waitLoad(`#vocabulary`, createWordSets);
    }

    if (sidebar) {
        addTOC();
    }

    // essay folder
    if (uri.includes("topic")) {
        question = document.querySelector("section");
        article = document.querySelector("article");
        article.classList.toggle("w3-section");
        question.classList.toggle("w3-hide");
        createNode(["div", question.innerHTML], article, true);
        var textarea = addTextarea(main);
        textarea.classList.add("w3-section");
        textarea.classList.add("w3-block");
        textarea.classList.remove("w3-half");
        if (mobileFlag) {
            textarea.style.height = screen.height / 4 - 16 + "px";
            article.style.height = screen.height / 2 - 96 + "px";
            article.style.overflowY = "scroll";
        }
    }

    if (uri.includes("essay.html")) {
        topics.forEach(topic => {
            let div = createNode(["div", {
                class: "w3-section"
            }], main);
            if (!mobileFlag) {
                createNode(["span", {
                    class: "w3-padding my-color my-margin-small"
                }, `${topic.name}`], div);
            }
            addDropDown(topic.name, topic.count, div);
        })

        let div = createNode(["div", {
            class: "w3-bar"
        }], main, true);
        createSearchBtn(div, `${color} my-search`, filterNodes, main.querySelectorAll(".w3-section"));
    }

    if (uri.includes("scoring-rubric")) {

        function getChecked(array, description, table) {
            let row = 1
            let col = 0
            let length = table.querySelector("tr").children.length - 2
            for (let index = 0; index < array.length; index++) {
                const element = array[index];
                if (element.checked) {
                    if (index > length) {
                        row = index - length;
                    } else {
                        col = index + 1;
                    }
                }
            }

            description.innerHTML = table.rows[row].cells[col].textContent;
        }

        if (mobileFlag) {
            main.querySelectorAll(".my-table").forEach(table => {
                table.classList.add("w3-hide");

                // create row select and col select radio input
                let mobileTable = createNode(["table", {
                    class: "table"
                }], table.parentNode);
                let tr = createNode(["tr"], mobileTable);
                for (let i = 1; i < table.querySelectorAll("th").length; i++) {
                    const element = table.querySelectorAll("th")[i].innerText;
                    createChoiceInput(tr, "radio", element, "header").classList.add("my-margin-small");
                }
                tr = createNode(["tr"], mobileTable);
                for (let i = 1; i < table.rows.length; i++) {
                    createChoiceInput(tr, "radio", table.rows[i].cells[0].innerText, table.rows[0].cells[0].innerText).classList.add("my-margin-small");
                }

                tr = createNode(["tr"], mobileTable);
                let description = createNode(["div", {
                    class: "w3-section description"
                }], tr);

                let inputs = mobileTable.querySelectorAll("input");
                inputs.forEach(element => {
                    element.onchange = () => {
                        getChecked(inputs, description, table);
                    }
                });
                mobileTable.querySelectorAll("label").forEach(element => {
                    element.style.display = "unset";
                });
            })

        }
    }

    // index page
    if (uri.includes("index.html")) {
        function createIconText(element, parent, tag, before) {
            tag = tag ? tag : "p";
            let node = createNode([tag], parent, before);
            let size = tag == "p" ? 24 : (8 - parseInt(tag[1])) * 6
            let style = element.style ? element.style : "ios"
            createNode(["img", {
                src: `${icons8}/${style}/${size}/${rgb2hex(bgColor)}/${element.link}-filled.png`,
                class: "w3-padding-small"
            }], node);
            createNode(["span", `<b>${element.text}</b>`], node);
        }

        let info = [{
                "link": "developer",
                "text": "Developer"
            },
            {
                "link": "marker",
                "text": "San Francisco"
            },
            {
                "link": "email",
                "text": "AI@mail.com"
            },
            {
                "link": "phone",
                "text": "1800800800"
            },
        ]
        info.forEach(element => {
            createIconText(element, main.querySelector("#info"));
        })

        let skills = [{
            "link": "machine-learning",
            "text": "Machine-learning",
            "percent": "60%"
        }, {
            "link": "powershell",
            "text": "PowerShell",
            "percent": "50%"
        }, {
            "link": "javascript",
            "text": "JavaScript",
            "percent": "40%"
        }, {
            "link": "python",
            "text": "Python",
            "percent": "30%"
        }, ]
        let parent = main.querySelector("#skills");

        skills.forEach(element => {

            createIconText(element, parent);
            let div = createNode(["div", {
                class: "w3-light-gray w3-round-xlarge w3-small"
            }], parent);
            createNode(["div", {
                class: "w3-center w3-round-xlarge w3-text-white my-color"
            }, element.percent], div).style.width = element.percent;

        });
        let element = {
            "link": "web",
            "text": "My Sites"
        }
        createIconText(element, main.querySelector("#sites"), "h3", true);
    }

    if (document.querySelector("pre")) {
        hljs.initHighlighting();
        removeLeadingWhiteSpace();
    }

    if (uri.includes("quantitative")) {
        createSVG();
    }

    
    setStyle();
}

sidebar = document.querySelector("#sidebar");
if (document.querySelector("#questions")) questions = document.querySelectorAll("#questions [id^='question']");
else questions = document.querySelectorAll("#question > div");
testFlag = questions.length > 0 || document.querySelector("#question");
initialize();