# Publications

    Meteor.publish 'singleGame', (_id) ->
      Games.find _id: _id

    Meteor.publish 'singlePrompt', (_id) ->
      Prompts.find _id: _id

    Meteor.publish 'openGames', ->
      x = 0
      while x < 5000000
        x += .01
      criteria =
        hasStarted: no
      Games.find {}
