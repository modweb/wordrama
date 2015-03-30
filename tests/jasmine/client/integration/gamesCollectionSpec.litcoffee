# Create Game

    describe 'Create Game', ->

      subscription = null

      afterEach ->
        subscription?.stop()
        subscription = null

## Success test

      it 'should create a new game if logged in', (done) ->

### Setup

        Meteor.loginWithPassword 'testuser','password', (error) ->

          expect(error).toBeUndefined()
          expect(Meteor.user()).not.toBeUndefined()

### Execute

          Meteor.call 'createGame', (error, result) ->

            expect(error).toBeUndefined()

Subscribe to `singleGame` to access the collection

### Verify

            subscription = Meteor.subscribe 'singleGame', result, () ->
              player =
                name: Meteor.user().username
                userId: Meteor.userId()

              expectedGame =
                _id: result
                createdBy: player.userId
                players: [ player ]
                currentPlayersTurn: player.userId
                hasStarted: no
                hasFinished: no

              actualGame = Games.findOne()

We don't know the createdAt time, so let's check the actualGame has a date for
createdAt, then remove it for the comparison.

              expect(Match.test actualGame.createdAt, Date).toBe yes

              actualGame = _.omit actualGame, 'createdAt'

              expect(actualGame).toEqual expectedGame
              done()

## Fail test

      it 'should throw `access-denied` error if not logged in', (done) ->

### Setup

        Meteor.logout()

### Execute

        Meteor.call 'createGame', (error, result) ->
          expect(error.error).toEqual 'access-denied'
          done()

# Start Game

    describe 'Start Game', ->

Keep track of subscription to clean at the end of the test.

      subscription = null

      afterEach ->
        subscription?.stop()
        subscription = null

      beforeEach ClientIntegrationTestHelpers.loginIfLoggedOut

## Success test start game

      it 'should start the game and set properties appropriately', (done) ->

### Setup

        Games.insert ClientIntegrationTestHelpers.getDummyGame(), (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->
            Meteor.call 'startGame', gameId, (error, result) ->
              expect(error).toBeUndefined()

### Verify

              actualGame = Games.findOne()
              expect(actualGame.hasStarted).toBeTruthy()
              done()

## Start game, throw error is < 2 players

      it 'should throw an error if < 2 players', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        dummyGame.players = [dummyGame.players[0]]
        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

            Meteor.call 'startGame', gameId, (error, result) ->

### Verify

              expect(error.error).toEqual 'not-enough-players'
              done()

## Fail when game already started

      it 'should throw an error if game has already started', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

            criteria = _id: gameId
            update =
              $set:
                hasStarted: yes

            Games.update criteria, update, (error, result) ->

### Execute

              Meteor.call 'startGame', gameId, (error, result) ->

### Verify

                console.log "THE FUCKING ERROR", error
                expect(error?.error).toEqual 'game-already-started'
                done()

## Fail when game already finished

      it 'should throw an error if game has finished', (done) ->

### Setup

        Games.insert ClientIntegrationTestHelpers.getDummyGame(), (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

            criteria = _id: gameId
            action =
              $set:
                hasFinished: yes

            Games.update criteria, action, (error, result) ->

### Execute

              Meteor.call 'startGame', gameId, (error, result) ->

### Verify

                expect(error.error).toEqual 'game-already-finished'
                done()

## Fail when promptId isn't set

      it 'should throw an error if game is missing prompt', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        delete dummyGame.promptId

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

            Meteor.call 'startGame', gameId, (error, result) ->

### Verify

              expect(error.error).toEqual 'game-missing-promptId'
              done()

## Fail when story isn't set

      it 'should throw an error if game is missing story', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        delete dummyGame.story

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

            Meteor.call 'startGame', gameId, (error, result) ->

### Verify

              expect(error.error).toEqual 'game-missing-story'
              done()

## Fail when game isn't found

      it 'should throw an error if game is not found', (done) ->

### Setup

        gameId = 'fakegameId'


### Execute

        Meteor.call 'startGame', gameId, (error, result) ->

### Verify

          expect(error.error).toEqual 'game-not-found'
          done()

# Join Game

    describe 'Join Game', ->

Keep track of subscription to clean at the end of the test.

      subscription = null

      afterEach ->
        subscription?.stop()
        subscription = null

      beforeEach ClientIntegrationTestHelpers.loginIfLoggedOut

## Successfully join game

      it 'should successfully join a newly created game', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        delete dummyGame.promptId

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Logout of testuser

          Meteor.logout ->

Login as testuser2

            Meteor.loginWithPassword 'testuser2','password', (error) ->
              expect(error).toBeUndefined()
              expect(Meteor.user()).not.toBeUndefined()

Subscribe to `singleGame` to access the collection

            subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

              Meteor.call 'joinGame', gameId, (error, result) ->

### Verify

                actualGame = Games.findOne()

                player =
                  userId: Meteor.userId()
                  name: Meteor.user().username
                testuser2IsInGame = _.findWhere actualGame.players, player
                expect(testuser2IsInGame).toBeTruthy()
