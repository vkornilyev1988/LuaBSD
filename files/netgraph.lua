#!/bin/lua
--luabsd.cfg.netgraph     Путь до файла netgraph
--luabsd.cfg.init.path    Путь до датасета zdata/cfg

run = {}
run.mountpoint = require 'luabsd'.cfg.init.path
run.cfg = require 'luabsd'.cfg
run.netgraph = require 'luabsd'.cmd.ngctl
run.dbpath = system.kenv_get("kcs.bdb.path") or "/db"
run.ngraph = {}
run.ipfw = {}
run.wait = require 'luabsd'.subr.wait.iface


function run.ngraph:load(dsname)

	print("Netgraph apply :",dsname)
	run.netgraph.load();
	if dsname then
		local ng_list = run.netgraph.list();
		for k,v in pairs(ng_list) do
			if v.type == 'vlan' then
				local mac = nil;
				for k1,v1 in pairs(v.hooks) do
					if v1.peertype == 'ether' then
						run.netgraph.msg(v1.peername, 'setpromisc', '1')
						run.netgraph.msg(v1.peername, 'setautosrc', '0')
						local ds = zfs.ds_list(dsname, {'net:ifconfig_'..v1.peername..'_mac'});
						mac = ds[dsname]['net:ifconfig_'..v1.peername..'_mac'];
					elseif v1.peertype == 'eiface' and v1.peername == 'br0' then
						local ds = zfs.ds_list(dsname, {'net:ifconfig_'..v1.peername..'_mac'});
						mac = ds[dsname]['net:ifconfig_'..v1.peername..'_mac'];
					end
				end
				if mac then
					for k1,v1 in pairs(v.hooks) do
						if v1.peertype == 'eiface' then
							ifnet.setmac(v1.peername, mac);
						end
					end
				end
			end
		end
	end
end



function run:main()
	run.cfg:load()
	local data, k, el = bdb.get_all('ngraph', run.dbpath), nil,nil
	if data then
		for k, el in pairs(data) do 
			if el.type == 'ether' then
				run.wait(el.name, 20)
			end
		end
	end
	run.ngraph:load(run.mountpoint)
end
return run