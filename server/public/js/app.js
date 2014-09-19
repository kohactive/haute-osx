
$(document).ready(function(){


  

  function browse(){
    $.post('/browse')
  }

  $('button#browse').on('click', browse);

})