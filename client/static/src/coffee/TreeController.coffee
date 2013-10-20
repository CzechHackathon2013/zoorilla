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
