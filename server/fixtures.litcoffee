    criteria = username: 'testuser'
    if Meteor.users.find(criteria).count() is 0
      console.log 'creating test user'
      options =
        username: 'testuser'
        password: 'password'
      Accounts.createUser options
