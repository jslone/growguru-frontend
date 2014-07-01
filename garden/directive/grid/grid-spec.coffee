describe 'grid', () ->

  beforeEach module 'garden'

  beforeEach inject ($rootScope, $compile) ->
    scope = $rootScope.$new()
    compile = $compile

  it 'should ...', () ->

    # To test your directive, you need to create some html that would use your directive,
    # send that through compile() then compare the results.
    #
    # element = compile('<div mydirective name="name">hi</div>')(scope);
    # expect(element.text()).toBe('hello, world');

    expect(1).toBe 1
