NK.status = document.createElement("div");
NK.status.setAttribute("class","toolbar");
NK.status.setAttribute("id","status");
NK.status.messages = {};
document.body.appendChild(NK.status);

NK.status.refresh = function() {
  var content = "", msg, height;
  var now = new Date().getTime();
  for (msg in NK.status.messages) { 
    if (now > parseInt(msg) + 20000) {
      delete NK.status.messages[msg];
    }
  }
  for (msg in NK.status.messages) { 
    content += '<div class="statusmsg">'+NK.status.messages[msg]+'</div>';
  }
  NK.status.innerHTML = content;

  if (!!Object.keys(NK.status.messages).length) {
    $("#status").animate({"max-height": "200px"}); 
  } else {
    $("#status").animate({"max-height": "0px"}); 
  }
}

NK.functions.log = function(msg) {
  var now = new Date().getTime();
  NK.status.messages[new Date().getTime()] = msg;
  NK.status.refresh();
  setTimeout(NK.status.refresh, 21000);
  return now;
}
NK.functions.updateLog = function(time, msg) {
  delete NK.status.messages[time];
  NK.functions.log(msg);
}