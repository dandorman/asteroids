describe 'User:', ->
  describe 'fullName()', ->
    it 'should concat first and last names', ->
      user = User.init firstName:'Thom', lastName:'Yorke'
      expect(user.fullName()).toEqual 'Thom Yorke'
