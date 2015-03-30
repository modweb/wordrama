# Global client test helpers

    @ClientIntegrationTestHelpers =
      loginIfLoggedOut: (done) ->
        if not Meteor.userId()?
          console.log 'logging in as testuser'
          Meteor.loginWithPassword 'testuser','password', (error) ->
            expect(error).toBeUndefined()
            expect(Meteor.user()).not.toBeUndefined()
            done()
        else
          done()
      getDummyGame: ->
        players = [
          name: 'player1'
          userId: 'asdfasdfasdfasdf1'
        ,
          name: 'player2'
          userId: 'asdfasdfasdfasdf2'
        ,
          name: 'player2'
          userId: 'asdfasdfasdfasdf2'
        ]
        dummyGame =
          createdBy: 'asdfasdfasdfasdf1'
          createdAt: new Date()
          hasStarted: yes
          hasFinished: no
          players: players
          currentPlayersTurn: 'asdfasdfasdfasdf1'
          promptId: 'asdfasdfasdfasdf1'
          story: 'This is a story prompt and'

    ((Meteor, Tracker, Router) ->
      isRouterReady = no
      callbacks = [];

      @waitForRouter = (callback) ->
        if isRouterReady
          callback()
        else
          callbacks.push callback

      Router.onAfterAction ->
        if !isRouterReady && this.ready()
          Tracker.afterFlush ->
            isRouterReady = yes
            callbacks.forEach (callback) ->
              callback()
            callbacks = []

      Router.onRerun ->
        isRouterReady = no
        this.next()

      Router.onStop ->
        isRouterReady = no
        if this.next then this.next()
    )(Meteor, Tracker, Router)
