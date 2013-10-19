NodeController = ($scope, $routeParams, $http, $timeout) ->
    $scope.node = {}
    $scope.node.name = $routeParams.path.replace(/---/g, "/")

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

    $scope.save = ->
        $http({
            url: window.settings.connection + "/0/node" + $scope.node.name + "/",
            method: "POST",
            data: $scope.node.data,
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
                    
