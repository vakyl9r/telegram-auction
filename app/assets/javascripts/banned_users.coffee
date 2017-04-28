$ ->
  $('.ban').on 'click', ->
    $parent = $(this).parent()
    $grandparent = $parent.parent()
    $button = $(this)
    user_id = $grandparent.find('.id').text()
    first_name = $grandparent.find('.first_name').text()
    last_name = $grandparent.find('.last_name').text()
    chat_id = $('.chanel_id').text()
    $.ajax
      type: 'POST'
      url: "../banned_users"
      data: {
        banned_user: {
          user_id: user_id, first_name: first_name, last_name: last_name, chat_id: chat_id
        }
      }
      dataType: "json"
      success: (data) ->
        $button.remove()
        $parent[0].innerHTML = 'Banned'
      error: (data) ->
        alert('Не удалось забанить пользователя!')
  $('.unban').on 'click', ->
    $parent = $(this).parent()
    $grandparent = $parent.parent()
    $user_id = $parent.find('#banned_id').val()
    $.ajax
      type: 'DELETE'
      url: "banned_users/#{$user_id}"
      dataType: "json"
      success: (data) ->
        $grandparent.remove()
      error: (data) ->
        alert('Не удалось разбанить пользователя!')
