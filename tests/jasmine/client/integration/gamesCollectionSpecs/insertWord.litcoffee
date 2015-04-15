# End Game Spec

    describe 'Insert Word', ->

Keep track of subscription to clean at the end of the test.

      subscription = null

      afterEach ->
        subscription?.stop()
        subscription = null

      beforeEach ClientIntegrationTestHelpers.loginIfLoggedOut

## Success path

      it 'should successfully insert a word to a newly created game', (done) ->

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

              word = 'test'
              Meteor.call 'insertWord', gameId, word, (error, result) ->

### Verify

                actualGame = Games.findOne()

                expect(error).toBeUndefined()
                expect(actualGame.story).toEqual "#{dummyGame.story} #{word}"
                expect(actualGame.currentPlayersTurn).toEqual dummyGame.players[1].userId
                done()

## Not logged in

      it 'should throw an error if not logged in', (done) ->

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

              word = 'test'

              Meteor.logout ->
                Meteor.call 'insertWord', gameId, word, (error, result) ->

### Verify

                  expect(error.error).toEqual 'not-logged-in'
                  done()

## Game not found

      it 'should throw an error if game not found', (done) ->

### Setup

        badGameId = 'fakeGameId'
        word = 'word'

### Execute

        Meteor.call 'insertWord', badGameId, word, (error, result) ->

### Verify

          expect(error.error).toEqual 'game-not-found'
          done()

## Game hasn't started

      it "should throw an error if game hasn't started", (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

            word = 'test'
            Meteor.call 'insertWord', gameId, word, (error, result) ->

### Verify

              expect(error.error).toEqual 'game-hasnt-started'
              done()

## Game already ended

      it 'should throw an error if game already ended', (done) ->

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

                word = 'test'
                Meteor.call 'insertWord', gameId, word, (error, result) ->

### Verify

                  expect(error.error).toEqual 'game-already-ended'
                  done()

## Not your turn

      it 'should throw an error if not your turn', (done) ->

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

              word = 'test'
              Meteor.call 'insertWord', gameId, word, (error, result) ->

### Verify

                expect(error.error).toEqual 'not-your-turn'
                done()
