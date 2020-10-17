#!/bin/lua
function dhclient(t_iface,t_path)
local runfile = t_path or "/bin/dhcpcd"
	if t_iface and runfile then
		system.execv_nowait(runfile, t_iface)
	end
runfile, t_iface = nil,nil;
end
return dhclient
