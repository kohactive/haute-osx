$ ->
  $('nav li').click ->
    href = $(this).data('href')
    $('.content').load href, ->
      projectLoadID = currentProject
      if projectLoadID
        loadedProject = new Project
        loadedProject.load projectLoadID, ->
          if href == 'template'
            editor.setValue loadedProject.pageTemplate

    $('.nav-active').removeClass('nav-active')
    $(this).addClass('nav-active')