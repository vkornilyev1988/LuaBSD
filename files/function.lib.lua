
function read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end



function rcload_json(path)
	local a,a1,a2,a3,b,b1,b2,b3
	local file = read_file(path);

    local cjdata = cjson.decode(file);
    local ifaces = cjdata.ifaces;
    for a,b in pairs(ifaces) do
    	if b.ip == nil then
	    	for a1,b1 in pairs(b) do
	    		if a1 == "name" then 
	    			term.color(32)
	    			print("rename: "..a..": "..b.name)
	    			pcall(ip.name, a,b.name) 
			    end
			end
		end
    end

    for a,b in pairs(ifaces) do
    	if b.ip ~= nil then
		    	for a2,b2 in pairs(b.ip) do 
		    		if b2.addr == "dhcp" then
		    			pcall(ip.dhcp, a)
		    		else
		    			term.color(32)
		    			print("Static ip: " .. a .. " addr: " .. b2.addr .. "...")
		    			pcall(ip.set, a,b2.proto,b2.addr,b2.mask)
		    			term.color(0)
		    		end
		    	end
		end
    end
   term.color(32)

   if cjdata.hostname ~= nil then hostname(cjdata.hostname); print("Hostname: " .. cjdata.hostname) end
   if cjdata.defaultrouter ~= nil then routeadd("gw",4,cjdata.defaultrouter); print("Gateway: " .. cjdata.defaultrouter) end
   if cjdata.kldlist ~= nil then 
   local thread_i
   for thread_i string.gmatch(cjdata.kldlist, "[^%s]+") do
   		coroutine.create(function () system.kldload(thread_i) end)
   end
   thread_i = nil
end
	-- host = cjdata.hostname

    --if host ~= nil then hostname(host) end
    