TreeController = ($scope, $http, $rootScope) ->
    isConnected()

    $scope.settings = window.settings
    $scope.nodes = NodeStorage.nodes

    $scope.loadChildren = (name) ->
        if name == "/"
            name = "" 

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

    $scope.showHideChildren = (node) ->
        if node.hasChildrens
            node.deleteChildren()
        else
            $scope.loadChildren(node.name)
        $scope.nodes = NodeStorage.nodes

    $scope.loadChildren "/"
    # rootNode = new Node("/", "persistent")
    $scope.nodes = NodeStorage.nodes

    ws = new WebSocket(window.settings.wsConnection+"/0/notify/")

    ws.onerror = (event) ->
        console.log(event)

    ws.onmessage = (event) ->
        console.log(event)
        data = JSON.parse(event.data)
        $scope.$apply (scope) ->
            path = data.path
            if path.charAt(path.length - 1) != '/'
                path = path + '/'
            
            if data.add
                element = data.add
                new Node(path+element.name, element.type, not element.leaf)
                
            if data.delete
                node = new Node(path+data.delete)
                node.delete()

            $scope.nodes = NodeStorage.nodes


    ws.onopen = (event) ->
        tmp =
            watch: 'true'
            path: '/'
            type: 'CHILDREN'
        ws.send(JSON.stringify(tmp))

    ws.onclose = (event) ->
        console.log(event)
