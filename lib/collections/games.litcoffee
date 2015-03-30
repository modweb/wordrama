# Games Collection

    PlayerSchema = new SimpleSchema
      name:
        type: String
      userId:
        type: SimpleSchema.RegEx.Id

    @GameSchema = new SimpleSchema
      createdBy:
        type: SimpleSchema.RegEx.Id
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
          this.unset()
        optional: yes
      hasFinished:
        type: Boolean
        autoValue: ->
          return no if this.isInsert
          return $setOnInsert: no if this.isUpsert
          this.unset()
        optional: yes
      players:
        type: [ PlayerSchema ]
      currentPlayersTurn:
        type: SimpleSchema.RegEx.Id
      promptId:
        type: SimpleSchema.RegEx.Id
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
      update: (userId, doc, fieldNames, modifier) -> _.contains doc.players, Meteor.userId()
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

        game = Games.findOne gameId

        if not game? then throw new Meteor.Error 'game-not-found', "Game with id #{gameId} was not found."

Check that game hasn't started

Check that game hasn't finished

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
