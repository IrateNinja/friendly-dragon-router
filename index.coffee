###

    Friendly Dragon Router

                    __                  __
                   ( _)                ( _)
                  / / \\              / /\_\_
                 / /   \\            / / | \ \
                / /     \\          / /  |\ \ \
               /  /   ,  \ ,       / /   /|  \ \
              /  /    |\_ /|      / /   / \   \_\
             /  /  |\/ _ '_| \   / /   /   \    \\
            |  /   |/  0 \0\    / |    |    \    \\
            |    |\|      \_\_ /  /    |     \    \\
            |  | |/    \.\ o\o)  /      \     |    \\
            \    |     /\\`v-v  /        |    |     \\
             | \/    /_| \\_|  /         |    | \    \\
             | |    /__/_     /   _____  |    |  \    \\
             \|    [__]  \_/  |_________  \   |   \    ()
              /    [___] (    \         \  |\ |   |   //
             |    [___]                  |\| \|   /  |/
            /|    [____]                  \  |/\ / / ||
           (  \   [____ /     ) _\      \  \    \| | ||
            \  \  [_____|    / /     __/    \   / / //
            |   \ [_____/   / /        \    |   \/ //
            |   /  '----|   /=\____   _/    |   / //
         __ /  /        |  /   ___/  _/\    \  | ||
        (/-(/-\)       /   \  (/\/\)/  |    /  | /
                      (/\/\)           /   /   //
                             _________/   /    /
                            \____________/    (

###
'use strict'

fs = require 'fs'
path = require 'path'
assert = require 'assert'

_ = require 'lodash'
debug = require 'debug'
logger = debug 'FD-Router'



resolvePath = (file) ->
	logger 'resolvePath %s', file

	if not file then return undefined
	if _.isArray file then file = path.join file
	return path.resolve file


findControllers = (file, controllers = []) ->
	logger 'findControllers %s %s', file, controllers

	# Bail if file isn't a string or doesn't exist
	if not _.isString file then return controllers
	assert.ok fs.existsSync(file), 'File not found: ' + file

	# Get file details and check if it is a directory
	stats = fs.statSync file; isDir = stats.isDirectory()

	# If it is not a directory and is a js/coffee file add to controllers
	# If it is a directory recursively scan all files and folders that match
	if not isDir and file.match /\.(js|coffee)$/i then controllers.push file
	else if isDir then scan(path.join(file, child), controllers) for child in fs.readdirSync(file)
	return controllers


loadRoute = (app, def) ->
	logger 'loadRoute %s %s', app, def

	assert.ok def.path, 'path is required'
	assert.ok _.isFunction(def.handler), 'handler is required'

	method = (def.method or 'get').toLowerCase()
	app[method] def.path, def.handler
	return


loadController = (app, controller) ->
	logger 'loadController %s %s', app, controller

	controllerFunc = require controller
	validController = (c) -> _.isFunction c and c.length is 1
	if validController controllerFunc then controller app
	return



isExpress = (app) -> app.handle and app.set



init = module.exports = (app) ->

	withRoutes = (settings = {}) ->

		if directory = settings.directory
			controllers = findControllers resolvePath directory
			loadController app, c for c in controllers

		if routes = settings.routes
			loadRoute route for route in routes


	withRoutes: withRoutes
