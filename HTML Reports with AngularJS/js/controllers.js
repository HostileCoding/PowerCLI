'use strict';

/* Controllers */

var vmMonitorControllers = angular.module('vmMonitorControllers', []);

vmMonitorControllers.controller('vmListCtrl', ['$scope', '$http',
  function($scope, $http) {
    $http.get('data/vms_all.json').success(function(data) {
      $scope.vms = data;
    });

    $scope.orderProp = 'Id';
  }]);

vmMonitorControllers.controller('vmDetailCtrl', ['$scope', '$routeParams', '$http',
  function($scope, $routeParams, $http) {
    $http.get('data/' + $routeParams.Id + '.json').success(function(data) {
      $scope.vms = data;
    });

  }]);
  
