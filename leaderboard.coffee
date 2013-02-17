# Set up a collection to contain player information. On the server,
# it is backed by a MongoDB collection named "players".
Players = new Meteor.Collection("players")
Calendars = new Meteor.Collection('calendars')
Events = new Meteor.Collection('events')

# calendar:
# id:
# google_id:
# user_id:
# name:

# Event
#
if Meteor.isClient

  # configure accounts
  Accounts.ui.config
    requestPermissions:
      google: ['https://www.googleapis.com/auth/calendar']



  Template.leaderboard.players = ->
    Players.find {},
      sort:
        score: -1
        name: 1

  Template.leaderboard.selected_name = ->
    player = Players.findOne(Session.get("selected_player"))
    player and player.name

  Template.player.selected = ->
    (if Session.equals("selected_player", @_id) then "selected" else "")

  Template.leaderboard.events "click input.inc": ->
    Players.update Session.get("selected_player"),
      $inc:
        score: 5

  Template.player.events click: ->
    Session.set "selected_player", @_id


# On server startup, create some players if the database is empty.
if Meteor.isServer
  Meteor.startup ->

    Accounts.onCreateUser (options, user) ->
      Meteor.http.get 'https://www.googleapis.com/calendar/v3/users/me/calendarList',
                  params:
                    access_token: user.services.google.accessToken
                  (err, result) ->
                    format_and_save_calendar(cal) for cal in result.data.items


    if Players.find().count() is 0
      names = ["Ada Lovelace", "Grace Hopper", "Marie Curie", "Carl Friedrich Gauss", "Nikola Tesla", "Claude Shannon"]
      i = 0

      while i < names.length
        Players.insert
          name: names[i]
          score: Math.floor(Math.random() * 10) * 5

        i++


format_and_save_calendar = (cal) ->
  calendar =
    google_id: cal.id
    name: cal.summary
    user_id: Meteor.user()
  existing_cal = Calendars.findOne({user_id: calendar.user_id, name: calendar.summary})
  if not existing_cal?
    Calendars.insert(calendar)








