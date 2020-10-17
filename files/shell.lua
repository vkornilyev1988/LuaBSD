#!/bin/lua
shell = {}
function shell:init()
df 			= require 'luabsd'.cmd.df
kldstat 	= require 'luabsd'.cmd.kldstat
kldload		= require 'system'.kldload
kldunload   = require 'system'.kldunload
ngctl 		= require 'luabsd'.cmd.ngctl
zfs 		= require 'luabsd'.cmd.zfs
cat			= require 'luabsd'.cmd.cat
env 		= require 'luabsd'.env
service		= require 'luabsd'.subr.service
term 		= require 'plterm'
ls 			= require 'system'.ls
poweroff	= require 'system'.shutdown
reboot 		= require 'system'.reboot
cat 		= require 'luabsd'.cmd.cat
ip 			= require 'luabsd'.cmd.ip
help 		= require 'luabsd'.cmd.help
ps 			= require 'system'.ps
lano		= require 'luabsd'.cmd.lano
cd 			= require 'luabsd'.cmd.cd
cfg 		= require 'luabsd'.cfg
rm 			= require 'system'.rm
mkdir 		= require 'system'.mkdir
ping 		= require 'luabsd'.cmd.ping
exec 		= require 'luabsd'.cmd.exec
run 		= require 'luabsd'.cmd.run
clear		= require 'luabsd'.cmd.clear
ipfw 		= require 'luabsd'.cmd.ipfw
uname 		= require 'luabsd'.cmd.uname
hostname 	= require 'luabsd'.cmd.hostname
--[[---------------------------------------]]
env:read()
end

function shell:user()
	local enviroms = posix.stdlib.getenv()
	if type(enviroms) == "table" and arg[1] == "session" and enviroms.USER_SESSION and enviroms.USER_SESSION == arg[2] then
		system.cmd("lua -i "..arg[0].." init");
	else
		return posix.errno.EACCES
	end
	enviroms = nil
end

if arg[1] == "init" then shell:init(); else shell:user(); end


