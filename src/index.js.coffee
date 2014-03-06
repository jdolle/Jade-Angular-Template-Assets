fs = require 'fs'
pathutil = require 'path'
uglify = require 'uglify-js'
Asset = require('asset-rack').Asset
jade = require 'jade'


walk = (dir, done) ->

  results = []
  fs.readdir dir, (err, list) ->
    done(err) if err

    pending = list.length

    return done(null, results) unless pending

    list.forEach (file) ->
      file = dir + '/' + file
      
      fs.stat file, (err, stat) ->
        if stat?.isDirectory()
          walk file, (err, res) ->
            results = results.concat(res)
            done(null, results) if not --pending
        else
          results.push(file)
          done(null, results) if not --pending


class exports.JadeAngularTemplatesAsset extends Asset
  mimetype: 'text/javascript'

  create: (options) ->
    options.dirname ?= options.directory # for backwards compatiblity
    @dirname = pathutil.resolve options.dirname
    @toWatch = @dirname
    @compress = options.compress or false

    # walk through and collect all files
    walk @dirname, (err, files) =>
      console.log err if err

      # files = fs.readdirSync @dirname
      templates = []

      jadeOptions =
        compileDebug: options.debug || false
        pretty: options.pretty || false

      for file in files when file.match(/\.jade$/)
        template = fs.readFileSync(file, 'utf8')
        template = jade.compile(template, jadeOptions)(options.locals || {})
          .replace(/\\/g, '\\\\')
          .replace(/\n/g, '\\n')
          .replace(/'/g, '\\\'')

        file = options.rename?(file)

        templates.push "$templateCache.put('#{file}', [200, '#{template}', {}])"

      javascript = """
        (function(){
          var module = null;
          try {
            module = angular.module('#{options.module || "Templates"}')
          }
          catch (e) {
            module = angular.module('#{options.module || "Templates"}', [])
          }
          module.run(function($templateCache) {
            #{templates.join(';\n  ')}
          });
        })();
      """
      if options.compress is true
        @contents = uglify.minify(javascript, { fromString: true }).code
      else
        @contents = javascript
      @emit 'created'