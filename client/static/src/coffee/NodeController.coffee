NodeController = ($scope, $routeParams, $http, $timeout) ->
    $scope.$watch 'node.name', ->
        if $scope.node && $scope.node.name
            $http.get(window.settings.connection + "/0/node/" + $scope.node.name + "/")
                .success (data) ->
                    $scope.node.data = data
                .error () ->
                    $scope.node.data = "failed to load data for node '" + $scope.node.name + "'"
    $scope.save = ->
        $http.post(window.settings.connection + "/0/node/" + $scope.node.name + "/", $scope.node.data)
            .success () ->
                $scope.flashSuccess = 'Node data saved'
                $timeout ->
                    $scope.flashSuccess = null
                , 5000
            .error (data, status) ->
                status
                    .when(409, $scope.flashInfo = 'Bad version')
                    .when(404, $scope.flashError = "Node '" + $scope.node.name + "' does not exist.")
                    
