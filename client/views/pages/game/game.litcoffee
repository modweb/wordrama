    Template.game.helpers
      readyToStart: -> (not this.hasStarted) and this.promptId? and this.story?
      needsPrompt: -> not (this.promptId? and this.story?)
      promptValidation: ->
        invalid = yes
        if invalid then 'has-warnding'
      usersTurn: ->
        usersTurn = Meteor.userId() is this.currentPlayersTurn and this.hasStarted

    Template.game.events
      'click .start-game': (event, template) ->
        Meteor.call 'startGame', this._id
      'submit #newPromptForm': (event, template) ->
        event.preventDefault()
        phrase = event.target.phrase.value
        console.log this
        Meteor.call 'insertPromptForGame', Template.currentData()._id, phrase, (error, result) ->
          if error? then sweetAlert "Uh oh...", error.message, 'error'
