projectPath = ''

browse = (params) ->
  # loads the file system browser
  # required: `route` as the api route
  # optional: `complete` for callback
  $.post params.route, { project_path : params.projectPath }
    .success (pathObject) ->
      params.complete(pathObject) if $.isFunction(params.complete)

$ ->

  $('.js-browse-for-folder').click ->
    $_this = $(this)
    browse
      projectPath : $('.project-selector h1').attr 'data-project-path'
      route       : '/browse-for-folder'
      complete    : (paths) ->
        $_this
          .val paths.relative_path
          .attr 'data-absolute-path', paths.absolute_path
        
        saveProject()


  $('.js-browse-for-file').click ->
    $_this = $(this)
    browse
      projectPath : $('.project-selector h1').attr 'data-project-path'
      route       : '/browse'
      complete    : (paths) ->
        $_this
          .val paths.relative_path
          .attr 'data-absolute-path', paths.absolute_path
        
        saveProject()

  $('#add-project').click ->
    $_this = $(this)
    $.post('/browse-for-folder').success (data) ->
      
      projectPath = data.path
      folderName  = data.path.trim().split('/')

      # Remove empties
      folderName  = $.grep folderName, (n) ->
        n

      newProject = new Project
      newProject.create
        title     : folderName[folderName.length - 1]
        path      : data.path
        complete  : ->
          console.log newProject
