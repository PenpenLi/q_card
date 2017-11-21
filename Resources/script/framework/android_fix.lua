
local AndroidIO = class("AndroidIO")

function AndroidIO:ctor(path)
  self._path = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
end

function AndroidIO:read()
  echo("reading:"..self._path)
  local buf = CCFileUtils:sharedFileUtils():getFileData(self._path)
  if buf == nil then
    buf = CCFileUtils:sharedFileUtils():getFileDataFromZip(self._path)
  end
  return buf
end

function AndroidIO:close()

end

function io.open(path)

  return  AndroidIO.new(path)

end