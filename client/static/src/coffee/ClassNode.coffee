Array.prototype.pop = (i) ->
    if i?
        return this.splice(i, 1)[0]
    return this.splice(this.length-1, 1)[0]

class NodeStorage
    constructor: () ->
        @nodes = []
        @lastId = 0
    
    push: (node) ->
        node.id = @lastId++
        @nodes.push node

    deleteById: (id) ->
        for i in [0..this.length-1]
            if this[i]? and this[i].id == id
                this.pop i

    get: (name) ->
        for node in @nodes
            if node.name == name
                return node

NodeStorage = new NodeStorage()

class Node
    constructor: (@name, @type, @data) ->
        @name = @name.substring(0, @name.length-1) if (@name.lastIndexOf("/") == @name.length-1)
        @name = "/" if not @name  # root node
        @path = @name.split("/").slice(1)
        @path = ["/"] if @name == "/"  # root node
        @children = []

        for node in NodeStorage.nodes
            if @.isChildOf(node)
                node.children.push @
        NodeStorage.push @

    isChildOf: (node) ->
    # Node.isChildOf(Node)   Child, Parrent
        for i in [0..node.path.length-1]
            if node.path[i] == "/"  # root node
                return true         # root node
            if @path[i] != node.path[i]
                return false
        return true

    delete: ->
        for child in @children
            NodeStorage.deleteById child.id
        NodeStorage.deleteById @id


# root = new Node("/")
# b = new Node("/b")
# a = new Node("/a")
# aa = new Node("/a/a")