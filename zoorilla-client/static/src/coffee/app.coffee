main = angular.module 'main', []

connection = window.localStorage.getItem 'zoorilla_connection'
settings =
    connection: connection
    wsConnection: connection.replace(/^http(s|)/, 'ws') if connection

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
       templateUrl: "static/templates/browse.html",
    })
    .otherwise {redirectTo: "/browse/"}


String.prototype.replaceslashes = (c) ->
    this.replace /\//g, c

Node.prototype.level = () ->
    if this.name == "/"
        return 0
    return this.path.length

Node.prototype.logState = () ->
    [this.hasChildren(), this.children.length]

Node.prototype.iconSuffix = () ->
    if this.hasChildren()
        if this.children.length != 0
            return "minus"
        return "plus"
    return ""

Node.prototype.deleteChildren = () ->
    for node in this.children
        node.delete()
    this.children = []

Array.prototype.sortNodes = () ->
    this.sort (a, b) ->
        if (a.name < b.name)
            return -1
        if (a.name > b.name)
            return 1
        return 0

isConnected = ->
    if not window.settings.connection
        window.location.hash = "#/no-connection"
