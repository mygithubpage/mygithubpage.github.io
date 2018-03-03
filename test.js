
    document.querySelectorAll(".w3-dropdown-content").forEach(element => {
        element.style.minWidth = "auto";
      });
  
      window.addEventListener( "resize", function () {
        if(window.screen.width > 600) {
          document.querySelector("#tpo").classList.remove("w3-small");
          
          document.querySelectorAll("div.w3-bar").forEach(element => {
            element.classList.remove("my-margin-small");
            element.classList.add("w3-margin");
            element.classList.add("w3-left");
            element.style.width = "auto";
          });
  
          document.querySelectorAll("#tpo button").forEach(element => {
            element.classList.remove("w3-padding-small");
          });
  
        } else {
          document.querySelector("#tpo").classList.add("w3-small");
          document.querySelectorAll("div.w3-bar").forEach(element => {
            element.classList.add("my-margin-small");
            element.classList.remove("w3-margin");
            element.classList.remove("w3-left");
            element.style.width = "100%";
          });
  
          document.querySelectorAll("#tpo button").forEach(element => {
            element.classList.add("w3-padding-small");
          });
        }
      });
  