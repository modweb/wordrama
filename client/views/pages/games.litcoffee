    Template.games.events
      'click #createGame': (event) ->
        Meteor.call 'createGame', (error, result) ->
          console.log error if error?
          console.log "id of newly created game: #{result}"
          Router.go 'game', _id: result
