require("framework.protobuf")


local ConfigPackageName = "DianShiTech.Config"
local GameConfigName = "Game"
local MappingConfigName = "IdMappingConfig"
local CommonDefineConfigName = "CommonDefine"
local SummaryLuaFile = "config._Summary"
local MappFiledAddLua = "config._MappFiledAddLua"
local configs = {}
local targetPlatform = CCApplication:sharedApplication():getTargetPlatform()
local _mapping = {}

local _datas = {}
local _mappfiled = require(MappFiledAddLua)
local function registerPb(path)
  pb.load(path)
end

local load_data = function(folder,data_file)
  -- load all pb files
  registerPb(string.format("%s/pbs/%sConfig.pb",folder,CommonDefineConfigName))
  for config, config_file in pairs(require(SummaryLuaFile)) do
    registerPb(string.format("%s/pbs/%sConfig.pb",folder,config))
  end
  for index, addPb in pairs(_mappfiled)do
    registerPb(string.format("%s/pbs/%s.pb",folder,addPb[3]))
  end
  registerPb(string.format("%s/pbs/%sConfig.pb",folder,GameConfigName))
  local path = string.format("%s/datas/%s",folder,data_file)
  path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)

  if targetPlatform == kTargetWindows then
    local in_data = assert(io.open(path,"rb"))
    local buffer =  in_data:read "*a"
    local all_config_data = protobuf.decode(string.format("%s.%sConfig",ConfigPackageName,GameConfigName) , buffer)
    _datas = all_config_data
    in_data:close()
  else
      print("path ====",path)
      local isExit = CCFileUtils:sharedFileUtils():isFileExist(path)    -- zip文件
      print("isexit======",isExit)
      if isExit == true then
	      local buffer =  CCFileUtils:sharedFileUtils():getFileDataFromZip(path,"all_config_data.data")   -- in_data:read "*a"
	      local all_config_data = protobuf.decode(string.format("%s.%sConfig",ConfigPackageName,GameConfigName) , buffer)
	      _datas = all_config_data
      else
	      local path = string.format("%s/datas/%s",folder,"all_config_data.data")	     
	      path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
		    print("data_file path2===",path)
	      local in_data = assert(io.open(path,"rb"))
	      local buffer =  in_data:read "*a"
	      local all_config_data = protobuf.decode(string.format("%s.%sConfig",ConfigPackageName,GameConfigName) , buffer)
	      _datas = all_config_data
	      in_data:close()
      end
  end
  configs["data_version"] = _datas.version
end

local function GetDataMappFiledId(name)
  for index, data in pairs(_mappfiled)do
    if string.lower(data[2]) == name then
      return string.lower(data[3])
    end
  end
  return nil
end

local setup_mapping = function(folder,mapping_file)
  -- register id mapping pb file
  registerPb(string.format("%s/pbs/%s.pb",folder, MappingConfigName))
  local path = string.format("%s/datas/%s",folder,mapping_file)
  path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
  print("mapping: ", path)
  local mapping_id_data = {}
  if targetPlatform == kTargetWindows then
	  local in_data = assert(io.open(path,"rb"))
	  local buffer =  in_data:read "*a"
	  mapping_id_data = protobuf.decode( string.format("%s.%s",ConfigPackageName,MappingConfigName), buffer)
	  in_data:close()
  else
	  local isExit = CCFileUtils:sharedFileUtils():isFileExist(path)    -- zip文件
	  if isExit == true then
		  local buffer =  CCFileUtils:sharedFileUtils():getFileDataFromZip(path,"mapping_id_data.data")
		  mapping_id_data = protobuf.decode( string.format("%s.%s",ConfigPackageName,MappingConfigName), buffer)
	  else
		  local path = string.format("%s/datas/%s",folder,"mapping_id_data.data")
		  path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
		  print("mapping_file path===",path)
		  local in_data = assert(io.open(path,"rb"))
		  local buffer =  in_data:read "*a"
		  mapping_id_data = protobuf.decode( string.format("%s.%s",ConfigPackageName,MappingConfigName), buffer)
		  in_data:close()
	  end
  end

  local mapping_id = {}
  if mapping_id_data == false then
    print("error........")
    return 
  end
  
  for index, addPb in pairs(_mappfiled)do
    print(mapping_id_data[string.lower(addPb[2])][string.lower(addPb[4])])
  end
  
  local tableCount = 0
  for k1, v1 in pairs(mapping_id_data) do
   for k2, v2 in pairs(v1)do
    --print("load table:",k2)
    tableCount = tableCount + 1
    configs[k2] = {}
    mapping_id[k2] ={}
    for k3, record in pairs(v2) do
      local gindex = GetDataMappFiledId(k1)
      if gindex == nil then
        assert(false)
        print("error........", k1)
        return 
      end
      configs[k2][record.id] = _datas[gindex][k2][record.index]
    end
   end
  end
  _mapping = mapping_id

  print("tableCount:",tableCount)
end

configs.init = function (root,data_file,mapping_file)
  _mapping = {}
  _datas = {}
  load_data(root,data_file)
  setup_mapping(root,mapping_file)
end

return configs