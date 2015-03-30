# Games Collection

    PlayerSchema = new SimpleSchema
      name:
        type: String
      userId:
        type: String
        regEx: SimpleSchema.RegEx.Id

    @GameSchema = new SimpleSchema
      createdBy:
        type: String
        regEx: SimpleSchema.RegEx.Id
      createdAt:
        type: Date
        autoValue: ->
          return new Date() if this.isInsert
          return $setOnInsert: new Date() if this.isUpsert
          this.unset()
        optional: yes
      hasStarted:
        type: Boolean
        autoValue: ->
          return no if this.isInsert
          return $setOnInsert: no if this.isUpsert
        optional: yes
      hasFinished:
        type: Boolean
        autoValue: ->
          return no if this.isInsert
          return $setOnInsert: no if this.isUpsert
        optional: yes
      players:
        type: [ PlayerSchema ]
      currentPlayersTurn:
        type: String
        regEx: SimpleSchema.RegEx.Id
      promptId:
        type: String
        regEx: SimpleSchema.RegEx.Id
        optional: yes
      story:
        type: String
        optional: yes

TODO: ideas for more features

isPublic
maxPlayers

    @Games = new Mongo.Collection 'games'
    Games.attachSchema GameSchema

## Allow/Deny

    Games.allow
      insert: (userId, doc) -> Meteor.userId() isnt null
      update: (userId, doc, fieldNames, modifier) ->
        player =
          userId: Meteor.userId()
          name: Meteor.user().username
        console.log doc.players, player
        console.log "conatains:", (_.findWhere doc.players, player)?
        (_.findWhere doc.players, player)? and doc.hasFinished is no
      remove: (userId, doc) -> no

## Meteor Methods

    Meteor.methods
      createGame: ->

Must be logged in to create a game

TODO: use this.userId, how can we set Meteor.method context for tests?

        if not this.userId then throw new Meteor.Error 'access-denied', 'You must be logged in to create a game.'

        user = Meteor.users.findOne this.userId
        player =
          name: user.username
          userId: this.userId
        newGame =
          createdBy: this.userId
          players: [ player ]
          currentPlayersTurn: this.userId

        id = Games.insert newGame

Navigate to game route

        if Meteor.isClient then Router.go 'game', _id: id
        return id

      startGame: (gameId) ->

Lookup game, error if not found

        game = Games.findOne _id: gameId

        console.log game
        if not game? then throw new Meteor.Error 'game-not-found', "Game with id #{gameId} was not found."

Check that game hasn't started

        if game.hasStarted
          console.log "GOOD JOB"
          throw new Meteor.Error 'game-already-started', "Game with id #{gameId} has already started"

Check that game has enough players

        if game.players.length < 2
          throw new Meteor.Error 'not-enough-players', "Game with id #{gameId} only has #{game.players.length} player, at least 2 players are required to start the game"

Check that game hasn't finished

        if game.hasFinished
          throw new Meteor.Error 'game-already-finished', "Game with id #{gameId} has already finished"

Check that game isn't missing story

Check that game isn't missing promptId

Start game!


## Server Helper Methods

    @GameHelpers =
      getNextPlayerTurnId: (game) ->
        check game, GameSchema

Get the current currentPlayersTurn's index in players

        indexCurrentPlayerTurn = 0
        _.each game.players, (player, index) ->
          if player.userId is game.currentPlayersTurn
            indexCurrentPlayerTurn = index
            return
        indexNextPlayerTurn = (indexCurrentPlayerTurn + 1) % game.players.length
        nextplayerTurnId = game.players[indexNextPlayerTurn].userId
