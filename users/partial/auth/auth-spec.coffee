describe 'AuthController', () ->

  beforeEach module 'users'

  beforeEach inject ($rootScope, $controller) ->
    @scope = $rootScope.$new()
    @controller = $controller 'AuthController', {$scope: @scope}

  it 'should ...', inject () ->
    expect(1).toEqual 1

  # test a scope value
  it 'should have demo text...', inject () ->
    expect(@scope.demo).toEqual 'just some text'

  # test the result of a method call
  it 'should have 1 remaining element...', inject () ->
    expect(@controller.remaining()).toEqual 1
