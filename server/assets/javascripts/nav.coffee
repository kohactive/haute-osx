$ ->
  $('nav li').click ->
    href = $(this).data('href')
    $('.content').load href, ->
      if href == 'blocks'
        $.get "/blocks/#{currentProject}", (blocks) ->
          $.each blocks, ->
            block = new Block
            block.load this

      else if href == 'project'
        projectLoadID = currentProject
        if projectLoadID
          loadedProject = new Project
          loadedProject.load(projectLoadID)

    $('.nav-active').removeClass('nav-active')
    $(this).addClass('nav-active')