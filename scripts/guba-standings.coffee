# Description:
#   The GUBA Standings.
#
# Commands:
#   thegubabot standings <division> - Displays standings for that division.  Division names are east, central, west, latino, euro, fareast and mbbawc or fibbwc for wildcard standings? Example 'standings fibbwc'
#   thegubabot topspecs hitters - will return hitters from Top 100 Prospects
#   thegubabot topspecs pitchers - will return pitchers from Top 100 Prospects
#    thegubabot draft - returns number-name-team of last drafted player and who is on the clock
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.

request = require 'request'
cheerio = require 'cheerio'
#teamInfo = require './teamInfo'

module.exports = (robot) ->

  robot.respond /scout (.*)/i, (res) ->
    name = res.match[1]
    name = name.toLowerCase()
    names = name.split "_"
    first_name = names[0]
    last_name = names[1]
    search_letter = last_name[0]
    search_term = last_name + ", " + first_name
    console.log("First: " + first_name + " Last: " + last_name)
    console.log("Search_letter: " + search_letter)
    
    search_host = 'http://www.thefibb.net/news/html/leagues/league_100_players_' + search_letter + '.html'
    reqeust host, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        $('td .dl').each (i, element) ->
          text = $(this).text()
          console.log(text)
            
    
    
  robot.respond /test trans/i, (res) ->
    host = 'http://www.thefibb.net/news/html/leagues/league_100_transactions_0_0.html'
    request host, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        date = $('th[class=dl]').first().text()
        res.send date
        
  robot.respond /exports/i, (res) ->
    host = 'http://www.thefibb.net/cgi-bin/ootpou.pl?page=export'
    request host, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        payload = "Team Exports\n"
        $('span').each (i, element) ->
          teamName = $(this).text()
          exportTime = $(this).parent().parent().parent().find('font').text()
        
          payload += teamName + " " + exportTime + "\n"
        payload = "```" + payload + "```"
        res.send payload
    
  robot.respond /dold/i, (res) ->
    host = 'http://www.thefibb.net/cgi-bin/ootpou.pl?page=draftPicks'
    request.get {uri: host, encoding: 'binary'}, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        payload = "Last pick "
        $('td').each (i, element) ->
          text = $(this).text()
          if (text.substring(0,4) is 'Pick')
            $(this).parent().prev('tr').children('td').each (i, element) ->
              pickNum = $(this).text()
              pickTeam = $(this).next('td').text()
              pickName = $(this).next('td').next('td').text()
              payload += pickNum + ": " + pickName + " by " + pickTeam
              false
        payload = "```" + payload + "```" 
        res.send payload
 
  robot.respond /draft/i, (res) ->
    host = 'http://www.thefibb.net/cgi-bin/ootpou.pl?page=draftPicks'
    request.get {uri: host, encoding: 'binary'}, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        payload1 = "Last pick "
        payload2 = ""
        $('td').each (i, element) ->
          text = $(this).text()
          if (text.substring(0,4) is 'Pick')
            teamOC = $(this).prev('td').text()
            payload2 = teamOC + " on clock " + text + "\n"
            $(this).parent().prev('tr').children('td').each (i, element) ->
              pickNum = $(this).text()
              pickTeam = $(this).next('td').text()
              pickName = $(this).next('td').next('td').text()
              payload1 += pickNum + ": " + pickName + " by " + pickTeam
              payload1 += ";\n"
              false
        payload = "```" + payload1 + payload2 + "```" 
        res.send payload
  
  robot.respond /on clock/i, (res) ->
    host = 'http://www.thefibb.net/cgi-bin/ootpou.pl?page=draftPicks'
    request.get {uri: host, encoding: 'binary'}, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        payload = "On clock "
        $('td').each (i, element) ->
          text = $(this).text()
          if (text.substring(0,4) is 'Pick')
            teamOC = $(this).prev('td').text()
            payload += teamOC + " " + text + "\n"
            false
        payload = "```" + payload + "```" 
        res.send payload
        
  robot.respond /topspecs hitters/i, (res) ->
    host = 'http://www.thefibb.net/news/html/leagues/league_100_top_prospects.html';
    request.get {uri: host, encoding: 'binary'}, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        console.log(body)
        payload = ""
        $('table .data').eq(0).children('tr').each (i, element) ->
          if (i == 0)
            payload += "Top Hitting Specs\n"
          else
            $(this).children('td .dr').eq(0).each (j, element) ->
              specNum = $(this).text();
              specName = $(this).next('td').text()
              specTeam = $(this).next('td').next('td').text()
              specPos = $(this).next('td').next('td').next('td').next('td').text()
              payload += specNum + " | " + specName + " | " + specTeam + " | " + specPos + "\n"
              
        payload = "```" + payload + "```" 
        res.send payload
        
  robot.respond /topspecs pitchers/i, (res) ->
    host = 'http://www.thefibb.net/news/html/leagues/league_100_top_prospects.html';
    request.get {uri: host, encoding: 'binary'}, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        console.log(body)
        payload = ""
        $('table .data').eq(1).children('tr').each (i, element) ->
          if (i == 0)
            payload += "Top Pitching Specs\n"
          else
            $(this).children('td .dr').eq(0).each (j, element) ->
              specNum = $(this).text();
              specName = $(this).next('td').text()
              specTeam = $(this).next('td').next('td').text()
              specPos = $(this).next('td').next('td').next('td').next('td').text()
              payload += specNum + " | " + specName + " | " + specTeam + " | " + specPos + "\n"
              
        payload = "```" + payload + "```" 
        res.send payload 
        
  robot.respond /standings (.*)/i, (res) ->
    division = res.match[1] 
    divLC = division.toLowerCase()
    
    host = 'http://www.thefibb.net/news/html/leagues/league_100_standings.html'
    request.get {uri: host, encoding : 'binary'}, (err, response, body) ->
      if not err and response.statusCode == 200
        
        $ = cheerio.load body
        
        team = "Team"
        payload = padString(team, 25) + "   " + padString("W", 5) + padString("L", 5) + " " + padString("PCT", 6) + padString("GB", 5) + "\n"
        wins = new Object()
        loses = new Object()
        pct = new Object()
        gb = new Object()
        
        if divLC is 'east'
          $('table .data').eq(0).children('tr').each (i, element) ->
            if (i == 0)
               payload += "MBBA East Standings\n"
            else 
              $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'central'
          $('table .data').eq(1).children('tr').each (i, element) ->
            if (i == 0)
              payload += "MBBA Central Standings\n"
            else 
              $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'west'
          $('table .data').eq(2).children('tr').each (i, element) ->
            if (i == 0)
              payload += "MBBA West Standings\n"
            else 
              $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'mbbawc'
          $('table .data').eq(3).children('tr').each (i, element) ->
            if (i == 0)
              payload += "MBBA Wildcard Standings\n"
            else 
              $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'latino'
          $('table .data').eq(4).children('tr').each (i, element) ->
            if (i == 0)
              payload += "FIBB Latino Standings\n"
            else 
             $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'euro'
          $('table .data').eq(5).children('tr').each (i, element) ->
            if (i == 0)
              payload += "FIBB Euro Standings\n"
            else 
              $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'fareast'
          $('table .data').eq(6).children('tr').each (i, element) ->
            if (i == 0)
              payload += "FIBB Far East Standings\n"
            else 
              $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'fibbwc'
          $('table .data').eq(7).children('tr').each (i, element) ->
            if (i == 0)
              payload += "FIBB Wildcard Standings\n"
            else 
              $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        
        payload = "```" + payload + "```"
        res.send payload

padString = (str, length) ->

    str = str + Array(length + 1 - str.length).join(' ')