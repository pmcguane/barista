merchant = angular.module('CupTown', ['ngResource', 'ngRoute', 'ngMaterial'])
#Factory
merchant.factory 'Merchants', [
  '$resource'
  ($resource) ->
    $resource '/shopping/merchants.json', {},
      query:
        method: 'GET'
        isArray: true
      create:
        method: 'POST'
]
merchant.factory 'Merchant', [
  '$resource'
  ($resource) ->
    $resource '/shopping/merchants/:id.json', {},
      show:
        method: 'GET'
      update:
        method: 'PUT'
        params:
          id: '@id'
      delete:
        method: 'DELETE'
        params:
          id: '@id'
]
#Controller
merchant.controller 'MerchantListCtrl', [
  '$scope'
  '$http'
  '$resource'
  'Merchants'
  'Merchant'
  '$location'
  ($scope, $http, $resource, Merchants, Merchant, $location) ->
    $scope.merchants = Merchants.query()

    $scope.deleteMerchant = (merchantId) ->
      if confirm('Are you sure you want to delete this merchant?')
        Merchant.delete {id: merchantId}, ->
          $scope.merchants = Merchants.query()
          $location.path '/merchants'
]

merchant.controller 'MerchantShowCtrl', [
  '$scope'
  '$http'
  '$resource'
  'Merchants'
  'Merchant'
  '$location'
  ($scope, $http, $resource, Merchants, Merchant, $location) ->
    $scope.merchants = Merchant.show('$resource.id')
]

# ---
# generated by js2coffee 2.2.0


#Routes
merchant.config [
  '$routeProvider'
  '$locationProvider'
  ($routeProvider, $locationProvider) ->
    $routeProvider.when '/merchants',
      templateUrl: '/templates/merchants/terms.html'
      controller: 'MerchantListCtrl'
    $routeProvider.when '/merchant/:id',
      templateUrl: '/templates/merchants/terms.html'
      controller: 'MerchantShowCtrl'
    $routeProvider.otherwise redirectTo: '/merchants'

]

