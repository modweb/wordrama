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
          if error?
            sweetAlert "Uh oh...", error.message, 'error'
          else
            Router.go 'game', _id: result
