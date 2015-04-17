# Games Collection

    PlayerSchema = new SimpleSchema
      name:
        type: String
      userId:
        type: String
        regEx: SimpleSchema.RegEx.Id

    @WordSchema = new SimpleSchema
      word:
        type: String
        regEx: /^[^\s.]*$/
        label: 'Next Word'
        min: 1
        max: 25

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

## Start Game

      startGame: (gameId) ->

        if not Meteor.user()? then throw new Meteor.Error 'not-logged-in', 'You must be logged in to start a game'

Lookup game, error if not found

        criteria =
          _id: gameId
        game = Games.findOne criteria

        if not game? then throw new Meteor.Error 'game-not-found', "Game with id #{gameId} was not found."

Check that game hasn't started

        if game.hasStarted
          throw new Meteor.Error 'game-already-started', "Game with id #{gameId} has already started"

Check that game has enough players

        if game.players.length < 2
          throw new Meteor.Error 'not-enough-players', "Game with id #{gameId} only has #{game.players.length} player, at least 2 players are required to start the game"

Check that user is one of the players

        isPlayer = !!_.findWhere game.players, userId: Meteor.userId()

        if not isPlayer then throw new Meteor.Error 'not-member-of-game', "You (#{Meteor.userId()}) are not a player in game with id #{gameId}"

Check that game hasn't finished

        if game.hasFinished
          throw new Meteor.Error 'game-already-finished', "Game with id #{gameId} has already finished"

Check that game isn't missing story

        if not game.story?
          throw new Meteor.Error 'game-missing-story', "Game with id #{gameId} is missing story"

Check that game isn't missing promptId

        if not game.promptId?
          throw new Meteor.Error 'game-missing-promptId', "Game with id #{gameId} is missing promptId"

Start game!

        action =
          $set:
            hasStarted: yes

        Games.update criteria, action

## Join Game

      joinGame: (gameId) ->

        if not Meteor.user()? then throw new Meteor.Error 'not-logged-in', 'You must be logged in to join a game'

Lookup game

        criteria =
          _id: gameId
        game = Games.findOne criteria

Create new player

        player =
          userId: Meteor.userId()
          name: Meteor.user()?.username

Check if player is already in game.

        hasAlreadyJoined = !!_.findWhere game.players, userId: Meteor.userId()

        if hasAlreadyJoined then console.log "user has already joined game", game, player

        if hasAlreadyJoined then throw new Meteor.Error 'already-joined-game', "You (#{Meteor.userId()}) have already joined game with id #{gameId} #{hasAlreadyJoined} #{player}"

        if game.hasStarted then throw new Meteor.Error 'already-started', "Whoa there! You can't join a game that's already started. Try another game or make your own."

Update action

        action =
          $addToSet: players: player

Add player to the game

        Games.update criteria, action

## End Game

      endGame: (gameId) ->

        if not Meteor.user()? then throw new Meteor.Error 'not-logged-in', 'You must be logged in to end a game'

        criteria =
          _id: gameId

        game = Games.findOne criteria

        if not game? then throw new Meteor.Error 'game-not-found', "Game with id #{gameId} was not found"

        if game.hasFinished then throw new Meteor.Error 'game-already-ended', "Game with id #{gameId} has already finished"

        if not game.hasStarted then throw new Meteor.Error 'game-hasnt-started', "Game with id #{gameId} hasn't started yet"

        if game.currentPlayersTurn isnt @userId then throw new Meteor.Error 'not-your-turn', "Games can only be ended if it's your turn"

        action =
          $set:
            hasFinished: yes

        Games.update criteria, action

## Insert Word

      insertWord: (gameId, word) ->

        if not Meteor.user()? then throw new Meteor.Error 'not-logged-in', 'You must be logged in to end a game'

        criteria =
          _id: gameId

        game = Games.findOne criteria


        if not game? then throw new Meteor.Error 'game-not-found', "Game with id #{gameId} was not found"

        if game.hasFinished then throw new Meteor.Error 'game-already-ended', "Game with id #{gameId} has already finished"

        if not game.hasStarted then throw new Meteor.Error 'game-hasnt-started', "Game with id #{gameId} hasn't started yet"

        if game.currentPlayersTurn isnt @userId then throw new Meteor.Error 'not-your-turn', "You can only insert word if it's your turn"

Prepend space if word isn't a period.

        if word isnt '.' then word = " #{word}"

Get the next players turn Id

        nextPlayersTurnId = GameHelpers.getNextPlayerTurnId game

        story = game.story + word
        action =
          $set:
            currentPlayersTurn: nextPlayersTurnId
            story: story

        Games.update criteria, action


## Server Helper Methods

    @GameHelpers =
      getNextPlayerTurnId: (game) ->
        game = _.omit game, '_id'
        check game, GameSchema

Get the current currentPlayersTurn's index in players

        indexCurrentPlayerTurn = 0
        _.each game.players, (player, index) ->
          if player.userId is game.currentPlayersTurn
            indexCurrentPlayerTurn = index
            return
        indexNextPlayerTurn = (indexCurrentPlayerTurn + 1) % game.players.length
        nextplayerTurnId = game.players[indexNextPlayerTurn].userId
