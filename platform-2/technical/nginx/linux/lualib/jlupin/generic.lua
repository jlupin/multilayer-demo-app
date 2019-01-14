-- ################################
--         Registry Functions
-- ################################

------------
-- RegSet --
------------
function RegSet(reg_name, reg_key, reg_value, reg_ttl)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. reg_name .. "," .. reg_key .. "," .. tostring(reg_value) .. "," .. GenNilHandler(reg_ttl,"nil") .. ")")

  local reg = ngx.shared[reg_name]
  if not reg
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error, reg is nil or false, aborting")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return nil, "reg is nil or false"
  end

  local succ, err, forcible = reg:set(reg_key,reg_value,GenNilHandler(reg_ttl,"num"))
  if succ
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Succeeded, forcible=(" .. tostring(forcible) .. ")")
  else
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error, err=(" .. GenNilHandler(err) .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return nil,err
  end

  RegDump(reg_name)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
  return true,""

end

------------
-- RegAdd --
------------
function RegAdd(reg_name, reg_key, reg_value, reg_ttl)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. reg_name .. "," .. reg_key .. "," .. tostring(reg_value) .. "," .. GenNilHandler(reg_ttl,"nil") .. ")")

  local reg = ngx.shared[reg_name]
  if not reg
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error, reg is nil or false, aborting")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return nil, "reg is nil or false"
  end

  local succ, err, forcible = reg:add(reg_key,reg_value,GenNilHandler(reg_ttl,"num"))

  if succ == true
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Succeeded, forcible=(" .. tostring(forcible) .. ")")
  else
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error, err=(" .. GenNilHandler(err) .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return nil,err
  end

  RegDump(reg_name)

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
  return true,""

end

------------
-- RegGet --
------------
function RegGet(reg_name, reg_key)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. reg_name .. "," .. reg_key .. ")")

  local reg = ngx.shared[reg_name]
  if not reg
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error, reg is nil or false, aborting")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return nil, "reg is nil or false"
  end

  local reg_value = reg:get(reg_key)
  if reg_value
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": reg_value=(" .. tostring(reg_value) .. ")")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return reg_value,""
  else
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": reg_value=(nil)")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return nil,"Key not found or equals nil"
  end
end

---------------
-- RegGetAll --
---------------
function RegGetAll(reg_name)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. reg_name .. ")")

  local reg = ngx.shared[reg_name]

  if not reg
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error, reg is nil or false, aborting")
    return nil, "reg is nil or false"
  end

  local reg_keys = reg:get_keys(0)
  local regValueList = {}
  local idx = 1

  while idx <= GenTableLen(reg_keys)
  do
    regValueList[reg_keys[idx]] = reg:get(reg_keys[idx])
    idx = idx + 1
  end

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
  return regValueList
end


-------------
-- RegDump --
-------------
function RegDump(reg_name)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. reg_name .. ")")

  local reg = ngx.shared[reg_name]
  if not reg
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error, reg is nil or false, aborting")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return nil, "reg is nil or false"
  end

  local regKeys = reg:get_keys(0)
  if not regKeys
  then
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error, regKeys is nil of false, aborting")
    ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
    return nil, "regKeys is nil of false"
  end

  local i = 1
  while i <= #regKeys
  do
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": " .. reg_name .. "(" .. regKeys[i] .. ")=" .. tostring(reg:get(regKeys[i])))
    i = i + 1
  end

  ngx.log(ngx.DEBUG,"[JLUPIN DISCOVER] Worker " .. ngx.worker.pid() .. ": END")
  return true,""
end


-- ################################
--         OS Functions
-- ################################

---------------------------
--  OSCommandExecute  --
---------------------------

function OSCommandExecute(command)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(command) .. ")")

  if not command
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": command is nil, aborting")
    return nil,"command is nil"
  end

  local tmpFile = OSGenerateTmpFile()

  if not tmpFile
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": tmpFile is null, aborting...")
    return nil,"tmpFile is null"
  end

  local wrappedCommand = command .. " > " .. tmpFile .. " 2>&1"

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": wrappedCommand=(" .. wrappedCommand .. ")")

  local result = os.execute(wrappedCommand)
  local errorDesc = {}

  if not result
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error has accured occured during command execution (result=nil), aborting...")
    os.remove(tmpFile)
    errorDesc[1] = "result is nil"
    return nil,errorDesc
  end

  if result ~= true
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error has accured occured during command execution (result=" .. tostring(result) .. "), aborting...")
    errorDesc = GenReadFileAsTable(tmpFile)
    if not errorDesc
    then
      errorDesc[1] = "errorDesc is nul"
    end
    os.remove(tmpFile)
    return nil,errorDesc
  end

  local resultTable = GenReadFileAsTable(tmpFile)
  os.remove(tmpFile)

  if not resultTable
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot read the result file (resultTable=nil), aborting...")
    errorDesc[1] = "result is nil"
    return nil, errorDesc
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": OS command has been succeeded")

  return resultTable,errorDesc
end


-----------------------
-- OSGenerateTmpFile --
-----------------------
function OSGenerateTmpFile()

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")


  osType = RegGet("nodeInfo","osType")

  if not osType
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot determine OS type")
    return nil,"cannot determine OS type"
  end

  local tmpFile = os.tmpname()

  if not tmpFile
  then
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot generate temp file name, aborting")
    return nil,"Cannot generate temp file name"
  end

  local tempDir =  ""

  if osType == "windows"
  then
    tempDir = os.getenv("TEMP")
  elseif osType == "linux"
  then
    tempDir = ""
  else
    ngx.log(ngx.ERR, "[JLUPIN] Worker " .. ngx.worker.pid() .. ": Unknown OS type: " .. osType)
    return nil,"unknown OS type"
  end

  local tmpPath = tempDir .. tmpFile

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": tmpPath=(" .. tmpPath .. ")")

  return tmpPath

end



-- ################################
--         Misc Functions
-- ################################


---------------------------
-- GenReadNumberFromFile --
---------------------------
function GenReadNumberFromFile(filePath)

    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(filePath) .. ")")

    local file = io.open(filePath, "rb")

    if not file
    then
      ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot open the file " .. filePath .. ", aborting")
      return nil,"cannot open the file"
    end

    local content = file:read("*all")
    file:close()

    if not content
    then
      ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": The content from file " .. filePath .. " is nil, aborting")
      return nil,"content is nil"
    end

    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": content=(" .. content .. ")")

    if content == ""
    then
      ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": The  " .. filePath .. " file is empty, aborting")
      return nil,"file is empty"
    end

    local contentNumber = tonumber(content)

    if not contentNumber
    then
      ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Return value is not a number")
      return nil, "not a number"
    else
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": contentNumber=(" .. content ..")")
      return contentNumber
    end
end

-----------------------------
--   GenReadFileAsTable    --
-----------------------------

function GenReadFileAsTable(filePath)

    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. GenNilHandler(filePath) .. ")")

    if not filePath
    then
      ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": filePath is nil, aborting")
      return nil,"filePath is nil"
    end

    local file = io.open(filePath, "rb")

    if not file
    then
      ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Cannot open the file, aborting...")
      return nil,"cannot open the file"
    else
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": The file has been opened successfully")
    end

    local lines = {}
    local i = 1

    for line in file:lines()
    do
      lines[i] = line
      i = i + 1
    end

    file:close()

    return lines

end


------------------------
--   GenNilHandler    --
------------------------
function GenNilHandler(value,mode)

  if not value
  then

    if not mode
    then
      return ""
    end

    if mode == "num"
    then
      return 0
    elseif mode == "nil"
    then
      return "nil"
    else
      return ""
    end
  else
    return value
  end
end

-----------------
-- GenTableLen --
-----------------
function GenTableLen(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

--------------------
-- GenTableToJson --
--------------------
function GenTableToJson(table)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local inputType = tostring(type(table))
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": inputType=(" .. inputType ..")")

  local cjson = require "cjson"
  local cjson_safe = require "cjson.safe"
  local cjson2 = cjson.new()

  local jsonFromTable = cjson.encode(table)

  if not jsonFromTable
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": jsonFromTable is nil")
    return nil
  else
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": jsonFromTable=(" .. jsonFromTable .. ")")
  end

  local outputType = tostring(type(jsonFromTable))
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": outputType=(" .. outputType ..")")

  return jsonFromTable
end

--------------------
-- GenJsonToTable --
--------------------
function GenJsonToTable(json)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. json .. ")")

  local inputType = tostring(type(json))
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": inputType=(" .. inputType ..")")

  local cjson = require "cjson"
  local cjson_safe = require "cjson.safe"
  local cjson2 = cjson.new()

  local tableFromJson = cjson.decode(json)

  if not tableFromJson
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": tableFromJson is nil")
    return nil
  end

  local outputType = tostring(type(tableFromJson))
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": outputType=(" .. outputType ..")")

  return tableFromJson
end


----------------------
-- GenTableMinValue --
----------------------
function GenListMinValue(inputList,property,baseline)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. type(inputList) .. "," .. GenNilHandler(property) .. "," .. GenNilHandler(baseline) .. ")")

  if type(inputList) ~= "table"
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": inputList is not a table")
    return nil
  end

  if not property
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": property is nil")
    return nil
  end

  if not baseline
  then
    baseline = -1
  end

  local lowestValue = -1

  local key = ""
  local value = 0

  for key,value in pairs(inputList)
  do
    if type(value[property]) == "number"
    then

      if value[property] > baseline
      then
          if lowestValue == -1 or value[property] < lowestValue
          then
            lowestValue = value[property]
            ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": UPDATE lowestValue=(" .. lowestValue .. ")")
          end
      end

    end
  end

  if lowestValue == -1
  then
    lowestValue = nil
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END(lowestValue): " .. tostring(lowestValue))

  return lowestValue

end
