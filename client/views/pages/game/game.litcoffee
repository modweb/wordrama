    Template.game.helpers
      readyToStart: -> (not this.hasStarted) and this.promptId? and this.story?
      needsPrompt: -> not (this.promptId? and this.story?)
      promptValidation: ->
        invalid = yes
        if invalid then 'has-warnding'
      usersTurn: ->
        usersTurn = Meteor.userId() is this.currentPlayersTurn and this.hasStarted
      canSkipMove: ->
        turnMoreThan15SecondsAgo = Template.instance().secondsToSkip?.get() >= 15
      secondsFromMoveStart: ->
        Template.instance().secondsToSkip.get()

    Template.game.events
      'click .start-game': (event, template) ->
        Meteor.call 'startGame', this._id
      'click .skip-move': (event, template) ->
        Meteor.call 'skipPlayerMove', this._id, (error, result) ->
          if error? then sweetAlert "Uh oh...", error.message, 'error'
      'submit #newPromptForm': (event, template) ->
        event.preventDefault()
        phrase = event.target.phrase.value
        console.log this
        Meteor.call 'insertPromptForGame', Template.currentData()._id, phrase, (error, result) ->
          if error? then sweetAlert "Uh oh...", error.message, 'error'

    Template.game.onCreated ->
      this.secondsToSkip = new ReactiveVar(null)
      self = this
      Meteor.setInterval ->
        now = moment.utc()
        timeTurnStarted = moment Games.findOne().timeTurnStarted
        self.secondsToSkip.set (now.diff timeTurnStarted, 'seconds')
      , 1000
