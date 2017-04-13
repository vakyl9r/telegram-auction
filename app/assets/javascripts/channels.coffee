$ ->
  $('#add-channel').on 'click', ->
    $(this).parent().find('#new-channel').show()
  $('#cancel').on 'click', ->
    $(this).parent().hide()
  $('#create-channel').on 'click', ->
    $parent = $(this).parent()
    $name = $parent.find('#channel-name').val()
    $link = $parent.find('#channel-link').val()
    $.ajax
      type: 'POST'
      url: '/channels'
      data: {
        channel: {
          name: $name, link: $link
        }
      }
      dataType: "json"
      success: () ->
        $parent.hide()
        $('#auction_channel').append("<option value=#{$link} selected='selected'>#{$name}</option>")
