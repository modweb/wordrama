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

                  console.log actualGame

                  player =
                    userId: Meteor.userId()
                    name: Meteor.user().username

Check if the user is in the game

                  testuser2IsInGame = _.findWhere actualGame.players, player
                  expect(testuser2IsInGame).toBeTruthy()
                  done()

## Error on rejoin game

      it 'should throw an error on rejoining a game', (done) ->

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

                  actualGame = Games.findOne()


                  player =
                    userId: Meteor.userId()
                    name: Meteor.user().username

Check if the user is in the game

                  testuser2IsInGame = _.findWhere actualGame.players, player
                  expect(testuser2IsInGame).toBeTruthy()

                  Meteor.call 'joinGame', gameId, (error, result) ->
                    expect(error.error).toEqual 'already-joined-game'
                    done()

## Error on join game and not logge din

      it 'should throw an error on joining a game and not logged in', (done) ->

### Setup

        dummyGame = ClientIntegrationTestHelpers.getDummyGame()
        delete dummyGame.promptId

        Games.insert dummyGame, (error, result) ->
          expect(error).toBeUndefined()
          gameId = result

Logout of testuser

          Meteor.logout ->

### Execute

            Meteor.call 'joinGame', gameId, (error, result) ->

### Verify

              expect(error.error).toEqual 'not-logged-in'
              done()
