exports.config =
  # See http://brunch.io/#documentation for docs.
  files:
    javascripts:
      joinTo: 'app.js'
    stylesheets:
      joinTo: 
        'app.css': /^app/
        'controller.css': /^app[\\/]controller/
    templates:
      joinTo: 'app.js'
