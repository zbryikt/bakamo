# @servebase/pugutil


## mixins

 - `register-locals(name)`: convert server variable into a ldc module `viewlocals` for frontend access.
   - name: default `exports`. the server variable to convert.
   - generate a script tag which register a `viewlocals` ldc module, which can be used like:

         ldc.register(<[viewlocals]>, ({viewlocals}) -> ... )

mixin register-locals(name = "exports")
 - `meta(meta)`: generate meta tags for basic page information.
   - `meta` parameter should be an object with following fields:
     - `url`: url of this page.
     - `title`: title of this page.
     - `description`: description of this page.
     - `locale`: default `zh_TW`.
     - `type`: og type. default `website`
     - `favicon`: default `/favicon.ico`
     - `thumb`: thumb information. an object with following fields:
       - `url`: thumbnail url.
       - `type`: default `image/jpeg`
       - `width: default 1200
       - `height: default 630


## functions

A `ldui` object is provided with following member util functions:

 - `ellipsis(str, len)`: limit the length of given `str` to `len`, with `...` appended if str is too long.
   - `str`: string to handle
   - `len`: maximal length of the string. default `200`.


## License

MIT
