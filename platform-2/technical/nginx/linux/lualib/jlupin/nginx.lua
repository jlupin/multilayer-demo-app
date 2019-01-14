---------------------
-- NginxServerList --
---------------------
function NginxConfServerList()

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")


  -- determine the nginx binary path
  local nginxBin = NginxGetBinPath()
  if not nginxBin
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": nginxBin is null, aborting...")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return nil,"nginxBin is null"
  end

  -- get the current configuration
  local NginxConf,err = OSCommandExecute(nginxBin .. " -T")

  if not NginxConf
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Getting Nginx conf has failed")
    for key,value in pairs(err)
    do
      ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Getting Nginx conf has failed, err[" .. key .. "]: " .. value)
    end
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return nil, "getting nginx conf has failed"
  end

  -- find virtual servers in the configuration
  local virtualServerPort = ""
  local virtualServerName = ""
  local virtualServerType = ""
  local confBlockId = 0
  local detectedBlocks = 0
  local i = 0

  local virtualServer = {}
  local virtualServerList = {}


  for idx,confLine in pairs(NginxConf)
  do
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Start analysing NginxConf[" .. idx .. "]: " .. confLine)
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": confBlockId=(" .. confBlockId .. ")")

    -- searching for 'server' directives
    if confBlockId == 0
    then
        if NginxConfDetectServerBlock(confLine)
        then
          confBlockId = 1
          i = i + 1
        end
    -- searching for 'listen', 'server_name' and 'server_type'
    elseif confBlockId == 1
    then
      detectedBlocks = NginxConfDetectBlock(confLine)
      confBlockId = confBlockId + detectedBlocks

      virtualServerPort = NginxConfGetServerPort(confLine)
      if virtualServerPort
      then
          virtualServer["port"]=virtualServerPort
      end

      virtualServerName = NginxConfGetServerName(confLine)
      if virtualServerName
      then
          virtualServer["name"]=virtualServerName
      end

      virtualServerType = NginxConfGetServerType(confLine)
      if virtualServerType
      then
          virtualServer["type"]=virtualServerType
      end

      if confBlockId == 0
      then
        table.insert(virtualServerList,virtualServer)
        virtualServer = {}
        ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": the 'server' block is closed")
      end

    else
      detectedBlocks = NginxConfDetectBlock(confLine)
      confBlockId = confBlockId + detectedBlocks
    end

    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": confBlockId=(" .. confBlockId .. ")")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Stop analysing NginxConf[" .. idx .. "]: " .. confLine)
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
  return virtualServerList

end



--------------------------
-- NginxConfDetectBlock --
--------------------------
function NginxConfDetectBlock(confLine)

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local _,beginBlockCount = string.gsub(confLine, "[^#]*{", "%1")
  local _,endBlockCount = string.gsub(confLine, "[^#]*}", "%1")

  if beginBlockCount > 0
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": beginBlockCount=(" .. beginBlockCount .. ")")
  end

  if endBlockCount > 0
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": endBlockCount=(" .. endBlockCount .. ")")
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
  return beginBlockCount - endBlockCount
end


--------------------------------
-- NginxConfDetectServerBlock --
--------------------------------
function NginxConfDetectServerBlock(confLine)

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local serverConfBlock = confLine:match("^%s*server%s*{[%s,#]*.*")

  if serverConfBlock
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": the 'server' block is opened")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return true
  else
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return nil
  end

end


----------------------------
-- NginxConfGetServerPort --
----------------------------
function NginxConfGetServerPort(confLine)

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")
  local virtualServerPort = ""

  -- listen <port>;
  virtualServerPort = confLine:match("^%s*listen%s+(%d+)%s*;[%s,#]*.*")
  if virtualServerPort
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": 'listen <port>' match, virtualServerPort=(" .. virtualServerPort .. ")")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return virtualServerPort
  end

  -- listen <ip|hostname>:port;
  virtualServerPort = confLine:match("^%s*listen%s+[%w,%.]+:(%d+)%s*;[%s,#]*.*")
  if  virtualServerPort
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": 'listen <ip|hostname>:port' match, virtualServerPort=(" .. virtualServerPort .. ")")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return virtualServerPort
  end

  -- listen *:port;
  virtualServerPort = confLine:match("^%s*listen%s+%*:(%d+)%s*;[%s,#]*.*")
  if virtualServerPort
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": 'listen *:port' match, virtualServerPort=(" .. virtualServerPort .. ")")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return virtualServerPort
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
  return nil
end

----------------------------
-- NginxConfGetServerName --
----------------------------
function NginxConfGetServerName(confLine)

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")
  local virtualServerName = ""

  -- server_name <name>;
  virtualServerName = confLine:match("^%s*server_name%s+(.*);[%s,#]*.*")
  if virtualServerName
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": 'server_name <name>' match, virtualServerName=(" .. virtualServerName .. ")")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return virtualServerName
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
  return nil
end

----------------------------
-- NginxConfGetServerType --
----------------------------
function NginxConfGetServerType(confLine)

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")
  local virtualServerType = ""

  -- set $server_type '<type>';
  virtualServerType = confLine:match("^%s*set%s+%$server_type%s+'([admin,data]+)'%s*;[%s,#]*.*")
  if virtualServerType
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": 'set $server_type '<type>'' match, virtualServerType=(" .. virtualServerType .. ")")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return virtualServerType
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
  return nil
end

---------------------
-- NginxGetBinPath --
---------------------
function NginxGetBinPath()

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local osType = RegGet("nodeInfo","osType")

  local binPath = ""

  if osType == "linux"
  then
    binPath = "." .. RegGet("nodeInfo","separator") .."sbin" .. RegGet("nodeInfo","separator") .. "nginx -p ./"
  elseif osType == "windows"
  then
    binPath = "." .. RegGet("nodeInfo","separator") .."nginx.exe"
  else
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Unsupported os type: " .. osType)
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return nil,"unsupported os type"
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": binPath=(" .. binPath .. ")")
  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

  return binPath
end


-----------------------
-- NginxGetMasterPID --
-----------------------
function NginxGetMasterPID()

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local pidFilePath = "logs" .. RegGet("nodeInfo","separator") .."nginx.pid"
  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": pidFilePath=(" .. pidFilePath .. ")")

  local masterPid = GenReadNumberFromFile(pidFilePath)

  if not masterPid
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot determine PID of NGINX master process from the file")
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
    return nil,"masterPid is nil"
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPid=(" .. masterPid .. ")")
  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

  return masterPid

end


------------------------
-- NginxSetMasterPID  --
------------------------
function NginxSetMasterPID()

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  masterPID = NginxGetMasterPID()

  if not masterPID
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPID is nil, cannot determine PID of NGINX master")
    return nil,"masterPID is nil"
  else
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPID=(" .. masterPID .. ")")
    RegSet("nodeInfo","masterPID",masterPID)
  end

  ngx.log(ngx.INFO, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": NGINX master has been found (" .. masterPID .. ")")

  return true,""
end


------------------------
-- NginxCheckPIDinOS  --
------------------------
function NginxCheckPIDinOS(pid)

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. pid ..")")

  local osType = RegGet("nodeInfo", "osType")
  local osCommand = ""

  if osType == "windows"
  then
    osCommand = "tasklist /FI \"PID eq " .. pid .. "\" /NH | find /c \"nginx.exe\""
  elseif osType == "linux"
  then
    osCommand = "cat /proc/" .. pid .. "/cmdline | grep -c \"nginx: master process\""
  else
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Unsupported os type")
    return nil,"unsupported os type"
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": osCommand=(" .. osCommand ..")")

  local res = {}
  local err = {}

  res, err = OSCommandExecute(osCommand)

  if not res
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot check the presense of master process in OS, res in nil")
    return nil,"res is nil"
  end

  if not res[1]
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot check the presense of master process in OS, res[1] in nil")
    return nil,"res[1] is nil"
  end

  local masterPIDStatus = tonumber(res[1])
  if not masterPIDStatus
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot check the presense of master process in OS, masterPIDStatus in nil")
    return nil,"masterPIDStatus is nil"
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPIDStatus=(" .. masterPIDStatus .. ")")

  return masterPIDStatus
end


-----------------------
-- NginxCheckMaster  --
-----------------------
function NginxCheckMaster()

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local masterPIDfromReg = RegGet("nodeInfo","masterPID")
  if not masterPIDfromReg
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPIDfromReg is nil, assumed that master is dead")
    return nil,"masterPIDfromReg is nil"
  end
  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPIDfromReg=(" .. masterPIDfromReg .. ")")

  local masterPIDfromFile = NginxGetMasterPID()
  if not masterPIDfromFile
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPIDfromFile is nil, assumed that master is dead")
    return nil,"masterPIDfromFile is nil"
  end

  ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPIDfromFile=(" .. masterPIDfromFile .. ")")

  if masterPIDfromReg ~= masterPIDfromFile
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Master process is probably dead, different PID detected in the file")
    return nil,"different PID detected in the file"
  end

  local masterPIDStatus = NginxCheckPIDinOS(masterPIDfromReg)

  if not masterPIDStatus
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": masterPIDStatus is nil, assumed that master is dead")
    return nil,"masterPIDStatus is nil"
  end

  if masterPIDStatus == 0
  then
    ngx.log(ngx.DEBUG, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": NGINX master process is not present in OS")
    return nil,"nginx is not present"
  end

  return true,""

end
