#!/bin/lua
--[[ BSD IPFW RULES SCRIPT STARTUP SYSTEM ]]--
function luabsd.cfg.ipfw:load()
	local data = bdb.get_all("objects", luabsd.cfg.db.dir);
	local k,v,entry,obj_n, obj_id,n
	for k,v in pairs(data) do
		ipfw.table_create('o' .. k);
		for n, entry in pairs(v.ips) do
			ipfw.table_add('o' .. k, entry);
		end
	end
	data = bdb.get_all("groups", luabsd.cfg.db.dir);
	for k,v in pairs(data) do
		ipfw.table_create('g' .. k);
		for obj_n, obj_id in pairs(v.objects) do
			local obj = bdb.get("objects", luabsd.cfg.db.dir, obj_id)
			for n, entry in pairs(obj.ips) do
				ipfw.table_add('g' .. k, entry);
			end

			ipfw.table_add('g' .. k, entry);
		end
	end
	data = bdb.get_all("plainnat", luabsd.cfg.db.dir);
	for k,v in pairs(data) do
		ipfw.nat_config(k, v.nat);
	end
	data = bdb.get_all("plainpipe", luabsd.cfg.db.dir);
	for k,v in pairs(data) do
		ipfw.pipe_config(k, v.pipe);
	end
	data = bdb.get_all("plainqueue", luabsd.cfg.db.dir);
	for k,v in pairs(data) do
		ipfw.queue_config(k, v.queue);
	end
	data = bdb.get_all("plainrules", luabsd.cfg.db.dir);
	for k,v in pairs(data) do
		local r = v.rule;
		r = r:sub(r:find(' ') + 1, r:len())
		ipfw.rule_add(r);
	end
end

pcall(luabsd.cfg.ipfw.load)