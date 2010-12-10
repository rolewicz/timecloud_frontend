// Aliases
var Dom = YAHOO.util.Dom,
    Event = YAHOO.util.Event;
    
// Utility function for displaying errors on top of the page
// Takes an array containing error messages as an argument
function displayErrors(errors, closeFunction){

    var errorsBox = Dom.get("errorsBox");
    var errorList = Dom.get("errorList");
    
    
    for(i = 0; i < errors.length ; i = i+1) {
    
        // The close "button"
        var close_button = document.createElement("img");
        close_button.src = "/static/images/close.png";
        close_button.alt = "close";
        close_button.className = "closeButton";
        close_button.onclick = function() {closeFunction(this);};
        
        var li = document.createElement("li");
        li.innerHTML = errors[i];
        li.appendChild(close_button);
        
        errorList.appendChild(li);
    }
    
    errorsBox.style.paddingTop = "20px";
}

// Utility function called whenever the close button of an error message
// is clicked
function closeErrorEntry(target) {

    // If this is the last error in the list
    if(target.parentNode.parentNode.children.length == 1) {
        Dom.get("errorsBox").style.paddingTop = '0px';
    }
    
    // Remove the li from the list
    target.parentNode.parentNode.removeChild(target.parentNode);
    
}
