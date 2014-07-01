angular.module('plants').directive 'plant', () ->
  restrict: 'E'
  replace: true
  scope: {}
  templateUrl: 'plants/directive/plant/plant.html',
  link: (scope, element, attrs, fn) ->
    null
