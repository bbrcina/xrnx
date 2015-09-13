--[[============================================================================
xEffectColumn
============================================================================]]--
--[[

  This class is representing renoise.EffectColumn
  Unlike the renoise.EffectColumn, this one can be freely defined, 
  without the need to have the line present in an actual song 

]]

class 'xEffectColumn'

xEffectColumn.tokens = {
    "number_value","number_string", 
    "amount_value","amount_string",
}

-------------------------------------------------------------------------------
-- constructor
-- @param args (table), a xline descriptor - fully or sparsely populated

function xEffectColumn:__init(args)

  self.number_value = property(self.get_number_value,self.set_number_value)
  self._number_value = nil
  self.number_string = property(self.get_number_string,self.set_number_string)
  self._number_string = nil

  self.amount_value = property(self.get_amount_value,self.set_amount_value)
  self._amount_value = nil
  self.amount_string = property(self.get_amount_string,self.set_amount_string)
  self._amount_string = nil

  for token,value in pairs(args) do
    if (table.find(xEffectColumn.tokens,token)) then
      --print("*** xEffectColumn:__init - token,value",token,value)
      self[token] = args[token]
    end
  end

end

-------------------------------------------------------------------------------
-- Get/set methods
-------------------------------------------------------------------------------

function xEffectColumn:get_number_value()
  return self._number_value
end

function xEffectColumn:set_number_value(val)
  self._number_value = val
  self._number_string = xEffectColumn.number_value_to_string(val)
end

function xEffectColumn:get_number_string()
  return self._number_string
end

function xEffectColumn:set_number_string(str)
  self._number_string = str
  self._number_value = xEffectColumn.number_string_to_value(str)
end

-------------------------------------------------------------------------------

function xEffectColumn:get_amount_value()
  return self._amount_value
end

function xEffectColumn:set_amount_value(val)
  self._amount_value = val
  self._amount_string = xEffectColumn.amount_value_to_string(val) 
end

function xEffectColumn:get_amount_string()
  return self._amount_string
end

function xEffectColumn:set_amount_string(str)
  self._amount_string = str
  self._amount_value = xEffectColumn.amount_string_to_value(str)
end


-------------------------------------------------------------------------------
-- Converter methods (static implementation)
-------------------------------------------------------------------------------

function xEffectColumn.number_value_to_string(val)
  --TRACE("xEffectColumn.number_value_to_string(val)",val)
  local first = math.floor(val/256)
  local str_first = xLinePattern.EFFECT_CHARS[first+1]
  local str_second = xLinePattern.EFFECT_CHARS[val-(first*256)+1]
  if str_first and str_second then
    return str_first..str_second
  else
    error("Unexpected effect number. Expected two bytes between 0-35 respectively")
  end
end

function xEffectColumn.number_string_to_value(str)
  local digit_1 = table.find(xLinePattern.EFFECT_CHARS,string.sub(str,1,1))-1
  local digit_2 = table.find(xLinePattern.EFFECT_CHARS,string.sub(str,2,2))-1
  if digit_1 and digit_2 then
    return digit_1*256 + digit_2
  else
    return 0
  end
end

-------------------------------------------------------------------------------

function xEffectColumn.amount_value_to_string(val)
  --TRACE("xEffectColumn.amount_value_to_string(val)",val)
  return ("%.2X"):format(val)
end

function xEffectColumn.amount_string_to_value(str)
  return tonumber("0x"..str)
end

-------------------------------------------------------------------------------
-- @param fx_col (renoise.EffectColumn)
-- @param tokens (table<xStreamModel.output_tokens>)
-- @param clear_undefined (bool)

function xEffectColumn:do_write(fx_col,tokens,clear_undefined)

  for k,token in ipairs(tokens) do
    if self["do_write_"..token] then
      local success = pcall(function()
        self["do_write_"..token](self,fx_col,clear_undefined)
      end)
      if not success then
         LOG("WARNING: xEffectColumn - Trying to write invalid value to property:",token,self[token])
      end
    --else
    --  LOG("WARNING: xEffectColumn - Trying to assign value to non-existing property:",token)
    end
  end

end

-------------------------------------------------------------------------------
-- we need a function for each possible token

function xEffectColumn:do_write_number_value(fx_col,clear_undefined)
  --TRACE("xEffectColumn:do_write_number_value(fx_col,clear_undefined)",fx_col,clear_undefined)
  if self.number_value then 
    fx_col.number_value = self.number_value
  elseif clear_undefined then
    fx_col.number_value = 0
  end
end

function xEffectColumn:do_write_number_string(fx_col,clear_undefined)
  --TRACE("xEffectColumn:do_write_number_string(fx_col,clear_undefined)",fx_col,clear_undefined)
  if self.number_string then 
    fx_col.number_string = self.number_string
  elseif clear_undefined then
    fx_col.number_string = xLinePattern.EMPTY_STRING
  end
end

function xEffectColumn:do_write_amount_value(fx_col,clear_undefined)
  --TRACE("xEffectColumn:do_write_amount_value(fx_col,clear_undefined)",fx_col,clear_undefined)
  if self.amount_value then 
    fx_col.amount_value = self.amount_value
  elseif clear_undefined then
    fx_col.amount_value = 0
  end
end

function xEffectColumn:do_write_amount_string(fx_col,clear_undefined)
  --TRACE("xEffectColumn:do_write_amount_string(fx_col,clear_undefined)",fx_col,clear_undefined)
  if self.amount_string then 
    fx_col.amount_string = self.amount_string
  elseif clear_undefined then
    fx_col.amount_string = xLinePattern.EMPTY_STRING
  end
end

-------------------------------------------------------------------------------
-- @param fx_col (renoise.EffectColumn)
-- @return table 

function xEffectColumn.do_read(fx_col)
  --TRACE("xEffectColumn.do_read(fx_col)")

  local rslt = {}
  for k,v in ipairs(xEffectColumn.tokens) do
    rslt[v] = fx_col[v]
  end

  return rslt

end


-------------------------------------------------------------------------------

function xEffectColumn:__tostring()

  return "xEffectColumn"

end
