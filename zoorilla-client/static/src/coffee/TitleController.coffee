TitleController = ($scope, $location) ->
    $scope.settings = window.settings

    $scope.server = $scope.settings.connection.replace /^http(s|):\/\//, ''