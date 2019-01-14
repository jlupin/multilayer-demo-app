-- LIBS --
require "jlupin.generic"
require "jlupin.http"
require "jlupin.nginx"
require "jlupin.common"
require "jlupin.balancer"
require "jlupin.discover"
require "jlupin.core"
require "jlupin.healthcheck"

-- Init JLupin module --
function JLupinInitModule()

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  CoreSetOSInfo()

  if not nginxDiscoveryPeriod
  then
    nginxDiscoveryPeriod = 15
  end

  if not discoveryPeersSource
  then
    discoveryPeersSource = "manual"
  end

  if not healthcheckSwitch
  then
    healthcheckSwitch = 0
  end

  if not healthcheckPeriod
  then
    healthcheckPeriod = 5
  end

  if not healthcheckDefaultURI
  then
    healthcheckDefaultURI = "/isAlive"
  end

  if not healthcheckOKlimit
  then
    healthcheckOKlimit = 3
  end

  if not healthcheckFAILEDlimit
  then
    healthcheckFAILEDlimit = 2
  end

  if not healthcheckConnectionTimeout
  then
    healthcheckConnectionTimeout = 2000
  end

  if not healthcheckSendTimeout
  then
    healthcheckSendTimeout = 3000
  end

  if not healthcheckReadTimeout
  then
    healthcheckReadTimeout = 5000
  end

  discoverTimerLockTimeout = 2 * discoveryPeriod + 2
  balancerTimerLockTimeout = 2 * balancerSwitchPeriod + 1
  nginxTimerLockTimeout = 2 * nginxDiscoveryPeriod + 5
  healthTimerLockTimeout = 2 * healthcheckPeriod + 5

  discoveryAdminTools = {}
  table.insert(discoveryAdminTools,"webcontrol")


  -- Global Variables
  G_MICROSERVICE_STATE = {}
  G_MICROSERVICE_STATE["AVAILABLE"] = "AVAILABLE"
  G_MICROSERVICE_STATE["UNAVAILABLE"] = "UNAVAILABLE"
  G_MICROSERVICE_STATE["DEACTIVATED"] = "DEACTIVATED"
  G_MICROSERVICE_STATE["RUNNING"] = "RUNNING"
  G_MICROSERVICE_STATE["UNKNOWN"] = "UNKNOWN"

  G_CONTEXT_STATE  = {}
  G_CONTEXT_STATE["AVAILABLE"] = "AVAILABLE"
  G_CONTEXT_STATE["UNAVAILABLE"] = "UNAVAILABLE"
  G_CONTEXT_STATE["DEACTIVATED"] = "DEACTIVATED"

  G_SERVER_TYPE  = {}
  G_SERVER_TYPE["admin"] = "admin"
  G_SERVER_TYPE["data"] = "data"

  G_API_TYPE  = {}
  G_API_TYPE["SERVLET"] = "SERVLET"
  G_API_TYPE["NATIVE"] = "NATIVE"

  G_NODE_STATE  = {}
  G_NODE_STATE["UNAVAILABLE"] = "UNAVAILABLE"
  G_NODE_STATE["ENABLED"] = "ENABLED"
  G_NODE_STATE["DISABLED"] = "DISABLED"
  G_NODE_STATE["DEACTIVATED"] = "DEACTIVATED"

  G_LOCALHOST_RAW_PRIORITY = CommonGetRawPriorityForHost(discoveryHost,discoveryPort)

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

end

----------------------------------------
-- Start Discovery Timer for a Worker --
----------------------------------------
function JLupinInitStartDiscoveryTimer()

  ngx.log(ngx.DEBUG, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": BEGIN")

  ngx.log(ngx.INFO, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": Initializing the discovery timers")

  local ok,err = NginxSetMasterPID()

  if not ok
  then
    ngx.log(ngx.ERR, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": Failed to set master PID (" .. err .. "), aborting")
    os.exit()
  end

  -- CoreHealthDiscoveryTimer
  ngx.log(ngx.DEBUG, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": Initializing CoreHealthDiscoveryTimer timer")
  local ok, err = ngx.timer.at(1, CoreHealthDiscoveryTimer)

  if not ok then
      ngx.log(ngx.ERR, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": Failed to init CoreNginxDiscoveryTimer timer (" .. err .. ")")
  end

  -- CoreNginxDiscoveryTimer
  ngx.log(ngx.DEBUG, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": Initializing CoreNginxDiscoveryTimer timer")
  local ok, err = ngx.timer.at(2, CoreNginxDiscoveryTimer)

  if not ok then
      ngx.log(ngx.ERR, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": Failed to init CoreNginxDiscoveryTimer timer (" .. err .. ")")
  end

  -- CoreDiscoveryTimer
  ngx.log(ngx.DEBUG, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": Initializing CoreDiscoveryTimer timer")
  local ok, err = ngx.timer.at(3, CoreDiscoveryTimer)

  if not ok then
      ngx.log(ngx.ERR, "[JLUPIN INIT] Worker " .. ngx.worker.pid() .. ": Failed to init CoreDiscoveryTimer timer (" .. err .. ")")
  end

end

----------------------------------------
-- Start Balancer Timer for a Worker --
----------------------------------------
function JLupinInitStartBalancerTimer()

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  ngx.log(ngx.INFO, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Initializing the balancer timer")
  local ok, err = ngx.timer.at(4, CoreBalancerTimer)

  if not ok then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Failed to init the balncer timer (" .. err .. ")")
  end

end


--------------------
-- Proxy endpoint --
--------------------
function JLupinLocationProxy(server_port, server_type, api_type, elastic_api, context_name)

  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. server_port .. "," .. GenNilHandler(server_type) .. "," .. GenNilHandler(api_type) .. "," .. GenNilHandler(elastic_api) .. "," .. GenNilHandler(context_name) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": ngx.var.scheme=(" .. ngx.var.scheme .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": ngx.var.request_uri=(" .. ngx.var.request_uri .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": Http header['Content-Type']=(" .. tostring(ngx.req.get_headers()["Content-Type"]) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": Http header['Accept']=(" .. tostring(ngx.req.get_headers()["Accept"]) .. ")")

  if not server_type
  then
    server_type = G_SERVER_TYPE.data
  end

  if not api_type
  then
    api_type = G_API_TYPE.SERVLET
  end

  if not elastic_api or elastic_api == ""
  then
    ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": Service Unavailable (elastic_api is nil or empty)")
    HttpRequestError("Service unavailable","elastic_api is nil or empty",503)
  end

  if not context_name or context_name == ""
  then
    context_name = "ROOT"
  end

  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": context_name=(" .. context_name .. ")")


  local contextRouteKey = CommonGetContextRouteKey(api_type,context_name,server_port,elastic_api)
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": contextRouteKey=(" .. contextRouteKey .. ")")

  local contextHttpStickySession = RegGet("nodeInfo","_contextList_httpStickySession_" .. contextRouteKey)
  local contextHttpStickySessionCookieOptions = RegGet("nodeInfo","_contextList_httpStickySessionCookieOptions_" .. contextRouteKey)


  if not contextHttpStickySession
  then
    contextHttpStickySession = "false"
  end

  if not contextHttpStickySessionCookieOptions
  then
    contextHttpStickySessionCookieOptions = ""
  end

  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": contextHttpStickySession=(" .. tostring(contextHttpStickySession) .. ")")

  -- Determine the backend  for a request
  local backend = nil

  if contextHttpStickySession == "true"
  then
    local jlebCookie = CommonGetContextCookieName(contextRouteKey)

    if not jlebCookie
    then
      HttpRequestError("General error","jlebCookie is nil after CommonGetContextCookieName()",500)
    end

    ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": jlebCookie=(" .. tostring(jlebCookie) .. ")")

    local jlebCookieValue = ngx.var["cookie_" .. jlebCookie]
    ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": CURRENT jlebCookieValue=(" .. tostring(jlebCookieValue) .. ")")

    if not jlebCookieValue
    then
        jlebCookieValue = CoreGetCookieForContext(contextRouteKey)
        ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": NEW jlebCookieValue=(" .. tostring(jlebCookieValue) .. ")")

        if not jlebCookieValue
        then
          HttpRequestError("Service unavailable","no available microservice to handle the request",503)
        else
          ngx.header['Set-Cookie'] = jlebCookie .. '=' .. jlebCookieValue .. contextHttpStickySessionCookieOptions
        end
    end

    backend = CoreGetBackendForContext(jlebCookieValue,contextHttpStickySession)

    if not backend
    then
      ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": backend is not available for " .. jlebCookieValue .. ", switched to another one")
      jlebCookieValue = CoreGetCookieForContext(contextRouteKey)

      if jlebCookieValue
      then
        ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": NEW jlebCookieValue=(" .. tostring(jlebCookieValue) .. ")")
        ngx.header['Set-Cookie'] = jlebCookie .. '=' .. jlebCookieValue .. contextHttpStickySessionCookieOptions
        backend = CoreGetBackendForContext(jlebCookieValue,contextHttpStickySession)
      else
        HttpRequestError("Service unavailable","no available microservice to handle the request",503)
      end
    end
  else
    backend = CoreGetBackendForContext(contextRouteKey,contextHttpStickySession)
  end

  if not backend
  then
    ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": Service unavailable (" .. contextRouteKey .. ")")
    HttpRequestError("Service Unavailable","no available microservice to handle the request",503)
  end

  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": Context is available on backend = " .. backend)

  -- proxy parameters
  local frontendProtocol = ngx.var.scheme
  local backendProtocol = 'http'
  local backendURI = ngx.var.request_uri:gsub("^(/_eapi/[^/]+)","")

  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": backendProtocol=(" .. backendProtocol .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": frontendProtocol=(" .. frontendProtocol .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": backendURI=(" .. backendURI .. ")")

  ngx.var.frontendBaseURL = frontendProtocol .. "://" .. ngx.var.host .. ":" .. ngx.var.server_port
  ngx.var.backendBaseURL = backendProtocol .. "://" .. backend
  ngx.var.backend = backendProtocol .. "://" .. backend .. backendURI

  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": ngx.var.frontendBaseURL=(" .. ngx.var.frontendBaseURL .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": ngx.var.backendBaseURL=(" .. ngx.var.backendBaseURL .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": ngx.var.backend=(" .. ngx.var.backend .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN PROXY] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": END")
end

-----------------------------
-- Healthchecking endpoint --
-----------------------------
function JLupinLocationHealthcheck(server_port,api_type,elastic_api,context_name)

  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. server_port .."," .. api_type .. "," .. elastic_api .. "," .. context_name .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": ngx.var.scheme=(" .. ngx.var.scheme .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": ngx.var.request_uri=(" .. ngx.var.request_uri .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": Http header['Content-Type']=(" .. tostring(ngx.req.get_headers()["Content-Type"]) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": Http header['Accept']=(" .. tostring(ngx.req.get_headers()["Accept"]) .. ")")

  -- First step: node availability
  local status, err = RegGet("nodeInfo","state")

  if not status
  then
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": END: error")
    HttpRequestError("Service unavailable","Node is unavailable, status = nil, err = " .. err,503)
  else
    if status ~= G_NODE_STATE.ENABLED
    then
      ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": END: node is unavailable")
      HttpRequestError("Service unavailable","Node is unavailable, status = " .. tostring(status),503)
    end
  end

  if context_name == ""
  then
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": END: node is OK")
    HttpRequestOK()
  end

  local contextRouteKey = CommonGetContextRouteKey(api_type,context_name,server_port,elastic_api)

  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": BEGIN")

  local backend = CoreGetBackendForContext(contextRouteKey,false)

  if not backend
  then
    ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": END: Service unavailable")
    HttpRequestError("Service unavailable","",503)
  end

  ngx.log(ngx.DEBUG,"[JLUPIN HEALTHCHECK] Worker " .. ngx.worker.pid() .. ": " .. contextRouteKey .. ": END: OK")
  HttpRequestOK()
end


-------------------------
-- /_discover endpoint --
-------------------------
function JLupinLocationDiscover(server_type)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(server_type) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": ngx.var.scheme=(" .. ngx.var.scheme .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": ngx.var.request_uri=(" .. ngx.var.request_uri .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Http header['Content-Type']=(" .. GenNilHandler(ngx.req.get_headers()["Content-Type"]) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Http header['Accept']=(" .. GenNilHandler(ngx.req.get_headers()["Accept"]) .. ")")

  if not server_type
  then
        HttpRequestError("Configuration error","server_type is nil",500)
  end

  if server_type ~= G_SERVER_TYPE.admin
  then
      HttpRequestError("Service unavailable","Discovery is available only on admin servers",503)
  end

  local dataSet = HttpGetElementFromURI(ngx.var.request_uri,2)

  if not dataSet
  then
    HttpRequestError("Request error (nil)","dataSet is nil",500)
  end

  if dataSet == ""
  then
    HttpRequestError("Request error (empty)","dataSet is empty",500)
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": dataSet(" .. dataSet .. "): BEGIN")

  local content_type = "application/json"
  if ngx.var.arg_content
  then
    if ngx.var.arg_content == "plain"
    then
      content_type = "text/plain"
    end
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": dataSet(" .. dataSet .. "): content-type=(" .. content_type .. ")")

  local regName = ""
  local regKey = ""


  if dataSet == "microservices"
  then
    regName = "nodeInfo"
    regKey = "microserviceFilteredList"
  elseif dataSet == "contexts"
  then
    regName = "nodeInfo"
    regKey = "contextList"
  elseif dataSet == "routes"
  then
    regName = "nodeInfo"
    regKey = "contextRoutesList"
  else
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": dataSet(" .. dataSet .. "): END (unsupported dataSet)")
    HttpRequestError("Request error (unsupported data set)","unsupported dataSet",500)
  end

  local response_body = ""
  local dataSetValue = {}

  local regEntry,err = CoreRegDump(regName,regKey)

  if not regEntry
  then
    HttpRequestError(err,err,500)
  end

  if regKey == ""
  then

    if content_type == "application/json"
    then
      response_body = GenTableToJson(regEntry)
    else

      local regEntry_key = ""
      local regEntry_value = ""

      for regEntry_key,regEntry_value in pairs(regEntry)
      do
          response_body = response_body .. regEntry_key .. ":" .. regEntry_value .. "\n"
      end
    end
  else
      response_body = regEntry.value
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": dataSet(" .. dataSet .. "): END(response_body): " .. response_body)

  ngx.header['Content-Type'] = content_type
  ngx.header['Content-Length'] = response_body:len()
  ngx.status = 200
  ngx.say(response_body)
  ngx.exit(ngx.HTTP_OK)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

end


-------------------------
-- /_status endpoint --
-------------------------
function JLupinLocationStatus(server_type)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(server_type) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": ngx.var.scheme=(" .. ngx.var.scheme .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": ngx.var.request_uri=(" .. ngx.var.request_uri .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Http header['Content-Type']=(" .. GenNilHandler(ngx.req.get_headers()["Content-Type"]) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Http header['Accept']=(" .. GenNilHandler(ngx.req.get_headers()["Accept"]) .. ")")

  if not server_type
  then
        HttpRequestError("Configuration error","server_type is nil",500)
  end

  if server_type ~= G_SERVER_TYPE.admin
  then
      HttpRequestError("Service unavailable","Status info is available only on admin servers",503)
  end

  local statusScope = HttpGetElementFromURI(ngx.var.request_uri,2)

  if not statusScope
  then
    HttpRequestError("statusScope error (nil)","dataSet is nil",500)
  end

  if statusScope == ""
  then
    HttpRequestError("Request error (empty)","statusScope is empty",500)
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": statusScope(" .. statusScope .. "): BEGIN")

  local responseBody = {}
  local responseBodyJson = ""

  if statusScope == "components"
  then
    responseBody = CoreGetComponentsStatus()
  else
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": statusScope(" .. statusScope .. "): END (unsupported scope)")
    HttpRequestError("Request error (unsupported scope)","unsupported scope",500)
  end

  if not responseBody
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": statusScope(" .. statusScope .. "): END (data error)")
    HttpRequestError("Request error (data error)","responseBody is nil",500)
  else
    responseBodyJson = GenTableToJson(responseBody)
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": statusScope(" .. statusScope .. "): END(responseBodyJson): " .. responseBodyJson)

  ngx.header['Content-Type'] = "application/json"
  ngx.header['Content-Length'] = responseBodyJson:len()
  ngx.status = 200
  ngx.say(responseBodyJson)
  ngx.exit(ngx.HTTP_OK)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
end

----------------------
-- RegDump endpoint --
----------------------
function JLupinLocationRegDump(server_type)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. server_type .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": ngx.var.scheme=(" .. ngx.var.scheme .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": ngx.var.request_uri=(" .. ngx.var.request_uri .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Http header['Content-Type']=(" .. GenNilHandler(ngx.req.get_headers()["Content-Type"]) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Http header['Accept']=(" .. GenNilHandler(ngx.req.get_headers()["Accept"]) .. ")")

  if not server_type
  then
        HttpRequestError("Configuration error","server_type is nil",500)
  end

  if server_type ~= G_SERVER_TYPE.admin
  then
      HttpRequestError("Service unavailable","RegDump is available only on admin servers",503)
  end

  local regName = HttpGetElementFromURI(ngx.var.request_uri,2)
  local regKey = HttpGetElementFromURI(ngx.var.request_uri,3)

  if not regName
  then
    HttpRequestError("Request error (nil)","regName is nil",500)
  end

  if regName == ""
  then
    HttpRequestError("Request error (empty)","regName is empty",500)
  end

  if not regKey
  then
    regKey = ""
  end

  local content_type = "application/json"
  if ngx.var.arg_content
  then
    if ngx.var.arg_content == "plain"
    then
      content_type = "text/plain"
    end
  end

  local response_body = ""

  local regEntry,err = CoreRegDump(regName,regKey)
  if not regEntry
  then
    HttpRequestError(err,err,500)
  end

  if regKey == ""
  then

    if content_type == "application/json"
    then
      response_body = GenTableToJson(regEntry)
    else

      local regEntry_key = ""
      local regEntry_value = ""

      for regEntry_key,regEntry_value in pairs(regEntry)
      do
          response_body = response_body .. regEntry_key .. ":" .. regEntry_value .. "\n"
      end
    end
  else
      response_body = regEntry.value
  end

  ngx.header['Content-Type'] = content_type
  ngx.header['Content-Length'] = response_body:len()
  ngx.status = 200
  ngx.say(response_body)
  ngx.exit(ngx.HTTP_OK)

end
