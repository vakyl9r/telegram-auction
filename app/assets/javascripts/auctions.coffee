$ ->
  addZero = (i) ->
    if i < 10
      i = '0' + i
    i
  $('#time').on 'change', ->
    totalMin = $(this).val()
    totalmSec = totalMin * 60000
    hours = Math.floor( totalMin / 60)
    minutes = totalMin % 60
    today = Date.now()
    endDaymSec = today + totalmSec
    endDate = new Date(endDaymSec)
    endHours = endDate.getHours()
    endMinutes = endDate.getMinutes()
    endDay = endDate.getDate()
    endMonth = endDate.getMonth() + 1
    endYear = endDate.getYear() + 1900
    $('#time_p').show()
    $('#time_p')[0].innerHTML = "#{hours} hour(s) #{minutes} minute(s). Auction will end at #{addZero(endDay)}/#{addZero(endMonth)}/#{endYear} #{addZero(endHours)}:#{addZero(endMinutes)}"
    debugger
