saveBlock = ($obj) ->
  $.post '/save-block',
    id            : $('.project-selector h1').attr 'data-project-id'
    block_title   : $('.block-title').val()
    block_content : $('.block-content').val()
  , (data) ->
    console.log data

$(document).on 'blur', '.block-title', ->
  saveBlock $(this)

$(document).on 'blur', '.block-content', ->
  saveBlock $(this)
