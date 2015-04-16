    criteria = username: 'testuser'
    if Meteor.users.find(criteria).count() is 0
      users = [
        username: 'testuser'
        email: 'test@user.com'
        password: 'password'
      ,
        username: 'testuser2'
        email: 'test@user2.com'
        password: 'password'
      ]
      console.log 'creating test users'
      _.each users, (user) ->
        Accounts.createUser user

    if Prompts.find().count() is 0
      console.log 'Creating fixture prompts'
      prompt =
        phrase: 'This app could be better if'
      Prompts.insert prompt

    if Games.find().count() is 0
      console.log 'Creating fixture games'

Find prompt

      prompt = Prompts.findOne()

      players = [
        name: 'fakeplayer1'
        userId: 'xC8Bg3dCofQokrKy4'
      ,
        name: 'fakeplayer2'
        userId: 'xC8Bg3dCofQokrKy3'
      ]
      game =
        createdBy: 'xC8Bg3dCofQokrKy4'
        createdAt: new Date()
        hasStarted: yes
        hasFinished: no
        players: players
        currentPlayersTurn: 'xC8Bg3dCofQokrKy4'
        promptId: prompt._id
        story: prompt.phrase

      Games.insert game
