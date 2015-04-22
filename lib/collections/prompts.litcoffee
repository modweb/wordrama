# Prompts Collection

    @PromptSchema = new SimpleSchema
      phrase:
        type: String
        label: 'Story prompt'
        min: 1
        max: 200
        autoform:
          placeholder: 'Once upon a time, the story begin like this...'

    @Prompts = new Mongo.Collection 'prompts'
    Prompts.attachSchema PromptSchema

## Prompts Meteor Methods

    Meteor.methods
      insertPromptForGame: (gameId, phrase) ->

check user is logged in

        if not this.userId?
          throw new Meteor.Error 'access-denied', 'You have to be logged in to insert a prompt on a game'

check arguments

        check gameId, String
        check phrase, String

lookup game

        game = Games.findOne gameId

        if not game?
          throw new Meteor.Error 'game-not-found', "Sorry, there is no game with _id: #{gameId}"

check game hasn't started

        if game.hasStarted
          throw new Meteor.Error 'game-started', 'No changes to the prompt are allowed once the game has started'

insert prompt

        prompt =
          phrase: phrase

        promptId = Prompts.insert prompt

        criteria =
          _id: gameId
        action =
          $set:
            promptId: promptId
            story: phrase

update game

        Games.update criteria, action
