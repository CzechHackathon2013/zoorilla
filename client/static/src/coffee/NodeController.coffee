NodeController = ($scope, $routeParams, $http, $timeout) ->
    $scope.node = {}
    $scope.node.name = $routeParams.path.replace(/---/g, "/")

    # Hold the reference to Ace editor
    editor = null

    $scope.$on 'closeEditMode', () ->
        $scope.node.dataEdit = null

    $scope.$watch 'node.name', ->
        if $scope.node && $scope.node.name
            $http.get(window.settings.connection + "/0/node" + $scope.node.name + "/")
                .success (data) ->
                    $scope.node.data = data
                .error () ->
                    $scope.flashError = "failed to load data for node '" + $scope.node.name + "'"

    $scope.edit = ->
        $scope.node.dataEdit = $scope.node.data
        editor = ace.edit("editor")
        editor.setTheme("ace/theme/twilight")

        # Fallback data type is plain text
        dataType = "text"
        try
            tmp = JSON.parse $scope.node.dataEdit
            # If we got here, we have valid JSON
            dataType = "json"
        catch error
            # We don't care

        editor.getSession().setMode("ace/mode/" + dataType)

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
                    
