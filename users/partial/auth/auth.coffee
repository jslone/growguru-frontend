'use strict'

app = angular.module 'users'

app.controller 'AuthController',
  class AuthController

    @$inject: ['$scope']

    constructor: (@scope) ->
      @scope.demo = 'just some text'
      @scope.someParameter = @someParameter

    list: [
      text: "learn coffescript"
      done: false
    ,
      text: "learn angular"
      done: true
    ]

    oldList: []

    addTodo: ->
      @list.push
        text: @input
        done: false
      @input = ''

    remaining: ->
      count = 0
      for todo in @list
        count += if todo.done then 0 else 1
      count

    unarchive: ->
      for todo in @oldList
        @list.push todo
      @oldList = []

    archive: ->
      t = @list
      @list = []
      for todo in t
        @list.push todo unless todo.done
        @oldList.push todo if todo.done

    removeTodo: (index) ->
      @list.splice index, 1
