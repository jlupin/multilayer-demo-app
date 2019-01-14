---------------------------------
-- CommonSetMicroserviceStatus --
---------------------------------
function CommonSetMicroserviceState(name, status, available, activated)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN(" .. name .. "," .. status .. "," .. available .. "," .. activated .. ")")

  local state = G_MICROSERVICE_STATE.AVAILABLE

  if activated == "false"
  then
    state = G_MICROSERVICE_STATE.DEACTIVATED
  end

  if available == "false"
  then
    state = G_MICROSERVICE_STATE.UNAVAILABLE
  end

  if status ~= G_MICROSERVICE_STATE.RUNNING
  then
    state = status
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END(state): " .. state)

  return state
end


-----------------------------------
-- CommonGetMicroserviceProperty --
-----------------------------------
function CommonGetMicroserviceProperty(microservice_name,microservice_property,default_value)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN(" .. tostring(microservice_name) .. "," .. tostring(microservice_property).. "," .. tostring(default_value) .. ")")

  if not microservice_name
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microservice_name is nil")
    return default_value,"microservice_name is nil"
  end

  if not microservice_property
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microservice_property is nil")
    return default_value,"microservice_property is nil"
  end

  local microserviceListJson = RegGet("nodeInfo","microserviceList")

  if not microserviceListJson
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceListJson is nil")
    return default_value
  end

  local microserviceList = GenJsonToTable(microserviceListJson)

  if not microserviceList
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceList is nil")
    return default_value,"microserviceList is nil"
  end

  for list_key, list_value in pairs(microserviceList)
  do
    if microservice_name == list_value["name"]
    then
      return list_value[microservice_property]
    end
  end
  return default_value
end


------------------------------
-- CommonMicroserviceFilter --
------------------------------
function CommonMicroserviceFilter(microservice_name,server_port)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. microservice_name .. "," .. server_port .. ")")

  local microserviceFilterListJson = RegGet("nodeInfo","microserviceFilterList")
  local microserviceFilterList = GenJsonToTable(microserviceFilterListJson)

  if not microserviceFilterList
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceFilterList is nil")
    return nil
  end

  local microserviceFilterInput = microservice_name .. "." .. server_port

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceFilterInput=(" .. microserviceFilterInput .. ")")

  if microserviceFilterList[microservice_name]
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Checking filters: OK*")
    return true,""
  else
    if microserviceFilterList[microserviceFilterInput]
    then
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Checking filters: OK")
      return true,""
    else
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Checking filters: RESTRICTED")
      return nil,"restricted"
    end
  end
end

-------------------------------
-- CommonContextRoutesFilter --
-------------------------------
function CommonContextRoutesFilter(context_routes,server_port)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. type(context_routes) .. "," .. server_port .. ")")

  local routes_idx = ""
  local routes_value = ""

  local contextRoutesFiltered = {}

  for routes_idx,routes_value in pairs(context_routes)
  do
    if CommonMicroserviceFilter(routes_value.name,server_port)
    then
      table.insert(contextRoutesFiltered,routes_value)
    end
  end

  return contextRoutesFiltered
end



-------------------------------
-- CommonContextRoutesFilter --
-------------------------------
function CommonGetRawPriorityForHost(host,discovery_port)
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(host) .. "," .. GenNilHandler(discovery_port) .. ")")

  if not host or not discovery_port
  then
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END (input data error)")
      return nil
  end

  local hostItem = ""
  local routePriority = ""

  for hostItem in string.gmatch("." .. host,"%.([^%.]+)")
  do
      if hostItem
      then
        ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": hostItem=(" .. hostItem .. ")")
        hostItem = tostring(tonumber(hostItem) + 100)
        ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Normalized hostItem=(" .. hostItem .. ")")
        routePriority = routePriority .. hostItem
        ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": PARTIAL routePriority=(" .. routePriority .. ")")
      end
  end

  routePriority = tonumber(routePriority .. tostring(tonumber(discovery_port) + 10000))

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END (routePriority): " .. routePriority)
  return routePriority

end


-------------------------------
-- CommonContextRoutesFilter --
-------------------------------
function CommonGetContextRoutesPriorities(context_routes,elastic_api)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. type(context_routes) .. "," .. GenNilHandler(elastic_api) .. ")")

  local contextRoutes_idx = ""
  local contextRoutes_value = ""

  local contextRoutesPriorities = {}
  local contextRoutesWithPriorities = context_routes


  -- set priorities
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Setting priorities: BEGIN")
  for contextRoutes_idx,contextRoutes_value in pairs(context_routes)
  do
    local microserviceRouteKey = CommonGetMicroserviceRouteKey(contextRoutes_value,elastic_api)

    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Setting priorities: " .. microserviceRouteKey .. ": BEGIN")

    local routeRawPriority = CommonGetRawPriorityForHost(contextRoutes_value.host,contextRoutes_value.discoveryPort)

    if routeRawPriority
    then

      table.insert(contextRoutesPriorities,{
        ["microserviceRouteKey"] = microserviceRouteKey,
        ["rawPriority"] = routeRawPriority
      })

      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Setting priorities: " .. microserviceRouteKey .. ": END(routePriority): " .. routeRawPriority)
    else
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Setting priorities: " .. microserviceRouteKey .. ": END(routePriority): nil")
    end
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Setting priorities: END(contextRoutesPriorities): " .. GenTableToJson(contextRoutesPriorities))

  local contextRoutesPriorities_key = ""
  local contextRoutesPriorities_value = ""

  -- normalize
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Normalize: BEGIN")
  local lowestPriority = GenListMinValue(contextRoutesPriorities,"rawPriority")

  if not lowestPriority
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Normalize: END: lowestPriority is nil")
    return context_routes
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Normalize: lowestPriority=(" .. lowestPriority .. ")")

  for contextRoutesPriorities_key,contextRoutesPriorities_value in pairs(contextRoutesPriorities)
  do
    contextRoutesPriorities_value.normalizedPriority = contextRoutesPriorities_value.rawPriority - lowestPriority + 1
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Normalize: " .. contextRoutesPriorities_key .. " after being normalized: " .. contextRoutesPriorities_value.normalizedPriority)
  end
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Normalize: END(contextRoutesPriorities): " .. GenTableToJson(contextRoutesPriorities))

  --  order
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Order: BEGIN")

  local contextRoutesPrioritiesTmp = {}

  local idx = 1
  local orderNum = 1
  local baseline = -1
  local lowestNormalizedPriority = GenListMinValue(contextRoutesPriorities,"normalizedPriority",baseline)

  while idx <= GenTableLen(contextRoutesPriorities)
  do
    if not lowestNormalizedPriority
    then
      break
    end

    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Order: lowestNormalizedPriority: " .. lowestNormalizedPriority .. ": BEGIN")

    for contextRoutesPriorities_key,contextRoutesPriorities_value in pairs(contextRoutesPriorities)
    do
        if contextRoutesPriorities_value.normalizedPriority <= lowestNormalizedPriority and contextRoutesPriorities_value.normalizedPriority > baseline
        then
          table.insert(contextRoutesPrioritiesTmp,contextRoutesPriorities_value)
          ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Order: orderNum(" .. contextRoutesPriorities_value.microserviceRouteKey .. "," .. contextRoutesPriorities_value.normalizedPriority .. "): " .. orderNum)
          orderNum = orderNum + 1
        end
    end
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Order: lowestNormalizedPriority: " .. lowestNormalizedPriority .. ": END")

    baseline = lowestNormalizedPriority
    lowestNormalizedPriority = GenListMinValue(contextRoutesPriorities,"normalizedPriority",baseline)

    idx = idx + 1
  end

  contextRoutesPriorities = contextRoutesPrioritiesTmp
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Order: END(contextRoutesPriorities): " .. GenTableToJson(contextRoutesPriorities))

  -- shift & set final priority

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: BEGIN")

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: middle-bottom iteration: BEGIN")

  local localHostPointer = 0
  local normalizedPriorityPointer = 1
  local priority = 1
  local idx = 1

  for contextRoutesPriorities_key,contextRoutesPriorities_value in pairs(contextRoutesPriorities)
  do

    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: middle-bottom iteration: microserviceRouteKey: " .. contextRoutesPriorities_value.microserviceRouteKey .. ": BEGIN")

    if contextRoutesPriorities_value.rawPriority == G_LOCALHOST_RAW_PRIORITY
    then

      contextRoutesPriorities_value.priority = priority
      normalizedPriorityPointer = contextRoutesPriorities_value.normalizedPriority

      if localHostPointer == 0
      then
        localHostPointer = idx
      end

      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: middle-bottom iteration: microserviceRouteKey: " .. contextRoutesPriorities_value.microserviceRouteKey .. ": localHostPointer=(" .. localHostPointer .. ")")
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: middle-bottom iteration: microserviceRouteKey: " .. contextRoutesPriorities_value.microserviceRouteKey .. ": normalizedPriorityPointer=(" .. normalizedPriorityPointer .. ")")

    else
      if localHostPointer > 0
      then

        if contextRoutesPriorities_value.normalizedPriority ~= normalizedPriorityPointer
        then
          priority = priority + 1
        end

        contextRoutesPriorities_value.priority = priority
        normalizedPriorityPointer = contextRoutesPriorities_value.normalizedPriority
        ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: middle-bottom iteration: microserviceRouteKey: " .. contextRoutesPriorities_value.microserviceRouteKey .. ": normalizedPriorityPointer=(" .. normalizedPriorityPointer .. ")")

      end
    end

    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: middle-bottom iteration: microserviceRouteKey: " .. contextRoutesPriorities_value.microserviceRouteKey .. ": END(priority): " .. GenNilHandler(contextRoutesPriorities_value.priority))

    idx = idx + 1
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: middle-bottom iteration: END(contextRoutesPriorities): " .. GenTableToJson(contextRoutesPriorities))


  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: top-middle iteration: BEGIN")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: top-middle iteration: normalizedPriorityPointer=(" .. normalizedPriorityPointer .. ")")

  if localHostPointer == 0
  then
    localHostPointer = GenTableLen(contextRoutesPriorities) + 1
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: top-middle iteration: localHostPointer=(" .. localHostPointer .. ")")

  idx = 1
  while idx < localHostPointer
  do
    if contextRoutesPriorities[idx].normalizedPriority ~= normalizedPriorityPointer
    then
      priority = priority + 1
    end

    contextRoutesPriorities[idx].priority = priority
    normalizedPriorityPointer = contextRoutesPriorities[idx].normalizedPriority
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: top-middle iteration: microserviceRouteKey: " .. contextRoutesPriorities[idx].microserviceRouteKey .. ": normalizedPriorityPointer=(" .. normalizedPriorityPointer .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: top-middle iteration: microserviceRouteKey: " .. contextRoutesPriorities[idx].microserviceRouteKey .. ": priority=(" .. priority .. ")")

    idx = idx + 1
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: top-middle iteration: END(contextRoutesPriorities): " .. GenTableToJson(contextRoutesPriorities))
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Shift: END(contextRoutesPriorities): " .. GenTableToJson(contextRoutesPriorities))


  --- finally - saving shifted & normalized priorities to contextRoutes
  idx = 1
  while idx <= GenTableLen(contextRoutesWithPriorities)
  do

    local microserviceRouteKey = CommonGetMicroserviceRouteKey(contextRoutesWithPriorities[idx],elastic_api)

    for contextRoutesPriorities_key,contextRoutesPriorities_value in pairs(contextRoutesPriorities)
    do
      if contextRoutesPriorities_value.microserviceRouteKey == microserviceRouteKey
      then
        contextRoutesWithPriorities[idx].priority = contextRoutesPriorities_value.priority
      end
    end

    idx = idx + 1
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

  return contextRoutesWithPriorities
end

-----------------------------
-- CommonCheckInAdminTools --
-----------------------------
function CommonCheckInAdminTools(context_name)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(context_name) .. ")")

  local idx = 1
  while idx <= GenTableLen(discoveryAdminTools)
  do
    if discoveryAdminTools[idx] == context_name
    then
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": matched, return true")
      return true
    end
    idx = idx + 1
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": not matched, return nil")
  return nil
end

--------------------------------
-- CommonGetVirtualServerType --
--------------------------------
function CommonGetVirtualServerType(server_port)
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(server_port) .. ")")

  local nginxVirtualServerListJson = RegGet("nodeInfo","virtualServerList")
  if not nginxVirtualServerListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": nginxVirtualServerListJson is nil")
    return nil
  end

  local nginxVirtualServerList = GenJsonToTable(nginxVirtualServerListJson)

  if not nginxVirtualServerList
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": nginxVirtualServerList is nil")
    return nil
  end

  local idx = 1
  while idx <= GenTableLen(nginxVirtualServerList)
  do
    if nginxVirtualServerList[idx].port == server_port
    then
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": matched, return=(" .. nginxVirtualServerList[idx].type ..")")
      return nginxVirtualServerList[idx].type
    end
    idx = idx + 1
  end
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": not matched, return nil")
  return nil
end

------------------------------
-- CommonGetContextRouteKey --
------------------------------
function CommonGetContextRouteKey(api_type,context_name,server_port,elastic_api)
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(api_type) .. "," .. GenNilHandler(context_name) .. "," .. GenNilHandler(server_port) .. "," .. GenNilHandler(elastic_api) .. ")")

  return tostring(api_type) .. "." .. tostring(context_name) .. "." .. tostring(server_port) .. "." .. tostring(elastic_api)

end

-----------------------------------
-- CommonGetMicroserviceRouteKey --
-----------------------------------
function CommonGetMicroserviceRouteKey(route,elastic_api)
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. type(route) .. "," .. GenNilHandler(elastic_api) .. ")")

  if type(route) ~= "table"
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": route is not a table")
    return nil
  end

  if not elastic_api
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": elastic_api is nil")
    return nil
  end

  local microserviceRouteKey = tostring(route.name) .. "." .. tostring(route.host) .. "." .. tostring(route.discoveryPort) .. "." .. tostring(elastic_api)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceRouteKey=(" .. microserviceRouteKey .. ")")

  return microserviceRouteKey

end

--------------------------------------
-- CommonGetMicroserviceRouteCookie --
--------------------------------------
function CommonGetMicroserviceRouteCookie(microservice_route_key)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. tostring(microservice_route_key) .. ")")

  if not microservice_route_key
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microservice_route_key is nil")
    return nil
  end

  local md5 = require 'jlupin.md5'
  local microserviceRouteCookieHash = md5.sumhexa(microservice_route_key)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceRouteCookieHash=(" .. microserviceRouteCookieHash .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

  return microserviceRouteCookieHash

end

--------------------------------
-- CommonGetContextCookieName --
--------------------------------
function CommonGetContextCookieName(context_route_key)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. tostring(context_route_key) .. ")")

  if not context_route_key
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": context_route_key is nil")
    return nil
  end

  local md5 = require 'jlupin.md5'
  local cookieName = "jleb." .. md5.sumhexa(context_route_key)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": cookieName=(" .. cookieName .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

  return cookieName

end
