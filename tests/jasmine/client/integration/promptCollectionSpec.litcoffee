# Client integration tests for prompt collection

    describe 'Create Prompt', ->

## Successfully create prompt

      it 'should create a prompt and attach it to a game if logged in', (done) ->

### Setup

        Meteor.loginWithPassword 'testuser','password', (error) ->
          expect(error).toBeUndefined()
          expect(Meteor.user()).not.toBeUndefined()

Create a new game to attach the prompt to

          gameId = Meteor.call 'createGame'
          expect(gameId).not.toBeNull()

          prompt = 'some prompt'

### Execute

          Meteor.call 'insertPromptForGame', gameId, prompt (error, result) ->

### Verify

            expect(error).toBeUndefined()

            Meteor.subscribe 'singleGame', gameId, ->
              actualGame = Games.findOne()
              actualPrompt = Prompts.findOne()

The promptId for the game should match the prompt._id

              expect(actualGame.promptId).toEqual actualPrompt._id
              expect(actualGame.story).toEqual actualPrompt.prompt

## Fail when not logged in

      it 'should throw an error if not logged it', (done) ->

### Setup

        Meteor.logout()

### Execute

        Meteor.call 'insertPromptForGame', 'fakeGameId', (error, result) ->

### Verify

          expect(error.error).toEqual 'access-denied'
          done()

## Fail on bad arguments

      it 'should throw an error if given bad arguments', (done) ->

### Setup

        Meteor.loginWithPassword 'testuser','password', (error) ->
          expect(error).toBeUndefined()
          expect(Meteor.user()).not.toBeUndefined()

### Execute

          badArg = stupid: 'object', thisDefinitely: 'is not an id of a game'
          gameId = 'fakeGameId'
          Meteor.call 'insertPromptForGame', gameId, badArg, (error, result) ->

### Verify

            expect(error.error).toEqual 'bad-args'
            done()

## Fail on missing game

      it 'should thrown an error if gameId can\'t be found', (done) ->

### Setup

        Meteor.loginWithPassword 'testuser','password', (error) ->
          expect(error).toBeUndefined()
          expect(Meteor.user()).not.toBeUndefined()

### Execute

          goodArg = 'This is a legit writing prompt extraordinaire...'
          badGameId = 'fakeGameId'
          Meteor.call 'insertPromptForGame', badGameId, goodArg, (error, result) ->

### Verify

            expect(error.error).toEqual 'game-not-found'
            done()
