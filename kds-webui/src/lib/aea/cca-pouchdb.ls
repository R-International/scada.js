require! 'prelude-ls': {join}

PouchDB = require \pouchdb
    ..plugin require \pouchdb-authentication
    #..plugin require \pouchdb-adapter-node-websql

export PouchDB

console.log "PouchDB adapters: ", PouchDB.adapters

export signup = (db, user, callback) ->
    require! \crypto

    salt = crypto.randomBytes(16).toString('hex')
    hash = crypto.createHash('sha1')
    hash.update(user.passwd + salt)
    password-sha = hash.digest('hex')

    new-user =
        _id: "org.couchdb.user:#{user.name}"
        name: user.name
        roles: user.roles or []
        type: \user
        password_sha: password-sha
        salt: salt

    err, res <- db.put new-user
    callback err, res if typeof! callback is \Function

# check whether we are logged in or not
export function check-login (db, callback)
    session-db = db._db_name.split '/'
        ..[session-db.length - 1] = '_session'

    session-url = join "/" session-db
    console.log "Checking sessoni with url: ", session-url
    $.ajax do
        type: \GET
        url: session-url
        xhrFields: {+withCredentials}
        headers:
            'Content-Type':'application/x-www-form-urlencoded'
        success: (data) ->
            try
                res = JSON.parse data
                throw "not logged in..." if res.user-ctx.name is null
                console.log "We are already logged in as ", res.user-ctx.name
                callback false if typeof! callback is \Function
            catch
                console.log "Check login not succeeded: ", e?.to-string!
                callback true if typeof! callback is \Function

        error: (err) ->
            console.log "Something went wrong while checking logged in state: ", err
            callback true if typeof! callback is \Function


export function make-design-doc (obj)
    # convert functions to strings in design docs
    for p of obj
        try
            throw if typeof! obj[p] isnt \Object
            obj[p] = make-design-doc obj[p]
        catch
            if typeof! obj[p] is \Function
                    obj[p] = '' + obj[p]
    obj


/*
x =
    a: 1
    b: 2
    c:
        d: -> \naber

console.log "make design doc: ", make-design-doc x
*/