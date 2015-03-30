# GameHelpers Spec

    players = [
      name: 'player1'
      userId: 'asdfasdfasdfasdf1'
    ,
      name: 'player2'
      userId: 'asdfasdfasdfasdf2'
    ,
      name: 'player2'
      userId: 'asdfasdfasdfasdf2'
    ]
    testGame =
      createdBy: 'asdfasdfasdfasdf1'
      createdAt: new Date()
      hasStarted: yes
      hasFinished: no
      players: players
      currentPlayersTurn: 'asdfasdfasdfasdf1'
      promptId: 'asdfasdfasdfasdf1'
      story: 'This is a story prompt and'

    describe 'Rotate Turns', ->

      it 'should return the next player', ->
        actualNextPlayerId = GameHelpers.getNextPlayerTurnId testGame
        expectedNextPlayerId = players[1].userId
        expect(actualNextPlayerId).toEqual expectedNextPlayerId
