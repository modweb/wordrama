# Publications

    Meteor.publish 'singleGame', (_id) ->
      Games.find _id: _id

    Meteor.publish 'singlePrompt', (_id) ->
      Prompts.find _id: _id

    Meteor.publish 'openGames', ->
      criteria =
        hasStarted: no
      Games.find {}
