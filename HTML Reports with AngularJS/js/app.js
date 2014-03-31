'use strict';

/* App Module */

var VmMonitorApp = angular.module('VmMonitorApp', [
  'ngRoute',
  'vmMonitorControllers',
  'vmFilters'
]);

VmMonitorApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/data', {
        templateUrl: 'partials/vm-list.html',
        controller: 'vmListCtrl'
      }).
      when('/data/:Id', {
        templateUrl: 'partials/vm-detail.html',
        controller: 'vmDetailCtrl'
      }).
      otherwise({
        redirectTo: '/data'
      });
  }]);