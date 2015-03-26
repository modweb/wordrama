# Client integration tests for prompt collection

    describe 'Create Prompt', ->

      beforeEach (done) -> ClientIntegrationTestHelpers.loginIfLoggedOut done

      subscription = null

      afterEach ->
        subscription?.stop()
        subscription = null

## Successfully create prompt

      it 'should create a prompt and attach it to a game if logged in', (done) ->

### Setup

Create a new game to attach the prompt to

        Meteor.call 'createGame', (error, gameId) ->
          expect(gameId).not.toBeNull()

          phrase = 'some prompt'

### Execute

          Meteor.call 'insertPromptForGame', gameId, phrase, (error, result) ->

### Verify

            expect(error).toBeUndefined()

            subscription = Meteor.subscribe 'singleGame', gameId, ->
              actualGame = Games.findOne(gameId)

The promptId for the game should match the prompt._id

              expect(actualGame.promptId).not.toBeUndefined()
              expect(actualGame.story).toEqual phrase

### Teardown

              Games.remove actualGame._id
              done()

## Fail on bad arguments

      it 'should throw an error if given bad arguments', (done) ->

### Setup

### Execute

        badArg = stupid: 'object', thisDefinitely: 'is not an id of a game'
        gameId = 'fakeGameId'
        Meteor.call 'insertPromptForGame', gameId, badArg, (error, result) ->

### Verify

Expect a Match.Error 400

          console.log 'bad args!', error.error

          expect(error.error).toEqual 400
          done()

## Fail on missing game

      it 'should thrown an error if gameId can\'t be found', (done) ->

### Setup

### Execute

        goodArg = 'This is a legit writing prompt extraordinaire...'
        badGameId = 'fakeGameId'
        Meteor.call 'insertPromptForGame', badGameId, goodArg, (error, result) ->

### Verify

          expect(error.error).toEqual 'game-not-found'
          done()

## Fail when not logged in

      it 'should throw an error if not logged it', (done) ->

### Setup

        Meteor.logout()

### Execute

        Meteor.call 'insertPromptForGame', 'fakeGameId', 'whatever prompt', (error, result) ->

### Verify

          expect(error.error).toEqual 'access-denied'
          done()
