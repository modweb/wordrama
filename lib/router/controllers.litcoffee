# Route Controllers

    @RouteControllers =
      singleGame: RouteController.extend
        waitOn: -> Meteor.subscribe 'singleGame', this.params._id
        data: -> Games.findOne()
      openGames: RouteController.extend
        waitOn: -> Meteor.subscribe 'openGames'
        data: -> games: Games.find()
