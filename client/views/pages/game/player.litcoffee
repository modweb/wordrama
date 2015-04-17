    Template.player.helpers
      isPlayerTurn: ->
        isPlayerTurn = this.userId is Template.parentData().currentPlayersTurn
        if isPlayerTurn then 'label-success'
