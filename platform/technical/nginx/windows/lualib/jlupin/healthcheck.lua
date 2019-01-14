---------------------------
-- HealthcheckingService --
---------------------------
function HealthcheckingService()
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local microserviceHealthcheckList = {}

  if healthcheckSwitch == 0
  then
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Healthchecking is turned off")
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
    return true
  end

  -- get node state and abort if it is unavailable
  local nodeState = RegGet("nodeInfo","state")

  if not nodeState or nodeState == G_NODE_STATE.UNAVAILABLE
  then
      ngx.log(ngx.ERR,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Node is  UNAVAILABLE, aborting")
      ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
      return false
  end

  local microserviceListJson = RegGet("nodeInfo","microserviceList")
  if not microserviceListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": microserviceListJson is nil")
    RegSet("nodeInfo","microserviceHealthcheckList",GenTableToJson(microserviceHealthcheckList),healthTimerLockTimeout)
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
    return false
  end

  local microserviceList = GenJsonToTable(microserviceListJson)
  if not microserviceList
  then
    ngx.log(ngx.ERR,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": microserviceList is nil")
    RegSet("nodeInfo","microserviceHealthcheckList",GenTableToJson(microserviceHealthcheckList),healthTimerLockTimeout)
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
    return false
  end

  local microserviceHealthcheckListJson = RegGet("nodeInfo","microserviceHealthcheckList")
  if microserviceHealthcheckListJson
  then
    microserviceHealthcheckList = GenJsonToTable(microserviceHealthcheckListJson)
  end

  local microserviceList_idx = 0
  local microserviceList_value = ""

  for microserviceList_idx,microserviceList_value in pairs(microserviceList)
  do
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": BEGIN")

    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": state=(" .. microserviceList_value.state .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": type=(" .. microserviceList_value.type .. ")")

    if microserviceList_value.type == G_API_TYPE.SERVLET
    then
      if microserviceList_value.isExternalHealthcheck == "true"
      then

        if not microserviceHealthcheckList[microserviceList_value.name]
        then
          microserviceHealthcheckList[microserviceList_value.name] = {}
        end

        if not microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount
        then
          microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount = 0
        end

        if not microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount
        then
          microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount = 0
        end

        if not microserviceHealthcheckList[microserviceList_value.name].state
        then
          microserviceHealthcheckList[microserviceList_value.name].state = G_MICROSERVICE_STATE.UNAVAILABLE
        end

        if microserviceList_value.state == G_MICROSERVICE_STATE.AVAILABLE or
            microserviceList_value.state == G_MICROSERVICE_STATE.UNAVAILABLE or
            microserviceList_value.state == G_MICROSERVICE_STATE.RUNNING or
            microserviceList_value.state == G_MICROSERVICE_STATE.DEACTIVATED
        then

          local healthcheckResult =
            HealthcheckingRequest (
              microserviceList_value.host,
              microserviceList_value.directPort,
              "/" .. microserviceList_value.contextName .. "/" .. microserviceList_value.externalHealthcheckURI:gsub("^/",""),
              1,0,0
            )

          ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": healthcheckResult=(" .. healthcheckResult .. ")")

          if healthcheckResult == 1
          then
            microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount = microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount + 1
            microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount = 0
          end

          if healthcheckResult == 0
          then
            microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount = microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount + 1
            microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount = 0
          end

          ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": healthcheckOKcount=(" .. microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount .. ")")
          ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": healthcheckFAILEDcount=(" .. microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount .. ")")

          if microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount == healthcheckOKlimit
          then
            microserviceHealthcheckList[microserviceList_value.name].state = G_MICROSERVICE_STATE.AVAILABLE
            microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount = 0
            ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": Setting state to " .. microserviceHealthcheckList[microserviceList_value.name].state)
          end

          if microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount == healthcheckFAILEDlimit
          then
            microserviceHealthcheckList[microserviceList_value.name].state = G_MICROSERVICE_STATE.UNAVAILABLE
            microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount = 0
            ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": Setting state to " .. microserviceHealthcheckList[microserviceList_value.name].state)
          end

          ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": healthcheck data: " .. GenTableToJson(microserviceHealthcheckList[microserviceList_value.name]))
          ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": END")
        else
          ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": Microservice is not running, setting state to " .. G_MICROSERVICE_STATE.UNAVAILABLE)
          microserviceHealthcheckList[microserviceList_value.name].state = G_MICROSERVICE_STATE.UNAVAILABLE
          microserviceHealthcheckList[microserviceList_value.name].healthcheckOKcount = 0
          microserviceHealthcheckList[microserviceList_value.name].healthcheckFAILEDcount = 0
          ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": END")
        end
      else
          ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": Healthchecking is turned off, skipping")
      end
    else
      ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": Unsupported microservice type, skipping")
      ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": " .. microserviceList_value.name ..": END")
    end
  end

  -- Garbage Collection
  local microserviceHealthcheckList_key = ""
  local microserviceHealthcheckList_value = ""

  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Garbage collection: BEGIN")

  for microserviceHealthcheckList_key,microserviceHealthcheckList_value in pairs(microserviceHealthcheckList)
  do
    local found = 0
    for microserviceList_idx,microserviceList_value in pairs(microserviceList)
    do
      if microserviceList_value.name == microserviceHealthcheckList_key
      then
        found = 1
      end
    end

    if found == 0
    then
      ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Garbage collection: " .. microserviceHealthcheckList_key .. ": INACTIVE (to be removed)")
      microserviceHealthcheckList[microserviceHealthcheckList_key] = nil
    else
      ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Garbage collection: " .. microserviceHealthcheckList_key .. ": ACTIVE")
    end
  end

  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Garbage collection: END")

  microserviceHealthcheckListJson = GenTableToJson(microserviceHealthcheckList)
  ngx.log(ngx.INFO,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Healthchecking status: " .. microserviceHealthcheckListJson)
  RegSet("nodeInfo","microserviceHealthcheckList",microserviceHealthcheckListJson,healthTimerLockTimeout)
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
end

---------------------------
-- HealthcheckingRequest --
---------------------------
function HealthcheckingRequest(host, port, uri, default_ok, default_failed, default_err, num_of_iterations)
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": BEGIN(" .. tostring(host) .. "," .. tostring(port) .. "," .. tostring(uri) .. "," .. tostring(default_ok) .. "," .. tostring(default_failed) .. "," .. tostring(default_err) .. "," .. tostring(num_of_iterations) .. ")")

  if not num_of_iterations
  then
    num_of_iterations = 1
  end

  local healthcheckURI = "http://" .. host .. ":" .. port .. uri
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": healthcheckURI=(" .. healthcheckURI .. ")")

  local res = {}
  local err = ""
  local idx = 0

  while idx < num_of_iterations
  do
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Healthcheck iteration #" .. idx + 1)
    res, err = HttpHealthcheck(healthcheckURI)
    idx = idx + 1
  end

  if not res then
    ngx.log(ngx.ERR,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Healthchecking has failed, err=(".. tostring(err) ..")")
    return default_err
  else
    if res.status == 200
    then
      ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Healthchecking status: OK")
      return default_ok
    else
      ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": Healthchecking status: FAILED")
      return default_failed
    end
  end
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
end


----------------------------------------
-- HealthcheckingGetMicroserviceState --
----------------------------------------
function HealthcheckingGetMicroserviceState(name)
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": BEGIN(" .. tostring(name) .. ")")

  local microserviceHealthcheckListJson = RegGet("nodeInfo","microserviceHealthcheckList")
  if not microserviceHealthcheckListJson
  then
    ngx.log(ngx.NOTICE,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": microserviceHealthcheckListJson is nil")
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
    return G_MICROSERVICE_STATE.UNAVAILABLE
  end

  local microserviceHealthcheckList = GenJsonToTable(microserviceHealthcheckListJson)
  if not microserviceHealthcheckList
  then
    ngx.log(ngx.ERR,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": microserviceHealthcheckList is nil")
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
    return G_MICROSERVICE_STATE.UNAVAILABLE
  end

  if not microserviceHealthcheckList[name]
  then
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": microserviceHealthcheckList[" .. name .. "] is nil")
    return G_MICROSERVICE_STATE.UNAVAILABLE
  end

  if not microserviceHealthcheckList[name].state
  then
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": microserviceHealthcheckList[" .. name .. "].state is nil")
    return G_MICROSERVICE_STATE.UNAVAILABLE
  else
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": microserviceHealthcheckList[" .. name .. "].state=(" .. microserviceHealthcheckList[name].state .. ")")
    return microserviceHealthcheckList[name].state
  end

  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECKING] Worker " .. ngx.worker.pid() .. ": END")
end
