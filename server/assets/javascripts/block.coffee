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
      '<li>' +
        "<h4>#{_this.blockTitle or 'New Block'}</h4>" +
        "<div class='block-editable#{' hidden' unless params.isNew}'>" +
          "<input class='block-title-input' placeholder='Block title' value='#{_this.blockTitle or ''}' />" +
          "<textarea class='block-content' placeholder='Block content'>#{_this.blockContent or ''}</textarea>" +
        '</div>' +
      '</li>')

    $blockTemplate
      .appendTo('.blocks')
      .find('h4').click ->
        $('.block-editable', $blockTemplate).slideToggle()
      
    $blockTemplate.find('input, textarea').blur ->
      _this.save
        blockTitle   : $('.block-title-input', $blockTemplate).val()
        blockContent : $('.block-content', $blockTemplate).val()

  save: (params) ->
    _this = this

    $.post "/blocks/#{_this.id}",
      block_title   : params.blockTitle
      block_content : params.blockContent
    , (block) ->
      console.log block
      _this.blockTitle    = block.block_title
      _this.blockContent  = block.block_content

$(document).on 'click', '.js-add-block', ->
  block = new Block
  block.create()
