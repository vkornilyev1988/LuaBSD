#!/bin/lua
if system.ls("/lib/login.lib", true) then
	login = require 'login'
	login.main()
end