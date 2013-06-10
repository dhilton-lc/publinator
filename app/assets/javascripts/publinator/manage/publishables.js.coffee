$.fn.toggleClick = ()->
  functions = arguments
  return this.click( ()->
    iteration = $(this).data('iteration') || 0
    functions[iteration].apply(this, arguments)
    iteration = (iteration + 1) % functions.length
    $(this).data('iteration', iteration)
  )


$(document).ready ->

  $('#addAssetModal').on 'hidden', ()->
    $(this).removeData 'modal'


  $('#addAssetButton').on 'click', ()->
    # Collect all selected asset items
    checks = $(this).closest('.modal').find('input[type=checkbox]:checked')
    $.each( checks, (index, cbox)->
      $('#asset_file_fields').append """
        <input type="hidden" name="page[publication_attributes][publication_asset_files_attributes][][asset_file_id]" value="#{$(cbox).attr('value')}"/>
      """
    )
    return true

  $('#pub_asset_files').nestedSortable({
    handle: '.handle .move'
    items: 'li'
    toleranceElement: '> div.handle'
    placeholder: 'placeholder'
    forcePlaceholderSize: true
    maxLevels: 1
    protectRoot: true
    update: (e,ui)->
      $('#pub_asset_files li').each( (index, el)->
        $(el).find('input.position_input').val( index )
      )
  })

  $('#publishables').nestedSortable({
    handle: '.handle .move'
    items: 'li'
    toleranceElement: '> div.handle'
    placeholder: 'ui-state-disabled'
    forcePlaceholderSize: true
    errorClass: 'ui-state-error'
    isAllowed: (item,parent)->
      unless parent
        return true

      if ( $(parent).is('.publinator-page') and $(item).is('.publinator-page, .publinator-publishable_type') )
        return true
      else
        return false
    stop: (e,ui)->
      ui.item.children('.handle').effect('highlight',{},1000)
    update: (e,ui)->
      item_id = ui.item.data('item_id')
      position = ui.item.index()
      parentId = null
      parentEl = ui.item.closest('ol').closest('li')
      if ( parentEl.length > 0 )
        parentId = parentEl.data('item_id')

      $.ajax(
        type: 'POST'
        url: $(this).data('update_url')
        dataType: 'script'
        data: {id: item_id, publication: { row_order_position: position, parent_id: parentId } }
      )
  })

  $('#publishables a.toggle').toggleClick( ()->
    $(this).removeClass('ui-icon-plusthick')
    $(this).addClass('ui-icon-minusthick')
    $(this).closest('li').find('> ol').show()
  , ()->
    $(this).removeClass('ui-icon-minusthick')
    $(this).addClass('ui-icon-plusthick')
    $(this).closest('li').find('> ol').hide()
  )

