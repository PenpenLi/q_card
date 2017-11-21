local localization = {}

function localization.init()
  -- local _language = CCApplication:sharedApplication():getCurrentLanguage()
  -- if _language == kLanguageChinese then
  --     _language = "zhcn"
  -- elseif _language == kLanguageFrench then
  --     _language = "fr"
  -- elseif _language == kLanguageItalian then
  --     _language = "it"
  -- elseif _language == kLanguageGerman then
  --     _language = "gr"
  -- elseif _language == kLanguageSpanish then
  --     _language = "sp"
  -- elseif _language == kLanguageRussian then
  --     _language = "ru"
  -- else
  --     _language = "en"
  -- end
  
  local _language = "zhcn" --简体中文
  local langCode = AllConfig.characterinitdata[24].data
  echo("==== language code:", langCode)
  if langCode == 2 then --繁体中文
    _language = "zhtw"
  elseif langCode == 3 then --日文
    _language = "jpn"    
  end 


  localization.language = _language
  
  -- for test
--  _language = "en"
  
  -- load language file
  i18n.setLocale(_language)
  local i18nPath = "localization/".._language..".lua"
  local i18nLang = require(i18nPath)
  
  if SEVER_LISTS_NAME ~= nil then
     for key, var in pairs(SEVER_LISTS_NAME) do
     	  i18nLang[key] = var
     end
  end
  local i18nData = {}

  localization.currentLanguage=i18nLang
  i18nData[_language] = i18nLang
  i18n.load(i18nData)
  
end

function localization.translate(key, data)
  local word = i18n(key, data)
  if nil == word then
    word = key
    word = string.gsub(word, "%%", " ") 
    printf("Can not found word for key:%s",key)
  end
  return word
end

_tr = localization.translate

return localization
