$ ->
  browse = ->
    $.post('/browse').success((data) ->
      $("input#variables").val(data.path)
    )
  $("button#browse").on('click', browse)