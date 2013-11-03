NodeController = ($scope, $routeParams, $location, $http, $timeout) ->
    if $location.search().connection
        window.settings.connection = $location.search().connection
        window.settings.wsConnection = window.settings.connection.replace(/^http(s|)/, 'ws') if window.settings.connection

    $scope.node = NodeStorage.get($location.search().path)

    if not $scope.node
        $scope.flashInfo = "Select node from list"

    # Hold the reference to Ace editor
    editor = ace.edit("editor")
    #editor.setReadOnly(true)
    editor.setTheme("ace/theme/twilight")

    $scope.$watch 'node.name', ->
        if not $scope.node
            return
        $scope.node.readOnly = true
        editor.setValue("")
        editor.setReadOnly(true)
        editor.setTheme("ace/theme/dawn")
        if $scope.node && $scope.node.name
            # Clear editor contents before trying to load new node contents
            $http.get(window.settings.connection + "/0/node" + $scope.node.name + "/")
                .success (data) ->
                    $scope.node.data = data
                    # Fallback data type is plain text
                    dataType = "json"
                    if data.constructor == String
                        dataType = "text"
                        tmpData = data
                    else
                        tmpData = JSON.stringify(data)

                    editor.getSession().setMode("ace/mode/" + dataType)
                    editor.setValue(tmpData)
                .error () ->
                    $scope.flashError = "failed to load data for node '" + $scope.node.name + "'"

    $scope.edit = ->
        $scope.node.readOnly = false
        editor.setReadOnly(false)
        editor.setTheme("ace/theme/twilight")

    $scope.save = ->
        nodeData = editor.getValue()
        $http({
            url: window.settings.connection + "/0/node" + $scope.node.name + "/",
            method: "POST",
            data: nodeData,
            headers: {
                'X-Zoo-Original-Version': '-1',
            },
        })
            .success () ->
                $scope.flashSuccess = 'Node data saved'
                $timeout ->
                    $scope.flashSuccess = null
                , 5000
            .error (data, status) ->
                switch status
                    when 409 then $scope.flashInfo = 'Bad version'
                    when 404 then $scope.flashError = "Node '" + $scope.node.name + "' does not exist."

    $scope.save_exit = ->
        $scope.node.readOnly = true
        editor.setReadOnly(true)
        editor.setTheme("ace/theme/dawn")
        $scope.save()