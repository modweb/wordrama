# Client integration tests for games UI

    describe 'Create Game (UI)', ->

      beforeEach (done) -> ClientIntegrationTestHelpers.loginIfLoggedOut done

      beforeEach (done) ->
        Router.go 'games'
        Tracker.afterFlush done

      beforeEach waitForRouter

# Create new game when 'create new game' button is clicked

      it 'should create a new game and navigate to game route when create new game button is clicked', (done) ->

### Execute

        $('#createGame').trigger 'click'

setTimeout is necessary to wait for Iron Router to do it's thing.
TODO: there must be a better way to do this!

        Meteor.setTimeout ->

### Verify

          currentRoute = Router.current().route

          expect(currentRoute.getName()).toEqual 'game'

We should have one game in the data context

          numberOfGames = Games.find().count()
          expect(numberOfGames).toEqual 1

          game = Games.findOne()
          expect(Router.current().params._id).toEqual game._id

The game should match the game schema
Strip game of _id to match GameSchema

          expect(Match.test (_.omit game, '_id'), GameSchema).toBeTruthy()
          done()
        , 100
