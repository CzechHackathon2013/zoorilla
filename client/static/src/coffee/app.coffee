main = angular.module 'main', []

conn = window.localStorage.getItem 'zoorilla_connection'
settings =
    connection: conn
    wsConnection: conn.replace(/^http/, 'ws')

main.config ($routeProvider) -> 
    $routeProvider
    .when("/settings", {
       templateUrl: "static/templates/settings.html",
       controller: SettingsController,
    })
    .when("/no-connection", {
       templateUrl: "static/templates/no-connection.html",
    })
    .when("/browse/:path", {
       templateUrl: "static/templates/view.html",
    })
    .otherwise {redirectTo: "/browse/"}


String.prototype.replaceslashes = (c) ->
    this.replace /\//g, c

Node.prototype.level = () ->
    if this.name == "/"
        return 0
    return this.path.length

isConnected = ->
    if not window.settings.connection
        window.location.hash = "#/no-connection"
