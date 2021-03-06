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
unorm = require 'unorm'
#teamInfo = require './teamInfo'

module.exports = (robot) ->
  
  robot.respond /scout1 (.*)/i, (res) ->
    
    level = res.match[2]
    console.log("LEVEL is :" + level) 
    name = res.match[1]
    name = name.toLowerCase()
    names = name.split "_"
    first_name = names[0]
    last_names = names[1..]
    last_name = ""
    for i in [0..last_names.length-1]
      last_name = last_name + last_names[i] 
      if i < last_names.length - 1
        last_name = last_name + " "

    search_letter = last_name[0]
    search_term = last_name + ", " + first_name
    
    if level == 'R'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_105_players_' + search_letter + '.html'
    else if level == 'SA'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_104_players_' + search_letter + '.html'
    else if level == 'A'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_103_players_' + search_letter + '.html'
    else if level == 'AA'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_102_players_' + search_letter + '.html'
    else if level == 'AAA'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_101_players_' + search_letter + '.html'
    else
      search_host = 'http://www.thefibb.net/news/html/leagues/league_100_players_' + search_letter + '.html'

    request search_host, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        payload = ""
        player_id = 0
        $('a').each (i, element) ->
          text = $(this).text()
          if (text.toLowerCase() is search_term)
            player_link = $(this).attr('href')
            strs1 = player_link.split "_"
            strs2 = strs1[1].split "."
            player_id = strs2[0]
            false
        
        player_link = 'http://www.thefibb.net/news/html/players/player_' + player_id + '.html'
        request player_link, (err, response, body) ->
          $ = cheerio.load body
          #get position
          player_title = $('td .reptitle').text()
          player_pos = player_title.substring(0,1)
          console.log("Pos: " + player_pos)
          
          if (player_pos is 'P')
            #is pitcher
            console.log("we are a pitcher")
            payload = 'FEATURE NOT IMPLEMENTED YET'
            $('td').each (j, element1) ->
              text = $(this).text()
              if (text is 'Stuff')
                console.log ("*** FOUND STUFF ***")
                stuff_overall = $(this).next().next().next().text()
                stuff_vL = $(this).next().next().next().next().text()
                stuff_vR = $(this).next().next().next().next().next().text()
                stuff_potentail = $(this).next().next().next().next().next().next().text()
                console.log(stuff_overall + "/" + stuff_potentail + "/" + "Splits (l/R) " + stuff_vL + "/" + stuff_vR)
                payload = stuff_overall + "/" + stuff_potentail + "/" + "Splits (l/R) " + stuff_vL + "/" + stuff_vR
          else
            #is not pitcher
            payload = 'FEATURE NOT IMPLEMENTED YET'
          
        payload = "```" + payload + "```" 
        res.send payload
  
  robot.respond /scout (.*)/i, (res) ->

    thedata = res.match[1]
    thedata = thedata.toLowerCase()
    stuff = thedata.split " "
    level = stuff[1]
    
    names = stuff[0].split "_"
    first_name = names[0]
    last_names = names[1..]
    last_name = ""
    for i in [0..last_names.length-1]
      last_name = last_name + last_names[i] 
      if i < last_names.length - 1
        last_name = last_name + " "

    search_letter = last_name[0]
    search_term = last_name + ", " + first_name
    
    if level == 'r'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_105_players_' + search_letter + '.html'
    else if level == 'sa'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_104_players_' + search_letter + '.html'
    else if level == 'a'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_103_players_' + search_letter + '.html'
    else if level == 'aa'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_102_players_' + search_letter + '.html'
    else if level == 'aaa'
      search_host = 'http://www.thefibb.net/news/html/leagues/league_101_players_' + search_letter + '.html'
    else
      search_host = 'http://www.thefibb.net/news/html/leagues/league_100_players_' + search_letter + '.html'

    request search_host, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        payload = ""
        $('a').each (i, element) ->
          text = $(this).text()
          if (text.toLowerCase() is search_term)
            player_link = $(this).attr('href')
            strs1 = player_link.split "_"
            strs2 = strs1[1].split "."
            player_id = strs2[0]
            console.log(player_id)
            player_link = 'http://www.thefibb.net/news/html/players/player_' + player_id + '.html'
            payload = search_term + ': ' + player_link
        res.send payload
            
    
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
        if divLC is 'west'
          $('table .data').eq(1).children('tr').each (i, element) ->
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
          $('table .data').eq(2).children('tr').each (i, element) ->
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
        if divLC is 'north'
          $('table .data').eq(3).children('tr').each (i, element) ->
            if (i == 0)
              payload += "FIBB North Standings\n"
            else 
              $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'south'
          $('table .data').eq(4).children('tr').each (i, element) ->
            if (i == 0)
              payload += "FIBB South Standings\n"
            else 
             $(this).children('td .dl').each (j, element) ->
                teamName = $(this).text();
                wins[teamName] = $(this).next('td').text()
                loses[teamName] = $(this).next('td').next('td').text()
                pct[teamName] = $(this).next('td').next('td').next('td').text()
                gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
                payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        if divLC is 'fibbwc'
          $('table .data').eq(5).children('tr').each (i, element) ->
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
        ##if divLC is 'fareast'
        ##  $('table .data').eq(6).children('tr').each (i, element) ->
        ##    if (i == 0)
        ##      payload += "FIBB Far East Standings\n"
        ##    else 
        ##      $(this).children('td .dl').each (j, element) ->
        ##        teamName = $(this).text();
        ##        wins[teamName] = $(this).next('td').text()
        ##        loses[teamName] = $(this).next('td').next('td').text()
        ##        pct[teamName] = $(this).next('td').next('td').next('td').text()
        ##        gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
        ##        payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        ##if divLC is 'fibbwc'
        ##  $('table .data').eq(7).children('tr').each (i, element) ->
        ##    if (i == 0)
        ##      payload += "FIBB Wildcard Standings\n"
        ##    else 
        ##      $(this).children('td .dl').each (j, element) ->
        ##        teamName = $(this).text();
        ##        wins[teamName] = $(this).next('td').text()
        ##        loses[teamName] = $(this).next('td').next('td').text()
        ##        pct[teamName] = $(this).next('td').next('td').next('td').text()
        ##        gb[teamName] = $(this).next('td').next('td').next('td').next('td').text()
        ##        payload += padString(teamName, 25) + " | " + padString(wins[teamName],5) + padString(loses[teamName],5) + padString(pct[teamName], 6) + " " + padString(gb[teamName], 5) + "\n"
        
        payload = "```" + payload + "```"
        res.send payload

  robot.respond /scoutacb (.*)/i, (res) ->

    thedata = res.match[1]
    thedata = thedata.toLowerCase()
    stuff = thedata.split " "
    level = stuff[1]
    
    names = stuff[0].split "_"
    first_name = names[0]
    last_names = names[1..]
    last_name = ""
    for i in [0..last_names.length-1]
      last_name = last_name + last_names[i] 
      if i < last_names.length - 1
        last_name = last_name + " "

    search_letter = last_name[0]
    search_term = last_name + ", " + first_name
    
    if level == 'acb'
      search_host = 'http://www.atlanticcoastbaseball.net/html/leagues/league_100_players_' + search_letter + '.html'
    else if level == 'rcb'
      search_host = 'http://www.atlanticcoastbaseball.net/html/leagues/league_106_players_' + search_letter + '.html'

    request search_host, (err, response, body) ->
      if not err and response.statusCode == 200
        $ = cheerio.load body
        payload = ""
        $('a').each (i, element) ->
          text = $(this).text()
          if (text.toLowerCase() is search_term)
            player_link = $(this).attr('href')
            strs1 = player_link.split "_"
            strs2 = strs1[1].split "."
            player_id = strs2[0]
            console.log(player_id)
            player_link = 'http://www.atlanticcoastbaseball.net/html/players/player_' + player_id + '.html'
            payload = search_term + ': ' + player_link
        res.send payload

padString = (str, length) ->

    str = str + Array(length + 1 - str.length).join(' ')