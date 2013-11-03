TreeController = ($scope, $http, $rootScope) ->
    isConnected()

    $scope.settings = window.settings
    $scope.nodes = NodeStorage.nodes
    $scope.nodes.sortNodes()


    $scope.loadChildren = (name) ->
        if name == "/"
            name = ""
        $http.get(window.settings.connection+"/0/children"+name+"/")
            .success (data) ->
                if name == ""
                    name = "/"
                node = NodeStorage.get(name)
                tree_watch "true", node.name, "CHILDREN"
                for element in data
                    node.createChild(element.name, element.type, not element.leaf)
                $scope.nodes = NodeStorage.nodes
                $scope.nodes.sortNodes()

    $scope.removeNode = (node) ->
        if not confirm "Really remove node '" + node.name + "'"
            return
        node.name = "" if node.name == "/"
        $http.delete(window.settings.connection+"/0/node"+node.name+"/")
            .success ->
                node.delete()
                $scope.nodes = NodeStorage.nodes
                $scope.nodes.sortNodes()

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
                $scope.nodes.sortNodes()
                tree_watch "true", node.name, "CHILDREN"
  
    $scope.nodeClick = () ->
        $rootScope.$broadcast 'closeEditMode'
        $rootScope.$broadcast 'onPathChange'

    $scope.showHideChildren = (node) ->
        node = NodeStorage.get(node.name)
        if node.isOpen
            node.deleteChildren()
            node.isOpen = false
            tree_watch 'false', node.name, "CHILDREN"
        else
            $scope.loadChildren(node.name)
            node.isOpen = true
            tree_watch 'true', node.name, "CHILDREN"
        $scope.nodes = NodeStorage.nodes
        $scope.nodes.sortNodes()

    # $scope.loadChildren "/"
    rootNode = new Node("/", "persistent", true)
    $scope.nodes = NodeStorage.nodes
    $scope.nodes.sortNodes()

    ws = new WebSocket(window.settings.wsConnection+"/0/notify/")

    ws.onerror = (event) ->
        console.log(event)

    ws.onmessage = (event) ->
        console.log(event)
        data = JSON.parse(event.data)
        $scope.$apply (scope) ->
            console.log data
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
            $scope.nodes.sortNodes()

    tree_watch = (watch, path, type) ->
        console.log  path
        ws.send JSON.stringify {
            watch: watch
            path: path
            type: type
        }

    ws.onopen = (event) ->
        console.log event

    ws.onclose = (event) ->
        console.log(event)
