class window.Project

  create : (params) ->
    _this = this

    $.post '/create-project',
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

  load : (id) ->
    _this = this
    
    $.post '/load-project',
      id : id
    , (data) ->
      _this.id                  = data.id
      _this.title               = data.title
      _this.path                = data.path
      _this.cssRelative         = data.css_relative
      _this.cssAbsolute         = data.css_absolute
      _this.stylesheetsRelative = data.stylesheets_relative
      _this.stylesheetsAbsolute = data.stylesheets_absolute
      _this.variablesRelative   = data.variables_relative
      _this.variablesAbsolute   = data.variables_absolute
      _this.outputRelative      = data.output_relative
      _this.outputAbsolute      = data.output_absolute

      _this.show()

  show : ->
    # reset inputs
    $('input').val('')
    $('.project-selector h1')
      .text this.title
      .attr
        'data-project-path' : this.path
        'data-project-id'   : this.id
    
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

window.updateProjectSelector = (params = '') ->
  # populates the project selector with projects
  # takes params.complete for callback
  $.get '/load-projects', (data) ->
    projectSelector = '.project-selector-projects ul'
    $(projectSelector).html('')
    $.each data.projects, (k,v) ->
      $('<li/>',
        'data-id'   : v.id
        'data-path' : v.path
        text        : v.title
      ).appendTo projectSelector

    if params.complete
      params.complete()

window.saveProject = ->
  $.post '/save-project',
    id                    : $('.project-selector h1').attr 'data-project-id'
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
    id              : $('.project-selector h1').attr 'data-project-id'
    stylesheet_path : $('.stylesheets-location').attr 'data-absolute-path'
    output_path     : $('.output-location').attr 'data-absolute-path'
  , (data) ->
    console.log data

$(document).on 'click', '.project-selector-projects li', ->
  # load the selected project's data to the ui
  projectLoadID = $(this).data('id')
  if projectLoadID
    loadedProject = new Project
    loadedProject.load(projectLoadID)
    remove_project_selector()
    $('.project-selector-active').removeClass('project-selector-active')
    $(this).addClass('project-selector-active')

$ ->
  updateProjectSelector
    complete : ->
      # show first project data on load
      $('.project-selector-projects li:first').click()

  $('.btn-project-selector').click ->
    if !$(this).hasClass('projects-selector-open')
      $('.project-selector-projects')
        .css
          left : ( $('.btn-project-selector .arrow').offset().left + ( $('.btn-project-selector .arrow').outerWidth() / 2 ) ) - ( $('.project-selector-projects').outerWidth() / 2 )
        .fadeIn()
      
      $(this).addClass('projects-selector-open')

      $('body').append '<div class="transparent-overlay"></div>'

      $('.transparent-overlay').click ->
        remove_project_selector()
