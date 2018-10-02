function initialize() {
    function updateCharacter() {
        main.html(main.html().replace(/\u00E2\u20AC\u201D/g, "\u2013"))
        main.html(main.html().replace(/\u00E2\u20AC\u201C/g, "\u2014"))
        main.html(main.html().replace(/\u00E2\u20Ac\u2122/g, "\u2019"))
        main.html(main.html().replace(/\u00E2\u20AC\u0153/g, "\u201C"))
        main.html(main.html().replace(/\u00E2\u20AC\u009D/g, "\u201D"))
        main.html(main.html().replace(/\u00E2\u20AC\u00A6/g, "\u2026"))
    }
    
    bgColor = window.getComputedStyle(footer[0]).backgroundColor;

    updateCharacter();

    if (uri.match(/toefl(\/(tpo|og)){2}\.html/)) {
        addCategoryFilter();
    }

    if (testFlag) {

        updateQuestionUI(questions);

        if (uri.match(/ing\d\.html/)) {
            addCategoryFilter();
        } else {
            if (greFlag) {
                var parent = $("<div>", {
                    class: `w3-bar`,
                }).prependTo(main)
            }
            else {
                var parent = main
            }
            $("<button>", {
                id: "test",
                class: `${color} w3-button w3-right w3-section my-bar-small`,
                html: "Test"
            }).prependTo(parent).click(startTest);
        }

    }

    if ($("#tags").length) {
        addTags();
    }

    // Create Recite Button for vocabulary
    if (uri.includes("vocabulary")) {
        waitLoad("#vocabulary", createWordSets);
    }

    if (sidebar.length) {
        addTOC();
    }

    // essay folder
    if (uri.includes("topic")) {
        //question = $("section").hide();
        article = $("article").toggleClass("w3-section");
            
        //createNode(["div", question.html()], article, true);
        var textarea = addTextarea(main).addClass("w3-section w3-block").removeClass("w3-half");
        if (mobileFlag) {
            textarea.css({height: screen.height / 4 - 16 + "px"});
            article.css({height: screen.height / 2 - 96 + "px", overflow : "scroll"});
        }
    }

    if (uri.includes("essay.html")) {
        topics.forEach(topic => {
            let div = $("<div>", {
                class: "w3-section"
            }).appendTo(main);
            if (!mobileFlag) {
                $("<span>", {
                    class: "w3-padding my-color my-margin-small",
                    html: `${topic.name}`
                }).appendTo(div);
            }
            addDropDown(topic.name, topic.count, div);
        })

        let div = $("<div>", {
            class: "w3-bar"
        }).appendTo(main, true);
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

            description.html(table.rows[row].cells[col].textContent);
        }

        if (mobileFlag) {
            main.querySelectorAll(".my-table").forEach(table => {
                table.addClass("w3-hide");

                // create row select and col select radio input
                let mobileTable = $("<table>", {
                    class: "table"
                }).appendTo(table.parentNode);
                let tr = $("<tr>").appendTo(mobileTable);
                for (let i = 1; i < table.querySelectorAll("th").length; i++) {
                    const element = table.querySelectorAll("th")[i].text();
                    createChoiceInput(tr, "radio", element, "header").addClass("my-margin-small");
                }
                tr = $("<tr>").appendTo(mobileTable);
                for (let i = 1; i < table.rows.length; i++) {
                    createChoiceInput(tr, "radio", table.rows[i].cells[0].text(), table.rows[0].cells[0].text()).addClass("my-margin-small");
                }

                tr = $("<tr>").appendTo(mobileTable);
                let description = $("<div>", {
                    class: "w3-section description"
                }).appendTo(tr);

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
        function createIconText(element, parent) {
            tag = "p" //tag ? tag : "p";

            let node = $(`<p>`).appendTo(parent);
            let size = 24 //tag == "p" ? 24 : (8 - parseInt(tag[1])) * 6
            let style = element.style ? element.style : "ios"

            $("<img>", {
                src: `${icons8}/${style}/${size}/${rgb2hex(bgColor)}/${element.link}-filled.png`,
                class: "w3-padding-small"
            }).appendTo(node);

            $("<span>", {
                html: `<b>${element.text}</b>`
            }).appendTo(node);

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
        $(info).each(function () {
            createIconText(this, $("#info"));
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
        let parent = $("#skills");

        $(skills).each(function () {

            createIconText(this, parent);
            $("<div>", {
                class: "w3-center w3-round-xlarge w3-text-white my-color",
                html: this.percent
            }).appendTo($("<div>", {
                class: "w3-light-gray w3-round-xlarge w3-small"
            }).appendTo(parent)).width(this.percent);

        });
    }

    if ($("pre").length) {
        removeLeadingWhiteSpace();
        $.getScript(`${prefix}highlight.js/9.12.0/highlight.min.js`, () => {
            flag = true;
            languages = ["apache", "bash", "cs", "cpp", "css", "coffeescript", "diff", "xml", "http", "ini", "json", "java", "js", "makefile", "markdown", "nginx", "objectivec", "php", "perl", "python", "ruby", "sql", "shell"]
            $("code").each(function () {
                let language = this.className.split(" ")[0];
                if (language && !languages.includes(language) && !language.includes("-")) {
                    flag = false;
                    languages.push(language);
                    if (language == "ps") language = "powershell"

                    $.getScript(`${prefix}highlight.js/9.12.0/languages/${language}.min.js`, () => {
                        hljs.initHighlighting();
                    });
                }
            });
            if (flag) hljs.initHighlighting();
        });
    }

    if (uri.includes("quantitative")) {
        let scripts = [
            "jsxgraph/1.3.5/jsxgraphcore.js",
            "mathjax/2.7.5/MathJax.js"
        ]
        $(scripts).each(function () {
            $.getScript(`${prefix}${this}`, () => {
                createSVG();
            });
        });
    }

    setStyle();
}

initialize();