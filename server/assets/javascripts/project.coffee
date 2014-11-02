window.currentProject = 0

class window.Project

  create : (params) ->
    _this = this

    $.post '/projects',
      title : params.title
      path  : params.path
    , (data) ->
      _this.id    = data.id
      _this.title = data.title
      _this.path  = data.path
      
      if params.complete
        params.complete()
      
      updateProjectSelector
        complete : ->
          _this.show()

  load : (id, complete='') ->
    _this = this
    
    $.get "/projects/#{id}", (project) ->
      _this.id                  = project.id
      _this.title               = project.title
      _this.path                = project.path
      _this.cssRelative         = project.css_relative
      _this.cssAbsolute         = project.css_absolute
      _this.stylesheetsRelative = project.stylesheets_relative
      _this.stylesheetsAbsolute = project.stylesheets_absolute
      _this.variablesRelative   = project.variables_relative
      _this.variablesAbsolute   = project.variables_absolute
      _this.outputRelative      = project.output_relative
      _this.outputAbsolute      = project.output_absolute
      _this.pageTemplate        = project.page_template

      _this.show()

      complete() if $.isFunction(complete)

  show : ->
    $('.project-selector h1')
      .text this.title
      .attr
        'data-project-path' : this.path
        'data-project-id'   : this.id

    window.currentProject = this.id
    
    if $('.js-project-page').length
      # reset inputs
      $('input').val('')

      $('.compiled-css-location')
        .val this.cssRelative
        .attr 'data-absolute-path', this.cssAbsolute

      $('.stylesheets-location')
        .val this.stylesheetsRelative
        .attr 'data-absolute-path', this.stylesheetsAbsolute

      $('.variables-location')
        .val this.variablesRelative
        .attr 'data-absolute-path', this.variablesAbsolute

      $('.output-location')
        .val this.outputRelative
        .attr 'data-absolute-path', this.outputAbsolute

    else if $('.js-template-page').length
      editor.setValue this.pageTemplate

    else if $('.js-blocks-page').length
      $('.js-blocks-page .blocks').html('')
      $.get "/blocks/#{currentProject}", (blocks) ->
        $.each blocks, ->
          block = new Block
          block.load this

window.updateProjectSelector = (params = '') ->
  # populates the project selector with projects
  # takes params.complete for callback
  $.get '/projects', (projects) ->
    projectSelector = '.project-selector-projects ul'
    $(projectSelector).html('')
    $.each projects, ->
      $("<li data-id='#{this.id}' data-path='#{this.path}'>#{this.title}<button class='btn-delete'>x</button></li>")
        .appendTo projectSelector

    if params.complete
      params.complete()

window.saveProject = ->
  $.post "/projects/#{currentProject}",
    css_relative          : $('.compiled-css-location').val()
    css_absolute          : $('.compiled-css-location').attr('data-absolute-path')
    stylesheets_relative  : $('.stylesheets-location').val()
    stylesheets_absolute  : $('.stylesheets-location').attr('data-absolute-path')
    variables_relative    : $('.variables-location').val()
    variables_absolute    : $('.variables-location').attr('data-absolute-path')
    output_relative       : $('.output-location').val()
    output_absolute       : $('.output-location').attr('data-absolute-path')
  , (data) ->
    console.log 'saved'

remove_project_selector = ->
  $('.project-selector-projects').fadeOut()
  $('.btn-project-selector').removeClass('projects-selector-open')
  $('.transparent-overlay').remove()

$(document).on 'click', '.build-project', ->
  $.post '/build',
    id              : currentProject
    stylesheet_path : $('.stylesheets-location').attr 'data-absolute-path'
    output_path     : $('.output-location').attr 'data-absolute-path'
  , (data) ->
    console.log data

$(document).on 'click', '.project-selector-projects li', ->
  $_this = $(this)

  # load the selected project's data to the ui
  $('.content').load 'project', ->
    projectLoadID = $_this.data('id')
    if projectLoadID
      loadedProject = new Project
      loadedProject.load projectLoadID
      remove_project_selector()
      $('.project-selector-active').removeClass 'project-selector-active'
      $(this).addClass 'project-selector-active'

$(document).on 'click', '.btn-project-selector', ->
  if !$(this).hasClass('projects-selector-open')
    $('.project-selector-projects')
      .css
        left : ( $('.btn-project-selector .arrow').offset().left + ( $('.btn-project-selector .arrow').outerWidth() / 2 ) ) - ( $('.project-selector-projects').outerWidth() / 2 )
      .fadeIn()
    
    $(this).addClass('projects-selector-open')

    $('body').append '<div class="transparent-overlay"></div>'

    $('.transparent-overlay').click ->
      remove_project_selector()

$(document).on 'click', '.project-selector-projects .btn-delete', (e) ->
  $_this = $(this)
  $parentLI = $(this).closest('li')
  e.stopPropagation()
  
  confirmResponse = confirm 'Delete project?'
  if confirmResponse
    $.ajax
      url: "/projects/#{$parentLI.data('id')}"
      type: "DELETE"
      success: (result) ->
        console.log result
        $parentLI.fadeOut()

$ ->
  updateProjectSelector
    complete : ->
      # show first project data on load
      $('.project-selector-projects li:first').click()
