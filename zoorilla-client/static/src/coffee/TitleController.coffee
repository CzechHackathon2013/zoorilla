TitleController = ($scope, $location) ->
    $scope.settings = window.settings

    $scope.server = $scope.settings.connection.replace /^http(s|):\/\//, ''

    $scope.path = $location.search().path
    $scope.$on 'onPathChange', () ->
        setTimeout () ->
            $scope.path = $location.search().path
            , 100