SettingsController = ($scope, $routeParams, $http) ->
    $scope.routeParams = $routeParams
    $scope.settings = window.settings

    $scope.save = ->
        $http.get(window.settings.connection+"/0/zoorilla/")
            .success () ->
                window.settings = $scope.settings
                localStorage.setItem 'zoorilla_connection', $scope.settings.connection
                alert "Saved"
            .error () ->
                alert "No running Zoorilla server on '"+$scope.settings.connection+"'"

    $scope.reset = ->
        if confirm "Reset all settings?"
            window.settings = {}
            $scope.settings = {}
            localStorage.setItem 'zoorilla_connection', ""

            alert "Done"
