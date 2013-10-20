main = angular.module 'main', []
settings = 
    connection: window.localStorage.getItem 'zoorilla_connection'

main.config ($routeProvider) -> 
    $routeProvider
    .when("/settings", {
       templateUrl: "static/templates/settings.html",
       controller: SettingsController,
    })
    .when("/no-connection", {
       templateUrl: "static/templates/no-connection.html",
    })
    .when("/browse/:path", {
       templateUrl: "static/templates/view.html",
    })
    .otherwise {redirectTo: "/browse/"}


String.prototype.replaceslashes = (c) ->
    this.replace /\//g, c

isConnected = ->
    if not window.settings.connection
        window.location.hash = "#/no-connection"

TreeController = ($scope, $http, $rootScope) ->
    isConnected()

    $scope.settings = window.settings
    $scope.nodes = NodeStorage.nodes

    $scope.loadChildren = (node) ->
        $http.get(window.settings.connection+"/0/children"+node.name+"/")
            .success (data) ->
                for element in data
                    new Node(element.name, element.type)
                $scope.nodes = NodeStorage.nodes

    $scope.removeNode = (node) ->
        node.delete()
        $scope.nodes = NodeStorage.nodes

    $scope.addNode = (node) ->
        suffix = prompt "Name of new node"
        if not suffix
            return
        while true
            type = prompt "Node type [e/p]"
            if type in ["e", "p"]
                break
        typeFull = "ephemeral" if type == "e"
        typeFull = "persistent" if type == "p"
        # $http({
        #     url: window.settings.connection+"/0/node"+name+"/",
        #     method: "PUT",
        #     data: JSON.stringify({"type": "persistent"}),
        #     headers: {'Content-Type': 'application/json'},
        # })
        #     .success ->
        node.createChild(suffix, typeFull)
        $scope.nodes = NodeStorage.nodes
  
    $scope.nodeClick = () ->
        $rootScope.$broadcast 'closeEditMode'

    $scope.loadChildren "/"
    rootNode = new Node("/", "persistent")
    $scope.nodes = NodeStorage.nodes

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
                window.settings.connection = null

