window.templateTimer = ''

window.templateEditorChange = ->
  clearTimeout templateTimer
  
  # wait until the user has stopped typing for two seconds,
  # then update the project
  window.templateTimer = setTimeout ->
    $.post "/projects/#{currentProject}",
      page_template  : editor.getValue()
  , 2000
