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
