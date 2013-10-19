main = angular.module 'main', []
settings = 
    connection: window.localStorage.getItem 'zoorilla_connection'

main.config ($routeProvider) -> 
    $routeProvider
    .when("/settings", {
       templateUrl: "static/templates/settings.html",
       controller: SettingsController,
    })
    .when("/:path", {
       templateUrl: "static/templates/view.html",
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

TreeController = ($scope, $http, $rootScope) ->
    $scope.settings = window.settings

    if window.tree?
        $scope.tree = window.tree
    else $scope.tree = []
    if window.tree_open?
        $scope.tree_open = window.tree_open
    else $scope.tree_open = []
    if window.tree_children_button?
        $scope.tree_children_button = window.tree_children_button
    else $scope.tree_children_button = {}

    $scope.$watch "tree", ->
        window.tree = $scope.tree
        for element in $scope.tree
            $scope.showHideChildrenLabel(element)

    $scope.$watch "tree_open", ->
        window.tree_open = $scope.tree_open

    $scope.showChildren = (path) ->
        $http.get(window.settings.connection+"/0/children"+path)
            .success (data) ->
                for element in data
                    $scope.tree.push path+element
                    $scope.showHideChildrenLabel(path+element)
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
        $scope.showHideChildrenLabel(path)

    $scope.showHideChildrenLabel = (path) ->
        $http.get(window.settings.connection+"/0/children"+path+"/")
            .success (data) ->
                # console.log data
                if data.length != 0
                    if $scope.tree_open.indexOf(path) == -1
                        $scope.tree_children_button[path] = "plus"
                    else
                        $scope.tree_children_button[path] = "minus"
                else
                    $scope.tree_children_button[path] = ""
            .error ->
                $scope.tree_children_button[path] = ""

    $scope.removeNode = (node) ->
        if confirm "Really remove node '"+node+"'"
            $http.delete(window.settings.connection+"/0/node"+node+"/")
                .success ->
                    for element in $scope.tree
                        if element.indexOf(node) == 0
                            $scope.tree = $scope.tree.remove element
                            $scope.tree_open = $scope.tree_open.remove element

    $scope.addNode = (node) ->
        suffix = prompt "Name of new node"
        if not suffix
            return
        node = node + "/" + suffix
        $http({
            url: window.settings.connection+"/0/node"+node+"/",
            method: "PUT",
            data: JSON.stringify({"type": "persistent"}), # {type: "ephemeral"}
            headers: {'Content-Type': 'application/json'},
        })
            .success ->
                $scope.tree.push node
                $scope.tree.sort()
  
    $scope.nodeClick = () ->
        $rootScope.$broadcast 'closeEditMode'

    if $scope.tree.length == 0
        $scope.showChildren "/"
        $scope.showHideChildrenLabel("")

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

