# Global client test helpers

    @ClientIntegrationTestHelpers =
      loginIfLoggedOut: (done) ->
        if not Meteor.userId()?
          console.log 'logging in as testuser'
          Meteor.loginWithPassword 'testuser','password', (error) ->
            expect(error).toBeUndefined()
            expect(Meteor.user()).not.toBeUndefined()
            done()
        else
          done()
