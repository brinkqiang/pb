
package.path = "../script/?.lua;" .. package.path

local lu = require "luaunit"

local pb     = require("pb")
local pbio   = require("pb.io")
local buffer = require("pb.buffer")
local slice  = require("pb.slice")
local conv   = require("pb.conv")
local protoc = require("protoc")

-- local assert_not = lu.assertEvalToFalse
local eq       = lu.assertEquals
local table_eq = lu.assertItemsEquals
local fail     = lu.assertErrorMsgContains
local is_true  = lu.assertIsTrue

protoc.proto3_optional = true

function _G.test()
   local function check_load(chunk, name)
      local pbdata = protoc.new():compile(chunk, name)
      local ret, offset = pb.load(pbdata)
      if not ret then
         error("load error at "..offset..
               "\nproto: "..chunk..
               "\ndata: "..buffer(pbdata):tohex())
      end
   end
  
  check_load(pbio.read("../proto/net.proto"), "../proto/net.proto")
  
  local message = {
     number = "13615632545",
     email = "13615632545@163.com",
     age = 28,
     ptype = "WORK",
     desc = {"first", "second", "three"},
     jobs = {{job_type=1, job_desc="dog"}, {job_type=2, job_desc="cat"}},
     optional_age="age"
  }
  
  local buf = pb.encode("net.tb_Person", message)
  
  local msg = pb.decode("net.tb_Person", buf)
  
  table_eq(message, msg)
end


if _VERSION == "Lua 5.1" and not _G.jit then
   lu.LuaUnit.run()
else
   os.exit(lu.LuaUnit.run(), true)
end
