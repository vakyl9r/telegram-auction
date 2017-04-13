$ ->
  $('#add-channel').on 'click', ->
    $(this).parent().find('#new-channel').show()
  $('#create-channel').on 'click', ->
    $parent = $(this).parent()
    $name = $parent.find('#channel-name').val()
    $link = $parent.find('#channel-link').val()
    $.ajax
      type: 'POST'
      url: '../channels'
      data: {
        channel: {
          name: $name, link: $link
        }
      }
      dataType: "json"
      success: (data) ->
        $parent.hide()
        $('#auction_channel').append("<option value=#{$link} selected='selected'>#{$name}</option>")
      error: (data) ->
        alert('Не удалось добавить канал!')
