# @servebase/discuss

## Frontend Usage

You can use `@plotdb/block` to load `@servebase/discuss`:

    manager.from {name: "@servebase/discuss"}, {root: document.body, data: data} .then -> ...

where `data` is an object with following fields:

 - `host`: an object providing host api including:
   - `avatar(obj)`: return URL to the avatar for the given comment data object `obj` (see `Comment Object` below).

Alternatively, you can overwrite this block's DOM or even build a block from scratch by calling `discuss` constructor directly. See `src/block.ls` for more information.


## Backend Usage


import `@servebase/discuss` and initialize `discuss` backend API by following code:

    require! <[@servebase/discuss]>
    (backend) <- (->module.exports = it)  _
    discuss {backend, route: route, api: api}

`@servebase/discuss` will route its APIs through `api` of the given `route` object (aka through `route.api`), or leave this job to you if `route` is omitted.

Additionally, `api` is an customizable object containing API extensions for discuss to call, including:

 - `role({users})`: return a Promise resolving with a hash mapping from user key to a list string for its corresponding roles.


## Comment Object

a comment object contains following fields:

 - `owner`: user id for who create this comment.
 - `_user`: user object containing `key` and `displayname` corresponding to `owner` above.
 - `content`: an object with following fields:
   - `body`: actual content string corresponding to this comment
   - `config`: comment config object with following fields:
     - `renderer`: decide how this comment should be rendered. either empty or `markdown`.


## ldview Structure
 
 - `comments`
   - `no-comment`
   - `comment`
     - `avatar`
     - `author`
     - `role`
     - `date`
     - `content`
 - `discuss`
 - `edit`
   - `avatar`
   - `input`
   - `preview`
   - `submit` 
   - `use-markdown`
     - `check`
     - `label`
   - `if-markdown`
   - `toggle-preview`
     - `check`
     - `label`
