angular.module('garden').directive 'grid', () ->
  restrict: 'E'
  replace: true
  scope: {}
  templateUrl: 'garden/directive/grid/grid.html',
  link: (scope, element, attrs, fn) ->
    null
