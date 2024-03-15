-- Constants
local IP_LENGTH = 32
local BYTES_COUNT = IP_LENGTH/8

-- Regular Colors
local RESET  = "\27[0m"
local RED    = "\27[31m"
local GREEN  = "\27[32m"
local YELLOW = "\27[33m"
local BLUE   = "\27[34m"

local function bad_usage_error(msg)
    msg = msg or ""
    print(string.format("%sERROR %s%s\nUsage:\n\tlua %s <ipv4>/<mask>\n", RED, msg, RESET, arg[0]))
    os.exit()
end

-- str: string to split
-- del: delimiter
-- returns a table with the pieces
local function split(str, del)
    local tabl = {}

    for word in string.gmatch(str, "([^"..del.."]+)") do
        tabl[#tabl + 1] = word
    end

    return tabl
end

-- num: number whose bits repesent an ipv4 
-- returns a string with ipv4 format
local function num_to_ip(num)
   local ip = ""
   local byte = 0

   for i=BYTES_COUNT,1,-1 do
       byte = num >> 8*(i-1)
       num = num & 2^(8*(i-1))-1
       ip = ip..tostring(byte)

       if (i > 1) then
           ip = ip.."."
       end
   end

   return ip
end

-- ip: string with ipv4 format 
-- returns a number whose bits repesent an ipv4 
local function ip_to_num(ip)
    local num = 0
    local number

    local bytes = split(ip, ".")
    if (#bytes ~= BYTES_COUNT) then
        bad_usage_error("that is not a correct ipv4")
    end

    for index=BYTES_COUNT,1,-1 do
        number = tonumber(bytes[BYTES_COUNT+1-index]);
        if (number == nil or number < 0 or number > 255) then
            bad_usage_error("that is not a correct ipv4")
        end
        num = num + (number << (8*(index-1)))
    end

    return num
end

-- require the ipv4/mask from command line arguments
if (#arg ~= 1) then
    bad_usage_error("this program requires exactly one argument")
end

-- split the ipv4 and mask
local tmp = split(arg[1], "/")
if (#tmp ~= 2) then
    bad_usage_error("use one (/) to separate the ipv4 and the mask")
end
local ip   = tmp[1]
local mask = tonumber(tmp[2])

-- check the mask is a number
if (mask == nil) then
    bad_usage_error("the mask is not a number")
end

-- check the mask is in [1-30]
if (mask < 1 or mask > IP_LENGTH-2) then
    bad_usage_error(string.format("the mask should be in range [1-%d]", IP_LENGTH-2))
end

-- do the calculations
local ip_num    = ip_to_num(ip)
local mask_num  = (2^(mask)-1) << (IP_LENGTH-mask)
local network   = ip_num  & mask_num
local broadcast = network | ((2^(IP_LENGTH-mask))-1)
local dev_cant  = broadcast-network-1

print(string.format("\n%s THE NETWORK IPs ARE:%s", GREEN, BLUE))
print(string.format(" IP          : %s", ip))
print(string.format(" MASK        : %s", num_to_ip(mask_num)))
print(string.format(" NETWORK     : %s", num_to_ip(network)))
print(string.format(" BROADCAST   : %s", num_to_ip(broadcast)))
print(string.format(" DEVS. RANGE.: %s-%s [%d]\n", num_to_ip(network+1), num_to_ip(broadcast-1), dev_cant))
