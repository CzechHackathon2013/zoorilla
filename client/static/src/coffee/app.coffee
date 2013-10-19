main = angular.module 'main', []
settings = 
    connection: window.localStorage.getItem 'zoorilla_connection'

main.config ($routeProvider) -> 
    $routeProvider
    .when("/:path", {
       templateUrl: "static/templates/view.html",
    })
    .when("/settings", {
       templateUrl: "static/templates/settings.html",
       controller: SettingsController,
    })
    .otherwise {redirectTo: "/"}


Array.prototype.remove = (r) ->
    out = []
    for e in this
        if e != r
            out.push e
    return out

String.prototype.replaceslashes = (c) ->
    this.replace /\//g, c

TreeController = ($scope, $http) ->
    $scope.tree = []
    $scope.tree_open = []
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
            if node.indexOf(path+"/") == -1
                res.push node
        $scope.tree = res

    $scope.showHideChildren = (path) ->
        if $scope.tree_open.indexOf(path) == -1
            $scope.showChildren(path+"/")
            $scope.tree_open.push path
        else
            $scope.hideChildren(path)
            $scope.tree_open = $scope.tree_open.remove(path)

    $scope.showHideChildrenLabel = (path) ->
        if $scope.tree_open.indexOf(path) == -1
            return "(+)"
        else
            return "(-)"

    $scope.showChildren "/"

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

