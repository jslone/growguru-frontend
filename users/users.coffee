angular.module 'users', ['ui.bootstrap', 'ui.utils', 'ui.router', 'ngAnimate']

angular.module('users').config ($stateProvider) ->

  $stateProvider.state 'auth', {url: '/users/auth', templateUrl: 'users/partial/auth/auth.html'}
  ## Add New States Above


