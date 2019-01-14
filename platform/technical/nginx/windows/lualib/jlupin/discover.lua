------------------
-- DiscoverNode --
------------------
function DiscoverNode()

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local nodeInfoState = G_NODE_STATE.UNAVAILABLE

  -- Setting timestamp of discovery iteration
  local timestamp = os.date('%Y-%m-%d %H:%M:%S', os.time())
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": timestamp=(" .. timestamp .. ")")
  RegSet("nodeInfo","timestamp",timestamp)

  -- Determine discovery URL
  local discoveryURL = "http://" .. discoveryHost .. ":" .. discoveryPort .. "/nodeInfo"
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": discoveryURL=(" .. discoveryURL .. ")")

  -- Discovery request to Main Server
  local res, err = HttpRequest("GET",discoveryURL,"application/json","")

  if not res then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Node discovery has failed (".. err .. ")")
    RegSet("nodeInfo","state",nodeInfoState)
    return false
  end

  local nodeInfoJson = res.body
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nodeInfoJson=(" .. nodeInfoJson .. ")")

  -- Saving the response for further use
  RegSet("nodeInfo","URI_nodeInfo",nodeInfoJson)

  -- Converting discovery data to object
  local nodeInfo = GenJsonToTable(nodeInfoJson)

  local nodeInfoZone = nodeInfo.zone
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nodeInfoZone=(" .. nodeInfoZone .. ")")

  local nodeInfoName = nodeInfo.name
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nodeInfoName=(" .. nodeInfoName .. ")")

  local nodeInfoisActivated = tostring(nodeInfo.isActivated)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nodeInfoisActivated=(" .. nodeInfoisActivated .. ")")

  local nodeIsMainServerDeactivatedForce = tostring(nodeInfo.isMainServerDeactivatedForce)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nodeIsMainServerDeactivatedForce=(" .. nodeIsMainServerDeactivatedForce .. ")")

  local nodeInfoPeersRawList = nodeInfo.peers
  local nodeInfoPeersRawListJson = GenTableToJson(nodeInfoPeersRawList)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nodeInfoPeersRawListJson=(" ..  nodeInfoPeersRawListJson .. ")")

  local nodeInfoElasticApiList = nodeInfo.elastic_api
  local nodeInfoElasticApiListJson = GenTableToJson(nodeInfoElasticApiList)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nodeInfoElasticApiListJson=(" ..  nodeInfoElasticApiListJson .. ")")


  nodeInfoState = G_NODE_STATE.ENABLED

  if nodeInfoisActivated == "false"
  then
    nodeInfoState = G_NODE_STATE.DEACTIVATED
  end

  if nodeIsMainServerDeactivatedForce == "true"
  then
    nodeInfoState = G_NODE_STATE.DISABLED
  end


  -- Saving nodeInfo data to register
  RegSet("nodeInfo","zone",nodeInfoZone)
  RegSet("nodeInfo","name",nodeInfoName)
  RegSet("nodeInfo","state",nodeInfoState)
  RegSet("nodeInfo","peersRawList",nodeInfoPeersRawListJson)
  RegSet("nodeInfo","elasticApiList",nodeInfoElasticApiListJson)

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered node's info (RAW): " .. nodeInfoJson)
  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered node's info (zone, name, state): " .. tostring(nodeInfoZone) .. ", " .. tostring(nodeInfoName) .. ", " .. tostring(nodeInfoState))
  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered node's peers (RAW): " .. nodeInfoPeersRawListJson)
  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered node's elasticApi (RAW): " .. nodeInfoElasticApiListJson)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
  return true

end

-------------------
-- DiscoverPeers --
-------------------
function DiscoverPeers()

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- get node state and abort if it is unavailable
  local nodeState = RegGet("nodeInfo","state")

  if not nodeState or nodeState == G_NODE_STATE.UNAVAILABLE
  then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Node is UNAVAILABLE, aborting")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
      return false
  end

  local peersList = {}

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": discoveryPeersSource=(" .. discoveryPeersSource .. ")")

  if discoveryPeersSource == "auto"
  then

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: BEGIN")

    local zone = RegGet("nodeInfo","zone",nodeInfoZone)
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: zone=(" .. zone .. ")")

    local peersRawListJson = RegGet("nodeInfo","peersRawList")
    if not peersRawListJson
    then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: END: peersRawListJson is nil")
      RegSet("nodeInfo","peersList",GenTableToJson(peersList),discoverTimerLockTimeout)
      return false
    end

    local peersRawList = GenJsonToTable(peersRawListJson)
    if not peersRawList
    then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: END: peersRawList is nil")
      RegSet("nodeInfo","peersList",GenTableToJson(peersList),discoverTimerLockTimeout)
      return false
    end

    discoveryPeers = {}

    local peersRawList_idx = 1
    local discoveryPeers_idx = 1
    while peersRawList_idx <= GenTableLen(peersRawList)
    do
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: peersRawList[" .. peersRawList_idx .. "].zone=(" .. peersRawList[peersRawList_idx].zone .. ")")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: peersRawList[" .. peersRawList_idx .. "].name=(" .. peersRawList[peersRawList_idx].name .. ")")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: peersRawList[" .. peersRawList_idx .. "].ip=(" .. peersRawList[peersRawList_idx].ip .. ")")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: peersRawList[" .. peersRawList_idx .. "].isAvailable=(" .. peersRawList[peersRawList_idx].isAvailable .. ")")

      if zone == peersRawList[peersRawList_idx].zone
      then
        discoveryPeers[discoveryPeers_idx] = discoveryPeersDefaultProtocol .. "://" .. peersRawList[peersRawList_idx].ip .. ":" .. discoveryPeersDefaultAdminPort
        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: NEW discoveryPeers[" .. discoveryPeers_idx .. "]=(" .. discoveryPeers[discoveryPeers_idx] .. ")")
        discoveryPeers_idx = discoveryPeers_idx + 1
      end
      peersRawList_idx = peersRawList_idx + 1
    end

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Peers autodiscovery: END(discoveryPeers): " .. GenTableToJson(discoveryPeers))

  end


  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Building peersList: BEGIN")

  local discoveryPeers_idx = 1
  while discoveryPeers_idx <= GenTableLen(discoveryPeers)
  do

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Building peersList: " .. discoveryPeers[discoveryPeers_idx] .. ": BEGIN")

    local host = discoveryPeers[discoveryPeers_idx]:match("^[http,https]+://(.+):[0-9]+$")
    local discoveryURL = discoveryPeers[discoveryPeers_idx] .."/_discovery/microservices"

    if host
    then
      table.insert(peersList,{
        ["host"] = host,
        ["discoveryURL"] = discoveryURL
      })
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Building peersList: " .. discoveryPeers[discoveryPeers_idx] .. ": END(peersList[" .. discoveryPeers_idx .. "]): " .. GenTableToJson(peersList[discoveryPeers_idx]))
    else
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Building peersList: " .. discoveryPeers[discoveryPeers_idx] .. ": END(peersList[" .. discoveryPeers_idx .. "]): Cannot derermine 'host' parameter")
    end

    discoveryPeers_idx = discoveryPeers_idx + 1
  end

  local peersListJson = GenTableToJson(peersList)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Building peersList: END")

  RegSet("nodeInfo","peersList",peersListJson,discoverTimerLockTimeout)

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered peers: " .. peersListJson)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
  return true

end



---------------------------
-- DiscoverMicroservices --
---------------------------
function DiscoverMicroservices()

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- Variables initializing for microservice discovery
  local mtype = ""
  local name = ""
  local available = "true"
  local active = "true"
  local status = ""
  local primaryPort = 0
  local secondaryPort = 0
  local contextName = ""
  local httpStickySession = "false"
  local externalPort = ""
  local healthcheckPrimaryPort = ""
  local healthcheckSecondaryPort = ""
  local externalHealthcheckURI = ""
  local isExternalHealthcheck = "false"
  local httpStickySessionCookieOptions = ""

  -- tables that will be saved to the register
  local microserviceList = {}
  local microserviceFilterList = {}

  -- get node state and abort if it is unavailable
  local nodeState = RegGet("nodeInfo","state")

  if not nodeState or nodeState == G_NODE_STATE.UNAVAILABLE
  then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Node is  UNAVAILABLE, aborting")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
      return false
  end

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nodeState=(" .. nodeState .. ")")

  -- Determine discovery URL
  local discoveryURL = "http://" .. discoveryHost .. ":" .. discoveryPort .. "/listMicroservices"
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Service discovery URL: " .. discoveryURL)

  -- Discovery request to JLupin Main Server
  local res, err = HttpRequest("GET",discoveryURL,"application/json","")

  if not res then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice discovery has failed (".. err .. ")")
    return
  end

  -- Saving the response for troubleshooting
  local listMicroJson = res.body
  RegSet("nodeInfo","URI_listMicroservices",listMicroJson)

  -- Converting discovery data to object
  local listMicro = GenJsonToTable(listMicroJson)

  -- Setting Service Repository
  local i = 1
  while i <= #listMicro
  do

    local primaryPortStatus = 0
    local secondaryPortStatus = 0
    local port = 0

    mtype = listMicro[i].type
    name = listMicro[i].name
    available = tostring(listMicro[i].available)
    activated = tostring(listMicro[i].activated)
    status = listMicro[i].status
    primaryPort = listMicro[i].primaryPort
    secondaryPort = listMicro[i].secondaryPort
    externalPort = listMicro[i].properties["externalPort"]
    healthcheckPrimaryPort = listMicro[i].url["healthcheckPrimaryPort"]
    healthcheckSecondaryPort = listMicro[i].url["healthcheckSecondaryPort"]
    externalHealthcheckURI = listMicro[i].properties["externalHealthcheckURI"]
    isExternalHealthcheck = tostring(listMicro[i].properties["isExternalHealthcheck"])
    httpStickySessionCookieOptions = listMicro[i].properties["httpStickySessionCookieOptions"]

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": BEGIN")

    if mtype == "SERVLET"
    then
      httpStickySession = tostring(listMicro[i].properties["httpStickySession"])
      contextName = listMicro[i].properties["contextName"]:gsub("/","")

      if not httpStickySessionCookieOptions or httpStickySessionCookieOptions == ""
      then
        httpStickySessionCookieOptions = balancerCookieOptions
      end

      httpStickySessionCookieOptions = httpStickySessionCookieOptions:gsub("^[%s]*;[%s]*","")

      if not externalHealthcheckURI or externalHealthcheckURI == ""
      then
        externalHealthcheckURI = healthcheckDefaultURI
      end

      if isExternalHealthcheck == "nil" or isExternalHealthcheck == ""
      then
        if healthcheckSwitch == 1
        then
          isExternalHealthcheck = "true"
        else
          isExternalHealthcheck = "false"
        end
      end

    else
      httpStickySession = "false"
      contextName = name
      isExternalHealthcheck = "false"
      httpStickySessionCookieOptions = ""
      isExternalHealthcheck = "false"
      externalHealthcheckURI = ""
    end

    if not contextName or contextName == ""
    then
      contextName = "ROOT"
    end

    if not externalPort or externalPort == ""
    then
      externalPort = discoveryDefaultExternalPort
    end

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": name=(" .. name .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": mtype=(" .. mtype .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": available=(" .. available .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": activated=(" .. activated .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": status=(" .. status .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": primaryPort=(" .. primaryPort .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": secondaryPort=(" .. secondaryPort .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": contextName=(" .. contextName .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": externalPort=(" .. externalPort .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": externalHealthcheckURI=(" .. externalHealthcheckURI .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": isExternalHealthcheck=(" .. isExternalHealthcheck .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": httpStickySession=(" .. httpStickySession .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": httpStickySessionCookieOptions=(" .. httpStickySessionCookieOptions .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": healthcheckPrimaryPort=(" .. healthcheckPrimaryPort .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": healthcheckSecondaryPort=(" .. healthcheckSecondaryPort .. ")")

    -- Restoring previous state
    local previousMicroserviceState = CommonGetMicroserviceProperty(name,"state",G_MICROSERVICE_STATE.UNKNOWN)
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": previousMicroserviceState=(" .. previousMicroserviceState .. ")")

    -- Setting aggregated status
    local microserviceState = CommonSetMicroserviceState(name,status,available,activated)

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": microserviceState=(" .. microserviceState .. ")")

    if nodeState == G_NODE_STATE.DEACTIVATED
    then
      microserviceState = G_MICROSERVICE_STATE.DEACTIVATED
    end

    if nodeState == G_NODE_STATE.DISABLED
    then
      microserviceState = G_MICROSERVICE_STATE.UNAVAILABLE
    end
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": After nodeState: microserviceState=(" .. microserviceState .. ")")

    local previousMicroservicePort = CommonGetMicroserviceProperty(name,"directPort",0)
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": previousMicroservicePort=(" .. previousMicroservicePort .. ")")

    -- set port to previous one, as a default value
    port = previousMicroservicePort

    local currentMicroserviceRestart = CommonGetMicroserviceProperty(name,"activeRestart",0)
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": currentMicroserviceRestart=(" .. currentMicroserviceRestart .. ")")

    -- Setting filters
    if externalPort == "*"
    then
      microserviceFilterList[name] = true
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": microserviceFilterList(" .. name .. ")=(" .. name .. ")")
    else
      externalPort = externalPort .. ","
      for externalPort in string.gmatch(externalPort, "([^,]+),")
      do
        microserviceFilterList[name .. "." .. externalPort] = true
        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": microserviceFilterList(" .. name .. ")=(" .. name .. "." .. externalPort .. ")")
      end
    end


    if microserviceState == G_MICROSERVICE_STATE.AVAILABLE or microserviceState == G_MICROSERVICE_STATE.DEACTIVATED
    then

      -- Healthchecking on primary port
      local hc_url = "http://" .. discoveryHost .. ":" .. discoveryPort .. healthcheckPrimaryPort
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": Healthcheck URL for primary port: " .. hc_url)

      local res, err = HttpRequest("GET",hc_url,"application/json","")

      if not res then
        ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": Healthchecking on primary port of microservice " .. name .. " has failed (" .. err .. ")")
      end

      if res.status == 200
      then
           primaryPortStatus = 1
      end

      -- Healthchecking on secondary port
      local hc_url = "http://" .. discoveryHost .. ":" .. discoveryPort .. healthcheckSecondaryPort
      local res, err = HttpRequest("GET",hc_url,"application/json","")

      if not res then
        ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": Healthchecking on secondary port of microservice " .. name .. " has failed (" .. err .. ")")
      end

      if res.status == 200
      then
         secondaryPortStatus = 1
      end

      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": currentMicroserviceRestart=(" .. currentMicroserviceRestart .. ")")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": previousMicroservicePort=(" .. previousMicroservicePort .. ")")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": primaryPortStatus=(" .. primaryPortStatus .. ")")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": secondaryPortStatus=(" .. secondaryPortStatus .. ")")

      -- Setting proper port number
      if primaryPortStatus == 1 and secondaryPortStatus == 0
      then
        port = primaryPort
        currentMicroserviceRestart = 0
      elseif primaryPortStatus == 0 and secondaryPortStatus == 1
      then
        port = secondaryPort
        currentMicroserviceRestart = 0
      elseif primaryPortStatus == 1 and secondaryPortStatus == 1
      then

        if currentMicroserviceRestart == 0
        then
          if previousMicroservicePort == primaryPortStatus
          then
            port = secondaryPort
            currentMicroserviceRestart = 1
          elseif previousMicroservicePort == secondaryPortStatus
          then
            port = primaryPort
            currentMicroserviceRestart = 1
          else
            port = secondaryPort
            currentMicroserviceRestart = 1
          end
        else
          port = previousMicroservicePort
        end

      end
    end

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": port=(" .. port .. ")")

    -- check external healthchecking
    if mtype == G_API_TYPE.SERVLET and healthcheckSwitch == 1 and isExternalHealthcheck == "true"
    then

      if microserviceState == G_MICROSERVICE_STATE.AVAILABLE or
          microserviceState == G_MICROSERVICE_STATE.RUNNING or
          microserviceState == G_MICROSERVICE_STATE.DEACTIVATED
      then

        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": External healthchecking: BEGIN")

        local microserviceHealthcheckState = HealthcheckingGetMicroserviceState(name)
        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": External healthchecking: microserviceHealthcheckState=(" .. microserviceHealthcheckState ..")")

        if microserviceHealthcheckState == G_MICROSERVICE_STATE.UNAVAILABLE
        then
          microserviceState = microserviceHealthcheckState
        end

        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": External healthchecking: microserviceState=(" .. microserviceState ..")")
        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": External healthchecking: END")
      end
    end

    table.insert(microserviceList,{
      ["name"] = name,
      ["type"] = mtype,
      ["state"] = microserviceState,
      ["directPort"] = port,
      ["contextName"] = contextName,
      ["activeRestart"] = currentMicroserviceRestart,
      ["host"] = discoveryHost,
      ["discoveryPort"] = discoveryPort,
      ["httpStickySession"] = httpStickySession,
      ["httpStickySessionCookieOptions"] = httpStickySessionCookieOptions,
      ["externalHealthcheckURI"] = externalHealthcheckURI,
      ["isExternalHealthcheck"] = isExternalHealthcheck
    })

    i = i + 1

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": microserviceList=(" .. GenTableToJson(microserviceList) ..")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Microservice: " .. name .. ": END")
  end


  local microserviceListJson = GenTableToJson(microserviceList)
  local microserviceFilterListJson = GenTableToJson(microserviceFilterList)

  RegSet("nodeInfo","microserviceList",microserviceListJson,discoverTimerLockTimeout)
  RegSet("nodeInfo","microserviceFilterList",microserviceFilterListJson,discoverTimerLockTimeout)

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered microservices (RAW): " .. listMicroJson)
  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered microservices: " .. microserviceListJson)
  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered microservices filters: " .. microserviceFilterListJson)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
end


-----------------------------------
-- DiscoverFilteredMicroservices --
-----------------------------------
function DiscoverFilteredMicroservices()
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- get node state and abort if it is unavailable
  local nodeState = RegGet("nodeInfo","state")

  if not nodeState or nodeState == G_NODE_STATE.UNAVAILABLE
  then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Node is  UNAVAILABLE, aborting")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
      return false
  end

  local microserviceFilteredList = {}

  local nginxVirtualServerListJson = RegGet("nodeInfo","virtualServerList")
  if not nginxVirtualServerListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nginxVirtualServerListJson is nil")
    RegSet("nodeInfo","microserviceFilteredList",GenTableToJson(microserviceFilteredList),discoverTimerLockTimeout)
    return false
  end

  local nginxVirtualServerList = GenJsonToTable(nginxVirtualServerListJson)
  if not nginxVirtualServerList
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nginxVirtualServerList is nil")
    RegSet("nodeInfo","microserviceFilteredList",GenTableToJson(microserviceFilteredList),discoverTimerLockTimeout)
    return false
  end


  local microserviceListJson = RegGet("nodeInfo","microserviceList")
  if not microserviceListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": microserviceListJson is nil")
    RegSet("nodeInfo","microserviceFilteredList",GenTableToJson(microserviceFilteredList),discoverTimerLockTimeout)
    return false
  end

  local microserviceList = GenJsonToTable(microserviceListJson)
  if not microserviceList
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": microserviceList is nil")
    RegSet("nodeInfo","microserviceFilteredList",GenTableToJson(microserviceFilteredList),discoverTimerLockTimeout)
    return false
  end

  local elasticApiListJson = RegGet("nodeInfo","elasticApiList")
  if not elasticApiListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": elasticApiListJson is nil")
    RegSet("nodeInfo","microserviceFilteredList",GenTableToJson(microserviceFilteredList),discoverTimerLockTimeout)
    return false
  end

  local elasticApiList = GenJsonToTable(elasticApiListJson)
  if not elasticApiList
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": elasticApiList is nil")
    RegSet("nodeInfo","microserviceFilteredList",GenTableToJson(microserviceFilteredList),discoverTimerLockTimeout)
    return false
  end


  local nginxVirtualServerList_idx = 0
  local nginxVirtualServerList_value = ""

  for nginxVirtualServerList_idx,nginxVirtualServerList_value in pairs(nginxVirtualServerList)
  do
    local microserviceList_idx = 1

    if not microserviceFilteredList[nginxVirtualServerList_value.port]
    then
      microserviceFilteredList[nginxVirtualServerList_value.port] = {}
    end

    while microserviceList_idx <= GenTableLen(microserviceList)
    do
      local microserviceList_value = microserviceList[microserviceList_idx]

      if CommonMicroserviceFilter(microserviceList_value.name,nginxVirtualServerList_value.port)
      then

        if microserviceList_value.type == G_API_TYPE.SERVLET
        then
          microserviceList_value.elasticApi = "NULL"
          table.insert(microserviceFilteredList[nginxVirtualServerList_value.port],microserviceList_value)
        else

          local elasticApiList_idx = 1
          while elasticApiList_idx <= GenTableLen(elasticApiList)
          do
            ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": elasticApiList(name,port)=(" .. elasticApiList[elasticApiList_idx].name .. "," .. elasticApiList[elasticApiList_idx].port .. ")")

            microserviceList_value.elasticApi = elasticApiList[elasticApiList_idx].name
            microserviceList_value.directPort = elasticApiList[elasticApiList_idx].port

            local microserviceList_valueJson = GenTableToJson(microserviceList_value)

            ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": microserviceList_value=(" .. microserviceList_valueJson .. ")")

            table.insert(microserviceFilteredList[nginxVirtualServerList_value.port],GenJsonToTable(microserviceList_valueJson))

            elasticApiList_idx = elasticApiList_idx + 1
          end

        end
      end
      microserviceList_idx = microserviceList_idx + 1
    end
  end

  local microserviceFilteredListJson = GenTableToJson(microserviceFilteredList)

  RegSet("nodeInfo","microserviceFilteredList",microserviceFilteredListJson,discoverTimerLockTimeout)

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered filtered microservices: " .. microserviceFilteredListJson)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")

end

---------------------------------
-- DiscoverRemoteMicroservices --
---------------------------------
function DiscoverRemoteMicroservices()

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- get node state and abort if it is unavailable
  local nodeState = RegGet("nodeInfo","state")

  if not nodeState or nodeState == G_NODE_STATE.UNAVAILABLE
  then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Node is  UNAVAILABLE, aborting")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
      return false
  end

  local peersListJson = RegGet("nodeInfo","peersList")
  if not peersListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": peersListJson is nil")
    return nil
  end

  local peersList = GenJsonToTable(peersListJson)
  if not peersList
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": peersList is nil")
    return nil
  end

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: BEGIN")
  local remoteMicroservicesList = {}

  local idx = 1
  while idx <= GenTableLen(peersList)
  do
    local host = peersList[idx].host
    local discoveryURL = peersList[idx].discoveryURL

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: host=(" .. host .. "): BEGIN")

    local remoteMicroservicesPeerListResponse,err = HttpRequest("GET",discoveryURL,"application/json","")

    if not remoteMicroservicesPeerListResponse
    then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: host=(" .. host .. "): END(remoteMicroservicesPeerListResponse): " .. err)
    else

      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: host=(" .. host .. "): remoteMicroservicesPeerListResponse.body=(" .. remoteMicroservicesPeerListResponse.body .. ")")

      local remoteMicroservicesPeerList = GenJsonToTable(remoteMicroservicesPeerListResponse.body)

      local remoteMicroservicesPeerList_port = ""
      local remoteMicroservicesPeerList_list = {}

      for remoteMicroservicesPeerList_port,remoteMicroservicesPeerList_list in pairs(remoteMicroservicesPeerList)
      do
        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: host=(" .. host .. "): port=(".. remoteMicroservicesPeerList_port .. "): BEGIN")

        if not remoteMicroservicesList[remoteMicroservicesPeerList_port]
        then
          remoteMicroservicesList[remoteMicroservicesPeerList_port] = {}
        end

        local idx2 = 1
        while idx2 <= GenTableLen(remoteMicroservicesPeerList_list)
        do
          remoteMicroservicesPeerList_list[idx2].host = host

          local remoteHost = remoteMicroservicesPeerList_list[idx2].host .. "." .. remoteMicroservicesPeerList_list[idx2].discoveryPort
          local localHost = discoveryHost .. "." .. discoveryPort

          if remoteHost ~= localHost
          then
            table.insert(remoteMicroservicesList[remoteMicroservicesPeerList_port],remoteMicroservicesPeerList_list[idx2])
            ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: host=(" .. host .. "): port=(".. remoteMicroservicesPeerList_port .. "): New remote microservice: " .. GenTableToJson(remoteMicroservicesPeerList_list[idx2]))
          end

          idx2 = idx2 + 1
        end

        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: host=(" .. host .. "): port=(".. remoteMicroservicesPeerList_port .. "): END(remoteMicroservicesList): " .. GenTableToJson(remoteMicroservicesList[remoteMicroservicesPeerList_port]))
      end

      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: host=(" .. host .. "): END(remoteMicroservicesList): " .. GenTableToJson(remoteMicroservicesList))
    end

    idx = idx + 1
  end

  local remoteMicroservicesListJson = GenTableToJson(remoteMicroservicesList)
  RegSet("nodeInfo","remoteMicroservicesList",remoteMicroservicesListJson,discoverTimerLockTimeout)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovering remote microservices: END")

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered remote microservices: " .. remoteMicroservicesListJson)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Merging lists of microservices: BEGIN")

  local microserviceFilteredListJson = RegGet("nodeInfo","microserviceFilteredList")
  if not microserviceFilteredListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": microserviceFilteredListJson is nil")
    return nil
  end

  local microserviceFilteredList = GenJsonToTable(microserviceFilteredListJson)
  if not microserviceFilteredList
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": microserviceFilteredList is nil")
    return nil
  end

  local remoteMicroservicesList_port = ""
  local remoteMicroservicesList_list = {}

  for remoteMicroservicesList_port,remoteMicroservicesList_list in pairs(remoteMicroservicesList)
  do
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Merging lists of microservices: port=(" .. remoteMicroservicesList_port .. "): BEGIN")
      if microserviceFilteredList[remoteMicroservicesList_port]
      then

        local idx = 1
        while idx <= GenTableLen(remoteMicroservicesList_list)
        do
          table.insert(microserviceFilteredList[remoteMicroservicesList_port],remoteMicroservicesList_list[idx])
          ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Merging lists of microservices: port=(" .. remoteMicroservicesList_port .. "): The following microservice has been merged: " .. GenTableToJson(remoteMicroservicesList_list[idx]))
          idx = idx + 1
        end

      end
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Merging lists of microservices: port=(" .. remoteMicroservicesList_port .. "): END(microserviceFilteredList[" .. remoteMicroservicesList_port .. "]): " .. GenTableToJson(microserviceFilteredList[remoteMicroservicesList_port]))
  end

  microserviceFilteredListJson = GenTableToJson(microserviceFilteredList)
  RegSet("nodeInfo","allMicroserviceFilteredList",microserviceFilteredListJson,discoverTimerLockTimeout)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Merging lists of microservices: END")

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Filtered microservices after merging with remote: " .. microserviceFilteredListJson)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
  return true
end

----------------------
-- DiscoverContexts --
----------------------
function DiscoverContexts()

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- get node state and abort if it is unavailable
  local nodeState = RegGet("nodeInfo","state")

  if not nodeState or nodeState == G_NODE_STATE.UNAVAILABLE
  then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Node is  UNAVAILABLE, aborting")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
      return false
  end

  local contextList = {}

  local microserviceFilteredListJson = RegGet("nodeInfo","allMicroserviceFilteredList")
  if not microserviceFilteredListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": microserviceFilteredListJson is nil")
    RegSet("nodeInfo","contextList",GenTableToJson(contextList),discoverTimerLockTimeout)
    return false
  end

  local microserviceFilteredList = GenJsonToTable(microserviceFilteredListJson)
  if not microserviceFilteredList
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": microserviceFilteredList is nil")
    RegSet("nodeInfo","contextList",GenTableToJson(contextList),discoverTimerLockTimeout)
    return false
  end

  local microserviceFilteredList_port = ""
  local microserviceFilteredList_list = ""

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: BEGIN")

  for microserviceFilteredList_port, microserviceFilteredList_list in pairs(microserviceFilteredList)
  do
    local microserviceFilteredList_list_idx = 0
    local microserviceFilteredList_list_value = ""

    local techContextList = {}
    local contextListOnPort = {}

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): BEGIN")

    for microserviceFilteredList_list_idx,microserviceFilteredList_list_value in pairs(microserviceFilteredList_list)
    do
        local contextHttpStickySession = "false"
        local contextHttpStickySessionCookieOptions = ""
        local contextRoutes = {}
        local techContext = microserviceFilteredList_list_value.type .. "." .. microserviceFilteredList_list_value.contextName .. "." .. "." .. microserviceFilteredList_list_value.elasticApi
        local microserviceFilteredList_list_idx2 = 0
        local microserviceFilteredList_list_value2 = ""

        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): context(" .. microserviceFilteredList_list_value.type .. "," .. microserviceFilteredList_list_value.contextName .. "," .. microserviceFilteredList_list_value.elasticApi .. "): BEGIN")

        if not techContextList[techContext]
        then
          local state = G_CONTEXT_STATE.UNAVAILABLE

          ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): context(" .. microserviceFilteredList_list_value.type .. "," .. microserviceFilteredList_list_value.contextName .. "," .. microserviceFilteredList_list_value.elasticApi .. "): Searching for routes: BEGIN")

          for microserviceFilteredList_list_idx2,microserviceFilteredList_list_value2 in pairs(microserviceFilteredList_list)
          do
            if microserviceFilteredList_list_value2.type == microserviceFilteredList_list_value.type and microserviceFilteredList_list_value2.contextName == microserviceFilteredList_list_value.contextName and microserviceFilteredList_list_value2.elasticApi == microserviceFilteredList_list_value.elasticApi
            then

              contextHttpStickySessionCookieOptions = microserviceFilteredList_list_value2.httpStickySessionCookieOptions

              if microserviceFilteredList_list_value2.httpStickySession == "true"
              then
                contextHttpStickySession = "true"
              end

              if microserviceFilteredList_list_value2.state == G_MICROSERVICE_STATE.AVAILABLE
              then
                state = G_CONTEXT_STATE.AVAILABLE
              end

              if state ~= G_CONTEXT_STATE.AVAILABLE
              then

                if microserviceFilteredList_list_value2.state == G_MICROSERVICE_STATE.DEACTIVATED
                then
                  state = G_CONTEXT_STATE.DEACTIVATED
                end

              end

              table.insert(contextRoutes,{
                ["host"] = microserviceFilteredList_list_value2.host,
                ["discoveryPort"] = microserviceFilteredList_list_value2.discoveryPort,
                ["name"] = microserviceFilteredList_list_value2.name,
                ["port"] = microserviceFilteredList_list_value2.directPort,
                ["state"] = microserviceFilteredList_list_value2.state
              })

              ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): context(" .. microserviceFilteredList_list_value.type .. "," .. microserviceFilteredList_list_value.contextName .. "," .. microserviceFilteredList_list_value.elasticApi .. "): new route: " .. microserviceFilteredList_list_value2.name .. "," .. microserviceFilteredList_list_value2.host .. "," .. microserviceFilteredList_list_value2.discoveryPort .. "," .. microserviceFilteredList_list_value2.state)

            end
          end
          ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): context(" .. microserviceFilteredList_list_value.type .. "," .. microserviceFilteredList_list_value.contextName .. "," .. microserviceFilteredList_list_value.elasticApi .. "): Searching for routes: END")

          local restricted = true

          if CommonCheckInAdminTools(microserviceFilteredList_list_value.contextName) and CommonGetVirtualServerType(microserviceFilteredList_port) == G_SERVER_TYPE.admin
          then
            restricted = false
          end

          if not CommonCheckInAdminTools(microserviceFilteredList_list_value.contextName) and CommonGetVirtualServerType(microserviceFilteredList_port) == G_SERVER_TYPE.data
          then
            restricted = false
          end

          if restricted == false
          then
            local contextRoutesWithPriorities = CommonGetContextRoutesPriorities(contextRoutes,microserviceFilteredList_list_value.elasticApi)
            if GenTableLen(contextRoutesWithPriorities) > 0
            then

              if contextHttpStickySessionCookieOptions ~= ""
              then
                contextHttpStickySessionCookieOptions = "; " .. contextHttpStickySessionCookieOptions
              end

              table.insert(contextListOnPort,{
                ["contextName"] = microserviceFilteredList_list_value.contextName,
                ["apiType"] = microserviceFilteredList_list_value.type,
                ["elasticApi"] = microserviceFilteredList_list_value.elasticApi,
                ["state"] = state,
                ["httpStickySession"] = contextHttpStickySession,
                ["httpStickySessionCookieOptions"] = contextHttpStickySessionCookieOptions,
                ["routes"] = contextRoutesWithPriorities
              })
              RegSet("nodeInfo","_contextList_httpStickySession_" .. CommonGetContextRouteKey(microserviceFilteredList_list_value.type, microserviceFilteredList_list_value.contextName,microserviceFilteredList_port,microserviceFilteredList_list_value.elasticApi),tostring(contextHttpStickySession),discoverTimerLockTimeout)
              RegSet("nodeInfo","_contextList_httpStickySessionCookieOptions_" .. CommonGetContextRouteKey(microserviceFilteredList_list_value.type, microserviceFilteredList_list_value.contextName,microserviceFilteredList_port,microserviceFilteredList_list_value.elasticApi),tostring(contextHttpStickySessionCookieOptions),discoverTimerLockTimeout)
            end
          else
            ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): context(" .. microserviceFilteredList_list_value.type .. "," .. microserviceFilteredList_list_value.contextName .. "," .. microserviceFilteredList_list_value.elasticApi .. "): END(restricted)")
          end

          techContextList[techContext] = true
          contextRoutes = {}

          ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): context(" .. microserviceFilteredList_list_value.type .. "," .. microserviceFilteredList_list_value.contextName .. "," .. microserviceFilteredList_list_value.elasticApi .. "): END")

        else
          ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): context(" .. microserviceFilteredList_list_value.type .. "," .. microserviceFilteredList_list_value.contextName .. "," .. microserviceFilteredList_list_value.elasticApi .. "): END(previously processed)")
        end
    end

    contextList[microserviceFilteredList_port] = contextListOnPort
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: virtual server(" .. microserviceFilteredList_port .. "): END(contextListOnPort): " .. GenTableToJson(contextListOnPort))
  end

  local contextListJson = GenTableToJson(contextList)
  RegSet("nodeInfo","contextList",contextListJson,discoverTimerLockTimeout)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList: END")

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered contexts list: " .. contextListJson)
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
end


--------------------
-- DiscoverRoutes --
--------------------
function DiscoverRoutes()

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- get node state and abort if it is unavailable
  local nodeState = RegGet("nodeInfo","state")

  if not nodeState or nodeState == G_NODE_STATE.UNAVAILABLE
  then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Node is  UNAVAILABLE, aborting")
      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
      return false
  end

  local contextRoutesList = {}
  local microserviceRoutesList = {}

  local contextListJson = RegGet("nodeInfo","contextList")
  if not contextListJson
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextListJson is nil")
    RegSet("nodeInfo","contextRoutesList",GenTableToJson(contextRoutesList),discoverTimerLockTimeout)
    RegSet("nodeInfo","microserviceRoutesList",GenTableToJson(microserviceRoutesList),discoverTimerLockTimeout)
    return false
  end

  local contextList = GenJsonToTable(contextListJson)
  if not contextList
  then
    ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": contextList is nil")
    RegSet("nodeInfo","contextRoutesList",GenTableToJson(contextRoutesList),discoverTimerLockTimeout)
    RegSet("nodeInfo","microserviceRoutesList",GenTableToJson(microserviceRoutesList),discoverTimerLockTimeout)
    return false
  end

  local contextList_port = ""
  local contextList_list = ""

  for contextList_port,contextList_list in pairs(contextList)
  do

    local idx = 1
    while idx <= GenTableLen(contextList_list)
    do
      local contextRoutesList_value = contextList_list[idx]

      local contextRouteKey = CommonGetContextRouteKey(contextRoutesList_value.apiType,contextRoutesList_value.contextName,contextList_port,contextRoutesList_value.elasticApi)

      ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": BEGIN")

      local routes_idx = 0
      local routes_value = ""
      local microserviceRoutes = {}

      for routes_idx,routes_value in pairs(contextRoutesList_value.routes)
      do
        local microserviceRouteKey = CommonGetMicroserviceRouteKey(routes_value,contextRoutesList_value.elasticApi)

        if routes_value.state == G_MICROSERVICE_STATE.AVAILABLE or routes_value.state == G_MICROSERVICE_STATE.DEACTIVATED
        then
            table.insert(microserviceRoutes,{
              ["microserviceRouteKey"] = microserviceRouteKey,
              ["priority"] = routes_value.priority,
              ["state"] = routes_value.state
            })

            ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": The new microservice route found (key,priority): " .. microserviceRouteKey .. "," .. routes_value.priority)

            microserviceRoutesList[microserviceRouteKey] = {
              ["route"] = routes_value.host .. ":" .. routes_value.port,
              ["cookie"] = CommonGetMicroserviceRouteCookie(microserviceRouteKey)
            }

            ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": The new microservice route (" .. microserviceRouteKey .. ") has been added to microserviceRoutesList (route,cookie): " .. microserviceRoutesList[microserviceRouteKey].route .. "," .. microserviceRoutesList[microserviceRouteKey].cookie)
        end
      end

      if GenTableLen(microserviceRoutes) > 0
      then
        contextRoutesList[contextRouteKey] = microserviceRoutes
        ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": END(contextRoutesList[" .. contextRouteKey .. "]): " .. GenTableToJson(contextRoutesList[contextRouteKey]))
      end

      idx = idx + 1
    end

  end

  local contextRoutesListJson = GenTableToJson(contextRoutesList)
  local microserviceRoutesListJson = GenTableToJson(microserviceRoutesList)

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered context routes: " .. contextRoutesListJson)
  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered microservice routes: " .. microserviceRoutesListJson)

  local microserviceRoutesList_key = ""
  local microserviceRoutesList_value = ""
  for microserviceRoutesList_key,microserviceRoutesList_value in pairs(microserviceRoutesList)
  do
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. microserviceRoutesList_key .. ": BEGIN")

    RegSet("microserviceRoutes",microserviceRoutesList_key,microserviceRoutesList_value.route,discoverTimerLockTimeout)
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. microserviceRoutesList_key .. ": Added to microserviceRoutes(key,value): " .. microserviceRoutesList_key .. "," .. microserviceRoutesList_value.route)

    RegSet("microserviceCookies",microserviceRoutesList_key,microserviceRoutesList_value.cookie,discoverTimerLockTimeout)
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. microserviceRoutesList_key .. ": Added to microserviceCookies(key,value): " .. microserviceRoutesList_key .. "," .. microserviceRoutesList_value.cookie)

    RegSet("contextRoutesPersistent",microserviceRoutesList_value.cookie,microserviceRoutesList_key,discoverTimerLockTimeout)
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. microserviceRoutesList_key .. ": Added to contextRoutesPersistent(key,value): " .. microserviceRoutesList_value.cookie .. "," .. microserviceRoutesList_key)

    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": " .. microserviceRoutesList_key .. ": END")
  end

  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered microserviceRoutes items: " .. GenTableToJson(RegGetAll("microserviceRoutes")))
  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered microserviceCookies items: " .. GenTableToJson(RegGetAll("microserviceCookies")))
  ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered contextRoutesPersistent items: " .. GenTableToJson(RegGetAll("contextRoutesPersistent")))

  RegSet("nodeInfo","contextRoutesList",contextRoutesListJson,discoverTimerLockTimeout)
  RegSet("nodeInfo","microserviceRoutesList",microserviceRoutesListJson,discoverTimerLockTimeout)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")

end


--------------------------
-- DiscoverNginxServers --
--------------------------
function DiscoverNginxServers()

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": BEGIN")

  -- Setting the list of virtual servers
  local nginxVirtualServerList = NginxConfServerList()

  if not nginxVirtualServerList
  then
      ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nginxVirtualServerList is nil")
  else
      local nginxVirtualServerListJson = GenTableToJson(nginxVirtualServerList)

      if not nginxVirtualServerListJson
      then
        ngx.log(ngx.ERR,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": nginxVirtualServerListJson is nil")
      else
        RegSet("nodeInfo","virtualServerList",nginxVirtualServerListJson)
        ngx.log(ngx.INFO,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": Discovered NGINX virtual servers: " .. nginxVirtualServerListJson)
      end
  end
  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
end
