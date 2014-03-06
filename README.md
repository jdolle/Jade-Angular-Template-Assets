Jade-Angular-Template-Assets
============================

Use Jade for Angular Templates in Asset Rack!

## Usage

```
jadeTemplates = require('jade-angular-templates');

var assets = [
  new jadeTemplates.JadeAngularTemplatesAsset({
    url: '/scripts/templates.js',
    module: 'ModuleTemplates',
    dirname: 'src/templates',
    locals: {},
    rename: function(name) {
      path.basename(name, '.jade')
    },
    debug: false,
    pretty: false
  })
];

app.use(new rack.Rack(assets))
```