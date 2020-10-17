#!/bin/lua

--[[                                   
	-- THIS MODULE TO INIT LUABSD INIT
	-- FIFE STAGES:
	----1.1] KENV/SYSCTL - LOAD PARAMS SYSTEM INIT							[]
	----1.2] LOAD RC SUBR PARAMS  											[ZFS/FS]:<name zpool>/<zfs dataset name>:rc.json:rc.conf	
	----1.3] LOAD MODULES          											
	----2.1] READ MOUNT LIST FILE SYSTEMS
	----2.1] MOUNT FILE SYSTEMS AND BLOCK DEVICES 							[/ROOTFS/TMPFS/PSEUDE FS]
	----3.1] SET IPV4/IPV6 AND OTHER PARAMS RC 
	----3.2] START DAEMONS

	|| SUBR FUNCTIONS IN TABLES luansd.subr

	PARAMS AVALABLE:
		local luabsd 	 = {}       																--	 			table : novar	:	global init table         										**  	Глобальная таблица                
		luabsd.env   	 = {}																		--   -> 		table : novar	:	kernel enviroments												*** 	Подтаблица инвироментов ядра
		luabsd.env.init	 = {}               	  						    		 		    	--   --> 		table : novar	:	init params                            							**** 	Подтаблица инвироментов ядра при инициализации системы
			luabsd.env.init.type 											= "hvm.cfg.type" 		--   --->   	string: value	:	default key														*****   Значение по умолчанию ключа [ тип источника данных для инициализации     ] 		Возвращаемые параметры:-строго----: json|fbsd|zfs|bdb
			luabsd.env.init.fstype 											= "hvm.cfg.fstype" 		--   --->   	string: value	:	default key	                            						*****   Значение по умолчанию ключа [ тип файловой систмы хранилища настроек     ] 		Возвращаемые параметры:-строго----: zfs|ufs|cdrom
			luabsd.env.init.fsdev   										= "hvm.cfg.fsdev"       --   --->   	string: value	:	default key	 													*****   Значение по умолчанию ключа [ путь устройства для монтирования cfg       ] 		Возвращаемые параметры:-переменно-: zrootfs/cfg0|/dev/gpt/LUABSDCFG
			luabsd.env.init.fspoint 										= "hvm.cfg.fspoint"     --   --->   	string: value	:	default key	                          						  	*****   Значение по умолчанию ключа [ путь точки монтирования хранилища настроек ] 		Возвращаемые параметры:-переменно-: zrootfs/cfg0|/dev/gpt/LUABSDCFG
		luabsd.cfg  	 = {}																		--   -> 		table : novar	:	cfg params                             						  	****    Подтаблица переменных полученныъ настроек
			luabsd.cfg.init.type        									= "json"                --   --->   	string: value	:	json/fbsd/zfs
			luabsd.cfg.init.path        									= "/etc/rc.json"		--   --->   	string: value	:	rc.conf|rc.conf|zroot/cfg
			luabsd.cfg.init.point 	    									= "/cfg" 				--   ---> 		string: value	:	/cfg
			luabsd.cfg.autoifname 	    									= "net1" 				--   ---> 		string: value	:	net1|net1 lua2
			luabsd.cfg.ifaces 												= table 				--   ---> 		table :	novar	:	params ifaces
				luabsd.cfg.ifaces.[<name iface>] 							= table 				--	 ---->		table : key 	:   name iface
					luabsd.cfg.ifaces.[<name iface>.ip 		 				= table 				--	 ----->		table : key 	:   ip params
						luabsd.cfg.ifaces.[<name iface>].ip[num] 			= table 				--	 ------>	table : numeric :	number ip global or aliases
							luabsd.cfg.ifaces.[<name iface>].ip[num].addr 	= "6.6.6.220" 			--	 -------> 	string: value 	: 	ip address
							luabsd.cfg.ifaces.[<name iface>].ip[num].mask 	= "255.255.255.0" 		--	 -------> 	string: value 	: 	netmask
							luabsd.cfg.ifaces.[<name iface>].ip[num].proto 	= "4" 					--	 -------> 	string: value 	: 	protocol 4 or 6
					luabsd.cfg.ifaces.[<name iface>.enable 					= "enable" 				--   ----->     string: value   :   enable or disable iface
					luabsd.cfg.ifaces.[<name iface>.type 					= "1" 					--   ----->     string: value   :   type lan or nglan or tun/tap
					luabsd.cfg.ifaces.[<name iface>.name 					= "net0" 				--   ----->     string: value   :   rename phy card to psevdo tap0 -> net0
					luabsd.cfg.ifaces.[<name iface>.create 					= "tap0" 				--   ----->     string: value   :   create if not in system iface type tap/tun ...
					luabsd.cfg.ifaces.[<name iface>.mac 					= "00:bd:d7:f5:05:00" 	--   ----->     string: value   :   mac-address
			luabsd.cfg.hostname         									= "Luabsd" 				--	 --->   	string: value	: 	hostname 							   
			luabsd.cfg.kldlist          									= "netgraph ng_bpf"		--	 --->		string: list 	: 
			luabsd.cfg.kldlistparallel  									= "if_re if_tap" 		--   ---> 		string: list 	: 	if_<etehr>
			luabsd.cfg.services         									= "ews shellinablx"     --   ---> 		string: list 	: 	<kernel modules> 
				luabsd.cfg.services[num] 									= "table" 				--   ----> 		table : numeric :   element from massive services params
					luabsd.cfg.services[num].name 							= "shellinabox" 		--   -----> 	string: value   :   Name service 			[_*_]
					luabsd.cfg.services[num].type 							= "BSD" 				--   -----> 	string: value   :   Type service 			[_*_]  BSD/LUA
					luabsd.cfg.services[num].comment						= " Shell In A Box" 	--   -----> 	string: value   :   Comment service 		[___] 
					luabsd.cfg.services[num].args 							= "-p 4500 -c" 			--   -----> 	string: value   :   argumets service 		[___]
					luabsd.cfg.services[num].command 						= "/bin/shellinaboxd" 	--   -----> 	string: value   :   Program path to run 	[_*_]
					luabsd.cfg.services[num].enable 						= "true"		 		--   -----> 	string: value   :   Enable/Disable service  [_*_]
					luabsd.cfg.services[num].nopid 							= "false" 		 		--   -----> 	string: value   :   Create pid disable      [___]  true/false/no key
					luabsd.cfg.services[num].stop 							= "/bin/ews stop -P " 	--   -----> 	string: value   :   Stop params service     [___]  value or no key 
			luabsd.cfg.netgraph	 											= "/lib/netgraph.lua"   --   --->       string: value   :   start program or script nergraph rules
			luabsd.cfg.route 												= "table" 				--   --->       table : value   :   route table params
				luabsd.cfg.route[str] 										= "table"               --   ---->      table : value   :   fib number 0|1|2.. 
					luabsd.cfg.route[str].gw 								= "table"               --   ----->     table : value   :   default routes params
						luabsd.cfg.route[str].enable						= "enable" 				--   ------>    string: value	:	enable/disable this fib and route
						luabsd.cfg.route[str].ip4							= "6.6.6.222" 			--   ------>    string: value	:	ip address default route
					luabsd.cfg.route[str].st 								= "table"               --   ----->     table : value   :   static routes params
						luabsd.cfg.route[str].st[num] 						= "table" 				--   ------>    table : numeric	:	number static route
						luabsd.cfg.route[str].st[num].enable				= "enable" 				--   ------->   string: value	:	enable/disable this static route
						luabsd.cfg.route[str].st[num].type					= "0" 					--   ------->   string: value	:	type static route 0 - network/ 1 - host
						luabsd.cfg.route[str].st[num].dest 					= "11.11.11.0/24"		--   ------->   string: value	:	destination route [ if type 0 : <ip/mask> ex: 7.7.7.0/24 or type 1 <ip> 7.7.7.7 ]
						luabsd.cfg.route[str].st[num].addr 					= "6.6.6.222"			--   ------->   string: value	:	ip address gateway host
						luabsd.cfg.route[str].st[num].proto 				= "4"					--   ------->   string: value	:	type proto 4 or 6 default 4
		luabsd.subr  	 = {}                           											

TODO
	mac addresses
	routes

]]--


local luabsd 	 = {}
luabsd.env    	 = {}
luabsd.cfg   	 = {}
luabsd.subr 	 = {}

luabsd.env.init  = {}
luabsd.cfg.init  = {}

--[[ DEFAULT PARAMS]]--
luabsd.env.init.type 	= "hvm.cfg.type" 							
luabsd.env.init.fstype 	= "hvm.cfg.fstype"
luabsd.env.init.fsdev   = "hvm.cfg.fsdev"
luabsd.env.init.fspoint = "hvm.cfg.fspoint"
luabsd.cfg.init.type 	= "json"
luabsd.cfg.init.dir		= "/etc"
luabsd.cfg.init.path 	= "/etc/rc.json"
luabsd.cfg.init.fstype	= "ufs"
luabsd.cfg.init.fspoint = "/cfg"
luabsd.cfg.init.fsdev   = "/dev/gpt/LUABSDCFG"
luabsd.cfg.services     = {}
luabsd.cfg.dir 		 	= {}
luabsd.cfg.dir.tmp   	= "/tmp"
luabsd.cfg.dir.run   	= "/tmp/run"


luabsd.subr.file 	  	= {}
luabsd.subr.kern 	  	= {}
luabsd.subr.kld 	  	= {}
luabsd.subr.service   	= {}
luabsd.subr.ifnetd    	= {}
luabsd.subr.routed		= {}
luabsd.subr.fs 		  	= {}
luabsd.cmd 				= {}
--[[ boot stage one        ]]--
-- Read enviroments from kernel
function luabsd.env:read()
	if system.kenv_get(luabsd.env.init.type) then luabsd.cfg.init.type = system.kenv_get(luabsd.env.init.type)  end 
	if system.kenv_get(luabsd.env.init.fstype) then luabsd.cfg.init.fstype = system.kenv_get(luabsd.env.init.fstype)  end 
	if system.kenv_get("hvm.cfg."..luabsd.cfg.init.type..".path") then luabsd.cfg.init.path = system.kenv_get("hvm.cfg."..luabsd.cfg.init.type..".path") end
	if system.kenv_get(luabsd.env.init.fsdev) then luabsd.cfg.init.fsdev = system.kenv_get(luabsd.env.init.fsdev) end 
	if system.kenv_get(luabsd.env.init.fspoint) then luabsd.cfg.init.fsdev = system.kenv_get(luabsd.env.init.fspoint) end 
end
-- Save enviroments in kernel
function luabsd.env:save()
end



function luabsd.subr.file:read(handler)
    local file = {}-- r read mode and b binary mode
           file.path = io.open(handler, "rb")
    if file.path then
  	    	file.data = file.path:read "*a" -- *a or *all reads the whole file
    	file.path:close()
    end
    return file.data
end

function luabsd.subr.kld:load(kldlist, parallel)
	local modprob
	if parallel == true then
		for modprob in string.gmatch(kldlist, "[^%s]+") do
			system.fork(system.kldload, modprob)
		end
	else
		for modprob in string.gmatch(kldlist, "[^%s]+") do
		    pcall(system.kldload, modprob)
		end
	end
	modprob = nil
end



function luabsd.subr.service:start(list)
	if luabsd.cfg.loaded ~= true then luabsd.cfg:load() end
		local unit, unitname = {} 

		if list then
			for unitname in string.gmatch(list, "[^%s]+") do
				unit.count = 0
				while luabsd.cfg.services[unit.count].name do
					if luabsd.cfg.services[unit.count].name == unitname then
						if luabsd.cfg.services[unit.count].name == true then
							if luabsd.cfg.services[unit.count].comment then
								io.write("Starting service... : ", luabsd.cfg.services[unit.count].comment, " ")
								io.flush()
							else
								io.write("Starting service... : ", unitname, " ")
								io.flush()
							end
									if 	luabsd.cfg.services[unit.count].type == string.lower("bsd") then
										function startservice(named, argsd)
												if 	luabsd.cfg.services[unit.count].before then
													while system.ls(luabsd.cfg.dir.run.."/"..luabsd.cfg.services[unit.count].before..".pid", true) == nil do
														posix.unistd.sleep(2)
													end
												end
												if argsd then
													unit.pid=system.execv_nowait(named. argsd)
												else
													unit.pid=system.execv_nowait(named)
												end
										end
										system.fork(startservice, luabsd.cfg.services[unit.count].command, luabsd.cfg.services[unit.count].args)

									end
							print("[ OK ]")
						end
					end
					if unit.pid then
						if system.ls(luabsd.cfg.dir.run) == nil then system.mkdir(luabsd.cfg.dir.run,nil,true) end
						if luabsd.cfg.services[unit.count].nopidfile ~= true then
							unit.pidfile = io.open(luabsd.cfg.dir.run.."/"..unitname..".pid", "w")
							unit.pidfile:write(unit.pid)
							unit.pidfile:close()
						end
					end

					unit.count = unit.count + 1

				end
				unit.count = nil
			end
		end
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end

function luabsd.subr.service:stop(list)
	if luabsd.cfg.loaded ~= true then luabsd.cfg:load() end
		local unitname, k, v
		if list then
			for unitname in string.gmatch(list, "[^%s]+") do
				if system.ls(luabsd.cfg.dir.run.."/"..unitname..".pid", true) then 
					io.write("Stoping service... : ", unitname)
					io.flush()
					for k,v in poris(luabsd.cfg.services) do 
						if v.name == unitname then 
							if v.stop then 
								system.cmd(v.stop)
							else
							system.kill(luabsd.subr.file:read(luabsd.cfg.dir.run.."/"..unitname..".pid")); system.rm(luabsd.subr.file:read(luabsd.cfg.dir.run.."/"..unitname..".pid")) 
							end
						end
					end
					print("[ OK ]")
				else
					print("Service already stoped")
				end
			end

		end
		unitname, k, v = nil, nil, nil
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end

function luabsd.subr.service:list(list)
	-- local k,v
	-- if luabsd.cfg.services then
	-- 	for k,v in pairs(luabsd.cfg.service) do 
	-- 		if luabsd.cfg.service[v] then print(luabsd.cfg.services[v])
	-- k,v = nil, nil
end

function luabsd.subr.service:restart(list)
	local unitname
	for unitname in string.gmatch(list, "[^%s]+") do
		luabsd.subr.service:stop(unitname)
		posix.unistd.sleep(1)
		luabsd.subr.service:stop(startname)
	end
end

function luabsd.subr.ifnetd:start()
	if luabsd.cfg.loaded ~= true  then luabsd.cfg:load() end
	if system.ls(luabsd.cfg.dir.run.."ifinetd.run", true) == nil then
	--[[ create ethernets only ]]
		if luabsd.cfg.ifaces then
			local iface
			 for iface in pairs(luabsd.cfg.ifaces) do 	
				if luabsd.cfg.ifaces[iface].enable == true then
					if luabsd.cfg.ifaces[iface].create then ifnet.create(iface) end
					if luabsd.cfg.ifaces[iface].name then ifnet.rename(iface, luabsd.cfg.ifaces[iface].name) end
				end
			 end
		end
		if luabsd.cfg.netgraph then
			if system.ls(luabsd.cfg.netgraph, true) ~= nil then
				pcall(dofile, luabsd.cfg.netgraph)
			end
		end
		if luabsd.cfg.ifaces then	 
			for iface in pairs(luabsd.cfg.ifaces) do 	
				if luabsd.cfg.ifaces[iface].enable == true then
					if luabsd.cfg.ifaces[iface].ip then 
					local count, ipcount = 0
						for ipcount in luabsd.cfg.ifaces[iface].ip[count] do
							if luabsd.cfg.ifaces[iface].ip[count].addr and luabsd.cfg.ifaces[iface].ip[count].proto and luabsd.cfg.ifaces[iface].ip[count].mask then ifnet.setip(iface,luabsd.cfg.ifaces[iface].ip[count].proto, luabsd.cfg.ifaces[iface].ip[count].addr, luabsd.cfg.ifaces[iface].ip[count].mask) ifnet.flags(iface, "up") end		
							count = count + 1
							if luabsd.cfg.ifaces[iface].ip[count] == nil then break end
						end
					end
					if luabsd.cfg.ifaces[iface].mac then ifnet.setmac(iface, luabsd.cfg.ifaces[iface].mac) end
				end
			end
		end
	end
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end

function luabsd.subr.routed:start()
	if luabsd.cfg.loaded ~= true  then luabsd.cfg:load() end
	local count,routed,k,v = 1
	if luabsd.cfg.route then
		for count, routed in pairs(luabsd.cfg.route) do 
			    if routed.gw.enable and routed.gw.ip4 then ifnet.route_add("4", routed.gw.ip4, count) elseif outed.gw.enable and routed.gw.ip6 then ifnet.route_add("6", routed.gw.ip4, count) end 
				if routed.st then for k,v in pairs(routed.st) do if v.enable then ifnet.route_add_static4(count,v.type, count,v.dest, count,v.addr, count) end end end
		end
	end
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end
function luabsd.subr.routed:stop()
	if luabsd.cfg.loaded ~= true  then luabsd.cfg:load() end
	local count,routed,k,v = 1
	if luabsd.cfg.route then
		for count, routed in pairs(luabsd.cfg.route) do 
				if routed.st then for k,v in pairs(routed.st) do if v.enable then ifnet.route_del_static4(count,v.type, count,v.dest, count,v.addr, count) end end end
			    if routed.gw.enable and routed.gw.ip4 then ifnet.route_del("4", routed.gw.ip4, count) elseif outed.gw.enable and routed.gw.ip6 then ifnet.route_add("6", routed.gw.ip4, count) end 
		end
	end
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end

function luabsd.subr.routed:restart()
luabsd.subr.routed:stop()
	posix.unistd.sleep(2)
luabsd.subr.routed:start()
end

function luabsd.subr.routed:show()
	local count,routed,k,v = 1
	if luabsd.cfg.route then
		for count, routed in pairs(luabsd.cfg.route) do 
			    if routed.gw.enable then print("fib default ip4: ","fib"..count,routed.gw.enable) end
				if routed.gw.ip4 then print("fib default ip4: ","fib"..count,routed.gw.ip4) end
				if routed.gw.ip6 then print("fib default ip6: ","fib"..count,routed.gw.ip6) end
				if routed.st then for k,v in pairs(routed.st) do print("fib static "..k.." status: ","fib"..count,v.enable) end end
				if routed.st then for k,v in pairs(routed.st) do print("fib static "..k.." dst ip: ","fib"..count,v.dest) end end
				if routed.st then for k,v in pairs(routed.st) do print("fib static "..k.." type : ","fib"..count,v.type) end end
				if routed.st then for k,v in pairs(routed.st) do print("fib static "..k.." ip4: ","fib"..count,v.addr) end end

		end
	end
end

--[[ CFG DEFAULT LOAD CONFIGURATIONS ]]--



function luabsd.cfg:default(type,path)
	local cfg, file = {}, {}
		file.default = "/etc/test.rc"
	if system.ls(file.default, true) then 
			  file.open = io.open(file.default, "rb")
			  file.data = cjson.decode(file.open:read("*a"))
			  file.open:close()
			  file.open = nil
			  for a,b in pairs(file.data) do print (a,b) end -- deffult_init.lua
	end
	cfg = nil
end


function luabsd.cfg.before()
	if luabsd.cfg.init.type == "zfs" then
		if luabsd.cfg.init.path then
			local ds=zfs.ds_list(luabsd.cfg.init.path, {'system:init'})
			if ds and ds[dsname]['system:init'] and ds[dsname]['system:init'] == 'true' then return nil end
		end
		return true 
	elseif luabsd.cfg.init.type == "json" then
		if system.ls(luabsd.cfg.init.path, true) then
			if cjson.decode(luabsd.subr.file:read(luabsd.cfg.init.path).init) == true then return nil end
			return true
		end
	end
end



function luabsd.cfg:checkpoint(point, pointtype)
	local count, unit = 1
	if pointtype == "dir" then
		for count, unit in pairs(system.mount()) do
			if unit.mountpoint == point then return true end
		end
	elseif pointtype == "dev" then
		for count,unit in pairs(system.mount()) do
			if unit.source == point then return true end
		end
	end
	count = nil
	return false
end


function luabsd.cfg:mount()
	if luabsd.cfg.init.fstype and luabsd.cfg.init.fsdev  and luabsd.cfg.init.fspoint and luabsd.cfg:checkpoint(luabsd.cfg.init.fspoint, 'dir') == false and luabsd.cfg:checkpoint(luabsd.cfg.init.fsdev, 'dev') == true then
		if system.ls(luabsd.cfg.init.fspoint, true) == nil then system.mkdir(luabsd.cfg.init.fspoint, nil, true) end
		system.mount(luabsd.cfg.init.fstype, luabsd.cfg.init.fspoint, luabsd.cfg.init.fsdev)	
	end
end


function luabsd.cfg.umount()
	if luabsd.cfg.init.fstype and luabsd.cfg.init.fsdev  and luabsd.cfg.init.fspoint and luabsd.cfg:checkpoint(luabsd.cfg.init.fspoint, 'dir') == true and luabsd.cfg:checkpoint(luabsd.cfg.init.fsdev, 'dev') == true  then
		system.umount(luabsd.cfg.init.fspoint, true)
	end
end

function luabsd.cfg:recover()
	if luabsd.cfg:mount() then system.cp(luabsd.cfg.init.fspoint.."/", luabsd.cfg.init.dir.."/") luabsd.cfg:umount() end
end

function luabsd.cfg:load()
	local data = {}
	if luabsd.cfg.init.type == "json" and luabsd.cfg.init.path then
		data = cjson.decode(luabsd.subr.file:read(luabsd.cfg.init.path))
		if data.autoifname then luabsd.cfg.autoifname = data.autoifname end
		if data.ifaces then luabsd.cfg.ifaces = data.ifaces end
		if data.hostname then luabsd.cfg.hostname = data.hostname end
		if data.kldlist then luabsd.cfg.kldlist = data.kldlist end
		if data.kldlistparallel then luabsd.cfg.kldlistparallel = data.kldlistparallel end
		if data.daemond then luabsd.cfg.services = data.daemond end
		if data.netgraph then luabsd.cfg.netgraph = data.netgraph end
		if data.route then luabsd.cfg.route = data.route end
	elseif luabsd.cfg.init.type == "zfs" and luabsd.cfg.init.path then
		local ds = zfs.ds_list(luabsd.cfg.init.path, {'net:hostname', 'net:autoifname', 'kernel:modules', 'kernel:modulesparallel', 'net:netgraph', 'net:ifconfig_rename', 'net:ifconfig_list', 'daemond:count', 'net:route_default', 'net:route_default:status', 'net:route_list'})
		if ds then
			if ds[luabsd.cfg.init.path]['net:autoifname'] then luabsd.cfg.autoifname = ds[luabsd.cfg.init.path]['net:autoifname'] end
			if ds[luabsd.cfg.init.path]['net:hostname'] then luabsd.cfg.hostname = ds[luabsd.cfg.init.path]['net:hostname'] end
			if ds[luabsd.cfg.init.path]['kernel:modules'] then luabsd.cfg.kldlist = ds[luabsd.cfg.init.path]['kernel:modules'] end
			if ds[luabsd.cfg.init.path]['kernel:modulesparallel'] then luabsd.cfg.kldlistparallel = ds[luabsd.cfg.init.path]['kernel:modulesparallel'] end
			if ds[luabsd.cfg.init.path]['net:netgraph'] then luabsd.cfg.netgraph = ds[luabsd.cfg.init.path]['net:netgraph'] end
			if ds[luabsd.cfg.init.path]['net:route_default'] then
				luabsd.cfg.route = {}
				luabsd.cfg.route[0] = {}
				luabsd.cfg.route[0].gw = {}
				luabsd.cfg.route[0].gw.ip4 = ds[luabsd.cfg.init.path]['net:route_default']
				if ds[luabsd.cfg.init.path]['net:route_default:status'] then
					luabsd.cfg.route[0].gw.enable = ds[luabsd.cfg.init.path]['net:route_default:status']
				else
					luabsd.cfg.route[0].gw.enable = "disable"
				end
			end
			if ds[luabsd.cfg.init.path]['net:route_list'] then
				if not luabsd.cfg.route then luabsd.cfg.route = {} end
				local r
				local count = 0
				for r in string.gmatch(ds[luabsd.cfg.init.path]['net:route_list'], '[^,]*') do
					local ids = zfs.ds_list(luabsd.cfg.init.path, {'net:route_static_'..r..'_gtw', 'net:route_static_'..r..'_dest', 'net:route_static_'..r..'_type', 'net:route_static_'..r..'_status', 'net:route_static_'..r..'_fib'})
					local fibnum = tonumber(ids[luabsd.cfg.init.path]['net:route_static_'..r..'_fib'])
					if not luabsd.cfg.route[fibnum] then luabsd.cfg.route[fibnum] = {} end
					if not luabsd.cfg.route[fibnum].st then luabsd.cfg.route[fibnum].st = {} end
					luabsd.cfg.route[fibnum].st[count] = {}
					if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_status'] and ids[luabsd.cfg.init.path]['net:route_static_'..r..'_status'] == '1' then
						luabsd.cfg.route[fibnum].st[count].enable = "enable"
					else
						luabsd.cfg.route[fibnum].st[count].enable = "disable"
					end
					if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_type'] then luabsd.cfg.route[fibnum].st[count].type = ids[luabsd.cfg.init.path]['net:route_static_'..r..'_type'] end
					if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_dest'] then luabsd.cfg.route[fibnum].st[count].dest = ids[luabsd.cfg.init.path]['net:route_static_'..r..'_dest'] end
					if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_gtw'] then luabsd.cfg.route[fibnum].st[count].addr = ids[luabsd.cfg.init.path]['net:route_static_'..r..'_gtw'] end
					luabsd.cfg.route[fibnum].st[count].proto = 4
					count = count + 1
				end
			end
			if ds[luabsd.cfg.init.path]['daemond:count'] then
				local count = tonumber(ds[luabsd.cfg.init.path]['daemond:count'])
				local n
				for n = 1,count do
					local pref = 'daemond:'..n
					local ids = zfs.ds_list(luabsd.cfg.init.path, {pref..':name', pref..':comment', pref..':enable', pref..':type', pref..':command', pref..':args', pref..':nopid', pref..':stop'})
					luabsd.cfg.services[n] = {}
					if ids[luabsd.cfg.init.path][pref..':name'] then luabsd.cfg.services[n].name = ids[luabsd.cfg.init.path][pref..':name'] end
					if ids[luabsd.cfg.init.path][pref..':comment'] then luabsd.cfg.services[n].comment = ids[luabsd.cfg.init.path][pref..':comment'] end
					if ids[luabsd.cfg.init.path][pref..':enable'] then luabsd.cfg.services[n].enable = ids[luabsd.cfg.init.path][pref..':enable'] end
					if ids[luabsd.cfg.init.path][pref..':type'] then luabsd.cfg.services[n].type = ids[luabsd.cfg.init.path][pref..':type'] end
					if ids[luabsd.cfg.init.path][pref..':command'] then luabsd.cfg.services[n].command = ids[luabsd.cfg.init.path][pref..':command'] end
					if ids[luabsd.cfg.init.path][pref..':args'] then luabsd.cfg.services[n].args = ids[luabsd.cfg.init.path][pref..':args'] end
					if ids[luabsd.cfg.init.path][pref..':nopid'] then luabsd.cfg.services[n].nopid = ids[luabsd.cfg.init.path][pref..':nopid'] end
					if ids[luabsd.cfg.init.path][pref..':stop'] then luabsd.cfg.services[n].stop = ids[luabsd.cfg.init.path][pref..':stop'] end
				end
			end
			if ds[luabsd.cfg.init.path]['net:ifconfig_rename'] then
				luabsd.cfg.ifaces = {}
				for ifname in string.gmatch(ds[luabsd.cfg.init.path]['net:ifconfig_rename'], '[^,]*') do
					luabsd.cfg.ifaces[ifname] = {}
					local pref = 'net:ifconfig:'..ifname
					local ids = zfs.ds_list(luabsd.cfg.init.path, {pref..'_enable', pref..'_type', pref..'_create', pref..'_name', pref..'_mac'});
					if ids[luabsd.cfg.init.path][pref .. '_enable'] then luabsd.cfg.ifaces[ifname].enable = ids[luabsd.cfg.init.path][pref .. '_enable'] end
					if ids[luabsd.cfg.init.path][pref .. '_type'] then luabsd.cfg.ifaces[ifname].type = ids[luabsd.cfg.init.path][pref .. '_type'] end
					if ids[luabsd.cfg.init.path][pref .. '_create'] then luabsd.cfg.ifaces[ifname].create = ids[luabsd.cfg.init.path][pref .. '_create'] end
					if ids[luabsd.cfg.init.path][pref .. '_name'] then luabsd.cfg.ifaces[ifname].name = ids[luabsd.cfg.init.path][pref .. '_name'] end
					if ids[luabsd.cfg.init.path][pref .. '_mac'] then luabsd.cfg.ifaces[ifname].mac = ids[luabsd.cfg.init.path][pref .. '_mac'] end
				end
			end
			if ds[luabsd.cfg.init.path]['net:ifconfig_list'] then
				if not luabsd.cfg.ifaces then luabsd.cfg.ifaces = {} end
				for ifname in string.gmatch(ds[luabsd.cfg.init.path]['net:ifconfig_list'], '[^,]*') do
					luabsd.cfg.ifaces[ifname] = {}
					local n = 0
					local ids = zfs.ds_list(luabsd.cfg.init.path, {'net:ifconfig_'..ifname..'_ip4_aliases', 'net:ifconfig_'..ifname..'_ip6_aliases'});
					local acount = 0;
					if ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_aliases'] then
						luabsd.cfg.ifaces[ifname].ip = {}
						for n in string.gmatch(ds[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_aliases'], '[^,]*') do
							local alias = zfs.ds_list(luabsd.cfg.init.path, {'net:ifconfig_'..ifname..'_ip4_alias_'..n, 'net:ifconfig_'..ifname..'_ip4_netmask_'..n})
							if alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_alias_'..n] and alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_netmask_'..n] then
								luabsd.cfg.ifaces[ifname].ip[n] = {}
								luabsd.cfg.ifaces[ifname].ip[n].addr = alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_alias_'..n]
								luabsd.cfg.ifaces[ifname].ip[n].mask = alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_netmask_'..n]
								luabsd.cfg.ifaces[ifname].ip[n].proto = 4
							end
							acount = n
						end
					end
					if ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_aliases'] then
						luabsd.cfg.ifaces[ifname].ip = {}
						for n in string.gmatch(ds[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_aliases'], '[^,]*') do
							local alias = zfs.ds_list(luabsd.cfg.init.path, {'net:ifconfig_'..ifname..'_ip6_alias_'..n, 'net:ifconfig_'..ifname..'_ip6_prefix_'..n})
							if alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_alias_'..n] and alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_prefix_'..n] then
								acount = acount + n
								luabsd.cfg.ifaces[ifname].ip[acount] = {}
								luabsd.cfg.ifaces[ifname].ip[acount].addr = alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_alias_'..n]
								luabsd.cfg.ifaces[ifname].ip[acount].mask = alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_prefix_'..n]
								luabsd.cfg.ifaces[ifname].ip[acount].proto = 6
							end
						end
					end
				end
			end
		end

	end
		luabsd.cfg.loaded = true
	date = nil
end
function luabsd.cfg:unload()
		luabsd.cfg.autoifname = nil
		luabsd.cfg.ifaces = nil
		luabsd.cfg.hostname = nil
		luabsd.cfg.kldlist = nil
		luabsd.cfg.services = nil
		luabsd.cfg.loaded = nil
		luabsd.cfg.netgraph = nil
end

function luabsd.cfg:apply()
	if luabsd.cfg.loaded ~= true then luabsd.cfg:load() end
	if luabsd.cfg.userspace == nil then luabsd.cfg:recover() end
	if luabsd.cfg.hostname then system.hostname(luabsd.cfg.hostname) end
	if luabsd.cfg.kldlistparallel then luabsd.subr.kld:load(luabsd.cfg.kldlistparallel, true) end
	if luabsd.cfg.kldlist then luabsd.subr.kld:load(luabsd.cfg.kldlist) end
	if luabsd.cfg.ifaces then system.fork(luabsd.subr.ifnetd:start()) end
	if luabsd.cfg.services then luabsd.subr.services:start(luabsd.cfg.services) end
	if luabsd.cfg.route then luabsd.subr.routed:start() end
end

function luabsd.cfg:save(list)
local unit
if luabsd.cfg:mount() and list then 
	for unit in string.gmatch(list, "[^%s]+") do
		system.cp(luabsd.cfg.init.dir.."/"..unit, luabsd.cfg.init.fspoint.."/"..unit) end
	end
	if checkpoint(luabsd.cfg.init.fspoint, 'dir') == true and checkpoint(luabsd.cfg.init.fsdev, 'dev') == true then luabsd.cfg:umount() end
	unit = nil
end


function luabsd:libinit (subr)
end
function luabsd:loadmod (name,arg1)
end
function luabsd:start (name)
end


function luabsd.cmd.kldstat()
	local k,v
	for k,v in pairs(system.kldstat()) do print(k, posix.libgen.dirname(v.path), v.name) end
	k,v = nil, nil
end

function luabsd.cmd.df()
	local col0_len, col1_len, header,  data, k, v = 0, 0, {}, system.mount();
	header[0] = "FS TYPE"
    header[1] = "SOURCE"
    header[2] = "MOUNTPOINT"
	for k,v in pairs(data) do 
		if col0_len < v.type:len() then
			col0_len = v.type:len()
		end
		if col1_len < v.source:len() then
			col1_len = v.source:len()
		end
	end
	col0_len = col0_len + 5
	col1_len = col1_len + 5
	header[0] = string.format("%" .. -col0_len .. "s", header[0]);
	header[1] = string.format("%" .. -col1_len .. "s", header[1]);
	io.write(header[0], header[1], header[2], "\n\n")
	for k,v in pairs(data) do 
		v.type = string.format("%" .. -col0_len .. "s", v.type);
		v.source = string.format("%" .. -col1_len .. "s", v.source);
		io.write(v.type, v.source, v.mountpoint, "\n");
	end
		io.flush()

	k,v = nil, nil
end
return luabsd
-- luabsd.env:read()
-- -- test = luabsd.subr.file:read("/tmp/loader2.conf")
-- -- print(test)
-- -- print(luabsd.cfg.init.path)
-- -- print(luabsd.cfg.init.type)
-- luabsd.cfg:load()
-- -- print(luabsd.cfg.services)
--  -- luabsd.cmd.kldstat()
for k,v in pairs(luabsd.cfg.services) do print(k,v) end
-- -- for k,v in pairs(luabsd.cfg.route[1]) do print(k,v) end
-- --luabsd.subr.routed:show()
-- for k,v in pairs(luabsd.cfg.route['0']) do print(k,v) end
-- -- luabsd.cmd.df()
-- -- print("CHECK /tmp: ", luabsd.cfg:checkpoint("zrootfs/usr/home2", 'dev'))
-- -- for a,b in pairs(luabsd.cfg.services[1]) do print(a,b) end
-- luabsd.cfg:unload()
