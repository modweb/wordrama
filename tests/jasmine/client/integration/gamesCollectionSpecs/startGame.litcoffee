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

## Start game, throw error if not player

      it 'should throw an error if not player in game', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        dummyGame.players = [
          name: 'fakeplayer2'
          userId: 'xC8Bg3dCofQokrKy2'
        ,
          name: 'fakeplayer'
          userId: 'xC8Bg3dCofQokrKy3'
        ]
        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

            Meteor.call 'startGame', gameId, (error, result) ->

### Verify

              expect(error.error).toEqual 'not-member-of-game'
              done()

## Start Game; Fail if not logged in

      it 'should throw an error if user is not logged in', (done) ->

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

              Meteor.logout ->
                Meteor.call 'startGame', gameId, (error, result) ->

### Verify

                  expect(error?.error).toEqual 'not-logged-in'
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
