    findGames = (hasStarted) -> ->
      criteria =
        hasStarted: hasStarted
      Games.find(criteria).fetch()

    Template.games.helpers
      games: -> Games.find().fetch()
      openGames: findGames no
      inProgressGames: findGames yes

    Template.games.events
      'click #createGame': (event) ->
        Meteor.call 'createGame', (error, result) ->
          console.log error if error?
          console.log "id of newly created game: #{result}"
          Router.go 'game', _id: result
