NodeController = ($scope, $routeParams, $http, $timeout) ->
    $scope.node = {}
    $scope.node.name = $routeParams.path.replace(/---/g, "/")

    $scope.$watch 'node.name', ->
        if $scope.node && $scope.node.name
            $http.get(window.settings.connection + "/0/node" + $scope.node.name + "/")
                .success (data) ->
                    $scope.node.data = data
                .error () ->
                    $scope.node.data = "failed to load data for node '" + $scope.node.name + "'"

    $scope.edit = ->
        $scope.node.dataEdit = $scope.node.data

    $scope.save = ->
        $http.post(window.settings.connection + "/0/node" + $scope.node.name + "/", $scope.node.data)
            .success () ->
                $scope.flashSuccess = 'Node data saved'
                $timeout ->
                    $scope.flashSuccess = null
                , 5000
            .error (data, status) ->
                switch status
                    when 409 then $scope.flashInfo = 'Bad version'
                    when 404 then $scope.flashError = "Node '" + $scope.node.name + "' does not exist."
                    
