# FIXME I don't like this javascript being in 'publinator' while associated HTML is in derived site

$(document).ready ()->
  $('#editUserModal, #addUserModal').on 'hidden', ()->
    $(this).removeData 'modal'


  $('#updateUserButton, #addUserButton').on 'click', ()->
    $(this).closest('.modal').find('form').submit()
