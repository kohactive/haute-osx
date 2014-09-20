$ ->
  $('nav li').click ->
    href = $(this).data('href')
    $('.content').load href, ->
      if href == 'blocks'
        $.post '/load-blocks',
          id : $('.project-selector h1').attr 'data-project-id'
        , (data) ->
          $('.block-title').val data.block_title
          $('.block-content').val data.block_content

      else if href == 'project'
        projectLoadID = $('.project-selector h1').data('project-id')
        if projectLoadID
          loadedProject = new Project
          loadedProject.load(projectLoadID)

    $('.nav-active').removeClass('nav-active')
    $(this).addClass('nav-active')