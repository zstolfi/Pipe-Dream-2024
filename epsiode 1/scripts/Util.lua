local Util = {};

--[[ Table Operations ]]--------------------------------------------------------
function Util.deepCopy(T)
	local result = {};
	for i,v in pairs(T) do
		result[i] = (type(v) == "table") and Util.deepCopy(v) or v;
	end
	return result;
end

--[[ Binary Input ]]------------------------------------------------------------
function Util.parseBase64(b64) --> expected binary string
	local Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	..               "abcdefghijklmnopqrstuvwxyz"
	..               "0123456789+/";
	local Pad = "=";
	local isDigit = function(c) return Alphabet:find(c) ~= nil; end;
	local isPad   = function(c) return c == Pad; end;
	local digitOf = function(c)
		return (c == Pad) and 0 or Alphabet:find(c) - 1;
	end;

	-- Check input size.
	if (#b64 % 4) ~= 0 or #b64 == 0 then
		return nil, "Unexpected b64 length";
	end

	-- Store each group of 4 bytes in a table.
	local tuples = {};
	for i=1, #b64, 4 do
		tuples[#tuples + 1] = b64:sub(i, i+3);
	end

	-- Check for correct digits.
	for i=1, #tuples do
		local isLast = i == #tuples;
		for j=1, (isLast and 2 or 4) do
			if not Alphabet:find(tuples[i]:sub(j,j)) then
				return nil, "Invalid b64 digit";
			end
		end
	end

	local p, q = unpack(tuples[#tuples]:sub(3,4):split(""));
	if  not (isDigit(p) and isDigit(q))
	and not (isDigit(p) and isPad  (q))
	and not (isPad  (p) and isPad  (q)) then
		return nil, "Invalid b64 padding";
	end

	-- Transform into bytes.
	local result = "";
	for i=1, #tuples do
		local c1, c2, c3, c4 = unpack(tuples[i]:split(""))
		result = result .. string.char(
			(digitOf(c1)* 4 + digitOf(c2)//16) % 256,
			(digitOf(c2)*16 + digitOf(c3)// 4) % 256,
			(digitOf(c3)*64 + digitOf(c4)// 1) % 256
		);
	end

	return result;
end

function Util.parseU32(bytes)
	return 256^3 * bytes:byte(1,1)
	+      256^2 * bytes:byte(2,2)
	+      256^1 * bytes:byte(3,3)
	+      256^0 * bytes:byte(4,4);
end

function Util.parseS32(bytes)
	local sign = bytes:byte(1,1) // 128 == 1;
	return Util.parseU32(bytes) - (sign and 256^4 - 1 or 0);
end

function Util.parseU16(bytes)
	return 256^1 * bytes:byte(1,1)
	+      256^0 * bytes:byte(2,2);
end

function Util.parseS16(bytes)
	local sign = bytes:byte(1,1) // 128 == 1;
	return Util.parseU16(bytes) - (sign and 256^2 - 1 or 0);
end

function Util.parseU8(bytes) return bytes:byte(1,1); end
function Util.parseS8(bytes) return ((bytes:byte(1,1) + 128) % 256) - 128; end

--[[ Binary Output ]]-----------------------------------------------------------
function Util.printBytes(bytes)
	local hex = function(x) return ("0123456789abcdef"):sub(x+1,x+1); end
	local line = "";
	for i=1, #bytes do
		print(hex(bytes:byte(i,i)//16) .. hex(bytes:byte(i,i)%16));
	end
end

return Util;