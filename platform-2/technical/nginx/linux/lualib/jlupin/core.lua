-------------------
-- CoreDiscovery --
-------------------
function CoreDiscovery()

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  DiscoverNode()
  DiscoverPeers()
  DiscoverMicroservices()
  DiscoverFilteredMicroservices()
  DiscoverRemoteMicroservices()
  DiscoverContexts()
  DiscoverRoutes()

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

end

------------------------------
-- CoreHealthDiscoveryTimer --
------------------------------
function CoreHealthDiscoveryTimer(premature)

  ngx.log(ngx.DEBUG, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- Setting the next iteration
  ngx.log(ngx.DEBUG, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Setting the next CoreHealthDiscoveryTimer timer iteration")
  local ok, err = ngx.timer.at(healthcheckPeriod, CoreHealthDiscoveryTimer)

  if not ok then
    if err == "process exiting"
    then
      ngx.log(ngx.NOTICE, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Setting a new CoreHealthDiscoveryTimer timer iteration has been aborted (" .. err ..")")
    else
      ngx.log(ngx.ERR, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Failed to set a new CoreHealthDiscoveryTimer timer iteration (" .. err ..")")
    end
  end

  -- Handling lock between workers in the discovery process
  local pid, err = RegGet("nodeInfo","healthDiscoveryTimerLock")

  if not pid
  then
    local lock, err = RegAdd("nodeInfo","healthDiscoveryTimerLock", ngx.worker.pid(), healthTimerLockTimeout)
    if lock then
      ngx.log(ngx.DEBUG, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. " has locked CoreHealthDiscoveryTimer process")
      pid = ngx.worker.pid()
    else
      ngx.log(ngx.ERR, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Could not lock CoreHealthDiscoveryTimer process (" .. err .. ")")
    end
  end

  if pid then
    if pid == ngx.worker.pid() then
      ngx.log(ngx.INFO, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": START of CoreHealthDiscoveryTimer process")
      HealthcheckingService()
      ngx.log(ngx.INFO, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": STOP of CoreHealthDiscoveryTimer process")
    else
      ngx.log(ngx.DEBUG, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": another worker has locked CoreHealthDiscoveryTimer process (" .. pid .. ")")
    end
  end
  ngx.log(ngx.DEBUG, "[JLUPIN HEALTH DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": END")
end




-----------------------------
-- CoreNginxDiscoveryTimer --
-----------------------------
function CoreNginxDiscoveryTimer(premature)

  ngx.log(ngx.DEBUG, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- Checking if NGINX master is OK
  local masterStatus = NginxCheckMaster()

  -- If NGINX master is dead -> aborting
  if not masterStatus
  then
    ngx.log(ngx.ERR, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": My master process is probably dead, aborting !")
    os.exit()
  end

  -- Setting the next iteration
  ngx.log(ngx.DEBUG, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Setting the next CoreNginxDiscoveryTimer timer iteration")
  local ok, err = ngx.timer.at(nginxDiscoveryPeriod, CoreNginxDiscoveryTimer)

  if not ok then
    if err == "process exiting"
    then
      ngx.log(ngx.NOTICE, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Setting a new CoreNginxDiscoveryTimer timer iteration has been aborted (" .. err ..")")
    else
      ngx.log(ngx.ERR, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Failed to set a new CoreNginxDiscoveryTimer timer iteration (" .. err ..")")
    end
  end

  -- Handling lock between workers in the discovery process
  local pid, err = RegGet("nodeInfo","nginxDiscoveryTimerLock")

  if not pid
  then
    local lock, err = RegAdd("nodeInfo","nginxDiscoveryTimerLock", ngx.worker.pid(), nginxTimerLockTimeout)
    if lock then
      ngx.log(ngx.DEBUG, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. " has locked CoreNginxDiscoveryTimer process")
      pid = ngx.worker.pid()
    else
      ngx.log(ngx.ERR, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Could not lock CoreNginxDiscoveryTimer process (" .. err .. ")")
    end
  end

  if pid then
    if pid == ngx.worker.pid() then
      ngx.log(ngx.INFO, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": START of CoreNginxDiscoveryTimer process")
      DiscoverNginxServers()
      ngx.log(ngx.INFO, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": STOP of CoreNginxDiscoveryTimer process")
    else
      ngx.log(ngx.DEBUG, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": another worker has locked CoreNginxDiscoveryTimer process (" .. pid .. ")")
    end
  end

  ngx.log(ngx.DEBUG, "[JLUPIN NGINX DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": END")
end

------------------------
-- CoreDiscoveryTimer --
------------------------
function CoreDiscoveryTimer(premature)

  ngx.log(ngx.DEBUG, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- Setting the next iteration
  ngx.log(ngx.DEBUG, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Setting the next CoreDiscoveryTimer timer iteration")
  local ok, err = ngx.timer.at(discoveryPeriod, CoreDiscoveryTimer)

  if not ok then
    if err == "process exiting"
    then
      ngx.log(ngx.NOTICE, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Setting a new CoreDiscoveryTimer timer iteration has been aborted (" .. err ..")")
    else
      ngx.log(ngx.ERR, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Failed to set a new CoreDiscoveryTimer timer iteration (" .. err ..")")
    end
  end

  -- Handling lock between workers in the discovery process
  local pid, err = RegGet("nodeInfo","discoverTimerLock")

  if not pid
  then
    local lock, err = RegAdd("nodeInfo","discoverTimerLock", ngx.worker.pid(), discoverTimerLockTimeout)
    if lock then
      ngx.log(ngx.DEBUG, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. " has locked CoreDiscoveryTimer process")
      pid = ngx.worker.pid()
    else
      ngx.log(ngx.ERR, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": Could not lock CoreDiscoveryTimer process (" .. err .. ")")
    end
  end

  if pid then
    if pid == ngx.worker.pid() then
      ngx.log(ngx.INFO, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": START of CoreDiscoveryTimer process")
      CoreDiscovery()
      ngx.log(ngx.INFO, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": STOP of CoreDiscoveryTimer process")
    else
      ngx.log(ngx.DEBUG, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": another worker has locked CoreDiscoveryTimer process (" .. pid .. ")")
    end
  end
  ngx.log(ngx.DEBUG, "[JLUPIN DISCOVERY TIMER] Worker " .. ngx.worker.pid() .. ": END")
end


-----------------------
-- CoreBalancerTimer --
-----------------------
function CoreBalancerTimer(premature)

  ngx.log(ngx.DEBUG, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- Setting the next iteration
  ngx.log(ngx.DEBUG, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": Setting the next balancer timer iteration")
  local ok, err = ngx.timer.at(balancerSwitchPeriod, CoreBalancerTimer)

  if not ok then
    if err == "process exiting"
    then
      ngx.log(ngx.NOTICE, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": Setting a new balancer timer iteration has been aborted (" .. err ..")")
    else
      ngx.log(ngx.ERR, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": Failed to set a new balancer timer iteration (" .. err ..")")
    end
  end

  -- Handling lock between workers in the discovery process
  local pid, err = RegGet("nodeInfo","balancerTimerLock")

  if not pid
  then
    local lock, err = RegAdd("nodeInfo","balancerTimerLock", ngx.worker.pid(), balancerTimerLockTimeout)
    if lock then
      ngx.log(ngx.DEBUG, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. " has locked the balancing process")
      pid = ngx.worker.pid()
    else
      ngx.log(ngx.ERR, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": Could not lock the balancing process (" .. err .. ")")
    end
  end

  if pid then
    if pid == ngx.worker.pid() then
      ngx.log(ngx.INFO, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": START of the balancing process")
      BalancerCyclicRoundRobin()
      ngx.log(ngx.INFO, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": STOP of the balancing process")
    else
      ngx.log(ngx.DEBUG, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": another worker has locked the balancing process (" .. pid .. ")")
    end
  end
  ngx.log(ngx.DEBUG, "[JLUPIN BALANCER TIMER] Worker " .. ngx.worker.pid() .. ": END")
end

------------------------------
-- CoreGetBackendForContext --
------------------------------
function CoreGetBackendForContext(context_route_key, context_http_stickysession)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(context_route_key) .. "," .. tostring(context_http_stickysession) .. ")")


  if not context_route_key
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": context_route_key is nil")
    return nil
  end

  local backendForContext = ""

  local microserviceRouteKey = ""
  if context_http_stickysession == "true"
  then
    microserviceRouteKey = RegGet("contextRoutesPersistent",context_route_key)
  else
    microserviceRouteKey = RegGet("contextRoutes",context_route_key)
  end

  if not microserviceRouteKey
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceRouteKey for " .. context_route_key .." has not been found")
    return nil
  end

  backendForContext = RegGet("microserviceRoutes",microserviceRouteKey)
  if not backendForContext
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": The microserviceRoute for " .. context_route_key .." has not been found ")
    return nil
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": backendForContext for " .. context_route_key ..":" .. backendForContext)
  return backendForContext
end

-----------------------------
-- CoreGetCookieForContext --
-----------------------------
function CoreGetCookieForContext(context_route_key)
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. tostring(context_route_key) .. ")")

  if not context_route_key
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": context_route_key is nil")
    return nil
  end

  local microserviceRouteKey = RegGet("contextRoutes",context_route_key)

  if not microserviceRouteKey
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceRouteKey for " .. context_route_key .." has not been found")
    return nil
  end

  local microserviceRouteCookie = RegGet("microserviceCookies",microserviceRouteKey)

  if not microserviceRouteCookie
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": The microserviceRouteCookie value for " .. microserviceRouteKey .." has not been found ")
    return nil
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": microserviceRouteCookie for " .. context_route_key ..": " .. microserviceRouteCookie)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

  return microserviceRouteCookie
end


------------------------
--   CoreSetOSInfo    --
------------------------
function CoreSetOSInfo()

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local separator = package.config:sub(1,1)

  if separator == "\\" then

    RegSet("nodeInfo","osType","windows")
    RegSet("nodeInfo","separator",separator)
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": separator: " .. RegGet("nodeInfo","separator"))

  elseif separator == "/"
  then

    RegSet("nodeInfo","osType","linux")
    RegSet("nodeInfo","separator",separator)
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": separator: " .. RegGet("nodeInfo","separator"))

  else

    RegSet("nodeInfo","osType","unknown")
    RegSet("nodeInfo","separator","/")
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": separator: " .. RegGet("nodeInfo","separator"))

  end

  local os_type = RegGet("nodeInfo","osType")

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": OsType: " .. os_type)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

  return os_type

end


------------------------
--   CoreRegDump    --
------------------------
function CoreRegDump(reg_name,reg_key)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN(" .. GenNilHandler(reg_name) .. "," .. GenNilHandler(reg_key) ..")")

  local regValueList = {}
  local reg = ngx.shared[reg_name]

  if not reg
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": The registry " .. GenNilHandler(reg_name) .. " hasn't been not found")
    return nil,"The registry does not exist"
  end

  if reg_key == ""
  then
    local regKeys = reg:get_keys(0)
    local idx = 1

    while idx <= GenTableLen(regKeys)
    do
      table.insert(regValueList,{
        ["key"] = regKeys[idx],
        ["value"] = reg:get(regKeys[idx])
      })
      idx = idx + 1
    end

  else
    local regValue = reg:get(reg_key)

    if not regValue
    then
      ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": The entry " .. GenNilHandler(reg_key) .. " in " .. GenNilHandler(reg_name).." register hasn't been not found")
      return nil,"The entry in the register does not exist"
    end

    regValueList = {
      ["key"] = reg_key,
      ["value"] = regValue
    }

  end

  return regValueList

end


-----------------------------
-- CoreGetComponentsStatus --
-----------------------------
function CoreGetComponentsStatus()
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local componentsStatusList = {}
  local componentsList = {}

  componentsStatusList["createdOn"] = RegGet("nodeInfo","timestamp")
  componentsStatusList["host"] = RegGet("nodeInfo","name")

  local microserviceList = GenJsonToTable(RegGet("nodeInfo","microserviceList"))

  if not microserviceList
  then
    microserviceList = {}
  end

  local idx = 1
  while idx <= GenTableLen(microserviceList)
  do
    table.insert(componentsList,{
      ["componentName"] = microserviceList[idx].name,
      ["status"] = microserviceList[idx].state
    })
    idx = idx + 1
  end

  componentsStatusList["componentsCount"] = GenTableLen(componentsList)
  componentsStatusList["components"] = componentsList

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END(componentsStatusList): " .. GenTableToJson(componentsStatusList))

  return componentsStatusList

end
