------------------------------
-- BalancerCyclicRoundRobin --
------------------------------
function BalancerCyclicRoundRobin()

  ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local contextRoutesListJson = RegGet("nodeInfo","contextRoutesList")
  if not contextRoutesListJson
  then
    ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": contextRoutesListJson is nil, nothing to do")
    return nil
  end

  local contextRoutesList = GenJsonToTable(contextRoutesListJson)
  if not contextRoutesList
  then
    ngx.log(ngx.ERR,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": contextRoutesList is nil")
    return nil
  end

  local contextRoutesPointersList = {}
  local contextRoutesPointersListJson = RegGet("nodeInfo","contextRoutesPointersList")
  if contextRoutesPointersListJson
  then
    contextRoutesPointersList = GenJsonToTable(contextRoutesPointersListJson)
  end

  local contextRoutesPrioritiesList = {}

  local contextRoutesList_key = ""
  local contextRoutesList_value = ""

  for contextRoutesList_key, contextRoutesList_value in pairs(contextRoutesList)
  do
    local priorityToActiveRoutes = {}

    ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": BEGIN")

    ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": priorityToActiveRoutes: BEGIN")

    idx = 1
    while idx <= GenTableLen(contextRoutesList_value)
    do
        if not priorityToActiveRoutes["p" .. contextRoutesList_value[idx].priority]
        then
          priorityToActiveRoutes["p" .. contextRoutesList_value[idx].priority] = {}
        end
        if contextRoutesList_value[idx].state == G_MICROSERVICE_STATE.AVAILABLE
        then
          table.insert(priorityToActiveRoutes["p" .. contextRoutesList_value[idx].priority],{
            ["microserviceRouteKey"] = contextRoutesList_value[idx].microserviceRouteKey
          })
        end
        idx = idx + 1
    end

    ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": priorityToActiveRoutes: END(" .. GenTableToJson(priorityToActiveRoutes) .. ")")

    contextRoutesPrioritiesList[contextRoutesList_key] = priorityToActiveRoutes

    local contextRouteKeyWithPriority = ""
    local contextRoutesPointer = 0
    local previousContextRoutesPointer = ""

    local idx = 1
    local maxIdx = GenTableLen(discoveryPeers) + 1
    ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": maxIdx=(" .. maxIdx .. ")")

    while idx <= maxIdx
    do
      local priorityKey = "p" .. idx
      ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": PriorityKey(" .. priorityKey .."): BEGIN")

      if priorityToActiveRoutes[priorityKey]
      then
        if GenTableLen(priorityToActiveRoutes[priorityKey]) > 0
        then

          contextRouteKeyWithPriority = contextRoutesList_key .. "." .. priorityKey

          ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": PriorityKey(" .. priorityKey .."): " .. contextRouteKeyWithPriority .. ": BEGIN")
          previousContextRoutesPointer = contextRoutesPointersList[contextRouteKeyWithPriority]

          ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": PriorityKey(" .. priorityKey .."): " .. contextRouteKeyWithPriority .. ": previousContextRoutesPointer=(" .. GenNilHandler(previousContextRoutesPointer) .. ")")

          if not previousContextRoutesPointer
          then
            contextRoutesPointer = 1
          else
            contextRoutesPointer = tonumber(previousContextRoutesPointer) + 1
            if contextRoutesPointer > GenTableLen(priorityToActiveRoutes[priorityKey])
            then
              contextRoutesPointer = 1
            end
          end

          ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": PriorityKey(" .. priorityKey .."): " .. contextRouteKeyWithPriority .. ": contextRoutesPointer=(" .. contextRoutesPointer .. ")")


          contextRoutesPointersList[contextRouteKeyWithPriority] = contextRoutesPointer
          contextRouteValue = priorityToActiveRoutes[priorityKey][contextRoutesPointer].microserviceRouteKey

          ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Balancing " .. contextRoutesList_key .. ": PriorityKey(" .. priorityKey .."): " .. contextRouteKeyWithPriority .. ": END(contextRoutesList_key): " .. contextRouteValue)

          RegSet("contextRoutes",contextRoutesList_key,contextRouteValue,balancerTimerLockTimeout)
          RegSet("nodeInfo","contextRoutesPointersList",GenTableToJson(contextRoutesPointersList),balancerTimerLockTimeout)

          ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": " .. contextRoutesList_key .. ": PriorityKey(" .. priorityKey .."): END")
          break
        else
            ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": " .. contextRoutesList_key .. ": PriorityKey(" .. priorityKey .."): END(no available routes)")
        end
      else
        ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": " .. contextRoutesList_key .. ": PriorityKey(" .. priorityKey .."): END(not existing)")
      end
      idx = idx + 1
    end
    ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": " .. contextRoutesList_key .. ": END")
  end

  RegSet("nodeInfo","contextRoutesPrioritiesList",GenTableToJson(contextRoutesPrioritiesList))


  ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutes: BEGIN")

  local currentContextRoutes = RegGetAll("contextRoutes")
  local key = ""
  local value = ""
  local found = false

  for key,value in pairs(currentContextRoutes)
  do
    ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutes: contextRoutes(key):" .. key .. ": BEGIN")

    for contextRoutesList_key, contextRoutesList_value in pairs(contextRoutesList)
    do
      if key == contextRoutesList_key
      then
        found = true
        ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutes: contextRoutes(key):" .. key .. ": ACTIVE")
      end
    end

    if found == false
    then
      ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutes: contextRoutes(key):" .. key .. ": INACTIVE")
      ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutes: contextRoutes(key):" .. key .. ": Removing from contextRoutes")
      RegSet("contextRoutes",key,nil)
    end

    ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutes: contextRoutes(key):" .. key .. ": END")
    found = false
  end

  ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutes: END")


  ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutesPointersList: BEGIN")

  local newContextRoutesPointersList = {}
  for key,value in pairs(contextRoutesPointersList)
  do
      ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutesPointersList: " .. key .. ": BEGIN")
      local found = false

      for contextRoutesList_key, contextRoutesList_value in pairs(contextRoutesList)
      do

        local idx = 1
        while idx <= GenTableLen(contextRoutesList_value)
        do
          if key == contextRoutesList_key .. ".p" .. contextRoutesList_value[idx].priority
          then
            found = true
            ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutesPointersList: " .. key .. ": ACTIVE")
            newContextRoutesPointersList[key] = value
          end
          idx = idx + 1
        end

      end

      if found == false
      then
        ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutesPointersList: " .. key .. ": INACTIVE")
        ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutesPointersList: " .. key .. ": Removed from contextRoutesPointersList")
      end

      ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutesPointersList: " .. key .. ": END")
      found = false
  end

  contextRoutesPointersList = newContextRoutesPointersList
  local contextRoutesPointersListJson = GenTableToJson(contextRoutesPointersList)
  RegSet("nodeInfo","contextRoutesPointersList",contextRoutesPointersListJson,balancerTimerLockTimeout)
  ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": Garbage collection for contextRoutesPointersList: END(contextRoutesPointersList): " .. contextRoutesPointersListJson)

  ngx.log(ngx.INFO,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": The current balancer state: " .. GenTableToJson(RegGetAll("contextRoutes")))
  
  ngx.log(ngx.DEBUG,"[JLUPIN BALANCER] Worker " .. ngx.worker.pid() .. ": END")

end
