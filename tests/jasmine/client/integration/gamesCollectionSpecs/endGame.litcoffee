# End Game Spec

    describe 'End Game', ->

Keep track of subscription to clean at the end of the test.

      subscription = null

      afterEach ->
        subscription?.stop()
        subscription = null

      beforeEach ClientIntegrationTestHelpers.loginIfLoggedOut

## Success path

      it 'should successfully end a newly created game', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

            Meteor.call 'startGame', gameId, (error, result) ->
              expect(error).toBeUndefined()

              Meteor.call 'endGame', gameId, (error, result) ->
                expect(error).toBeUndefined()

                actualGame = Games.findOne()

### Verify

Verify that the game has ended

                expect(actualGame.hasFinished).toBeTruthy()
                done()

## Fail if not logged in

      it 'should fail if user is not logged in', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

            Meteor.logout ->

              Meteor.call 'endGame', gameId, (error, result) ->

### Verify

                expect(error?.error).toEqual 'not-logged-in'
                done()

## Error if game isn't found

      it 'should throw an error if game is not found', (done) ->

### Setup

        badGameId = 'thisisfake'

### Execute

        Meteor.call 'endGame', badGameId, (error, result) ->

### Verify

          expect(error?.error).toEqual 'game-not-found'
          done()

## Error if game already finished

      it 'should throw an error if game has already finished', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

            Meteor.call 'startGame', gameId, (error, result) ->
              expect(error).toBeUndefined()

              Meteor.call 'endGame', gameId, (error, result) ->
                expect(error).toBeUndefined()

                actualGame = Games.findOne()

Verify that the game has ended

                expect(actualGame.hasFinished).toBeTruthy()

### Verify

                Meteor.call 'endGame', gameId, (error, result) ->
                  expect(error?.error).toEqual 'game-already-ended'
                  done()

## Error if not current users turn

      it 'should throw an error if not current users turn', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        dummyGame.currentPlayersTurn = 'xC8Bg3dCofQokrKy3'

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

            Meteor.call 'startGame', gameId, (error, result) ->
              expect(error).toBeUndefined()

              Meteor.call 'endGame', gameId, (error, result) ->

### Verify

                expect(error?.error).toEqual 'not-your-turn'
                done()
