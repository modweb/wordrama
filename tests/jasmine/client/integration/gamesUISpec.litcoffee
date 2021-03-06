Client integration tests for games UI

# Create Game (UI)

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

          gameId = Router.current().params._id
          criteria = _id: gameId
          numberOfGames = Games.find(criteria).count()
          expect(numberOfGames).toEqual 1

          game = Games.findOne(criteria)
          expect(gameId).toEqual game._id

The game should match the game schema
Strip game of _id to match GameSchema

          expect(Match.test (_.omit game, '_id'), GameSchema).toBeTruthy()
          done()
        , 100

# Browse open games (UI)

    describe 'Browse open games (UI)', ->

      beforeEach ClientIntegrationTestHelpers.loginIfLoggedOut

      beforeEach (done) ->
        Router.go 'games'
        Tracker.afterFlush done

      beforeEach waitForRouter

Look for some games (this relies on games being created, fixutres should do that)

      it 'should show a list of open games', (done) ->

        games = Template.games.__helpers.get('games')()

        console.log 'template games: ', games

        expect(games).not.toBeUndefined()
        expect(games.length).toBeGreaterThan 0

        gameElement = $ '.gameListItem'

        expect(gameElement).not.toBeUndefined()
        done()

# Join game (UI)

    describe 'Join open game (UI)', ->

      beforeEach ClientIntegrationTestHelpers.loginIfLoggedOut

      beforeEach (done) ->
        Router.go 'games'
        Tracker.afterFlush done

      beforeEach waitForRouter

      it 'should join a game and navigate to game route when join game button is clicked', (done) ->

        $('.join-game').trigger 'click'

setTimeout is necessary to wait for Iron Router to do it's thing.
TODO: there must be a better way to do this!

        Meteor.setTimeout ->
          currentRoute = Router.current().route
          expect(currentRoute.getName()).toEqual 'game'

We should have one game in the data context

          gameId = Router.current().params._id
          criteria = _id: gameId

          numberOfGames = Games.find(criteria).count()
          expect(numberOfGames).toEqual 1

          game = Games.findOne(criteria)
          expect(gameId).toEqual game._id

Current user should be a player in the game

          isPlayer = !!_.findWhere game.players, userId: Meteor.userId()
          expect(isPlayer).toBeTruthy()
          done()
        , 200
