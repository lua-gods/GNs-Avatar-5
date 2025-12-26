local PRECISION = 100

local measurements = {
	bit = 1/8,
	byte = 1,
	kb = 1000,
	mb = 1000 ^ 2,
	gb = 1000 ^ 3,
	tb = 1000 ^ 4,
	pb = 1000 ^ 5,
	
	kib = 1024,
	mib = 1024 ^ 2,
	gib = 1024 ^ 3,
	tib = 1024 ^ 4,
	pib = 1024 ^ 5,
	
	km = 1000,
	m = 0,
	cm = 0.01,
	mm = 0.001,
	um = 0.000001,
	nm = 0.000000001,
}


function convert(value, from, to)
	print((math.floor(value * measurements[from] / measurements[to]*PRECISION)/PRECISION)..to)
end