$ ->
  $('#add-channel').on 'click', ->
    $(this).parent().find('#new-channel').show()
  $('#cancel').on 'click', ->
    $(this).parent().hide()
  $('#create-channel').on 'click', ->
    $parent = $(this).parent()
    $name = $parent.find('#channel-name').val()
    $link = $parent.find('#channel-link').val()
    $rules = $parent.find('#channel-rules').val()
    $.ajax
      type: 'POST'
      url: '/channels'
      data: {
        channel: {
          name: $name, link: $link, rules: $rules
        }
      }
      dataType: "json"
      success: () ->
        $parent.hide()
        $('#auction_channel').append("<option value=#{$link} selected='selected'>#{$name}</option>")
      error: () ->
        alert('Не удалось создать канал! Заполните все поля')
