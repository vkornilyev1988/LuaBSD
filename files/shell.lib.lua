#!/bin/lua
shell = {}
function shell:init()
df 			= require 'luabsd'.cmd.df
kldstat 	= require 'luabsd'.cmd.kldstat
ngctl 		= require 'luabsd'.cmd.ngctl
zfs 		= require 'luabsd'.cmd.zfs
cat			= require 'luabsd'.cmd.cat
env 		= require 'luabsd'.env
service		= require 'luabsd'.subr.service
term 		= require 'plterm'
ls 			= require 'system'.ls
poweroff	= require 'system'.shutdown
reboot 		= require 'system'.reboot
end

function shell:motd()
end

function shell:user()
pcall(term.color, 0)
end

shell:init()
shell:user()
