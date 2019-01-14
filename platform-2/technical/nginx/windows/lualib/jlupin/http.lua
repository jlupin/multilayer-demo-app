-- ################################
--         HTTP Functions
-- ################################

-----------------
-- HttpRequest --
-----------------
function  HttpRequest(method,url,content_type,body)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. method .. "," .. url .. "," .. content_type .. "," .. body .. ")")

  local http = require "resty.http"
  local httpc = http.new()

  httpc:set_timeouts(discoveryConnectionTimeout,discoverySendTimeout,discoveryReadTimeout)

  local res, err = httpc:request_uri(url, {
    method = method,
    body = body,
    headers = {["Content-Type"] = content_type}
  })


  httpc:close()

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END ")

  return res, err
end


---------------------
-- HttpHealthcheck --
---------------------
function  HttpHealthcheck(url)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. tostring(url) .. ")")

  local http = require "resty.http"
  local httpc = http.new()

  httpc:set_timeouts(healthcheckConnectionTimeout,healthcheckSendTimeout,healthcheckReadTimeout)

  local res, err = httpc:request_uri(url, {
    method = "GET",
    body = "",
    headers = {["Content-Type"] = "text/plain"}
  })

  httpc:close()
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END ")
  return res, err
end


------------------------
-- HttpRequestError   --
------------------------
function HttpRequestError( msg, err, status)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. tostring(msg) .. "," .. tostring(err) .. "," .. tostring(status) ..")")

  ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Error message: " .. tostring(err))

  HttpSimpleResponse(msg,status)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

end


------------------------
-- HttpRequestOK   --
------------------------
function HttpRequestOK()

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")

  local status = 200
  local msg = "OK"

  HttpSimpleResponse(msg,status)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

end

------------------------
-- HttpSimpleResponse --
------------------------
function HttpSimpleResponse(msg,status)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (".. msg .. "," .. status .. ")")

  local formatted_msg = ""
  local content_type = HttpDetermineContentType(ngx.req.get_headers()["Content-Type"],ngx.req.get_headers()["Accept"],"text/plain")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": content_type=(".. content_type .. ")")

  if content_type == "text/html"
  then
    formatted_msg = formatted_msg .. "<!DOCTYPE html>\n"
    formatted_msg = formatted_msg .. "<html>\n"
    formatted_msg = formatted_msg .. "<head><title>" .. status .. " " .. msg .. "</title></head>\n"
    formatted_msg = formatted_msg .. "<style>\n"
    formatted_msg = formatted_msg .. "    body {\n"
    formatted_msg = formatted_msg .. "        width: 35em;\n"
    formatted_msg = formatted_msg .. "        margin: 0 auto;\n"
    formatted_msg = formatted_msg .. "        font-family: Tahoma, Verdana, Arial, sans-serif;\n"
    formatted_msg = formatted_msg .. "    }\n"
    formatted_msg = formatted_msg .. "</style>\n"
    formatted_msg = formatted_msg .. "<body>"
    formatted_msg = formatted_msg .. "<h1>Response status: " .. status .. "</h1>\n"
    formatted_msg = formatted_msg .. "<p>Response message: " .. msg .. "</p>\n"
    formatted_msg = formatted_msg .. "<p><em>JLupin Edge Balancer</em></p>\n"
    formatted_msg = formatted_msg .. "</body>\n"
    formatted_msg = formatted_msg .. "</html>\n"
  elseif content_type == "application/json"
  then
    formatted_msg = "{\n"
    formatted_msg = formatted_msg .. "\t\"responseMessage\": \"" .. msg .. "\",\n"
    formatted_msg = formatted_msg .. "\t\"responseCode\": \"" .. status .. "\"\n"
    formatted_msg = formatted_msg .. "}\n"
  else
    formatted_msg = msg
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": formatted_msg: " .. formatted_msg)

  ngx.header['Content-Type'] = content_type
  ngx.header['Content-Length'] = formatted_msg:len()
  ngx.status = status
  ngx.say(formatted_msg)
  ngx.exit(status)

end

------------------------------
-- HttpDetermineContentType --
------------------------------
function HttpDetermineContentType(req_content_type,req_accept,default_content_type)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (".. tostring(req_content_type) .. "," .. tostring(req_accept) .. "," .. tostring(default_content_type).. ")")

  local fin_content_type = req_content_type

  if type(fin_content_type) == "table"
  then
    ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Multiple 'Content-type' headers, assuming default")
    ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")
    return default_content_type
  end

  if not fin_content_type
  then
    if req_accept
    then

      if type(req_accept) == "table"
      then
        ngx.log(ngx.ERR,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Multiple 'Accept' headers, assuming default")
        ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN")
        return default_content_type
      end

      req_accept = req_accept .. ","

      for accept_part in string.gmatch(req_accept,"[^,]*,")
      do
        if accept_part
        then
          fin_content_type = accept_part:gsub(",","")
          ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": content_type from 'Accept' header: " .. tostring(fin_content_type))
          break
        end
      end
    end

    if not fin_content_type
    then
      fin_content_type = default_content_type
      ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": Default content_type: " .. tostring(content_type))
    end
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")
  return fin_content_type

end

----------------------------
-- HttpGetElementFromURI  --
----------------------------
function HttpGetElementFromURI(uri,num)

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": BEGIN (" .. tostring(uri) .. "," .. tostring(num).. ")")

  local i = 1
  local element_from_uri = ""

  for w in  string.gmatch(uri,"/[^/]*")
  do
    if i == num
    then
      element_from_uri = w:gsub("/","")
      break
    end

    i = i + 1
  end

  if not element_from_uri
  then
    element_from_uri = ""
  end

  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": element_from_uri=(" .. tostring(element_from_uri) .. ")")
  ngx.log(ngx.DEBUG,"[JLUPIN] Worker " .. ngx.worker.pid() .. ": END")

  return element_from_uri
end
