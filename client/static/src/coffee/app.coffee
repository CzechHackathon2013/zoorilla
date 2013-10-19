main = angular.module 'main', ["angularTreeview"]
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
    $scope.tree = []
    $http.get(window.settings.connection+"/0/children/")
        .success (data) ->
            $scope.tree = data

   # $scope.treedata = [
   #      { "label" : "User", "id" : "role1", "children" : [
   #          { "label" : "subUser1", "id" : "role11", "children" : [] },
   #          { "label" : "subUser2", "id" : "role12", "children" : [
   #              { "label" : "subUser2-1", "id" : "role121", "children" : [
   #                  { "label" : "subUser2-1-1", "id" : "role1211", "children" : [] },
   #                  { "label" : "subUser2-1-2", "id" : "role1212", "children" : [] }
   #              ]}
   #          ]}
   #      ]},
   #      { "label" : "Admin", "id" : "role2", "children" : [] },
   #      { "label" : "Guest", "id" : "role3", "children" : [] }
   #  ]

SettingsController = ($scope, $routeParams, $http) ->
    $scope.routeParams = $routeParams

    $scope.save = ->
        $http.get(window.settings.connection+"/0/zoorilla")
            .success () ->
                window.settings = $scope.settings
                localStorage.setItem 'zoorilla_connection', $scope.settings.connection
                alert "Saved"
            .error () ->
                alert "No running Zoorilla server on '"+$scope.settings.connection+"'"

