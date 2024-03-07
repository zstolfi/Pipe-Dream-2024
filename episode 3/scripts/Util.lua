local Util = {};

--[[ Table Operations ]]--------------------------------------------------------
function Util.tableEqual(t, u)
	if #t ~= #u then return false; end
	for i,v in pairs(t) do
		local w = u[i];
		if (type(v) ~= type(w))
		or (type(v) ~= "table" and v ~= w)
		or (type(v) == "table" and not Util.tableEqual(v,w)) then
			return false;
		end
	end
	return true;
end

function Util.deepCopy(T)
	local result = {};
	for i,v in pairs(T) do
		result[i] = (type(v) == "table") and Util.deepCopy(v) or v;
	end
	return result;
end

--[[ Table Lookup ]]------------------------------------------------------------
function Util.findUnitl(t, pred) --> index
	-- Binary search.
	local lower, upper = 1, #t;
	do
		local pl, pu = pred(lower), pred(upper);
		if (pl == false and pu == false) then return upper; end
		if (pl == true  and pu == true ) then return lower; end
	end

	-- Assume going forward: pred(lower) == false and pred(upper) == true
	while (lower < upper-1) do
		local middle = (lower+upper)//2;
		if (pred(middle) == false) then
			lower = middle;
		else
			upper = middle
		end
	end

	return lower;
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