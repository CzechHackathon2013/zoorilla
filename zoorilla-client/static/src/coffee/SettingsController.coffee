SettingsController = ($scope, $routeParams, $http) ->
    $scope.routeParams = $routeParams

    $scope.tmpSettings = {}
    $scope.tmpSettings.connection = window.settings.connection

    $scope.save = ->
        $http.get($scope.tmpSettings.connection+"/0/zoorilla/")
            .success () ->
                window.settings = $scope.tmpSettings
                window.settings.wsConnection = window.settings.connection.replace(/^http(s|)/, 'ws') if window.settings.connection
                localStorage.setItem 'zoorilla_connection', window.settings.connection
                alert "Saved"
            .error () ->
                alert "No running Zoorilla server on '"+$scope.tmpSettings.connection+"'"

    $scope.reset = ->
        if confirm "Reset all settings?"
            window.settings = {}
            $scope.tmpSettings = {}
            localStorage.setItem 'zoorilla_connection', ""

            alert "Done"
