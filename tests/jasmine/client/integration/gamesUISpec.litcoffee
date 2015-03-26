# Client integration tests for games UI

    describe 'Create Game (UI)', ->

      beforeEach (done) -> ClientIntegrationTestHelpers.loginIfLoggedOut done

# Create new game when 'create new game' button is clicked

      it 'should create a new game and navigate to game route when create new game button is clicked', (done) ->

### Setup

Navigate to the games page

        Router.go 'games'

### Execute

        $('#createGame').trigger 'click'

### Verify

Wait 100ms?

        currentRoute = Router.current()

        expect(currentRoute.name).toEqual 'game'

        gameData = currentRoute.data().game

        expect(Match.test gameData, GameSchema).toBeTruthy()
