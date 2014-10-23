class window.Block

  create: ->
    _this = this

    $.get "/projects/#{currentProject}/blocks", (block) ->
      _this.id = block.id
      _this.show
        isNew : true

  load: (block) ->
    _this               = this
    _this.id            = block.id
    _this.blockTitle    = block.block_title
    _this.blockContent  = block.block_content
    _this.show()

  show: (params = '') ->
    _this = this

    # this is lame, but it gets the job done for now
    $blockTemplate = $('' +
      "<li data-id=#{_this.id} class='block'>" +
        '<div class="block-title-container">' +
          "<input class='block-title-input' placeholder='Block title' value='#{_this.blockTitle or ''}' #{'readonly' unless params.isNew} />" +
          '<button class="btn-delete">x</button>' +
        '</div>' +
        "<div class='block-editable#{' hidden' unless params.isNew}'>" +
          "<div id=block-editor-#{_this.id} class='block-editor'></div>" +
        '</div>' +
      '</li>')

    # add block to dom and create click event
    $blockTemplate
      .appendTo('.blocks')
      .find('.block-title-container').click ->
        $('.block-editable', $blockTemplate).slideToggle ->
          if $('.block-title-input', $blockTemplate).is('[readonly]')
            $('.block-title-input', $blockTemplate)
              .removeAttr 'readonly'
              .click (e) ->
                e.stopPropagation()
          else
            $('.block-title-input', $blockTemplate)
              .attr 'readonly', true
              .off 'click'

    # focus on title field if a new block is being created
    if params.isNew
      $('.block-title-input', $blockTemplate).focus()

    # set ace editor for block content
    editor = ace.edit("block-editor-#{_this.id}")
    _this.editor = editor
    editor.setTheme "ace/theme/tomorrow_night_eighties"
    editor.getSession().setMode "ace/mode/haml"
    editor.getSession().setTabSize 2
    editor.setValue _this.blockContent
    blockTimer = ''
    editor.getSession().on "change", ->
      clearTimeout blockTimer
      
      # wait until the user has stopped typing for two seconds,
      # then update the block
      blockTimer = setTimeout ->
        _this.save
          blockTitle   : $('.block-title-input', $blockTemplate).val()
          blockContent : _this.editor.getValue()
      , 2000

    # save on input blur
    $blockTemplate.find('input, textarea').blur ->
      _this.save
        blockTitle   : $('.block-title-input', $blockTemplate).val()
        blockContent : _this.editor.getValue()

  save: (params) ->
    _this = this

    $.post "/blocks/#{_this.id}",
      block_title   : params.blockTitle
      block_content : _this.editor.getValue()
    , (block) ->
      console.log block
      _this.blockTitle    = block.block_title
      _this.blockContent  = block.block_content

$(document).on 'click', '.js-add-block', ->
  block = new Block
  block.create()

$(document).on 'click', '.block .btn-delete', (e) ->
  $_this = $(this)
  $parent = $(this).closest('.block')
  e.stopPropagation()
  
  confirmResponse = confirm 'Delete block?'
  if confirmResponse
    $.ajax
      url: "/blocks/#{$parent.data('id')}"
      type: "DELETE"
      success: (result) ->
        console.log result
        $parent.fadeOut()
