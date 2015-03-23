Client Integration Tests for Games collection

    describe 'Create Game (logged in)', ->

      beforeEach (done) ->
        criteria = username: 'testuser'
        if not Meteor.users.findOne criteria
          Accounts.createUser username: 'testuser', password: 'password'
        Meteor.loginWithPassword 'testuser','password', done

      it 'should create a new game if logged in', ->

## Execute

        Meteor.call 'createGame', (error, result) ->

## Verify

          userId = Meteor.userId()
          actualGame = Games.findOne()
          expectedGame =
            hasStarted: no
            createdBy: userId
            players: [ userId ]

          expect(actualGame).toBe expectedGame
