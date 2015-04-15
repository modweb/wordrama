# End Game Spec

    describe 'End Game', ->

Keep track of subscription to clean at the end of the test.

      subscription = null

      afterEach ->
        subscription?.stop()
        subscription = null

      beforeEach ClientIntegrationTestHelpers.loginIfLoggedOut

      it 'should successfully end a newly created game', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        delete dummyGame.promptId

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Subscribe to `singleGame` to access the collection

          subscription = Meteor.subscribe 'singleGame', gameId, ->

### Execute

            Meteor.call 'endGame', gameId, (error, result) ->
              expect(error).toBeUndefined()

              actualGame = Games.findOne()

### Verify

Verify that the game has ended

              expect(actualGame.hasFinished).toBeTruthy()
              done()
