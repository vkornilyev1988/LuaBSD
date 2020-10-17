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
		luabsd.env   	 = {}											  -> 		table : novar	:	kernel enviroments												*** 	Подтаблица инвироментов ядра
		luabsd.env.init	 = {}               	  						    		 		    	--   --> 		table : novar	:	init params                            							**** 	Подтаблица инвироментов ядра при инициализации системы
			luabsd.env.init.type 											= "hvm.cfg.type" 		--   --->   	string: value	:	default key														*****   Значение по умолчанию ключа [ тип источника данных для инициализации     ] 		Возвращаемые параметры:-строго----: json|fbsd|zfs|bdb
			luabsd.env.init.fstype 											= "hvm.cfg.fstype" 		--   --->   	string: value	:	default key	                            						*****   Значение по умолчанию ключа [ тип файловой систмы хранилища настроек     ] 		Возвращаемые параметры:-строго----: zfs|ufs|cdrom
			luabsd.env.init.fsdev   										= "hvm.cfg.fsdev"       --   --->   	string: value	:	default key	 													*****   Значение по умолчанию ключа [ путь устройства для монтирования cfg       ] 		Возвращаемые параметры:-переменно-: zrootfs/cfg0|/dev/gpt/LUABSDCFG
			luabsd.env.init.fspoint 										= "hvm.cfg.fspoint"     --   --->   	string: value	:	default key	                          						  	*****   Значение по умолчанию ключа [ путь точки монтирования хранилища настроек ] 		Возвращаемые параметры:-переменно-: zrootfs/cfg0|/dev/gpt/LUABSDCFG
		luabsd.cfg  	 = {}											  -> 		table : novar	:	cfg params                             						  	****    Подтаблица переменных полученныъ настроек
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
		run 																= "user" 				-    <------    "table" value   :   this system table to modules run apps
			run.main 														= "user main" 			--   -> 		"function"		: 	This main function modules and apps run
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
luabsd.env.init.ngraph  = "hvm.cfg.netgraph"
luabsd.env.init.dbdir 	= "kcs.bdb.path"
luabsd.env.init.ssldir	= "hvm.cfg.ssldir"
luabsd.env.init.debug 	= "hvm.cfg.debug"
luabsd.cfg.init.type 	= "json"
luabsd.cfg.init.dir		= "/etc"
luabsd.cfg.init.path 	= "/etc/rc.json"
luabsd.cfg.init.fstype	= "ufs"
luabsd.cfg.init.fspoint = "/cfg"
luabsd.cfg.init.fsdev   = "/dev/gpt/LUABSDCFG"
luabsd.cfg.db 			= {}
luabsd.cfg.db.dir 	    = "/data/db"
luabsd.cfg.services     = {}
luabsd.cfg.route 		 	= {}
luabsd.cfg.dir 		 	= {}
luabsd.cfg.dir.tmp   	= "/tmp"
luabsd.cfg.dir.run   	= "/tmp/run"
luabsd.cfg.dir.lib 		= "/lib"
luabsd.cfg.dir.ssl		= "/etc/ssl"
luabsd.cfg.dir.default  = "/tmp/run /tmp/log /data"
luabsd.cfg.userspace 	= system.kenv_get("hvm.userspace")
luabsd.cfg.db 			= {}
luabsd.cfg.debug 		= {}
luabsd.cfg.log 			= {}
luabsd.cfg.log.boot		= "/tmp/log/messages"
luabsd.cfg.log.enable 	= true
luabsd.cfg.dhcpcd 		= "dhclient"
luabsd.subr.kern 	  	= {}
luabsd.subr.kld 	  	= {}
luabsd.subr.service   	= {}
luabsd.subr.ifnetd    	= {}
luabsd.subr.routed		= {}
luabsd.subr.fs 		  	= {}
luabsd.subr.file 		= {}
luabsd.subr.check 		= {}
luabsd.subr.wait 		= {}
luabsd.subr.dir 		= {}
luabsd.subr.msg 		= {}
luabsd.subr.commit		= {}
luabsd.subr.firmware 	= {}
luabsd.cmd 				= {}
luabsd.cmd.zfs  		= require 'zfs'
luabsd.cmd.ngctl 	 	= require 'ngctl'
luabsd.cmd.ip 			= require 'ifnet'
luabsd.cmd.ssl 			= require 'openssl'
luabsd.cmd.ipfw			= require 'ipfw'
luabsd.cmd.table 		= {}
luabsd.cmd.stty 		= {}


-- system.fork = function ( f, ... )
-- 	f(...)
-- end



if system.ls(luabsd.cfg.dir.lib.."/plterm.lib", true) then luabsd.subr.term = require 'plterm'; term = luabsd.subr.term else luabsd.subr.term = {}; function luabsd.subr.term.color();  end term = luabsd.subr.term end
if system.ls(luabsd.cfg.dir.lib.."/lano.lib", true) then luabsd.cmd.lano = require 'lano'.main else luabsd.cmd.lano = {}; function luabsd.cmd.lano.main() print("Element not defination") end end

--[[ boot stage one        ]]--
-- Read enviroments from kernel

function luabsd.env:read()
	if system.kenv_get(luabsd.env.init.type) then luabsd.cfg.init.type = system.kenv_get(luabsd.env.init.type)  end 
	if system.kenv_get(luabsd.env.init.fstype) then luabsd.cfg.init.fstype = system.kenv_get(luabsd.env.init.fstype)  end 
	if system.kenv_get("hvm.cfg."..luabsd.cfg.init.type..".path") then luabsd.cfg.init.path = system.kenv_get("hvm.cfg."..luabsd.cfg.init.type..".path") end
	if system.kenv_get(luabsd.env.init.fsdev) then luabsd.cfg.init.fsdev = system.kenv_get(luabsd.env.init.fsdev) end 
	if system.kenv_get(luabsd.env.init.fspoint) then luabsd.cfg.init.fspoint = system.kenv_get(luabsd.env.init.fspoint) end 
	if system.kenv_get(luabsd.env.init.ngraph) then luabsd.cfg.netgraph = system.kenv_get(luabsd.env.init.ngraph) end 
	if system.kenv_get(luabsd.env.init.dbdir) then luabsd.cfg.db.dir = system.kenv_get(luabsd.env.init.dbdir) end
	if system.kenv_get(luabsd.env.init.ssldir) then luabsd.cfg.dir.ssl = system.kenv_get(luabsd.env.init.ssldir) end
	if system.kenv_get(luabsd.env.init.debug) then luabsd.cfg.debug.enable = luabsd.subr.toboolean(luabsd.env.init.debug) print("YA PRSVOILSY") end
end

-- Save enviroments in kernel
function luabsd.env:save()
end
function luabsd.env:show()
	print("\n[Kernel enviroments]")
	print("------------------------")
 	io.write ("type init system\t:\t") if luabsd.cfg.init.type then print(luabsd.cfg.init.type)  end 
	io.write ("type init file system\t:\t") if luabsd.cfg.init.fstype then print(luabsd.cfg.init.fstype)  end 
	io.write ("type init config\t:\t") if luabsd.cfg.init.path then print(luabsd.cfg.init.path) end
	io.write ("type init partition\t:\t") if luabsd.cfg.init.fsdev then print(luabsd.cfg.init.fsdev) end 
	io.write ("type init mountpouint\t:\t") if luabsd.cfg.init.fspoint then print(luabsd.cfg.init.fspoint) end 
	io.write ("type init ssl/tls dir\t:\t") if luabsd.cfg.dir.default then print(luabsd.cfg.dir.default) end 
	io.flush()
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
function luabsd.subr.file:write(t_file,data)
	local file
	if t_file and data then
	   	file = io.open(t_file, "w")
  	    file:write(data) -- *a or *all reads the whole file
    	file:close()
    	io.flush()
    else
    	return "Not set arguments : luabsd.subr.file:append(file,data)" 
    end
    file = nil
end

function luabsd.subr.file:append(t_file,data)
	local file
	if t_file and data then 
	   	file = io.open(t_file, "a")
  	    file:write(data) -- *a or *all reads the whole file
    	file:close()
    	io.flush()
    else
    	return "Not set arguments : luabsd.subr.file:append(file,data)" 
    end
    file = nil
end

function luabsd.subr.table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in luabsd.subr.spairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, luabsd.subr.table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tostring(tt) .. "\n"
  end
end

function luabsd.subr.toboolean(input)

	if input and type(input) == "string" then
		if string.lower(input) == "true" then return true end
		if string.lower(input) == "false" then return false end
	else
		return input
	end
end	

	
function luabsd.subr:debug(t_file,t_data)
	local file
		if t_file and t_data then
			file = io.open(t_file, "w")
			file:write(t_data.."\n")
			file:close()
			io.flush()
		end
	t_file,t_data = nil,nil

	--if luabsd.cfg.debug.enable == true then term.color(31) print("Mode DEBUGGING ALLOW /!\\") end
end



function luabsd.subr.kld.load(kldlist, parallel)
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



function luabsd.subr.errnotomsg(ERRNO)
local msg = {
						[posix.errno.E2BIG] 			= 			"argument list too long",
						[posix.errno.EACCES] 			= 			"permission denied",
						[posix.errno.EADDRINUSE] 		= 			"address already in use",
						[posix.errno.EADDRNOTAVAIL] 	=			"can't assign requested address",
						[posix.errno.EAFNOSUPPORT]	 	= 			"address family not supported by protocol family",
						[posix.errno.EAGAIN] 			= 			"resource temporarily unavailable",
						[posix.errno.EALREADY] 			= 			"operation already in progress",
						[posix.errno.EBADF] 			= 			"bad file descriptor",
						[posix.errno.EBADMSG] 			= 			"bad message",
						[posix.errno.EBUSY] 			= 			"resource busy",
						[posix.errno.ECANCELED] 		= 			"operation canceled",
						[posix.errno.ECHILD] 			= 			"no child processes",
						[posix.errno.ECONNABORTED] 		= 			"software caused connection abort",
						[posix.errno.ECONNREFUSED] 		= 			"connection refused",
						[posix.errno.ECONNRESET] 		= 			"connection reset by peer",
						[posix.errno.EDEADLK] 			= 			"resource deadlock avoided",
						[posix.errno.EDESTADDRREQ]	 	= 			"destination address required",
						[posix.errno.EDOM] 				= 			"numerical argument out of domain",
						[posix.errno.EEXIST] 			= 			"file exists",
						[posix.errno.EFAULT] 			= 			"bad address",
						[posix.errno.EFBIG] 			= 			"file too large",
						[posix.errno.EHOSTUNREACH]	 	= 			"no route to host",
						[posix.errno.EIDRM] 			= 			"identifier removed",
						[posix.errno.EILSEQ] 			= 			"illegal byte sequence",
						[posix.errno.EINPROGRESS]	 	= 			"operation now in progress",
						[posix.errno.EINTR] 			= 			"interrupted system call",
						[posix.errno.EINVAL] 			= 			"invalid argument",
						[posix.errno.EIO] 	 			= 			"input/output error",
						[posix.errno.EISCONN]	 		= 			"socket is already connected",
						[posix.errno.EISDIR] 			= 			"is a directory",
						[posix.errno.ELOOP] 			= 			"too many levels of symbolic links",
						[posix.errno.EMFILE] 			= 			"too many open files",
						[posix.errno.EMLINK] 			= 			"too many links",
						[posix.errno.EMSGSIZE] 	 		= 			"message too long",
						[posix.errno.ENAMETOOLONG]  	= 			"file name too long",
						[posix.errno.ENETDOWN]	 		= 			"network is down",
						[posix.errno.ENETRESET]  		= 			"network dropped connection on reset",
						[posix.errno.ENETUNREACH] 	 	= 			"network is unreachable",
						[posix.errno.ENFILE] 			= 			"too many open files in system",
						[posix.errno.ENOBUFS] 	 		= 			"no buffer space available",
						[posix.errno.ENODEV] 			= 			"operation not supported by device",
						[posix.errno.ENOENT] 			= 			"no such file or directory",
						[posix.errno.ENOEXEC] 	 		= 			"exec format error",
						[posix.errno.ENOLCK] 			= 			"no locks available",
						[posix.errno.ENOMEM] 			= 			"cannot allocate memory",
						[posix.errno.ENOMSG] 			= 			"no message of desired type",
						[posix.errno.ENOPROTOOPT] 	 	= 			"protocol not available",
						[posix.errno.ENOSPC] 			= 			"no space left on device",
						[posix.errno.ENOSYS] 			= 			"function not implemented",
						[posix.errno.ENOTCONN]	 		= 			"socket is not connected",
						[posix.errno.ENOTDIR] 			= 			"not a directory",
						[posix.errno.ENOTEMPTY] 		= 			"directory not empty",
						[posix.errno.ENOTSOCK] 	 		= 			"socket operation on non-socket",
						[posix.errno.ENOTSUP] 	 		= 			"operation not supported",
						[posix.errno.ENOTTY] 			= 			"inappropriate ioctl for device",
						[posix.errno.ENXIO] 			= 			"device not configured",
						[posix.errno.EOPNOTSUPP] 		=			"operation not supported on socket",
						[posix.errno.EOVERFLOW] 		= 			"value too large to be stored in data type",
						[posix.errno.EPERM] 			= 			"operation not permitted",
						[posix.errno.EPIPE] 			= 			"broken pipe",
						[posix.errno.EPROTO] 			= 			"protocol error",
						[posix.errno.EPROTONOSUPPORT] 	=			"protocol not supported",
						[posix.errno.EPROTOTYPE] 		= 			"protocol wrong type for socket",
						[posix.errno.ERANGE] 			= 			"result too large",
						[posix.errno.EROFS] 			= 			"read-only file system",
						[posix.errno.ESPIPE] 			= 			"illegal seek",
						[posix.errno.ESRCH] 			= 			"no such process",
						[posix.errno.ETIMEDOUT] 		= 			"operation timed out",
						[posix.errno.ETXTBSY] 			= 			"text file busy",
						[posix.errno.EWOULDBLOCK] 		= 			"operation would block",
						[posix.errno.EXDEV] 			= 			"cross-device link"
}


	if ERRNO then
		return msg[ERRNO]
	end
err = nil
end


function luabsd.subr.gidtoname(gid)
	if not gid then return posix.errno.EAGAIN end
	if system.ls(luabsd.cfg.init.dir, true) then
	end
end

---------------------_SECURITY FUNCTIONS-------------------

luabsd.sec = {}
luabsd.sec.subr = {}
function luabsd.sec.subr.login(username,password)
	if not username and password then return false end
	if not spwd.get(username) then return false end
	local pw_pass,result = password or ""
		if  spwd.verify(username,pw_pass) then
			result = spwd.get(username)
		else
			result = false
		end
		pw_pass = nil
		return result
end

-- posix.grp.getgrnam("www").gr_gid
function luabsd.subr.getgid(grname)
	if grname and system.ls(luabsd.cfg.init.dir.."/group",true) == true then
		return posix.grp.getgrnam(grname).gr_gid
	else return 0
	end
end

---------------------_SERVICES START_----------------------

function luabsd.subr.service:start(list)

	if not luabsd.cfg.loaded == true then luabsd.cfg:load() end
	local k,v,unitname
	function startunit(unit)
		if not unit then return -1 end
		if not luabsd.cfg.services then return 'no services found' end
		local col0_len ,pidfile,k,v,pid,file = 0, luabsd.cfg.dir.run.."/"..unit..".pid"
			for k,v in pairs(luabsd.cfg.services)  do
				if 		col0_len < v.name:len() then
						col0_len = v.name:len()
				end 
			end
			k,v = nil,nil; local k,v
			col0_len = col0_len + 5
			for k,v in pairs(luabsd.cfg.services)  do	
				if v.name == unit and v.enable == true and not system.ls(pidfile, true) then
					io.write(" Service starting ... "..string.format("%" .. -col0_len .. "s",v.name))						
					local user,group = luabsd.subr.getgid(v.user) or 0, v.group or 0
					if not system.ls(pidfile, true) and string.lower(v.type)  == "bsd" then
						if v.args then pid=system.su_execv_nowait(user,group,v.command, v.args) else pid=system.su_exec_nowait(user,group,v.command) end
					elseif not system.ls(pidfile, true) and string.lower(v.type) == "lua" then
						if v.args then pid=system.fork(dofile, v.command, v.args) else pid=system.fork(dofile, v.command) end
					end
					user,group = nil, nil
					if pid and not v.nopidfile == true and not system.ls(pidfile, true) then   --CICLE
						file = io.open(pidfile, "w")
						file:write(pid)
						file:close()
						term.color(32)
						io.write("[ OK ]\n")
						term.color(0)
					elseif pid and v.nopidfile == true then  --CICLE
						local countilme = 0
						while not system.ls(pidfile, true) do
							posix.unistd.sleep(1)
							countilme = countilme + 1
							if countilme == 10 then break end
						end
						term.color(32)
						if system.ls(pidfile, true) then 
							io.write("[ OK ]\n")
						else
							io.write("[ NOPIDFILE ]\n")
						end
						term.color(0)
						pid = nil
					else
						io.write("[ FALSE ]\n")
					end
					io.flush()
				elseif v.name == unit and v.enable == true and system.ls(pidfile, true) then --CICLE
					file = io.open(pidfile, "rb")
					pid = file:read("*a")
					file:close()
					io.write("[ ALREADY ]: [", pid,"]\n")
					io.flush()
				elseif v.name == unit and not v.enable == true then
					io.write("Service \t",unit,"[ DISABLED ]\n")
					io.flush()
				end
			end
		k,v,pid,pidfile,file = nil, nil, nil, nil
	end

	if list then 
		for unitname in string.gmatch(list, "[^%s]+") do
			startunit(unitname)
		end			
	else
			if not luabsd.cfg.userspace == true then
				local k,v 
				for k,v in pairs(luabsd.cfg.services) do startunit(v.name)  end
				k,v = nil, nil
			end
	end
	k,v,unitname = nil,nil,nil
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end

function luabsd.subr.dir:mkdirdefault(d_list)
	local dir_list,k  = d_list or luabsd.cfg.dir.default
		for k in string.gmatch(dir_list, "[^%s]+") do
			if not system.ls(k, true) == true then system.mkdir(k,770,true) end
		end
	dir_list = nil,nil
end

----------------------------------------------------------

function luabsd.subr.getcode()
	local byte=string.byte
	return byte(io.read(1))
end

function luabsd.cmd.stty:setrawmode()
	local ret, err = posix.termio.tcsetattr(0, 0, {



		   iflag = 2049,
		   lflag = 65,
		   cflag = 19200,
		   oflag = 2,
		   ispeed = 38400,
		   ospeed = 38400,
		   cc = { [0] = 4, [1] = 255, [2] = 255, [3] = 127, [4] = 23, [5] = 21, [6] = 18, [7] = 8, [8] = 3, [9] = 28,
		   			[10] = 26, [11] = 25, [12] = 17, [13] = 19, [14] = 22, [15] = 15, [16] = 1, [17] = 0, [18] = 20, [19] = 255
		   }
		})
	return ret
end

function luabsd.cmd.stty:setsanemode()
	local ret, err = posix.termio.tcsetattr(0, 0, {
		   iflag = 11010,
		   lflag = 1483,
		   cflag = 19200,
		   oflag = 3,
		   ispeed = 38400,
		   ospeed = 38400,
		   cc = { [0] = 4, [1] = 255, [2] = 255, [3] = 127, [4] = 23, [5] = 21, [6] = 18, [7] = 8, [8] = 3, [9] = 28,
		   			[10] = 26, [11] = 25, [12] = 17, [13] = 19, [14] = 22, [15] = 15, [16] = 1, [17] = 0, [18] = 20, [19] = 255
		   }
		})
	return ret
end

function luabsd.cmd.stty:savemode()
	local mode, msg, e = posix.termio.tcgetattr(0)
	return mode or nil, e, msg
end

function luabsd.cmd.stty:restoremode(mode)
	local ret, err = posix.termio.tcsetattr(0, 0, mode)
	return ret
end

function luabsd.subr.getpassword()
	io.flush()
	luabsd.cmd.stty:setrawmode()
	local s = ''
	local c = string.byte(io.read(1))
	while c ~= 13 do
		if c == 127 then
			if #s > 0 then
				io.write('\b \b')
				s = s:sub(1, -2)
			end
		else
			s = s .. string.char(c);
			io.write('*')
		end
		c = string.byte(io.read(1))
	end;
	luabsd.cmd.stty:setsanemode()
	print()
	return s
end


function luabsd.subr.service:status(list)
	if not luabsd.cfg.loaded == true then luabsd.cfg:load() end
	local k,v,unitname
	local function statunit(unit)
		if not unit then return -1 end
		if not luabsd.cfg.services then return 'No services found' end
		local col0_len ,pidfile,k,v,pid,file = 0, luabsd.cfg.dir.run.."/"..unit..".pid"
			for k,v in pairs(luabsd.cfg.services)  do
				if 		col0_len < v.name:len() then
						col0_len = v.name:len()
				end 
			end
			k,v = nil,nil; local k,v
			col0_len = col0_len + 5
			io.write("Service \t", unit)
			for k,v in pairs(luabsd.cfg.services)  do	
				term.color(36)
				if v.name == unit and v.enable == true and system.ls(pidfile, true) then
					pid = tonumber(luabsd.subr.file:read(pidfile))
					if system.ps(true)[pid] and system.ps(true)[pid].command and system.ps(true)[pid].command == posix.libgen.basename(v.command) then 
						term.color(32)
						print("\t[ STARTED ]")
						term.color(0)
						return true
					else
						term.color(31)
						print("\t[ STOPED ]")
						term.color(0)
					end						
				elseif v.name == unit and v.enable == true and v.nopidfile and not system.ls(pidfile, true) then
						term.color(33)
						print("\t[ PID NOT FOUND")
						term.color(0)
						return false
				elseif v.name == unit and not v.enable == true then
						term.color(33)
						io.write("\t[ DISABLED ]\n")
						term.color(0)
						return false
				else
						term.color(31)
						io.write("\t[ ERROR STAT ]\n")
						term.color(0)
						return false	
				end
				io.flush()
			end
		k,v,pid,pidfile,file = nil, nil, nil, nil
	end

	if list then 
		for unitname in string.gmatch(list, "[^%s]+") do
			statunit(unitname)
		end			
	else

				local k,v 
				for k,v in pairs(luabsd.cfg.services) do statunit(v.name)  end
				k,v = nil, nil

	end
	k,v,unitname = nil,nil,nil
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
					print("start stop: "..luabsd.cfg.dir.run.."/"..unitname..".pid")
					for k,v in pairs(luabsd.cfg.services) do 
						if v.name == unitname then 
							if v.stop then 
								print("stop services flag: ", v.stop)
								system.cmd(v.stop)
							else
								print("service stop: "..luabsd.cfg.dir.run.."/"..unitname..".pid")
							system.kill(luabsd.subr.file:read(luabsd.cfg.dir.run.."/"..unitname..".pid")); system.rm(luabsd.subr.file:read(luabsd.cfg.dir.run.."/"..unitname..".pid")) 
							posix.unistd.sleep(1)
							system.rm(luabsd.cfg.dir.run.."/"..unitname..".pid")
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

function luabsd.subr.service:list()
	if not luabsd.cfg.loaded == true then luabsd.cfg:load() end
	local k,v
	print("\n[Services list]")
	print("------------------------")		
	if type(luabsd.cfg.services) == "table" then
		for k,v in pairs(luabsd.cfg.services) do 
			print(k,":")
			print("\t name\t\t:\t",luabsd.cfg.services[k].name)
			print("\t comment\t:\t",luabsd.cfg.services[k].comment)
			print("\t status\t\t:\t",luabsd.cfg.services[k].enable)
			print("\t type\t\t:\t",luabsd.cfg.services[k].type)
			print("\t nopid\t\t:\t",luabsd.cfg.services[k].nopidfile)
			print("\t before\t\t:\t",luabsd.cfg.services[k].before)
			print("\t command\t:\t",luabsd.cfg.services[k].command)
			print("\t args\t\t:\t",luabsd.cfg.services[k].args)
			print("\t cmdstop\t:\t",luabsd.cfg.services[k].stop)
		end	
	end
	k,v = nil, nil
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end

function luabsd.subr.service:restart(list)
	local unitname
	for unitname in string.gmatch(list, "[^%s]+") do
		luabsd.subr.service:stop(unitname)
		posix.unistd.sleep(1)
		luabsd.subr.service:stop(startname)
	end
end

function luabsd.subr.check.iface(iface)
			local k,v
				for k,v in pairs(ifnet.info(iface)) do return true end 
			k,v = nil,nil
end



function luabsd.subr.log(t_log,log_file)
		local log_file = log_file or luabsd.cfg.log.boot or "/tmp/log/messages"
		if luabsd.subr.toboolean(luabsd.cfg.log.enable) == true then
			if not system.ls(log_file, true) then system.mkdir(log_file,660,true) end
			luabsd.subr.table_print(t_log)
			--luabsd.subr.file:append(log_file,luabsd.subr.table_print)
		end 
		log_file = nil

end

function luabsd.subr.wait.iface(t_iface,time)  -- TODO : POSIXMSG
		if not t_iface then return "Not set iface argument : luabsd.subr.wait:ifnet(<iface>,<time>)";  end
		local count, ifconfig, ctime  = 0, t_iface, time or 20
			while not luabsd.subr.check.iface(ifconfig) do
				posix.unistd.sleep(1)
				count = count + 1
				if count == ctime then break end
			end
			if not luabsd.subr.check.iface(t_iface) then return "Iface not available" end
end
function luabsd.subr.wait.ifnet(t_iface,command,time) 																															--iface  command time
		if not t_iface and command then return "Not set iface argument : luabsd.subr.wait:ifnet(<iface>,<command: create/name/ipset/flags>,<time>)" end
		local ctime,cmd = time or 10, command or "ipset"
				if cmd == "ipset" then
					if luabsd.subr.toboolean(luabsd.cfg.ifaces[t_iface].enable) == true then
						local k, el
						if luabsd.cfg.ifaces[t_iface].ip and type(luabsd.cfg.ifaces[t_iface].ip) == 'table' then
							for k,el in ipairs(luabsd.cfg.ifaces[t_iface].ip) do
								if el.proto and el.addr and el.mask and el.proto == 4 or el.proto == 6 and not el.addr == string.lower("dhcp") then luabsd.subr.wait.iface(t_iface,ctime); ifnet.setip(t_iface, el.proto, el.addr, el.mask);
								elseif  el.addr and el.addr == string.lower("dhcp") and luabsd.cfg.dhcpcd then luabsd.subr.wait.iface(t_iface,ctime);  if require(luabsd.cfg.dhcpcd) then local dhclient = require(luabsd.cfg.dhcpcd); dhclient(t_iface); dhclient = nil end
								end
							end
						end
						if_flag = nil
					end	
					if luabsd.subr.toboolean(luabsd.cfg.ifaces[t_iface].enable) == true and luabsd.cfg.ifaces[t_iface].flags then
						local if_flag
						for if_flag in string.gmatch(luabsd.cfg.ifaces[t_iface].flags, "[^%s]+") do
							luabsd.subr.wait.iface(t_iface,ctime);
							luabsd.subr.log(ifnet.flags(t_iface, if_flag))
						end
						if_flag = nil
					end
					k,el = nil,nil
				elseif cmd == "create" then
					if luabsd.cfg.ifaces[t_iface].create and luabsd.cfg.ifaces[t_iface].enable == true then
						luabsd.subr.log("Ifnet "..t_iface.."create: ".. luabsd.cfg.ifaces[t_iface].name)
						if luabsd.cfg.ifaces[t_iface].type == "eiface" then
						elseif  luabsd.cfg.ifaces[t_iface].type == "iface" then
						else
							if luabsd.subr.toboolean(luabsd.cfg.ifaces[t_iface].create) == true then luabsd.subr.wait.iface(t_iface,ctime); luabsd.subr.log(ifnet.create(t_iface)); end
						end
					end
				elseif cmd == "name" then
					if luabsd.cfg.ifaces[t_iface].name and luabsd.cfg.ifaces[t_iface].enable == true then
						luabsd.subr.log("Ifnet "..t_iface.."name: ".. luabsd.cfg.ifaces[t_iface].name)
						if luabsd.cfg.ifaces[t_iface].type == "eiface" then
						elseif  luabsd.cfg.ifaces[t_iface].type == "iface" then
						else
							if luabsd.cfg.ifaces[t_iface].name then luabsd.subr.wait.iface(t_iface,ctime); luabsd.subr.log(ifnet.rename(t_iface,luabsd.cfg.ifaces[t_iface].name)); end
						end
					end
				elseif cmd == "setmac" then
					if luabsd.cfg.ifaces[t_iface].mac and luabsd.cfg.ifaces[t_iface].enable == true then
						luabsd.subr.log("Ifnet "..t_iface.."name: ".. luabsd.cfg.ifaces[t_iface].mac)
						if luabsd.cfg.ifaces[t_iface].name then luabsd.subr.wait.iface(t_iface,ctime); luabsd.subr.log(ifnet.setmac(t_iface,luabsd.cfg.ifaces[t_iface].mac)); end
					end
				end

			ctime = nil
end
function luabsd.subr.ifnetd:start()
	if not luabsd.cfg.loaded == true  then luabsd.cfg:load() end
		term.color(36)
		io.write("Starting ifnetd ... ")
		io.flush()
	if not system.ls(luabsd.cfg.dir.run.."/ifinetd.run", true) then
	--[[ create ethernets only ]]
		 if luabsd.cfg.ifaces then
		 	term.color(36)
			io.write("Ifaces auto starting ... :")
			io.flush()
		 	local ifconfig
			for ifconfig in pairs(luabsd.cfg.ifaces) do
				system.fork(luabsd.subr.wait.ifnet, ifconfig,"create")
				system.fork(luabsd.subr.wait.ifnet, ifconfig,"name")
			end
			ifconfig = nil
			if luabsd.cfg.netgraph then
				if  pcall(require, luabsd.cfg.netgraph) then
					run = require(luabsd.cfg.netgraph)
					if run then
						run.main()
						run = {}
					end
				end
			end
		 	local ifconfig
			for ifconfig in pairs(luabsd.cfg.ifaces) do
				system.fork(luabsd.subr.wait.ifnet, ifconfig,"ipset")
			end
			ifconfig = nil			


		end
		term.color(32)
		print("[ OK ]")
		luabsd.subr.file:write(luabsd.cfg.dir.run.."/ifinetd.run","ifaces_rand")
	else
		term.color(34)
		print("[ ALREADY RUNNING ]")
	end
		term.color(0)
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end

function luabsd.subr.check.ifup(t_iface)
	local k,v = nil,nil
	local info = ifnet.info(t_iface)
	if info then
		for k,v in pairs(info[t_iface].flags) do
			if v == "UP" then
				return true
			end
		end
	end
end

function luabsd.subr.wait.ifacerouted(t_iface,t_time)
	local count,time = 0, t_time or 20
		if t_iface and t_time and luabsd.cfg.ifaces[t_iface] and luabsd.cfg.ifaces[t_iface].ip then
			if luabsd.subr.toboolean(luabsd.cfg.ifaces[t_iface].enable) == true then
				while not luabsd.subr.check.ifup(t_iface) do
					posix.unistd.sleep(1)
					count = count + 1
					if count == time then break end
				end
			end
		end
	count,time = nil,nil
end

function luabsd.subr.routed:start()
	local k,v,count,time,runfile  = 0, 20, luabsd.cfg.dir.run.."/ifinetd.run"   -- FOR NA ip.addr
	
	if luabsd.cfg.loaded ~= true  then luabsd.cfg:load() end
	for k,v in pairs(luabsd.cfg.ifaces) do
		if luabsd.subr.toboolean(luabsd.cfg.ifaces[k].enable) == true and v.ip then luabsd.subr.wait.ifacerouted(k) end
	end

	count,time,k,v = nil,nil,nil,nil
	if luabsd.cfg.loaded ~= true  then luabsd.cfg:load() end
	local fibnum,routed,k,v = 0
	if luabsd.cfg.route then
		for fibnum, routed in pairs(luabsd.cfg.route) do  -- TODO FIBS
			    if luabsd.subr.toboolean(routed.gw.enable) == true and routed.gw.ip4 then
			    	ifnet.route_add("4", routed.gw.ip4)
		    	elseif luabsd.subr.toboolean(routed.gw.enable) == true and routed.gw.ip6 then
		    		ifnet.route_add("6", routed.gw.ip6)
		    	end 
				if routed.st then for k,v in pairs(routed.st) do if luabsd.subr.toboolean(v.enable) then ifnet.route_add_static4(v.type, v.dest, v.addr, fibnum) end end end
		end
	end
	if luabsd.cfg.loaded == true and luabsd.cfg.userspace == true then luabsd.cfg:unload() end
end
function luabsd.subr.routed:stop()
	if luabsd.cfg.loaded ~= true  then luabsd.cfg:load() end
	local count,routed,k,v = 1
	local fibnum = 0
	if luabsd.cfg.route then
		for count, routed in pairs(luabsd.cfg.route[fibnum]) do 
				if routed.st then for k,v in pairs(routed.st) do if v.enable then ifnet.route_del_static4(v.type,v.dest, v.addr, fibnum) end end end
			    if routed.gw.enable and routed.gw.ip4 then ifnet.route_del("4", routed.gw.ip4, fibnum) elseif outed.gw.enable and routed.gw.ip6 then ifnet.route_add("6", routed.gw.ip4, fibnum) end 
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



function luabsd.subr.checkpoint(point, pointtype)
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

function luabsd.subr.dir.checkexists(dir)
	if dir and not system.ls(dir, true) then return system.mkdir(dir,750,true) else return true end
end

function luabsd.cfg:mount()
	if luabsd.cfg.init.fstype and luabsd.cfg.init.fsdev  and luabsd.cfg.init.fspoint and luabsd.subr.checkpoint(luabsd.cfg.init.fsdev, 'dev') == false and luabsd.subr.dir.checkexists(luabsd.cfg.init.fspoint) == true then
		system.mount(luabsd.cfg.init.fstype, luabsd.cfg.init.fspoint, luabsd.cfg.init.fsdev); 
		return true
	end
end



function luabsd.cfg:umount()
	if luabsd.cfg.init.fstype and luabsd.cfg.init.fsdev  and luabsd.cfg.init.fspoint and luabsd.subr.checkpoint(luabsd.cfg.init.fsdev, 'dev') == true then
		system.umount(luabsd.cfg.init.fspoint, true)	
	end
end


function luabsd.cfg:recover()
	pcall(luabsd.cfg.mount) 
		if luabsd.subr.checkpoint(luabsd.cfg.init.fsdev, 'dev') == true then 
			system.cp(luabsd.cfg.init.fspoint.."/", luabsd.cfg.init.dir.."/") 
			luabsd.cfg:umount() 
		end

end


function luabsd.cfg:save(savelist)
local unit
if not luabsd.cfg:mount() then return false end
if savelist  and luabsd.subr.checkpoint(luabsd.cfg.init.fsdev, 'dev') == true then 
	for unit in string.gmatch(savelist, "[^%s]+") do
		system.cp(luabsd.cfg.init.dir.."/"..unit, luabsd.cfg.init.fspoint.."/"..unit) 
	end
elseif not savelist  and luabsd.subr.checkpoint(luabsd.cfg.init.fsdev, 'dev') == true then
	system.cp(luabsd.cfg.init.dir.."/", luabsd.cfg.init.fspoint.."/") 
end
	if luabsd.subr.checkpoint(luabsd.cfg.init.fsdev, 'dev') == true then luabsd.cfg:umount() end
	unit = nil
end


function luabsd.subr.zfs_cfg_types(handle)
	local k,v
	if handle == "true" then
		return true
	elseif handle == 'false' then
		return false
	end

end


function luabsd.cfg:push(cmd,args)
	if not luabsd.cfg.loaded == true then luabsd.cfg:load(); luabsd.cfg.loaded = true end
	local cfg_table = {}
	if cmd and cmd == "ifaces" then
		cfg_table.ifaces = {}
		local ilist,k,v,k1,v1, info = ifnet.list()
		if ilist then
			for k,v in pairs(ilist) do
				info = ifnet.info(k)
				if info then
					cfg_table.ifaces[k] = {}
					local count = 0
					if info.ip4 then
						for k1, v1 in pairs(info.ip4) do
							if not cfg_table.ifaces[k].ip then cfg_table.ifaces[k].ip = {} end
							count = count + 1
							cfg_table.ifaces[k].ip[count] = {}
							cfg_table.ifaces[k].ip[count].addr = v1.ip
							cfg_table.ifaces[k].ip[count].mask = v1.netmask
							cfg_table.ifaces[k].ip[count].proto = 4
						end
					end
					if info.ip6 then
						for k1, v1 in pairs(info.ip6) do
							if not cfg_table.ifaces[k].ip then cfg_table.ifaces[k].ip = {} end
							count = count + 1
							cfg_table.ifaces[k].ip[count] = {}
							cfg_table.ifaces[k].ip[count].addr = v1.ip
							cfg_table.ifaces[k].ip[count].mask = tostring(v1.prefix)
							cfg_table.ifaces[k].ip[count].proto = 6
						end
					end
					if info.flags then
						cfg_table.ifaces[k].flags = ''
						for k1,v1 in pairs(info.flags) do
							cfg_table.ifaces[k].flags =  cfg_table.ifaces[k].flags  .. ' ' .. string.lower(v1)
						end
						if #cfg_table.ifaces[k].flags > 0 then
							cfg_table.ifaces[k].flags = cfg_table.ifaces[k].flags:sub(2)
						end
					end
				end
			end
		end
	end

end

function luabsd.subr.commit.zfs(cfg_type, cfg_table)

-- ZFS SAFE
	if cfg_type == "zfs" and cfg_table then
		local data, k,v = {}, nil, nil
		if cfg_table.hostname then data['net:hostname'] = cfg_table.hostname end
		if cfg_table.autoifname then data['net:autoifname'] = cfg_table.autoifname end
		if cfg_table.kldlist then data['kernel:modules'] = cfg_table.kldlist end
		if cfg_table.kldlistparallel then data['kernel:modulesparallel'] = cfg_table.kldlistparallel end
		if cfg_table.netgraph then data['net:netgraph'] = cfg_table.netgraph end
		if cfg_table.route then
			for k,v in pairs(cfg_table.route) do
				if v.gw and v.gw.ip4 then
					data['net:route_default'] = v.gw.ip4
					if v.gw.enable then data['net:route_default:status'] = '1' else data['net:route_default:status'] = '0' end
				end
				if v.st then
					local k1,v1,list = nil, nil, ""
					for k1,v1 in pairs(v.st) do
						if v1.name and v1.type and v1.dest and v1.addr and v1.proto then -- TODO proto and fib
							data['net:route_static_' .. v1.name .. '_type'] = v1.type
							data['net:route_static_' .. v1.name .. '_dest'] = v1.dest
							data['net:route_static_' .. v1.name .. '_gtw'] = v1.addr
							if v1.enable then data['net:route_static_' .. v1.name .. '_status'] = '1' else data['net:route_static_' .. v1.name .. '_status'] = '0' end
							data['net:route_static_' .. v1.name .. '_fib'] = tostring(k)
							list = list .. ',' .. v1.name
						end
					end
					if #list > 0 then
						list = list:sub(2)
						data['net:route_list'] = list
					end
				end
			end
		end
		if cfg_table.services then
			local count = 0
			for k,v in pairs(cfg_table.services) do
				if v.name and v.type and v.command then
					data['daemond:' .. k .. ':name'] = v.name
					data['daemond:' .. k .. ':type'] = v.type
					data['daemond:' .. k .. ':command'] = v.command
					if v.enable then data['daemond:' .. k .. ':enable'] = 'true' else data['daemond:' .. k .. ':enable'] = 'false' end
					if v.args then data['daemond:' .. k .. ':args'] = v.args else data['daemond:' .. k .. ':args'] = '-' end
					if v.comment then data['daemond:' .. k .. ':comment'] = v.comment else data['daemond:' .. k .. ':comment'] = '-' end
					if v.stop then data['daemond:' .. k .. ':stop'] = v.stop else data['daemond:' .. k .. ':stop'] = '-' end
					if v.user then data['daemond:' .. k .. ':user'] = v.user else data['daemond:' .. k .. ':user'] = '-' end
					if v.group then data['daemond:' .. k .. ':group'] = v.group else data['daemond:' .. k .. ':group'] = '-' end
					if v.before then data['daemond:' .. k .. ':before'] = v.before else data['daemond:' .. k .. ':before'] ='-' end
					if v.nopidfile then data['daemond:' .. k .. ':nopid'] = 'true' else data['daemond:' .. k .. ':nopid'] = 'false' end
					count = count + 1
				end
			end
			if count > 0 then
				data['daemond:count'] = tostring(count)
			end
		end
		if cfg_table.ifaces then
			local ilist, rlist, k1,v1 = '', '', nil, nil
			for k,v in pairs(cfg_table.ifaces) do
				if v.ip then
					local a4, a6, c4,c6 = '', '', 0, 0
					for k1,v1 in ipairs(v.ip) do
						if v1.addr and v1.mask and (v1.proto == 4 or v1.proto == 6) then
							if v1.proto == 4 then
								data['net:ifconfig_' .. k .. '_ip4_alias_' .. k1] = v1.addr
								data['net:ifconfig_' .. k .. '_ip4_netmask_' .. k1] = v1.mask
								a4 = a4 .. ',' .. tostring(c4)
								c4 = c4 + 1
							else
								data['net:ifconfig_' .. k .. '_ip6_alias_' .. k1] = v1.addr
								data['net:ifconfig_' .. k .. '_ip6_prefix_' .. k1] = v1.mask
								a6 = a6 .. ',' .. tostring(c4)
								c6 = c6 + 1
							end
						end
					end
					if #a4 > 0 then
						a4 = a4:sub(2)
						data['net:ifconfig_' .. k .. '_ip4_aliases'] = a4
					end
					if #a6 > 0 then
						a6 = a6:sub(2)
						data['net:ifconfig_' .. k .. '_ip6_aliases'] = a6
					end
					if c4 > 0 or c6 > 0 then
						ilist = ilist .. ',' .. k
						if v.flags then data['net:ifconfig_' .. k .. '_flags'] = v.flags end
						if v.enable then data['net:ifconfig_' .. k .. '_enable'] = 'true' else data['net:ifconfig_' .. k .. '_enable'] = 'false' end
					end
				else
					if v.enable then data['net:ifconfig:' .. k .. '_enable'] = 'true' else data['net:ifconfig:' .. k .. '_enable'] = 'false' end
					if v.create then data['net:ifconfig:' .. k .. '_create'] = 'true' else data['net:ifconfig:' .. k .. '_create'] = 'false' end
					if v.type then data['net:ifconfig:' .. k .. '_type'] = v.type end
					if v.name then data['net:ifconfig:' .. k .. '_name'] = v.name end
					if v.mac then data['net:ifconfig:' .. k .. '_mac'] = v.mac end
					if v.flags then data['net:ifconfig:' .. k .. '_flags'] = v.flags end
					rlist = rlist .. ',' .. k
				end
			end
			if #ilist > 0 then
				data['net:ifconfig_list'] = ilist
			end
			if #rlist > 0 then
				data['net:ifconfig_rename'] = rlist
			end
		end
		zfs.ds_update(luabsd.cfg.init.path, data)
	end
end

function luabsd.cfg:commit(cmd)
	if luabsd.cfg.loaded == true then luabsd.cfg:unload(); luabsd.cfg.loaded = nil end
end

function luabsd.cfg:rolback()
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
			if ds[luabsd.cfg.init.path]['net:autoifname'] ~= '-' then luabsd.cfg.autoifname = ds[luabsd.cfg.init.path]['net:autoifname'] end
			if ds[luabsd.cfg.init.path]['net:hostname'] ~= '-' then luabsd.cfg.hostname = ds[luabsd.cfg.init.path]['net:hostname'] end
			if ds[luabsd.cfg.init.path]['kernel:modules'] ~= '-' then luabsd.cfg.kldlist = ds[luabsd.cfg.init.path]['kernel:modules'] end
			if ds[luabsd.cfg.init.path]['kernel:modulesparallel'] ~= '-' then luabsd.cfg.kldlistparallel = ds[luabsd.cfg.init.path]['kernel:modulesparallel'] end
			if ds[luabsd.cfg.init.path]['net:netgraph'] ~= '-' then luabsd.cfg.netgraph = ds[luabsd.cfg.init.path]['net:netgraph'] end
			if ds[luabsd.cfg.init.path]['net:route_default'] ~= '-' then
				luabsd.cfg.route = {}
				luabsd.cfg.route[0] = {}
				luabsd.cfg.route[0].gw = {}
				luabsd.cfg.route[0].gw.ip4 = ds[luabsd.cfg.init.path]['net:route_default']
				if ds[luabsd.cfg.init.path]['net:route_default:status'] and ds[luabsd.cfg.init.path]['net:route_default:status'] == '1' then
					luabsd.cfg.route[0].gw.enable = true
				else
					luabsd.cfg.route[0].gw.enable = false
				end
			end
			if ds[luabsd.cfg.init.path]['net:route_list'] ~= '-' then
				if not luabsd.cfg.route then luabsd.cfg.route = {} end
				local r
				local count = 0
				for r in string.gmatch(ds[luabsd.cfg.init.path]['net:route_list'], '[^,]*') do
					local ids = zfs.ds_list(luabsd.cfg.init.path, {'net:route_static_'..r..'_gtw', 'net:route_static_'..r..'_dest', 'net:route_static_'..r..'_type', 'net:route_static_'..r..'_status', 'net:route_static_'..r..'_fib'})
					if ids then
						local fibnum = 0
						if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_fib'] ~= '-' then fibnum = tonumber(ids[luabsd.cfg.init.path]['net:route_static_'..r..'_fib']) end
						if not luabsd.cfg.route[fibnum] then luabsd.cfg.route[fibnum] = {} end
						if not luabsd.cfg.route[fibnum].st then luabsd.cfg.route[fibnum].st = {} end
						luabsd.cfg.route[fibnum].st[count] = {}
						if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_status'] ~= '-' and ids[luabsd.cfg.init.path]['net:route_static_'..r..'_status'] == '1' then
							luabsd.cfg.route[fibnum].st[count].enable = true
						else
							luabsd.cfg.route[fibnum].st[count].enable = false
						end
						if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_type'] ~= '-' then luabsd.cfg.route[fibnum].st[count].type = ids[luabsd.cfg.init.path]['net:route_static_'..r..'_type'] end
						if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_dest'] ~= '-' then luabsd.cfg.route[fibnum].st[count].dest = ids[luabsd.cfg.init.path]['net:route_static_'..r..'_dest'] end
						if ids[luabsd.cfg.init.path]['net:route_static_'..r..'_gtw'] ~= '-' then luabsd.cfg.route[fibnum].st[count].addr = ids[luabsd.cfg.init.path]['net:route_static_'..r..'_gtw'] end
						luabsd.cfg.route[fibnum].st[count].name = r
						luabsd.cfg.route[fibnum].st[count].proto = 4
						count = count + 1
					end
				end
			end
			if ds[luabsd.cfg.init.path]['daemond:count'] ~= '-' then
				local count = tonumber(ds[luabsd.cfg.init.path]['daemond:count'])
				local n
				for n = 1,count do
					local pref = 'daemond:'..n
					local ids = zfs.ds_list(luabsd.cfg.init.path, {pref..':name', pref..':comment', pref..':enable', pref..':type', pref..':command', pref..':args', pref..':nopid', pref..':stop'})
					if not luabsd.cfg.services then luabsd.cfg.services = {} end
					luabsd.cfg.services[n] = {}
					if ids[luabsd.cfg.init.path][pref..':name'] ~= '-' then luabsd.cfg.services[n].name = ids[luabsd.cfg.init.path][pref..':name'] end
					if ids[luabsd.cfg.init.path][pref..':comment'] ~= '-' then luabsd.cfg.services[n].comment = ids[luabsd.cfg.init.path][pref..':comment'] end
					if ids[luabsd.cfg.init.path][pref..':enable'] ~= '-' and ids[luabsd.cfg.init.path][pref..':enable'] == 'true' then
						luabsd.cfg.services[n].enable = true
					else
						luabsd.cfg.services[n].enable = false
					end
					if ids[luabsd.cfg.init.path][pref..':type'] ~= '-' then luabsd.cfg.services[n].type = ids[luabsd.cfg.init.path][pref..':type'] end
					if ids[luabsd.cfg.init.path][pref..':command'] ~= '-' then luabsd.cfg.services[n].command = ids[luabsd.cfg.init.path][pref..':command'] end
					if ids[luabsd.cfg.init.path][pref..':args'] ~= '-' then luabsd.cfg.services[n].args = ids[luabsd.cfg.init.path][pref..':args'] end
					if ids[luabsd.cfg.init.path][pref..':nopid'] ~= '-' and ids[luabsd.cfg.init.path][pref..':nopid'] == 'true' then
						luabsd.cfg.services[n].nopidfile = true
					else
						luabsd.cfg.services[n].nopidfile = false
					end
					if ids[luabsd.cfg.init.path][pref..':stop'] ~= '-' then luabsd.cfg.services[n].stop = ids[luabsd.cfg.init.path][pref..':stop'] end
				end
			end
			if ds[luabsd.cfg.init.path]['net:ifconfig_rename'] ~= '-' then
				luabsd.cfg.ifaces = {}
				for ifname in string.gmatch(ds[luabsd.cfg.init.path]['net:ifconfig_rename'], '[^,]*') do
					if not luabsd.cfg.ifaces[ifname] then luabsd.cfg.ifaces[ifname] = {} end
					local pref = 'net:ifconfig:'..ifname
					local ids = zfs.ds_list(luabsd.cfg.init.path, {pref..'_enable', pref..'_type', pref..'_create', pref..'_name', pref..'_mac', pref .. '_flags'});
					if ids[luabsd.cfg.init.path][pref .. '_enable'] ~= '-' then luabsd.cfg.ifaces[ifname].enable = luabsd.subr.toboolean(ids[luabsd.cfg.init.path][pref .. '_enable']) end
					if ids[luabsd.cfg.init.path][pref .. '_type'] ~= '-' then luabsd.cfg.ifaces[ifname].type = ids[luabsd.cfg.init.path][pref .. '_type'] end
					if ids[luabsd.cfg.init.path][pref .. '_create'] ~= '-' then luabsd.cfg.ifaces[ifname].create = luabsd.subr.toboolean(ids[luabsd.cfg.init.path][pref .. '_create']) end
					if ids[luabsd.cfg.init.path][pref .. '_name'] ~= '-' then luabsd.cfg.ifaces[ifname].name = ids[luabsd.cfg.init.path][pref .. '_name'] end
					if ids[luabsd.cfg.init.path][pref .. '_mac'] ~= '-' then luabsd.cfg.ifaces[ifname].mac = ids[luabsd.cfg.init.path][pref .. '_mac'] end
					if ids[luabsd.cfg.init.path][pref .. '_flags'] ~= '-' then luabsd.cfg.ifaces[ifname].flags = ids[luabsd.cfg.init.path][pref .. '_flags'] end
					if ids[luabsd.cfg.init.path][pref .. '_before'] ~= '-' then luabsd.cfg.ifaces[ifname].before = ids[luabsd.cfg.init.path][pref .. '_before'] end
					if ids[luabsd.cfg.init.path][pref .. '_group'] ~= '-' then luabsd.cfg.ifaces[ifname].group = tonumber(ids[luabsd.cfg.init.path][pref .. '_group']) end
					if ids[luabsd.cfg.init.path][pref .. '_user'] ~= '-' then luabsd.cfg.ifaces[ifname].user = tonumber(ids[luabsd.cfg.init.path][pref .. '_user']) end
				end
			end
			if ds[luabsd.cfg.init.path]['net:ifconfig_list'] ~= '-' then
				if not luabsd.cfg.ifaces then luabsd.cfg.ifaces = {} end
				for ifname in string.gmatch(ds[luabsd.cfg.init.path]['net:ifconfig_list'], '[^,]*') do
					if not luabsd.cfg.ifaces[ifname] then luabsd.cfg.ifaces[ifname] = {} end
					local n = 0
					local ids = zfs.ds_list(luabsd.cfg.init.path, {'net:ifconfig_'..ifname..'_ip4_aliases', 'net:ifconfig_'..ifname..'_ip6_aliases', 'net:ifconfig_'..ifname..'_enable', 'net:ifconfig_'..ifname..'_flags'});
					if ids then
						if ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_enable'] ~= '-' then luabsd.cfg.ifaces[ifname].enable = luabsd.subr.toboolean(ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_enable']) end
						if ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_flags']  ~= '-' then luabsd.cfg.ifaces[ifname].flags = ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_flags'] end
						local acount = 0;
						if ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_aliases'] ~= '-' then
							if not luabsd.cfg.ifaces[ifname].ip then luabsd.cfg.ifaces[ifname].ip = {} end
							for n in string.gmatch(ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_aliases'], '[^,]*') do
								local alias = zfs.ds_list(luabsd.cfg.init.path, {'net:ifconfig_'..ifname..'_ip4_alias_'..n, 'net:ifconfig_'..ifname..'_ip4_netmask_'..n})
								if alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_alias_'..n] ~= '-' and alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_netmask_'..n] ~= '-' then
									acount = tonumber(n) + 1
									luabsd.cfg.ifaces[ifname].ip[acount] = {}
									luabsd.cfg.ifaces[ifname].ip[acount].addr = alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_alias_'..n]
									luabsd.cfg.ifaces[ifname].ip[acount].mask = alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip4_netmask_'..n]
									luabsd.cfg.ifaces[ifname].ip[acount].proto = 4
								end
							end
						end
						if ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_aliases'] ~= '-' then
							if not luabsd.cfg.ifaces[ifname].ip then luabsd.cfg.ifaces[ifname].ip = {} end
							for n in string.gmatch(ids[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_aliases'], '[^,]*') do
								local alias = zfs.ds_list(luabsd.cfg.init.path, {'net:ifconfig_'..ifname..'_ip6_alias_'..n, 'net:ifconfig_'..ifname..'_ip6_prefix_'..n})
								if alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_alias_'..n] ~= '-' and alias[luabsd.cfg.init.path]['net:ifconfig_'..ifname..'_ip6_prefix_'..n] ~= '-' then
									acount = tonumber(acount) + tonumber(n)
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

function luabsd.subr:loopbackup()
system.kldload("if_lo");
ifnet.setip("lo0",4,"127.0.0.1","255.255.255.0")
end

function luabsd.subr:useluamem()
	local temp
	temp = math.floor(collectgarbage("count")) / 1024 / 1024
	return temp
end

function luabsd.cfg:apply()
	if not luabsd.cfg.loaded == true then  pcall(luabsd.cfg.load)  end	
	if luabsd.cfg.dir.default then pcall(luabsd.subr.dir.mkdirdefault) end
	if luabsd.cfg.userspace == nil then  pcall(luabsd.cfg.recover)  end
	if luabsd.cfg.hostname then pcall(system.hostname, luabsd.cfg.hostname) end
	if luabsd.cfg.kldlistparallel then pcall(luabsd.subr.kld.load, luabsd.cfg.kldlistparallel, true) end
	if luabsd.cfg.kldlist then pcall(luabsd.subr.kld.load, luabsd.cfg.kldlist) end
	pcall(luabsd.subr.loopbackup)
    if luabsd.cfg.ifaces then luabsd.subr.ifnetd:start() end
	if luabsd.cfg.services then pcall(luabsd.subr.service.start) end
	if luabsd.cfg.route then pcall(luabsd.subr.routed.start) end
end






function luabsd:libinit (subr)
end
function luabsd:loadmod (name,arg1)
end
function luabsd:start (name)
end

function luabsd.cmd.clear()
	system.clear();
end

function luabsd.cmd.cat(path)
	local file,data
	if path and system.ls(path,true)  then 
			local file, data 
			file = io.open(path, "rb")
			data = file:read "*a"
			file:close()
			return (data)
	end
	file,data = nil,nil
end

function luabsd.cmd.cd(dir)
if dir then posix.unistd.chdir(dir) else system.pwd() end
end

function luabsd.cmd.ln(target, link)
	local ret, err = posix.unistd.link(target, link, true)
	if not ret then
		print(err)
	end
end

function luabsd.cmd.ip:ping(host,timeout)
	local M,HOST,TIMEOUT = posix.sys.socket,"8.8.8.8","2"
	if host then HOST=host end
	if timeout then TIMEOUT = timeout end

   local fd, err = M.socket(M.AF_INET, M.SOCK_RAW, M.IPPROTO_ICMP)
   if not fd then
   	print(err)
   	return nil
   end
   assert(fd, err)
   M.setsockopt(fd, M.SOL_SOCKET, M.SO_SNDTIMEO, tonumber(TIMEOUT), 0)
   M.setsockopt(fd, M.SOL_SOCKET, M.SO_RCVTIMEO, tonumber(TIMEOUT), 0)

   -- Create raw ICMP echo (ping) message

   local data = string.char(0x08, 0x00, 0x89, 0x98, 0x6e, 0x63, 0x00, 0x04, 0x00)

   -- Send message

   local ok, err = M.sendto(fd, data, {family=M.AF_INET, addr=host, port=0})
   if not ok then
   	print(err)
   	return nil
   end
   -- assert(ok, err)

   -- Read reply

   local data, sa = M.recvfrom(fd, 1024)
   if not data then
   	print(sa)
   	return nil
   end
   -- assert(data, sa)

   if data then
      print('Received ICMP message from ' .. sa.addr)
   end
end

function luabsd.cmd.ping(host,timeout)
	luabsd.cmd.ip:ping(host,timeout)
end

function luabsd.cmd.ip:show(...)
	term.color(32)

	arguments = {...}
	arguments.n = #{...}
 local a,a1,a2,b
 local il = ifnet.list();
 if arguments.n == 0 then

 	for a,b in pairs(il) do 
 		for a1,a2 in pairs(ifnet.info(a)) do 
 			print(a1); 
 			if b == 0 then
 				print("\tstatus:\tno carrier "..b)
 			elseif b == 1 then
 				print("\tstatus:\tactive "..b)
 			else
 				print("\tstatus:\terror "..b)
 			end
 				for an1,an2 in pairs(a2) do 
 					print("\t" .. an1,an2); 
 					if (an1 == "groups") then
 						local an3,an4
 						for an3,an4 in pairs(an2) do
 							print("\t\t" .. an4)
 						end
 					elseif (an1 == "flags") then
 						local an3,an4
 						for an3,an4 in pairs(an2) do
 							print("\t\tflags: " .. an4)
 						end
 					elseif (an1 == "nd6") then
 						local an3,an4
 						for an3,an4 in pairs(an2) do
 							print("\t\tnd6: " .. an4)
 						end
 					elseif (an1 == "ip4") then
 						local an3,an4
 						for an3,an4 in pairs(an2) do
 							print("\t\tip: " .. an4.ip .. " netmask: " .. an4.netmask .. " broadcast: " .. an4.broadcast)
 						end
 					elseif (an1 == "ip6") then
 						local an3,an4
 						for an3,an4 in pairs(an2) do
 							print("\t\tip: " .. an4.ip .. " prefix: " .. an4.prefix)
 						end
 					
 					end

 				end 
 		end 
 	end
elseif arguments.n == 1 then
 		for a1,a2 in pairs(ifnet.info(arguments[1])) do 
 			print(a1);
 			b = il[a1];
 			if b == 0 then
 				print("\tstatus:\tno carrier")
 			elseif b == 1 then
 				print("\tstatus:\tactive")
 			else
 				print("\tstatus:\terror")
 			end
			for an1,an2 in pairs(a2) do 
				print("\t" .. an1,an2); 
				if (an1 == "groups") then
					local an3,an4
					for an3,an4 in pairs(an2) do
						print("\t\t" .. an4)
					end
				elseif (an1 == "flags") then
					local an3,an4
					for an3,an4 in pairs(an2) do
						print("\t\tflags: " .. an4)
					end
				elseif (an1 == "nd6") then
					local an3,an4
					for an3,an4 in pairs(an2) do
						print("\t\tnd6: " .. an4)
					end
				elseif (an1 == "ip4") then
					local an3,an4
					for an3,an4 in pairs(an2) do
						print("\t\tip: " .. an4.ip .. " netmask: " .. an4.netmask .. " broadcast: " .. an4.broadcast)
					end
				elseif (an1 == "ip6") then
					local an3,an4
					for an3,an4 in pairs(an2) do
						print("\t\tip: " .. an4.ip .. " prefix: " .. an4.prefix)
					end
				end
			end 
 		end

else
	print("error: not found arguments")
end
term.color(0)
end

function luabsd.cmd.ssl:autogen(ssldir,sslname)
	local sslpath, sslcertname = ssldir or luabsd.cfg.dir.ssl , sslname or 'default'
	if not system.ls(sslpath, true) then
		system.mkdir(sslpath, nil, true)
	end



	if not system.ls(sslpath.."/"..sslcertname..".key", true) or not system.ls(sslpath.."/"..sslcertname..".crt", true) then
		local unpack = table.unpack
		local pkey = openssl.pkey
		local nrsa =  {'rsa',2048}
		local rsa = pkey.new(unpack(nrsa))

		local file = io.open(sslpath.."/"..sslcertname..".key", "w")
		file:write(pkey.export(rsa))
		io.close(file)

		local cadn = openssl.x509.name.new({{commonName='hvm.local'}, {O='CyberSystems LLP'}})
		local req = openssl.x509.req.new(cadn, rsa)
		req:sign(rsa, 'sha256')
		local cacert = openssl.x509.new(
		  os.time(),      --serialNumber
		  req     --copy name and extensions
		)
		cacert:notbefore(os.time())
		cacert:notafter(os.time() + 3600*24*365)
		cacert:sign(rsa, cacert)  -- self-signed

		local file = io.open(sslpath.."/default.crt", "w")
		file:write(cacert:export())
		io.close(file)
	end
	if not system.ls(sslpath.."/certificate.pem", true) and system.ls(sslpath.."/"..sslcertname..".key", true) and system.ls(sslpath.."/"..sslcertname..".crt", true) then
		local file = io.open(sslpath.."/"..sslcertname..".key", "rb" )
		local certkey = file:read '*a'
		file:close()
		file = io.open(sslpath.."/"..sslcertname..".crt", "rb" )
		local certtls = file:read '*a'
		file:close()
		file = io.open(sslpath.."/certificate.pem", "w" )
		file:write(certkey)
		file:close()
		file = io.open(sslpath.."/certificate.pem", "a" )
		file:write(certtls)
		file:close()
		file = nil
		certtls = nil
		certkey = nil
	end
end

function luabsd.cmd.ngctl:show()
        
        tb = luabsd.cmd.ngctl.list();
        for k,v in pairs(tb) do
                print("Name: " .. k .. "\t\t\tType: " .. v.type)
                if (v.hooks) then
                        print("\tLocal hook\tPeer hook\tPeer name\tPeer type")
                        for k1, v1 in pairs(v.hooks) do
                                print("\t" .. v1.ourhook .. "\t\t" .. v1.peerhook .. "\t\t" .. v1.peername .. "\t\t" .. v1.peertype)
                        end
                end
                print("-------------------------------------------------------------------------")
        end
end

function luabsd.cmd.kldstat(libmod)
	local k,v
	for k,v in pairs(system.kldstat(libmod)) do print(k, posix.libgen.dirname(v.path), v.name) end
	k,v = nil, nil
end

--[[______________________########### ZFS FUNCTIONS #########__________________________]]--

function luabsd.cmd.zfs:set(dataset,key,value)
	if dataset and key and value then
		local param = {}
			  param[key] = value
		luabsd.cmd.zfs.ds_update(dataset,param)
		param = nil
	else
		print("Error arguments: <dataset>,<key>,<value> \nor please use zfs.ds_update")
	end

end

function luabsd.cmd.zfs:list()
	local col0_len, col1_len, header,  data, k, v = 0, 0, {}, zfs.ds_list({"name","mountpoint"});
	header[0] = "DATASET"
    header[1] = "MOUNTPOINT"
	for k,v in luabsd.subr.spairs(data) do 
		if col0_len < k:len() then
			col0_len = k:len()
		end
	end
	col0_len = col0_len + 5
	col1_len = col1_len + 5
	header[0] = string.format("%" .. -col0_len .. "s", header[0]);
	header[1] = string.format("%" .. -col1_len .. "s", header[1]);
	io.write(header[0], header[1], "\n\n")
	for k,v in luabsd.subr.spairs(data) do 
		k = string.format("%" .. -col0_len .. "s", k);
		io.write(k, v.mountpoint, "\n");
	end
		io.flush()
	io.flush()

	k,v = nil, nil
end



function luabsd.subr.spairs(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
    	table.sort(a, f)
    	local i = 0      -- iterator variable
		local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end


function luabsd.cmd.zfs:mount(zpool_name,cmd)
	if not zpool_name then return "'<zpool or dataset|auto>','<auto|none>' \n example: zfs:mount('zroot')" end
		term.color(36)
		if  zpool_name and cmd == "auto" then
				local dlist
				dlist = zfs.ds_list(zpool_name, {'mountpoint', 'canmount'});
				if dlist then
					for k,v in luabsd.subr.spairs(dlist) do 
						if v.mountpoint ~= 'noauto' and  v.mountpoint ~= 'none' and v.mountpoint ~= '-' and v.canmount == 'on' then
							io.write("MOUNT: "..k.."... ")
							if not luabsd.subr.checkpoint(k, 'dev') == true and luabsd.subr.dir.checkexists(v.mountpoint) and system.mount('zfs', v.mountpoint, k) then
								term.color(32)
								print("[ OK ]")
								result = true
							elseif luabsd.subr.checkpoint(zpool_name, 'dev') then
								term.color(33)
								print("[ ALREADY EXIST ]")
								result = true
							else
								term.color(31)
								print("[ FAILE ]")
								result = false						
							end
						end
					end
					
				end
				dlist = nil
		elseif zpool_name == "auto" and not cmd then
				local zpool_list, data, k,v,zk,zv = zfs.zpool_list({'health'})
				for zk,zv in luabsd.subr.spairs(zpool_list)  do
					if zv.name and string.lower(zv.health) == "online" then
						---

							local dlist = zfs.ds_list(zv.name, {'mountpoint', 'canmount'});
							if dlist then
								for k,v in luabsd.subr.spairs(dlist) do 
									if v.mountpoint and  v.mountpoint ~= 'none' and v.mountpoint ~= '-' and v.canmount == 'on' then
									io.write("MOUNT: "..k.."... ")
										if not luabsd.subr.checkpoint(k, 'dev') == true and luabsd.subr.dir.checkexists(v.mountpoint) and system.mount('zfs', v.mountpoint, k) then
											term.color(32)
											print("[ OK ]")
										elseif luabsd.subr.checkpoint(k, 'dev') then
											term.color(33)
											print("[ ALREADY EXIST ]")
											result = true
										else
											term.color(31)
											print("[ FAILE ]")
											result = false						
										end
									end
								end
								k,v = nil,nil
							end
							dlist = nil
						---

					end
				end
				zpool_list, data, zk, zv =nil,nil,nil,nil
		elseif zpool_name == "auto" and cmd == 'plusnoauto' then
				local zpool_list, data, k,v,zk,zv = zfs.zpool_list({'health'})
				for zk,zv in luabsd.subr.spairs(zpool_list)  do
					if zv.name and string.lower(zv.health) == "online" then
						---

							local dlist = zfs.ds_list(zv.name, {'mountpoint', 'canmount'});
							if dlist then
								for k,v in luabsd.subr.spairs(dlist) do 
									if v.mountpoint and  v.mountpoint ~= 'none' and v.mountpoint ~= '-' and v.canmount ~= 'off'  then
									io.write("MOUNT: "..k.."... ")
										if not luabsd.subr.checkpoint(k, 'dev') == true and luabsd.subr.dir.checkexists(v.mountpoint) and system.mount('zfs', v.mountpoint, k) then
											term.color(32)
											print("[ OK ]")
										elseif luabsd.subr.checkpoint(k, 'dev') then
											term.color(33)
											print("[ ALREADY EXIST ]")
											result = true
										else
											term.color(31)
											print("[ FAILE ]")
											result = false						
										end
									end
								end
								k,v = nil,nil
							end
							dlist = nil
						---

					end
				end
				zpool_list, data, zk, zv =nil,nil,nil,nil
		elseif zpool_name and luabsd.subr.checkpoint(zpool_name, 'dev') and not cmd or cmd == "none" then
				local data = zfs.ds_list(zpool_name, { 'mountpoint', 'canmount' })[zpool_name]
				if data.mountpoint and data.mountpoint ~= '-' and data.mountpoint ~= 'none' and data.canmount ~= "off" then
					io.write("MOUNT: "..zpool_name.."... ")
					if not luabsd.subr.checkpoint(zpool_name, 'dev') == true and system.ls(data.mountpoint,true ) and system.mount('zfs', data.mountpoint, zpool_name) then
						term.color(32)
						print("[ OK ]")
						result = true
					elseif luabsd.subr.checkpoint(zpool_name, 'dev') then
						term.color(33)
						print("[ ALREADY EXIST ]")
						result = true
					else
						term.color(31)
						print("[ FAILE ]")
						result = false						
					end
				end	
				data = nil
		end 
		io.flush()
		term.color(0)		
		return result		
end



function luabsd.cmd.ipfw:show()
	    local t,k,v,k1,v1 = ipfw.rules_list()
        for k,v in pairs(t) do
            print(k)
            for k1,v1 in pairs(v) do
                print(k1,v1)
            end
        end
        t,k,v,k1,v1 = nil,nil,nil,nil,nil
end

function luabsd.cmd.ipfw:list()
	local k,v
	for k,v in pairs(ipfw.rules_list()) do print (v.rule_num.." "..v.rule) end
end



--[[______________________########### CMD FUNCTIONS #########__________________________]]--




function luabsd.cmd.help(help)
	local k,v
		if help then
			for k,v in pairs(help) do print(k,v) end
		elseif not help then
			for k,v in pairs(_G) do print(k,v) end
		end
	k,v = nil,nil
end

function luabsd.cmd.hostname()
	return posix.sys.utsname.uname().nodename
end

function luabsd.cmd.uname()
	return luabsd.cmd.help(posix.sys.utsname.uname())
end


function luabsd.cmd.table:show(tb)
		luabsd.subr.table_print(tb)
end
function luabsd.cmd.table:save(tb,file)
	local file,data

			file = io.open(file, "w+")
			file:write(luabsd.subr.table_print(tb))
			file:close()
			io.flush()

end
function luabsd.cmd.table:log(tb,file)
	local file,data

			file = io.open(file, "a+")
			file:write(luabsd.subr.table_print(tb))
			file:close()
			io.flush()

end
function luabsd.cmd.table:open(tb,file)
		local file,data 
		if system.ls(file) then
			file = io.open(file, "rb")
			data = file:read("*a")
			file:close()
			file = nil
			io.flush()
			return tostring(data)
		else
			print("Error open file")
		end			
end
function luabsd.cmd.table:load(tb)
		local file,data 
		if system.ls(file) then
			file = io.open(file, "rb")
			data = file:read("*a")
			file:close()
			file = nil
			io.flush()
		else
			print("Error open file")
		end
		
end

function luabsd.cmd.ip:save(ifaces)
local count,unit
if not luabsd.cfg.loaded == true then luabsd.cfg:load(); luabsd.cfg.loaded = true end

local function iface_parse()
		ifnet.list()
end

local function savetocarrier()
		if luabsd.cfg.init.fstype and luabsd.cfg.init.fstype == "zfs" and luabsd.cfg.init.path and luabsd.cfg.ifaces then
			
		end 
end

		if ifaces and luabsd.cfg.ifaces then
			for unit in string.gmatch(list, "[^%s]+") do

			end
		end

if luabsd.cfg.loaded == true then luabsd.cfg:unload(); luabsd.cfg.loaded = nil end

count,unit = nil,nil
end

function luabsd.subr.firmware:update()

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
	io.flush()

	k,v = nil, nil
end


-- luabsd.env:read()
-- -- -- test = luabsd.subr.file:read("/tmp/loader2.conf")
-- -- -- print(test)
-- -- -- print(luabsd.cfg.init.path)
-- -- -- print(luabsd.cfg.init.type)
-- luabsd.cfg:load()
-- for k,v in pairs(luabsd.cfg.services) do if v.name == "ews" then print(v.comment) print(v.command) end end
-- -- print(luabsd.cfg.services)
--  -- luabsd.cmd.kldstat()
-- luabsd.subr.service:list()	
-- luabsd.env.show()
-- -- for k,v in pairs(luabsd.cfg.route[1]) do print(k,v) end
-- --luabsd.subr.routed:show()
--for k,v in pairs(luabsd.cfg.route['0']) do print(k,v) end
-- -- luabsd.cmd.df()
-- -- print("CHECK /tmp: ", luabsd.cfg:checkpoint("zrootfs/usr/home2", 'dev'))
-- -- for a,b in pairs(luabsd.cfg.services[1]) do print(a,b) end
-- luabsd.cfg:unload()
 -- luabsd.cmd.zfs:list()

return luabsd