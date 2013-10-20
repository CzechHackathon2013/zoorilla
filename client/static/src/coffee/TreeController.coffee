TreeController = ($scope, $http, $rootScope) ->
    isConnected()

    $scope.settings = window.settings
    $scope.nodes = NodeStorage.nodes

    $scope.loadChildren = (name) ->
        if name == "/"
            name = "" 
            rootNode = new Node("/", "p")
        $http.get(window.settings.connection+"/0/children"+name+"/")
            .success (data) ->
                for element in data
                    new Node("/"+element.name, element.type, not element.leaf)
                $scope.nodes = NodeStorage.nodes

    $scope.removeNode = (node) ->
        node.delete()
        $scope.nodes = NodeStorage.nodes

    $scope.addNode = (node) ->
        suffix = prompt "Name of new node"
        if not suffix
            return
        name = node.name + "/" + suffix
        typeFull = "ephemeral" if type == "e"
        typeFull = "persistent" if type == "p"
        $http({
            url: window.settings.connection+"/0/node"+name+"/",
            method: "PUT",
            data: JSON.stringify({"type": typeFull}),
            headers: {'Content-Type': 'application/json'},
        })
            .success ->
                node.createChild(suffix, "p")
                $scope.nodes = NodeStorage.nodes
  
    $scope.nodeClick = () ->
        $rootScope.$broadcast 'closeEditMode'

    $scope.loadChildren "/"
    # rootNode = new Node("/", "persistent")
    $scope.nodes = NodeStorage.nodes
