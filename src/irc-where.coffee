_ = require 'lodash'

module.exports = (System) ->
  checkMessage = (item) ->
    console.log 'post irc.message'
    text = item?.message?.message ? ''

    return item unless item.message.mention

    phrases = [
      'where\'s'
      'where is'
      'where are'
    ]
    found = _.find phrases, (phrase) -> (new RegExp phrase, 'i').test text

    return item unless found

    System.do 'me.location.last', {}
    .then (data) ->
      return item unless data?.location

      say = System.getMethod 'kerplunk-irc', 'say'
      place = "at #{data.location[0]}, #{data.location[1]}"
      if data.city
        place = "in #{data.city}"
      timeAgo = (Date.now() - data.timestamp.getTime())/1000
      hoursAgo = Math.floor timeAgo / 3600
      timeAgo -= hoursAgo * 3600
      minutesAgo = Math.floor timeAgo / 60
      timeAgo -= minutesAgo * 60

      since = ''
      if hoursAgo > 0
        since += " #{hoursAgo}h"
      if minutesAgo > 0
        since += " #{minutesAgo}m"
      if since == ""
        since = " #{Math.round timeAgo}s"
      since += " ago"
      message = "/me was last seen #{place}#{since}"
      say item.serverName, item.channelName, message
    .catch (err) ->
      console.log err.stack ? err

  events:
    irc:
      message:
        pre: checkMessage
