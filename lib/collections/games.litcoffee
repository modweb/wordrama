# Games Collection

    PlayerSchema = new SimpleSchema
      name:
        type: String
      userId:
        type: SimpleSchema.RegEx.Id

    @GameSchema = new SimpleSchema
      createdBy:
        type: SimpleSchema.RegEx.Id
      createdAt:
        type: Date
        autoValue: ->
          return new Date if this.isInsert
          return $setOnInsert: new Date if this.isUpsert
          this.unset()
        optional: yes
      hasStarted:
        type: Boolean
        autoValue: ->
          return value if this.isInsert
          return $setOnInsert: value if this.isUpsert
          this.unset()
        optional: yes
      hasFinished:
        type: Boolean
        autoValue: ->
          return value if this.isInsert
          return $setOnInsert: value if this.isUpsert
          this.unset()
        optional: yes
      players:
        type: [ PlayerSchema ]
      currentPlayersTurn:
        type: SimpleSchema.RegEx.Id
      promptId:
        type: SimpleSchema.RegEx.Id
        optional: yes
      story:
        type: String
        optional: yes

TODO: ideas for more features

isPublic
maxPlayers

    @Games = new Mongo.Collection 'games'
    Games.attachSchema GameSchema

## Allow/Deny

    Games.allow
      insert: (userId, doc) -> Meteor.userId() isnt null
      update: (userId, doc, fieldNames, modifier) -> _.contains doc.players, Meteor.userId()
      remove: (userId, doc) -> no

## Meteor Methods

    Meteor.methods
      createGame: ->

Must be logged in to create a game

TODO: use this.userId, how can we set Meteor.method context for tests?

        if not this.userId then throw new Meteor.Error 'access-denied', 'You must be logged in to create a game.'

        newGame =
          createdBy: this.userId
          players: [ this.userId ]
          currentPlayersTurn: this.userId

        id = Games.insert newGame
