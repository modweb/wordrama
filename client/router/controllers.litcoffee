# Route Controllers

    @RouteControllers =
      singleGame: RouteController.extend
        waitOn: -> Meteor.subscribe 'singleGame', this.params._id
        data: -> game: Games.findOne()
