# Description:
#   Wikia Public API
#
# Dependencies:
#   None
#
# Configuration:
#   WIKI_DOMAIN : wikia domain to search {ex: www, warframe, naruto, elderscrolls}
#
# Commands:
#   hubot wikia search <query> - Returns the first 5 Wikipedia articles matching the search <query>
#   hubot wikia summary <article> - Returns a one-line description about <article>
#
# Author:
#   aliasfalse
wikia = null
request = require('request')
md = require('hubot-markdown')
util = require('util')
domain = process.env.WIKI_DOMAIN || 'www';
WIKIA_URL = "http://#{domain}.wikia.com/api/v1/";
SEARCH = 'Search/List';

wikiaSearch = (query, callback) ->
  formData = 
    query: query
    limit: 1
  url = WIKIA_URL + SEARCH
  request.post WIKIA_URL + SEARCH, { form: formData }, (err, response, body) ->
    if err
      callback err, null
    else if response.statusCode == 404
      callback null, null
    else if response.statusCode != 200
      error = undefined
      error = new Error("#{url} returned HTTP status #{response.statusCode}")
      callback error, null
    else
      data = undefined
      try
        data = JSON.parse(body)
      catch e
        data = null
      if !data
        error = undefined
        error = new Error("Invalid JSON from #{url}")
        callback error, null
      else
        callback null, data.items[0]
    return
  return


module.exports = (robot) ->
    robot.respond /wikia(.+)/i, (res) ->
      type = res.match[1]
      if not type
        res.reply "#{md.codeMulti}Please specify a search term#{md.blockEnd}"
      else
        searchReg = /\ssearch\s(.+)/
        summaryReg = /\ssummary\s(.+)/
        
        if(summaryReg.test type)
          #wikia summary
          ###query = type.match(summaryReg)
          wikia.wikiaSummary query, (err, data, url) ->
            if err
              robot.logger.error err
            else if not data
              res.reply '#{md.codeMulti}Not found#{md.blockEnd}'
            else
              res.send util.format('#{data.title} : #{md.lineEnd}#{data.content.text}#{md.lineEnd}%s', url.replace('\\', ''))###
          res.reply "#{md.codeMulti}Not found#{md.blockEnd}"
        else
          #default case
          query = type.match(/(.+)/)
          wikiaSearch query, (err, data) ->
            if err
              robot.logger.error err
            else if not data
              res.reply "#{md.codeMulti}Not found#{md.blockEnd}"
            else res.send util.format("#{md.codeMulti} #{md.linkBegin} #{data.title} #{md.linkMid}%s#{md.linkEnd}#{md.blockEnd}", data.url.replace('\\', ''));
