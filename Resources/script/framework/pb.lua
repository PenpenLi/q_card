require("framework.protobuf")

local pb = {}

function pb.load(pb_file)
    local path = CCFileUtils:sharedFileUtils():fullPathForFilename(pb_file)
    local pb_file = io.open(path,"rb")
    if pb_file ~= nil then
      local buffer = pb_file:read "*a"
      protobuf.register(buffer)
    else
      echoError("Can not open "..path)
    end
    pb_file:close()

end

function pb.encode(pattern,data)
  return protobuf.encode(pattern, data)
end

function pb.decode(pattern,data)
  return protobuf.decode(pattern, data)
end

return pb