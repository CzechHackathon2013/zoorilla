main = angular.module 'main', ["angularTreeview"]
settings = 
    connection: window.localStorage.getItem 'zoorilla_connection'

main.config ($routeProvider) -> 
    $routeProvider
    .when("/", {
       templateUrl: "static/templates/tree.html",
       controller: TreeController,
    })
    .when("/node", {
       templateUrl: "static/templates/node.html",
       controller: NodeController,
    })
    .when("/settings", {
       templateUrl: "static/templates/settings.html",
       controller: SettingsController,
    })
    .otherwise {redirectTo: "/"}

TreeController = ($scope, $http) ->
    $scope.tree = []
    $http.get(window.settings.connection+"/0/children/")
        .success (data) ->
            $scope.treedata = []
            for element in data
                object =
                    label: element
                    id: element
                    children: []
                $scope.treedata.push object
                    


SettingsController = ($scope, $routeParams, $http) ->
    $scope.routeParams = $routeParams
    $scope.settings = window.settings
    $scope.save = ->
        $http.get(window.settings.connection+"/0/zoorilla/")
            .success () ->
                window.settings = $scope.settings
                localStorage.setItem 'zoorilla_connection', $scope.settings.connection
                alert "Saved"
            .error () ->
                alert "No running Zoorilla server on '"+$scope.settings.connection+"'"

