main = angular.module 'main', []
settings = 
    connection: window.localStorage.getItem 'zoorilla_connection'

main.config ($routeProvider) -> 
    $routeProvider
    .when("/", {
       templateUrl: "static/templates/tree.html",
       controller: TreeController,
    })
    .when("/settings", {
       templateUrl: "static/templates/settings.html",
       controller: SettingsController,
    })
    .otherwise {redirectTo: "/"}

TreeController = ($scope, $http) ->

SettingsController = ($scope, $routeParams, $http) ->
    $scope.routeParams = $routeParams
    $scope.settings = window.settings

    $scope.save = ->
        $http.get($scope.settings.connection+"/0/zoorilla")
            .success () ->
                window.settings = $scope.settings
                localStorage.setItem 'zoorilla_connection', $scope.settings.connection
                alert "Saved"
            .error () ->
                alert "No running Zoorilla server on '"+$scope.settings.connection+"'"

