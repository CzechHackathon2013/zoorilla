main = angular.module 'main', []
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

Array.prototype.pop = (i) ->
    if i?
        return this.splice(i, 1)[0];
    return this.splice(this.length-1, 1)[0];


Array.prototype.remove = (r) ->
    out = []
    for e in this
        if e != r
            out.push e
    return out


TreeController = ($scope, $http) ->
    $scope.tree = []
    $scope.showChildren = (path) ->
        $http.get(window.settings.connection+"/0/children"+path)
            .success (data) ->
                for element in data
                    $scope.tree.push path+element
                $scope.tree.sort()

    $scope.hideChildren = (path) ->
        res = []
        data = $scope.tree
        for node in data
            if node.indexOf(path) == -1
                res.push node
        $scope.tree = res

    $scope.showChildren "/"
    # $scope.showChildren "/b/"
    # $scope.hideChildren "/b/c"

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

