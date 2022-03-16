
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
   desc = {"first", "second", "three"}
}

local buf = pb.encode("net.tb_Person", message)
print(buf)