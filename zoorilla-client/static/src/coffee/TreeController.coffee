TreeController = ($scope, $http, $rootScope) ->
    isConnected()

    $scope.settings = window.settings
    $scope.nodes = NodeStorage.nodes

    $scope.loadChildren = (name) ->
        if name == "/"
            name = ""
        $http.get(window.settings.connection+"/0/children"+name+"/")
            .success (data) ->
                if name == ""
                    name = "/"
                node = NodeStorage.get(name)
                for element in data
                    node.createChild(element.name, element.type, not element.leaf)
                $scope.nodes = NodeStorage.nodes

    $scope.removeNode = (node) ->
        node.delete()
        $scope.nodes = NodeStorage.nodes

    $scope.addNode = (node) ->
        suffix = prompt "Name of new node"
        if not suffix
            return
        name = node.name + "/" + suffix
        name = "/" + suffix if node.name == "/"
        $http({
            url: window.settings.connection+"/0/node"+name+"/",
            method: "PUT",
            data: JSON.stringify({"type": "persistent"}),
            headers: {'Content-Type': 'application/json'},
        })
            .success ->
                node.createChild(suffix, "p")
                node.isOpen = false
                $scope.nodes = NodeStorage.nodes
  
    $scope.nodeClick = () ->
        $rootScope.$broadcast 'closeEditMode'

    $scope.showHideChildren = (node) ->
        node = NodeStorage.get(node.name)
        if node.isOpen
            node.deleteChildren()
            node.isOpen = false
        else
            $scope.loadChildren(node.name)
            node.isOpen = true
        $scope.nodes = NodeStorage.nodes

    # $scope.loadChildren "/"
    rootNode = new Node("/", "persistent", true)
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
