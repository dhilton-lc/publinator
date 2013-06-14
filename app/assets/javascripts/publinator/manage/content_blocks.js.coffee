$(document).ready ()->
  $('#updateContentButton').on 'click', ()->
    $(this).closest('.modal').find('form').submit()

  $('ol.content_blocks').nestedSortable({
    handle: '.handle .move'
    items: 'li.content-block'
    toleranceElement: '> div.handle'
    placeholder: 'ui-state-highlight'
    forcePlaceholderSize: true
    maxLevels: 1
    protectRoot: true
    connectWith: 'ol.content_blocks'
    tabSize: 100
    dropOnEmpty: true
    helper: (ev,el)->
      $('<div class="ui-state-default" style="width: 100px; height: 20px;"></div>')
    stop: (e,ui)->
      ui.item.children('.handle').effect('highlight',{},1000)
    update: (e,ui)->
      item_id = ui.item.data('item_id')
      area = null
      parentEl = ui.item.closest('ol')
      if ( parentEl.length > 0 )
        area = parentEl.data('area')
      position = ui.item.index()
      $.ajax(
        type: 'POST'
        url: $(this).data('update_url')
        dataType: 'script'
        data: {id: item_id, content_block: { layout_order_position: position, area: area } }
      )
  })
