    Template.gameListItem.events
      'click .join-game': (event, template) ->
        gameId = this._id
        Meteor.call 'joinGame', gameId, (error, result) ->
          if error?
            sweetAlert 'Oops...', error.message, 'error'
          else
            Router.go 'game', _id: gameId
