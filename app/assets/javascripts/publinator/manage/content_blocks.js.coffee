$(document).ready ()->
  $('#updateContentButton').on 'click', ()->
    $(this).closest('.modal').find('form').submit()
