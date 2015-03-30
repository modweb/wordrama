# Client Integration Tests for Games collection

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

    describe 'Start Game', ->

Keep track of subscript to clean at the end of the test.

      subscription = null

      afterEach ->
        subscription?.stop()
        subscription = null

      beforeEach ClientIntegrationTestHelpers.loginIfLoggedOut

      it 'should start the game and set properties appropriately', (done) ->

### Setup

        gameId = Games.insert ClientIntegrationTestHelpers.getDummyGame

### Execute

        Meteor.call 'startGame', gameId, (error, result) ->

          expect(error).toBeUndefined()

Subscribe to `singleGame` to access the collection

### Verify

          subscription = Meteor.subscribe 'singleGame', result, () ->

            actualGame = Games.findOne()
            expect(actualGame.hasStarted).toBeTruthy()
            done()

      it 'should throw an error if < 2 players', (done) ->

### Setup

        gameId = Games.insert ClientIntegrationTestHelpers.getDummyGame

        Games.update gameId,
          $set:
            players: [
              userId: 'asdfasdfasdfasdf1'
              name: 'oneLonelyPlayer1'
            ]

### Execute

        Meteor.call 'startGame', gameId, (error, result) ->

### Verify

          expect(error.error).toEqual 'not-enough-players'

## Fail when game already started

      it 'should throw an error if game has already started', (done) ->

### Setup

        gameId = Games.insert ClientIntegrationTestHelpers.getDummyGame

        Games.update gameId,
          $set:
            hasStarted: yes

### Execute

        Meteor.call 'startGame', gameId, (error, result) ->

### Verify

          expect(error.error).toEqual 'game-already-started'
          done()

## Fail when game already finished

      it 'should throw an error if game has finished', (done) ->

### Setup

        gameId = Games.insert ClientIntegrationTestHelpers.getDummyGame

        Games.update gameId,
          $set:
            hasFinished: yes

### Execute

        Meteor.call 'startGame', gameId, (error, result) ->

### Verify

          expect(error.error).toEqual 'game-already-finished'
          done()

## Fail when promptId isn't set

      it 'should throw an error if game is missing prompt', (done) ->

### Setup

        gameId = Games.insert ClientIntegrationTestHelpers.getDummyGame

        Games.update gameId,
          $unset:
            promptId: yes

### Execute

        Meteor.call 'startGame', gameId, (error, result) ->

### Verify

          expect(error.error).toEqual 'game-missing-promptId'
          done()

## Fail when story isn't set

      it 'should throw an error if game is missing story', (done) ->

### Setup

        gameId = Games.insert ClientIntegrationTestHelpers.getDummyGame

        Games.update gameId,
          $unset:
            story: yes

### Execute

        Meteor.call 'startGame', gameId, (error, result) ->

### Verify

          expect(error.error).toEqual 'game-missing-story'
          done()

## Fail when game isn't found

      it 'should throw an error if game is missing story', (done) ->

### Setup

        gameId = 'fakegameId'


### Execute

        Meteor.call 'startGame', gameId, (error, result) ->

### Verify

          expect(error.error).toEqual 'game-not-found'
          done()
