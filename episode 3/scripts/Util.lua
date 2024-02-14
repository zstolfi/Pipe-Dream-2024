local Util = {};

--[[ Table Operations ]]--------------------------------------------------------
function Util.deepCopy(T)
	local result = {};
	for i,v in pairs(T) do
		result[i] = (type(v) == "table") and Util.deepCopy(v) or v;
	end
	return result;
end

--[[ Table Search ]]------------------------------------------------------------
function Util.findMinByKey(t, less)
	local iMin, vMin;
	for i,v in pairs(t) do
		if iMin == nil or less(i, iMin) then
			iMin, vMin = i,v;
		end
	end
	return iMin, vMin;
end

function Util.firstPair(t)
	return Util.findMinByKey(t, function(i,j)
		return i < j;
	end);
end

function Util.lastPair(t)
	return Util.findMinByKey(t, function(i,j)
		return i > j;
	end);
end

function Util.pairBefore(t, i)
	return Util.findMinByKey(t, function(j,k)
		if j > i or k > i then
			return false; else
			return k > j; end
	end);
end

function Util.firstKey(t) local i,v = Util.firstPair(t); return i; end
function Util.firstVal(t) local i,v = Util.firstPair(t); return v; end

function Util.lastKey(t) local i,v = Util.lastPair(t); return i; end
function Util.lastVal(t) local i,v = Util.lastPair(t); return v; end

function Util.keyBefore(t, i) local i,v = Util.pairBefore(t); return i; end
function Util.valBefore(t, i) local i,v = Util.pairBefore(t); return v; end

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
	if #b64 % 4 ~= 0 or #b64 == 0 then
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
			if not isDigit(tuples[i]:sub(j,j)) then
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
		local c1, c2, c3, c4 = unpack(tuples[i]:split(""));
		result = result .. string.char(
			(digitOf(c1)* 4 + digitOf(c2)//16) % 256,
			(digitOf(c2)*16 + digitOf(c3)// 4) % 256,
			(digitOf(c3)*64 + digitOf(c4)// 1) % 256
		);
	end

	return result;
end

function Util.parseUint(bytes)
	local result = 0;
	for i=1, #bytes do
		result = 256*result + bytes:byte(i,i);
	end
	return result;
end

function Util.parseSint(bytes)
	local sign = bytes:byte(1,1) // 128;
	local exp = #bytes;
	return Util.parseUint(bytes) - sign * (256^exp - 1);
end

--[[ Binary Output ]]-----------------------------------------------------------
function Util.bytesToString(bytes)
	local hex = function(x) return ("0123456789abcdef"):sub(x+1,x+1); end;
	local result = "";
	for i=1, #bytes do
		result = result
		.. (i > 1 and " " or "")
		.. hex(bytes:byte(i,i)//16)
		.. hex(bytes:byte(i,i) %16);
	end
	return result;
end

return Util;