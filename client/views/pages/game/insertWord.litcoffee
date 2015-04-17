    Template.insertWord.onRendered ->
      $("[name='word']").focus()
      $("[name='word']").select()

    Template.insertWord.events
      'submit #wordForm': (event, template) ->
        event.preventDefault()
        if AutoForm.validateForm 'wordForm'
          word = event.target.word.value
          console.log "Submit word: #{word}"
          Meteor.call 'insertWord', Template.parentData()._id, word, (error, result) ->
            if error? then sweetAlert 'Uh oh!', error.message, 'error'
