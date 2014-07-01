angular.module 'growguru',        ['ui.bootstrap', 'ui.utils', 'ui.router', 'ngAnimate', 'users', 'plants', 'garden', 'scheduler']

angular.module('growguru').config ($stateProvider, $urlRouterProvider) ->

  ## Add New States Above
  $urlRouterProvider.otherwise '/'


angular.module('growguru').run ($rootScope) ->

  $rootScope.safeApply = (fn) ->
    phase = $rootScope.$$phase;
    if phase is '$apply' or phase is '$digest'
      if fn and (typeof(fn) is 'function') then fn() else @$apply fn
