# Router map

    Router.map ->
      @route 'home', path: '/'
      @route 'game',
        path: 'game/:_id'
        controller: RouteControllers.singleGame
      @route 'games',
        controller: RouteControllers.openGames
