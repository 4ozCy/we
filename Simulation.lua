-- Saved with DexRESerializer (https://github.com/Tesker-103/DexRecontinued/)

local v_u_1 = require(script.Parent.Parent.Config)
local v_u_2 = require(script.Parent.Ball)
local v_u_3 = require(script.Parent.Cluster)
local v_u_4 = require(script.Parent.Collision)
local v_u_5 = require(script.Parent.Cue)
local v_u_6 = require(script.Parent.Flight)
local v_u_7 = require(script.Parent.Table)
local v_u_8 = require(script.Parent.Parent.Ults.Effects)
local v_u_11 = {
	["newState"] = function(p9, p10) -- name: newState
		return {
			["geometry"] = nil,
			["balls"] = nil,
			["time"] = 0,
			["geometry"] = p9,
			["balls"] = p10
		}
	end
}
local function v_u_16(p12) -- name: deepCopy
	-- upvalues: (copy) v_u_16
	if type(p12) ~= "table" then
		return p12
	end
	local v13 = {}
	for v14, v15 in p12 do
		v13[v14] = v_u_16(v15)
	end
	return v13
end
function v_u_11.cloneState(p17) -- name: cloneState
	-- upvalues: (copy) v_u_2, (copy) v_u_16
	local v18 = {
		["geometry"] = p17.geometry,
		["balls"] = v_u_2.cloneList(p17.balls),
		["time"] = p17.time
	}
	local v19
	if p17.overrides then
		v19 = v_u_16(p17.overrides)
	else
		v19 = nil
	end
	v18.overrides = v19
	local v20
	if p17.fx then
		v20 = v_u_16(p17.fx)
	else
		v20 = nil
	end
	v18.fx = v20
	v18.halted = p17.halted
	v18.power = p17.power
	return v18
end
function v_u_11.isAtRest(p21) -- name: isAtRest
	-- upvalues: (copy) v_u_2, (copy) v_u_7
	for _, v22 in p21.balls do
		if v_u_2.isMoving(v22) then
			return false
		end
		if v22.pocketed or v_u_7.pocketAt(p21.geometry, v22.x, v22.y) == nil then
			continue
		end
		return false
	end
	return true
end
function v_u_11.energy(p23) -- name: energy
	-- upvalues: (copy) v_u_1, (copy) v_u_2
	local v24 = v_u_1.Balls.RadiusInches
	local v25 = 0
	for _, v26 in p23.balls do
		v25 = v25 + v_u_2.kineticEnergy(v26, v24, v_u_1.Physics.Gravity)
	end
	return v25
end
function v_u_11.findBall(p27, p28) -- name: findBall
	for _, v29 in p27.balls do
		if v29.id ~= p28 then
			continue
		end
		return v29
	end
	return nil
end
local function v_u_52(p30, p31, p32) -- name: integrateFalling
	-- upvalues: (copy) v_u_1, (copy) v_u_2
	local v33 = v_u_1.Physics
	local v34 = v_u_1.Table
	p30.vz = p30.vz - v33.Gravity * p31
	p30.z = p30.z + p30.vz * p31
	if p32 then
		local v35 = p30.x - p32.x
		local v36 = p30.y - p32.y
		local v37 = v35 * v35 + v36 * v36
		local v38 = math.sqrt(v37)
		if v38 > 1e-6 then
			local v39 = v35 / v38
			local v40 = v36 / v38
			p30.vx = p30.vx - v39 * v34.PocketFunnelAccel * p31
			p30.vy = p30.vy - v40 * v34.PocketFunnelAccel * p31
		end
	end
	local v41 = 1 - v34.PocketDragPerSecond * p31
	local v42 = math.max(0, v41)
	p30.vx = p30.vx * v42
	p30.vy = p30.vy * v42
	p30.x = p30.x + p30.vx * p31
	p30.y = p30.y + p30.vy * p31
	if p32 then
		local v43 = p30.x - p32.x
		local v44 = p30.y - p32.y
		local v45 = v43 * v43 + v44 * v44
		local v46 = math.sqrt(v45)
		local v47 = p32.radius - v_u_1.Balls.RadiusInches
		local v48 = math.max(v47, 0)
		if v48 < v46 and v46 > 1e-6 then
			local v49 = v43 / v46
			local v50 = v44 / v46
			p30.x = p32.x + v49 * v48
			p30.y = p32.y + v50 * v48
			local v51 = p30.vx * v49 + p30.vy * v50
			if v51 > 0 then
				p30.vx = p30.vx - (1 + v34.PocketWallRestitution) * v51 * v49
				p30.vy = p30.vy - (1 + v34.PocketWallRestitution) * v51 * v50
			end
		end
	end
	if p30.z <= -v34.PocketDropDepthInches then
		p30.z = -v34.PocketDropDepthInches
		v_u_2.stop(p30)
		p30.falling = false
		p30.tip = nil
	end
end
local function v_u_71(p53, p54, p55, p56) -- name: integrateTip
	-- upvalues: (copy) v_u_1
	local v57 = p53.tip
	if v57 == nil then
		return nil
	end
	local v58 = v_u_1.Balls.RadiusInches
	local v59 = v_u_1.Physics.Gravity
	v57.px = v57.px + p53.vx * p54
	v57.py = v57.py + p53.vy * p54
	local v60 = v57.omega
	local v61 = 5 * v59 / (7 * v58)
	local v62 = v57.theta
	v57.omega = v60 + v61 * math.sin(v62) * p54
	v57.theta = v57.theta + v57.omega * p54
	local v63 = v57.theta
	local v64 = math.sin(v63)
	local v65 = v57.theta
	local v66 = math.cos(v65)
	p53.x = v57.px + v58 * v64 * v57.nx
	p53.y = v57.py + v58 * v64 * v57.ny
	p53.z = v58 * (v66 - 1)
	p53.wx = -v57.ny * v57.omega
	p53.wy = v57.nx * v57.omega
	if v58 * v57.omega * v57.omega < v59 * v66 and v57.theta < 1.5707963267948966 then
		return nil
	end
	local v67 = v58 * v57.omega
	p53.vx = p53.vx + v57.nx * v67 * v66
	p53.vy = p53.vy + v57.ny * v67 * v66
	p53.vz = -v67 * v64
	p53.tip = nil
	if p55 then
		p53.pocket = p55.id
	end
	local v68 = {
		["t"] = nil,
		["type"] = "pocket",
		["ball"] = nil,
		["other"] = nil,
		["speed"] = nil,
		["t"] = p56,
		["ball"] = p53.id
	}
	local v69
	if p55 then
		v69 = p55.id
	else
		v69 = nil
	end
	v68.other = v69
	local v70 = p53.vx * p53.vx + p53.vy * p53.vy + p53.vz * p53.vz
	v68.speed = math.sqrt(v70)
	return v68
end
local function v_u_77(p72, p73, p74) -- name: leaveTable
	p72.pocketed = true
	p72.offTable = true
	p72.falling = false
	p72.pocket = nil
	p72.tip = nil
	if p73 then
		local v75 = {
			["t"] = nil,
			["type"] = "offTable",
			["ball"] = nil,
			["speed"] = nil,
			["t"] = p74,
			["ball"] = p72.id
		}
		local v76 = p72.vx * p72.vx + p72.vy * p72.vy + p72.vz * p72.vz
		v75.speed = math.sqrt(v76)
		table.insert(p73, v75)
	end
end
local function v_u_122(p78, p79, p80, p81, p82, p83, p84) -- name: integrateBall
	-- upvalues: (copy) v_u_71, (copy) v_u_52, (copy) v_u_6, (copy) v_u_7, (copy) v_u_1, (copy) v_u_77, (copy) v_u_122
	if p78.pocketed then
		local v85
		if p78.pocket then
			v85 = p80.pockets[p78.pocket]
		else
			v85 = nil
		end
		if p78.tip then
			local v86 = v_u_71(p78, p79, v85, p82)
			if v86 and p81 then
				table.insert(p81, v86)
				return
			end
		elseif p78.falling then
			v_u_52(p78, p79, v85)
		end
		return
	elseif p78.z > 0 or p78.vz > 0 then
		local v87 = v_u_6.fly(p78, p79)
		if p79 <= v87 then
			return
		else
			local v88 = p82 - (p79 - v87)
			if v_u_7.openingAt(p80, p78.x, p78.y) then
				return
			elseif v_u_7.containsCenter(p80, p78.x, p78.y, v_u_1.Balls.RadiusInches) then
				local v89 = -p78.vz
				v_u_6.slate(p78, v89, true)
				if p81 then
					local v90 = {
						["t"] = nil,
						["type"] = "land",
						["ball"] = nil,
						["speed"] = nil,
						["t"] = v88,
						["ball"] = p78.id,
						["speed"] = v89
					}
					table.insert(p81, v90)
				end
				v_u_122(p78, p79 - v87, p80, p81, p82, p83, p84)
			else
				v_u_77(p78, p81, v88)
			end
		end
	else
		local v91 = v_u_1.Physics
		local v92 = v_u_1.Balls.RadiusInches
		local v93 = v91.Gravity
		local v94 = p83 or v91.SlidingFriction
		local v95 = p84 or v91.RollingFriction
		local v96 = p78.vx - v92 * p78.wy
		local v97 = p78.vy + v92 * p78.wx
		local v98 = v96 * v96 + v97 * v97
		local v99 = math.sqrt(v98)
		local v100
		if v91.SlideEpsilon < v99 then
			local v101 = v96 / v99
			local v102 = v97 / v99
			local v103 = v94 <= 0 and (1 / 0) or v99 / (3.5 * v94 * v93)
			local v104 = math.min(v103, p79)
			local v105 = -v94 * v93
			local v106 = 2.5 * v94 * v93 / v92
			p78.x = p78.x + (p78.vx * v104 + 0.5 * v105 * v101 * v104 * v104)
			p78.y = p78.y + (p78.vy * v104 + 0.5 * v105 * v102 * v104 * v104)
			p78.vx = p78.vx + v105 * v101 * v104
			p78.vy = p78.vy + v105 * v102 * v104
			p78.wx = p78.wx + -v106 * v102 * v104
			p78.wy = p78.wy + v106 * v101 * v104
			v100 = p79 - v104
			if v103 <= p79 then
				p78.wx = -p78.vy / v92
				p78.wy = p78.vx / v92
			end
		else
			v100 = p79
		end
		if v100 > 0 then
			local v107 = p78.vx * p78.vx + p78.vy * p78.vy
			local v108 = math.sqrt(v107)
			if v108 > 0 then
				local v109 = v95 * v93
				local v110 = v109 <= 0 and (1 / 0) or v108 / v109
				local v111 = math.min(v110, v100)
				local v112 = p78.vx / v108
				local v113 = p78.vy / v108
				p78.x = p78.x + (p78.vx * v111 - 0.5 * v109 * v112 * v111 * v111)
				p78.y = p78.y + (p78.vy * v111 - 0.5 * v109 * v113 * v111 * v111)
				if v110 <= v100 then
					p78.vx = 0
					p78.vy = 0
				else
					p78.vx = p78.vx - v109 * v112 * v111
					p78.vy = p78.vy - v109 * v113 * v111
				end
			end
			p78.wx = -p78.vy / v92
			p78.wy = p78.vx / v92
		end
		if p78.wz ~= 0 then
			local v114 = p78.wz
			local v115 = p78.wz
			local v116 = math.sign(v115)
			local v117 = p78.wz
			local v118 = math.abs(v117)
			local v119 = v91.SideSpinDecel * p79
			p78.wz = v114 - v116 * math.min(v118, v119)
		end
		local v120 = p78.vx * p78.vx + p78.vy * p78.vy
		if math.sqrt(v120) < v91.RestSpeed then
			local v121 = (p78.vx - v92 * p78.wy) ^ 2 + (p78.vy + v92 * p78.wx) ^ 2
			if math.sqrt(v121) < v91.SlideEpsilon then
				p78.vx = 0
				p78.vy = 0
				p78.wx = 0
				p78.wy = 0
			end
		end
		return
	end
end
local function v_u_129(p123) -- name: railRestitution
	-- upvalues: (copy) v_u_1
	local v124 = v_u_1.Physics.RailRestitutionBySpeed
	if #v124 == 0 then
		return v_u_1.Physics.RailRestitution
	end
	if p123 <= v124[1].Speed then
		return v124[1].Restitution
	end
	for v125 = 2, #v124 do
		local v126 = v124[v125]
		if p123 > v126.Speed then
			continue
		end
		local v127 = v124[v125 - 1]
		local v128 = (p123 - v127.Speed) / (v126.Speed - v127.Speed)
		return v127.Restitution + v128 * (v126.Restitution - v127.Restitution)
	end
	return v124[#v124].Restitution
end
local function v_u_162(p130, p131, p132, p133, p134) -- name: resolveRail
	-- upvalues: (copy) v_u_1
	local v135 = v_u_1.Balls.RadiusInches
	local v136 = v_u_1.Physics.CushionNoseHeightInches / v135 - 1
	local v137 = 1 - v136 * v136
	local v138 = math.sqrt(v137)
	local v139 = -p132
	local v140 = p130.vx * p131 + p130.vy * p132
	if v140 >= 0 then
		return 0
	end
	local v141 = p130.vx * v139 + p130.vy * p131
	local v142 = p130.wx * p131 + p130.wy * p132
	local v143 = p130.wx * v139 + p130.wy * p131
	local v144 = p130.wz
	local v145 = -v140
	local v146 = v141 - v135 * (v138 * v144 + v136 * v142)
	local v147 = v136 * v140 + v135 * v143
	local v148 = v146 * v146 + v147 * v147
	local v149 = math.sqrt(v148)
	local v150 = (p133 + 1) * v138 * v145
	local v151, v152
	if v149 > 0 then
		local v153 = v149 / 3.5
		local v154 = p134 * v150
		local v155 = math.min(v153, v154)
		v151 = -v155 * v146 / v149
		v152 = -v155 * v147 / v149
	else
		v151 = 0
		v152 = 0
	end
	local v156 = v140 + (v150 * v138 + v152 * v136)
	local v157 = v141 + v151
	local v158 = v142 - 2.5 * v136 * v151 / v135
	local v159 = v143 + v152 * 2.5 / v135
	local v160 = v144 - v138 * 2.5 * v151 / v135
	local v161 = math.abs(v156)
	p130.vx = v161 * p131 + v157 * v139
	p130.vy = v161 * p132 + v157 * p131
	p130.wx = v158 * p131 + v159 * v139
	p130.wy = v158 * p132 + v159 * p131
	p130.wz = v160
	return v145
end
local function v_u_224(p163, p164, p165) -- name: resolveBalls3D
	-- upvalues: (copy) v_u_1, (copy) v_u_6, (copy) v_u_2, (copy) v_u_3
	local v166 = v_u_1.Balls.RadiusInches
	local v167 = p165 or v_u_1.Physics.BallRestitution
	local v168 = not v_u_6.isAirborne(p163)
	local v169 = not v_u_6.isAirborne(p164)
	local v170 = p164.x - p163.x
	local v171 = p164.y - p163.y
	local v172 = p164.z - p163.z
	local v173 = v170 * v170 + v171 * v171 + v172 * v172
	local v174 = math.sqrt(v173)
	if v174 < 1e-12 then
		return 0
	end
	local v175 = v170 / v174
	local v176 = v171 / v174
	local v177 = v172 / v174
	local v178 = (p163.vx - p164.vx) * v175 + (p163.vy - p164.vy) * v176 + (p163.vz - p164.vz) * v177
	if v178 <= 0 then
		return 0
	end
	local v179 = v_u_1.Physics
	local v180 = v179.Gravity
	local v181 = v_u_2.kineticEnergy(p163, v166, v180) + v_u_2.kineticEnergy(p164, v166, v180)
	local v182, v183, v184
	if math.abs(v177) > 0.5 and v178 < v179.PerchSpeed then
		local v185 = v177 < 0 and -1 or 1
		if v177 < 0 then
			v182 = p163
		else
			v182 = p164
		end
		local v186 = v185 * v175
		local v187 = v185 * v176
		local v188 = v186 * v186 + v187 * v187
		local v189 = math.sqrt(v188)
		if v189 < 1e-6 then
			v186 = 1
			v189 = 1
			v187 = 0
		end
		v183 = v186 / v189 * v179.PerchSlideSpeed
		v184 = v187 / v189 * v179.PerchSlideSpeed
		v167 = 0
	else
		v182 = nil
		v183 = 0
		v184 = 0
	end
	local v190 = (1 + v167) * v178 / 2
	p163.vx = p163.vx - v190 * v175
	p163.vy = p163.vy - v190 * v176
	p163.vz = p163.vz - v190 * v177
	p164.vx = p164.vx + v190 * v175
	p164.vy = p164.vy + v190 * v176
	p164.vz = p164.vz + v190 * v177
	local v191 = p163.wx + p164.wx
	local v192 = p163.wy + p164.wy
	local v193 = p163.wz + p164.wz
	local v194 = p163.vx - p164.vx + v166 * (v192 * v177 - v193 * v176)
	local v195 = p163.vy - p164.vy + v166 * (v193 * v175 - v191 * v177)
	local v196 = p163.vz - p164.vz + v166 * (v191 * v176 - v192 * v175)
	local v197 = v194 * v175 + v195 * v176 + v196 * v177
	local v198 = v194 - v197 * v175
	local v199 = v195 - v197 * v176
	local v200 = v196 - v197 * v177
	local v201 = v198 * v198 + v199 * v199 + v200 * v200
	local v202 = math.sqrt(v201)
	if v_u_1.Physics.BallSlipEpsilon < v202 then
		local v203 = v_u_3.ballFriction(v202) * v190
		local v204 = v202 / 7
		local v205 = math.min(v203, v204)
		local v206 = v198 / v202
		local v207 = v199 / v202
		local v208 = v200 / v202
		p163.vx = p163.vx - v205 * v206
		p163.vy = p163.vy - v205 * v207
		p163.vz = p163.vz - v205 * v208
		p164.vx = p164.vx + v205 * v206
		p164.vy = p164.vy + v205 * v207
		p164.vz = p164.vz + v205 * v208
		local v209 = v205 * -2.5 / v166
		local v210 = v209 * (v176 * v208 - v177 * v207)
		local v211 = v209 * (v177 * v206 - v175 * v208)
		local v212 = v209 * (v175 * v207 - v176 * v206)
		p163.wx = p163.wx + v210
		p163.wy = p163.wy + v211
		p163.wz = p163.wz + v212
		p164.wx = p164.wx + v210
		p164.wy = p164.wy + v211
		p164.wz = p164.wz + v212
	end
	if v168 then
		p163.vz = 0
	end
	if v169 then
		p164.vz = 0
	end
	if not v182 then
		return v178
	end
	local v213 = v182.vx
	local v214 = v182.vy
	local v215 = 0
	local v216 = 1
	local v217 = v213 + v183 * 1
	local v218 = v214 + v184 * 1
	v182.vx = v217
	v182.vy = v218
	if v181 < v_u_2.kineticEnergy(p163, v166, v180) + v_u_2.kineticEnergy(p164, v166, v180) then
		for _ = 1, 20 do
			local v219 = (v215 + v216) / 2
			local v220 = v213 + v183 * v219
			local v221 = v214 + v184 * v219
			v182.vx = v220
			v182.vy = v221
			if v181 < v_u_2.kineticEnergy(p163, v166, v180) + v_u_2.kineticEnergy(p164, v166, v180) then
				v216 = v219
			else
				v215 = v219
			end
		end
		local v222 = v213 + v183 * v215
		local v223 = v214 + v184 * v215
		v182.vx = v222
		v182.vy = v223
		local _ = v_u_2.kineticEnergy(p163, v166, v180) + v_u_2.kineticEnergy(p164, v166, v180)
	end
	return 0
end
local function v_u_245(p225, p226, p227) -- name: resolveBalls
	-- upvalues: (copy) v_u_224, (copy) v_u_1, (copy) v_u_3
	if p225.z > 0 or (p225.vz > 0 or (p226.z > 0 or p226.vz > 0)) then
		return v_u_224(p225, p226, p227)
	end
	local v228 = p227 or v_u_1.Physics.BallRestitution
	local v229 = p226.x - p225.x
	local v230 = p226.y - p225.y
	local v231 = v229 * v229 + v230 * v230
	local v232 = math.sqrt(v231)
	if v232 < 1e-12 then
		return 0
	end
	local v233 = v229 / v232
	local v234 = v230 / v232
	local v235 = (p225.vx - p226.vx) * v233 + (p225.vy - p226.vy) * v234
	if v235 <= 0 then
		return 0
	end
	local v236 = (1 + v228) * v235 / 2
	p225.vx = p225.vx - v236 * v233
	p225.vy = p225.vy - v236 * v234
	p226.vx = p226.vx + v236 * v233
	p226.vy = p226.vy + v236 * v234
	local v237, v238 = v_u_3.frictionImpulse(p225.vx - p226.vx, p225.vy - p226.vy, p225.wx + p226.wx, p225.wy + p226.wy, p225.wz + p226.wz, v233, v234, v236)
	if v237 ~= 0 or v238 ~= 0 then
		local v239 = v_u_1.Balls.RadiusInches
		local v240 = -v234 * v237
		local v241 = v233 * v237
		p225.vx = p225.vx + v240
		p225.vy = p225.vy + v241
		p226.vx = p226.vx - v240
		p226.vy = p226.vy - v241
		local v242 = 2.5 * v234 * v238 / v239
		local v243 = -2.5 * v233 * v238 / v239
		local v244 = 2.5 * v237 / v239
		p225.wx = p225.wx + v242
		p225.wy = p225.wy + v243
		p225.wz = p225.wz + v244
		p226.wx = p226.wx + v242
		p226.wy = p226.wy + v243
		p226.wz = p226.wz + v244
	end
	return v235
end
local function v_u_272(p246, p247) -- name: capturePockets
	-- upvalues: (copy) v_u_1, (copy) v_u_7, (copy) v_u_2
	local v248 = v_u_1.Balls.RadiusInches
	local v249 = v_u_1.Physics.Gravity
	local v250 = v_u_1.Table.PocketTipMinDegrees
	local v251 = math.rad(v250)
	for _, v252 in p246.balls do
		if v252.pocketed then
			continue
		end
		local v253 = v252.z > 0 and true or v252.vz > 0
		if v253 and v252.z >= v_u_1.Table.CushionHeightInches then
			continue
		end
		local v254
		if v253 then
			v254 = v_u_7.openingAt(p246.geometry, v252.x, v252.y)
		else
			v254 = v_u_7.pocketAt(p246.geometry, v252.x, v252.y)
		end
		if v254 == nil then
			continue
		end
		v252.pocketed = true
		v252.falling = true
		v252.pocket = v254.id
		v252.wz = 0
		if v253 then
			v252.wx = 0
			v252.wy = 0
			if not p247 then
				continue
			end
			local v255 = {
				["t"] = nil,
				["type"] = "pocket",
				["ball"] = nil,
				["other"] = nil,
				["speed"] = nil,
				["t"] = p246.time,
				["ball"] = v252.id,
				["other"] = v254.id
			}
			local v256 = v252.vx * v252.vx + v252.vy * v252.vy + v252.vz * v252.vz
			v255.speed = math.sqrt(v256)
			table.insert(p247, v255)
		else
			local v257 = v252.x - v254.x
			local v258 = v252.y - v254.y
			local v259 = v257 * v257 + v258 * v258
			local v260 = math.sqrt(v259)
			local v261 = (v254.radius - v260) / v248
			local v262
			if v260 > 1e-6 and v261 < 1 then
				local v263 = v257 / v260
				local v264 = v258 / v260
				local v265 = -v263
				local v266 = -v264
				local v267 = math.asin(v261)
				local v268 = math.max(v267, v251)
				local v269 = v252.vx * v265 + v252.vy * v266
				local v270 = math.max(v269, 0)
				local v271 = v270 / (v248 * math.cos(v268))
				if v248 * v271 * v271 < v249 * math.cos(v268) then
					v252.vx = v252.vx - v270 * v265
					v252.vy = v252.vy - v270 * v266
					v252.tip = {
						["px"] = v254.x + v263 * v254.radius,
						["py"] = v254.y + v264 * v254.radius,
						["nx"] = v265,
						["ny"] = v266,
						["theta"] = v268,
						["omega"] = v271
					}
				else
					v252.wx = 0
					v252.wy = 0
					if not p247 then
						continue
					end
					v262 = {
						["t"] = nil,
						["type"] = "pocket",
						["ball"] = nil,
						["other"] = nil,
						["speed"] = nil,
						["t"] = p246.time,
						["ball"] = v252.id,
						["other"] = v254.id,
						["speed"] = v_u_2.speed(v252)
					}
					table.insert(p247, v262)
				end
			else
				v252.wx = 0
				v252.wy = 0
				if not p247 then
					continue
				end
				v262 = {
					["t"] = nil,
					["type"] = "pocket",
					["ball"] = nil,
					["other"] = nil,
					["speed"] = nil,
					["t"] = p246.time,
					["ball"] = v252.id,
					["other"] = v254.id,
					["speed"] = v_u_2.speed(v252)
				}
				table.insert(p247, v262)
			end
		end
	end
end
function v_u_11.touchesCushion(p273, p274, p275) -- name: touchesCushion
	-- upvalues: (copy) v_u_1
	local v276 = v_u_1.Balls.RadiusInches
	for _, v277 in p273.segments do
		local v278 = (p274 - v277.ax) * v277.nx + (p275 - v277.ay) * v277.ny
		if v278 >= v276 or -v276 >= v278 then
			continue
		end
		local v279 = v277.bx - v277.ax
		local v280 = v277.by - v277.ay
		local v281 = ((p274 - v277.ax) * v279 + (p275 - v277.ay) * v280) / (v279 * v279 + v280 * v280)
		if v281 < 0 or v281 > 1 then
			continue
		end
		return true
	end
	for _, v282 in p273.points do
		local v283 = p274 - v282.x
		local v284 = p275 - v282.y
		local v285 = v276 + v282.radius
		if v283 * v283 + v284 * v284 >= v285 * v285 then
			continue
		end
		return true
	end
	return false
end
function v_u_11.goesOver(p286, p287, p288, p289, p290, p291) -- name: goesOver
	-- upvalues: (copy) v_u_1, (copy) v_u_7
	local v292 = v_u_1.Balls.RadiusInches
	if v_u_7.openingAt(p286, p287, p288) then
		return false
	end
	if not v_u_7.containsCenter(p286, p287, p288, v292) then
		return true
	end
	if p289 < v_u_1.Table.CushionHeightInches then
		return false
	end
	for _, v293 in p286.segments do
		local v294 = (p287 - v293.ax) * v293.nx + (p288 - v293.ay) * v293.ny
		if v294 >= v292 or (-v292 >= v294 or p290 * v293.nx + p291 * v293.ny >= 0) then
			continue
		end
		local v295 = v293.bx - v293.ax
		local v296 = v293.by - v293.ay
		local v297 = ((p287 - v293.ax) * v295 + (p288 - v293.ay) * v296) / (v295 * v295 + v296 * v296)
		if v297 < 0 or v297 > 1 then
			continue
		end
		return true
	end
	for _, v298 in p286.points do
		local v299 = p287 - v298.x
		local v300 = p288 - v298.y
		local v301 = v292 + v298.radius
		if v299 * v299 + v300 * v300 >= v301 * v301 or v299 * p290 + v300 * p291 >= 0 then
			continue
		end
		return true
	end
	return false
end
local function v_u_305(p302, p303) -- name: checkOffTable
	-- upvalues: (copy) v_u_6, (copy) v_u_11, (copy) v_u_77
	for _, v304 in p302.balls do
		if not (v_u_6.isAirborne(v304) and v_u_11.goesOver(p302.geometry, v304.x, v304.y, v304.z, v304.vx, v304.vy)) then
			continue
		end
		v_u_77(v304, p303, p302.time)
	end
end
local function v_u_339(p306, p307, p308, p309, p310, p311) -- name: findEarliestHit
	-- upvalues: (copy) v_u_1, (copy) v_u_6, (copy) v_u_4
	local v312 = v_u_1.Balls.RadiusInches
	local v313 = p306.geometry
	local v314 = p306.balls
	local v315 = v_u_1.Table.CushionHeightInches
	local v316 = p307
	local v317 = nil
	for v318, v319 in v314 do
		if v319.pocketed or p308 and p308[v319] or p310 and p310[v319.id] then
			continue
		end
		local v320
		if p309 then
			v320 = v_u_6.isAirborne(v319)
		else
			v320 = p309
		end
		local v321 = v319.vx ~= 0 and true or (v319.vy ~= 0 and true or v320)
		local v322 = v319.vx * v319.vx + v319.vy * v319.vy
		local v323 = math.sqrt(v322) * v316 + v312
		local v324 = v319.x
		local v325
		if math.abs(v324) + v323 >= v313.halfLength then
			v325 = true
		else
			local v326 = v319.y
			v325 = math.abs(v326) + v323 >= v313.halfWidth
		end
		if v321 and (v325 and v319.z < v315) then
			for _, v327 in v313.segments do
				local v328 = v_u_4.segmentTOI(v319.x, v319.y, v319.vx, v319.vy, v312, v327, p307)
				if not v328 or v328 >= p307 then
					continue
				end
				v317 = {
					["kind"] = "rail",
					["t"] = nil,
					["a"] = nil,
					["nx"] = nil,
					["ny"] = nil,
					["seg"] = nil,
					["t"] = v328,
					["a"] = v319,
					["nx"] = v327.nx,
					["ny"] = v327.ny,
					["seg"] = v327
				}
				p307 = v328
			end
			for _, v329 in v313.points do
				local v330, v331, v332 = v_u_4.pointTOI(v319.x, v319.y, v319.vx, v319.vy, v312, v329.x, v329.y, v329.radius, p307)
				if not v330 or v330 >= p307 then
					continue
				end
				p307 = v330
				v317 = {
					["kind"] = "point",
					["t"] = nil,
					["a"] = nil,
					["nx"] = nil,
					["ny"] = nil,
					["t"] = v330,
					["a"] = v319,
					["nx"] = v331,
					["ny"] = v332
				}
			end
		end
		for v333 = v318 + 1, #v314 do
			local v334 = v314[v333]
			if v334.pocketed or p308 and p308[v334] or p310 and p310[v334.id] then
				continue
			end
			if p311 then
				local v335 = p311[v319.id]
				local v336 = p311[v334.id]
				if v335 and v335[v334.id] or v336 and v336[v319.id] then
					continue
				end
			end
			if not v321 and (v334.vx == 0 and (v334.vy == 0 and not p309)) then
				continue
			end
			local v337
			if p309 then
				v337 = v_u_6.isAirborne(v334)
			else
				v337 = p309
			end
			if not v321 and (v334.vx == 0 and (v334.vy == 0 and not v337)) then
				continue
			end
			local v338
			if v320 or v337 then
				v338 = v_u_4.sphereTOI(v319.x, v319.y, v319.z, v319.vx, v319.vy, v319.vz, v334.x, v334.y, v334.z, v334.vx, v334.vy, v334.vz, v312, p307)
			else
				v338 = v_u_4.circleTOI(v319.x, v319.y, v319.vx, v319.vy, v334.x, v334.y, v334.vx, v334.vy, v312, p307)
			end
			if not v338 or v338 >= p307 then
				continue
			end
			p307 = v338
			v317 = {
				["kind"] = "ball",
				["t"] = nil,
				["a"] = nil,
				["b"] = nil,
				["nx"] = 0,
				["ny"] = 0,
				["t"] = v338,
				["a"] = v319,
				["b"] = v334
			}
		end
	end
	return v317
end
local function v_u_381(p340) -- name: pushOut
	-- upvalues: (copy) v_u_1, (copy) v_u_6
	local v341 = v_u_1.Balls.RadiusInches
	local v342 = v_u_1.Physics.ContactSlop
	local v343 = p340.a
	if p340.kind == "rail" and p340.seg then
		local v344 = p340.seg
		local v345 = (v343.x - v344.ax) * v344.nx + (v343.y - v344.ay) * v344.ny
		if v345 < v341 + v342 then
			v343.x = v343.x + (v341 + v342 - v345) * v344.nx
			v343.y = v343.y + (v341 + v342 - v345) * v344.ny
			return
		end
	elseif p340.kind == "ball" and (p340.b and (v_u_6.isAirborne(v343) or v_u_6.isAirborne(p340.b))) then
		local v346 = p340.b
		local v347 = v346.x - v343.x
		local v348 = v346.y - v343.y
		local v349 = v346.z - v343.z
		local v350 = v347 * v347 + v348 * v348 + v349 * v349
		local v351 = math.sqrt(v350)
		local v352 = 2 * v341 + v342
		if v351 > 1e-12 and v351 < v352 then
			local v353 = v_u_6.isAirborne(v343)
			local v354 = v_u_6.isAirborne(v346)
			local v_u_355 = v347 / v351
			local v_u_356 = v348 / v351
			local v_u_357 = v349 / v351
			local v358 = v353 and v354 and 0.5 or (v353 and 1 or 0)
			local v_u_359 = v352 - v351
			local function v371(p360, p361, p362) -- name: move
				-- upvalues: (copy) v_u_355, (copy) v_u_359, (copy) v_u_356, (copy) v_u_357, (ref) v_u_1
				if p362 > 0 then
					local v363 = p360.z
					p360.x = p360.x + p361 * v_u_355 * v_u_359 * p362
					p360.y = p360.y + p361 * v_u_356 * v_u_359 * p362
					local v364 = p360.z + p361 * v_u_357 * v_u_359 * p362
					p360.z = math.max(0, v364)
					local v365 = p360.z - v363
					if v365 > 0 then
						local v366 = v_u_1.Physics.Gravity
						local v367 = 0.5 * (p360.vx * p360.vx + p360.vy * p360.vy + p360.vz * p360.vz)
						if v367 > 0 then
							local v368 = v367 - v366 * v365
							local v369 = math.max(0, v368) / v367
							local v370 = math.sqrt(v369)
							p360.vx = p360.vx * v370
							p360.vy = p360.vy * v370
							p360.vz = p360.vz * v370
						end
					end
				end
			end
			v371(v343, -1, v358)
			v371(v346, 1, 1 - v358)
			return
		end
	elseif p340.kind == "ball" and p340.b then
		local v372 = p340.b
		local v373 = v372.x - v343.x
		local v374 = v372.y - v343.y
		local v375 = v373 * v373 + v374 * v374
		local v376 = math.sqrt(v375)
		local v377 = 2 * v341 + v342
		if v376 > 1e-12 and v376 < v377 then
			local v378 = (v377 - v376) / 2
			local v379 = v373 / v376
			local v380 = v374 / v376
			v343.x = v343.x - v379 * v378
			v343.y = v343.y - v380 * v378
			v372.x = v372.x + v379 * v378
			v372.y = v372.y + v380 * v378
		end
	end
end
local function v_u_400(p382, p383, p384) -- name: layFlat
	-- upvalues: (copy) v_u_1, (copy) v_u_2
	local v385 = v_u_1.Balls.RadiusInches
	local v386 = v_u_1.Physics.Gravity
	local v387 = p383.x - p382.x
	local v388 = p383.y - p382.y
	local v389 = p383.z - p382.z
	local v390 = v387 * v387 + v388 * v388
	local v391 = math.sqrt(v390)
	local v392 = v391 <= 1e-12 and 1 or v387 / v391
	local v393 = v391 <= 1e-12 and 0 or v388 / v391
	local v394 = 2 * v385 + v_u_1.Physics.ContactSlop
	if v391 < v394 then
		p382.x = p382.x - v392 * (v394 - v391)
		p382.y = p382.y - v393 * (v394 - v391)
	end
	local v395 = 0
	for _, v396 in p384 do
		v395 = v395 + v_u_2.kineticEnergy(v396, v385, v386)
	end
	local v397 = 4 * v385 * v385 - v389 * v389
	local v398 = math.max(v397, 1e-12)
	local v399 = math.sqrt(v398)
	return {
		["flyer"] = p382,
		["group"] = p384,
		["nx"] = v392,
		["ny"] = v393,
		["tilt"] = -v389 / v399,
		["vx"] = p382.vx,
		["vy"] = p382.vy,
		["energy"] = v395
	}
end
local function v_u_415(p401) -- name: liftFlyer
	-- upvalues: (copy) v_u_1, (copy) v_u_2
	local v402 = v_u_1.Balls.RadiusInches
	local v403 = v_u_1.Physics.Gravity
	local v404 = p401.flyer
	local v405 = (p401.vx - v404.vx) * p401.nx + (p401.vy - v404.vy) * p401.ny
	if v405 > 0 then
		v404.vz = v404.vz + p401.tilt * v405
		if v404.z <= 0 and v404.vz < 0 then
			v404.vz = 0
		end
		local v406 = 0
		local v407 = 0
		for _, v408 in p401.group do
			local v409 = v_u_2.kineticEnergy(v408, v402, v403)
			local v410 = 0.5 * v408.vz * v408.vz + v403 * v408.z
			v406 = v406 + (v409 - v410)
			v407 = v407 + v410
		end
		if v406 > 0 and v406 + v407 > p401.energy then
			local v411 = p401.energy - v407
			local v412 = math.max(0, v411) / v406
			local v413 = math.sqrt(v412)
			for _, v414 in p401.group do
				v414.vx = v414.vx * v413
				v414.vy = v414.vy * v413
				v414.wx = v414.wx * v413
				v414.wy = v414.wy * v413
				v414.wz = v414.wz * v413
			end
		end
	end
end
local function v_u_423(p416, p417, p418) -- name: mergeEvents
	local v419 = 1
	local v420 = 1
	while v419 <= #p417 or v420 <= #p418 do
		if #p418 < v420 or v419 <= #p417 and p417[v419].t <= p418[v420].t then
			local v421 = p417[v419]
			table.insert(p416, v421)
			v419 = v419 + 1
		else
			local v422 = p418[v420]
			table.insert(p416, v422)
			v420 = v420 + 1
		end
	end
end
local function v_u_498(p424, p425, p426, p427, p428) -- name: advance
	-- upvalues: (copy) v_u_1, (copy) v_u_339, (copy) v_u_122, (copy) v_u_272, (copy) v_u_305, (copy) v_u_6, (copy) v_u_3, (copy) v_u_400, (copy) v_u_415, (copy) v_u_498, (copy) v_u_423, (copy) v_u_381, (copy) v_u_245, (copy) v_u_129, (copy) v_u_162, (copy) v_u_2
	local v429 = v_u_1.Physics
	local v430 = 0
	local v431 = {}
	local v432 = p424.overrides
	local v433
	if p424.fx and next(p424.fx.ghost or {}) ~= nil then
		v433 = p424.fx.ghost
	else
		v433 = nil
	end
	local v434
	if v432 and (v432.PhaseCue and #v432.PhaseCue > 0) then
		local v435 = {}
		for _, v436 in v432.PhaseCue do
			v435[v436] = true
		end
		v434 = { v435 }
	else
		v434 = nil
	end
	local v437
	if p424.fx then
		v437 = p424.fx.passes
	else
		v437 = nil
	end
	if v437 and next(v437) ~= nil then
		v434 = not v434 and {} or table.clone(v434)
		for v438, v439 in v437 do
			local v440 = not v434[v438] and {} or table.clone(v434[v438])
			for v441 in v439 do
				v440[v441] = true
			end
			v434[v438] = v440
		end
	end
	local v442
	if p424.fx then
		v442 = p424.fx.material
	else
		v442 = nil
	end
	local v443
	if v433 then
		v443 = not p427 and {} or table.clone(p427)
		for _, v444 in p424.balls do
			if not v433[v444.id] then
				continue
			end
			v443[v444] = true
		end
	else
		v443 = p427
	end
	while true do
		if p425 <= 1e-9 or v430 >= v429.MaxEventsPerStep then
			return p425
		end
		v430 = v430 + 1
		local v445 = p425
		local v446 = false
		for _, v447 in p424.balls do
			if v447.pocketed or v447.z <= 0 and v447.vz <= 0 or p427 and p427[v447] then
				continue
			end
			local v448 = v429.AirStepSeconds
			v445 = math.min(p425, v448)
			v446 = true
		end
		local v449 = v_u_339(p424, v445, p427, v446, v433, v434)
		if v449 then
			v445 = v449.t
		end
		local v450, v451
		if v432 and p424.time < (v432.CueUntil or 0) then
			v450 = v432.CueSlidingFriction
			v451 = v432.CueRollingFriction
		else
			v450 = nil
			v451 = nil
		end
		for _, v452 in p424.balls do
			if p427 ~= nil and p427[v452] then
				continue
			end
			local v453 = nil
			local v454 = nil
			if v452.id == 0 then
				v454 = v451
				v453 = v450
			elseif v442 then
				local v455 = v442[v452.id]
				if v455 and p424.time < v455.Until then
					v453 = v455.SlidingFriction
					v454 = v455.RollingFriction
				end
			end
			if v453 or v454 then
				v_u_122(v452, v445, p424.geometry, p426, p424.time + v445, v453, v454)
			else
				v_u_122(v452, v445, p424.geometry, p426, p424.time + v445)
			end
		end
		p424.time = p424.time + v445
		p425 = p425 - v445
		v_u_272(p424, p426)
		if v446 then
			v_u_305(p424, p426)
		end
		if not v449 or (v449.a.pocketed or v449.b and v449.b.pocketed) then
			break
		end
		local v456 = nil
		local v457 = v449.b
		local v458
		if v457 and v_u_6.isAirborne(v449.a) ~= v_u_6.isAirborne(v457) then
			if v_u_6.isAirborne(v449.a) then
				v458 = v449.a
			else
				v458 = v457
			end
		else
			v458 = nil
		end
		if p428 and (v449.kind == "ball" and (v457 and not (v_u_6.isAirborne(v449.a) and v_u_6.isAirborne(v457)))) then
			if v458 == nil then
				if v_u_3.touchesAnother(p424.balls, v449.a, v457, v443) then
					v456 = v_u_3.gather(p424.balls, v449.a, v457, p424.geometry, v443, v458)
				end
			else
				local v459 = v449.a.z - v457.z
				if math.abs(v459) <= v429.SoftContactMaxHopInches then
					if v_u_3.touchesAnother(p424.balls, v449.a, v457, v443) then
						v456 = v_u_3.gather(p424.balls, v449.a, v457, p424.geometry, v443, v458)
					end
				end
			end
		end
		if v456 and v434 then
			for _, v460 in v456 do
				if not v434[v460.id] then
					continue
				end
				v456 = nil
			end
		end
		if v456 and v457 then
			local v461
			if v458 then
				local v462 = v_u_400
				local v463
				if v458 == v449.a then
					v463 = v457
				else
					v463 = v449.a
				end
				v461 = v462(v458, v463, v456)
			else
				v461 = nil
			end
			local v464 = v457.x - v449.a.x
			local v465 = v457.y - v449.a.y
			local v466 = v464 * v464 + v465 * v465
			local v467 = math.sqrt(v466)
			local v468 = v467 <= 1e-12 and 0 or ((v449.a.vx - v457.vx) * v464 + (v449.a.vy - v457.vy) * v465) / v467
			if p426 and v468 > 0 then
				local v469 = {
					["t"] = nil,
					["type"] = "ballHit",
					["ball"] = nil,
					["other"] = nil,
					["speed"] = nil,
					["t"] = p424.time,
					["ball"] = v449.a.id,
					["other"] = v457.id,
					["speed"] = v468
				}
				table.insert(p426, v469)
			end
			local v_u_470 = {}
			local v477 = v_u_3.resolve(v456, v449.a, v457, p424.time, p426 and function(p471, p472, p473, p474)
				-- upvalues: (copy) v_u_470
				local v475 = v_u_470
				local v476 = {
					["t"] = nil,
					["type"] = "ballHit",
					["ball"] = nil,
					["other"] = nil,
					["speed"] = nil,
					["t"] = p473,
					["ball"] = p471.id,
					["other"] = p472.id,
					["speed"] = p474
				}
				table.insert(v475, v476)
			end or nil)
			if v461 then
				v_u_415(v461)
			end
			local v478 = {}
			for _, v479 in v456 do
				v478[v479] = true
			end
			local v480 = p426 and {} or nil
			v_u_498(p424, v477, v480, v478, false)
			if p426 and v480 then
				v_u_423(p426, v_u_470, v480)
			end
			p425 = p425 - v477
		else
			v_u_381(v449)
			local v481 = nil
			local v482
			if v432 == nil then
				v482 = false
			else
				v482 = p424.time < (v432.CueUntil or 0)
			end
			local v483, v484
			if v449.kind == "ball" and v457 then
				local v485
				if v482 and (v449.a.id == 0 or v457.id == 0) then
					v485 = v432.CueBallRestitution
				else
					v485 = nil
				end
				if v485 == nil and v442 then
					local v486 = v442[v449.a.id]
					local v487 = v442[v457.id]
					if v486 and (p424.time < v486.Until and v486.BallRestitution) then
						v485 = v486.BallRestitution
					elseif v487 and (p424.time < v487.Until and v487.BallRestitution) then
						v485 = v487.BallRestitution
					end
				end
				v483 = v_u_245(v449.a, v457, v485)
				v481 = v457.id
				v484 = "ballHit"
			else
				local v488 = -(v449.a.vx * v449.nx + v449.a.vy * v449.ny)
				local v489 = p424.overrides
				local v490
				if v489 and v489.RailRestitution ~= nil then
					v490 = v489.RailRestitution
				else
					v490 = v_u_129(v488)
				end
				local v491
				if v489 and v489.RailFriction ~= nil then
					v491 = v489.RailFriction
				else
					v491 = v429.RailFriction
				end
				if v482 and v449.a.id == 0 then
					if v432.CueRailRestitution ~= nil then
						v490 = v432.CueRailRestitution
					end
					if v432.CueRailFriction ~= nil then
						v491 = v432.CueRailFriction
					end
				elseif v442 then
					local v492 = v442[v449.a.id]
					if v492 and p424.time < v492.Until then
						if v492.RailRestitution ~= nil then
							v490 = v492.RailRestitution
						end
						if v492.RailFriction ~= nil then
							v491 = v492.RailFriction
						end
					end
				end
				v483 = v_u_162(v449.a, v449.nx, v449.ny, v490, v491)
				v484 = "railHit"
			end
			if p426 and v483 > 0 then
				local v493 = v484 == "railHit"
				local v494 = {
					["t"] = p424.time,
					["type"] = v484,
					["ball"] = v449.a.id,
					["other"] = v481,
					["speed"] = v483
				}
				local v495
				if v493 then
					v495 = v449.a.x
				else
					v495 = nil
				end
				v494.x = v495
				local v496
				if v493 then
					v496 = v449.a.y
				else
					v496 = nil
				end
				v494.y = v496
				table.insert(p426, v494)
			end
		end
		if v449.t <= v429.InstantHitSeconds then
			local v497 = (v431[v449.a] or 0) + 1
			v431[v449.a] = v497
			if v429.MaxInstantHits <= v497 then
				v_u_2.stop(v449.a)
				if v457 then
					v_u_2.stop(v457)
				end
			end
		end
		if v429.MaxEventsPerStep > v430 then
			break
		end
		v_u_2.stop(v449.a)
		if not v457 then
			break
		end
		v_u_2.stop(v457)
	end
end
local v_u_529 = {
	["remove"] = function(p499, p500, p501, p502) -- name: remove
		-- upvalues: (copy) v_u_2
		if not p501.pocketed then
			local v503 = p501.x
			local v504 = p501.y
			p501.pocketed = true
			p501.falling = false
			p501.offTable = false
			p501.pocket = nil
			p501.tip = nil
			p501.z = 0
			v_u_2.stop(p501)
			local v505 = {
				["t"] = nil,
				["type"] = "removed",
				["ball"] = nil,
				["speed"] = 0,
				["x"] = nil,
				["y"] = nil,
				["kind"] = nil,
				["t"] = p499.time,
				["ball"] = p501.id,
				["x"] = v503,
				["y"] = v504,
				["kind"] = p502
			}
			table.insert(p500, v505)
		end
	end,
	["teleport"] = function(p506, p507, p508, p509, p510) -- name: teleport
		-- upvalues: (copy) v_u_1, (copy) v_u_381, (copy) v_u_245
		p508.x = p509
		p508.y = p510
		local v511 = v_u_1.Balls.RadiusInches
		for _, v512 in p506.balls do
			if v512 == p508 or v512.pocketed then
				continue
			end
			local v513 = v512.x - p508.x
			local v514 = v512.y - p508.y
			if v513 * v513 + v514 * v514 >= 4 * v511 * v511 then
				continue
			end
			local v515 = v513 * v513 + v514 * v514
			local v516 = math.sqrt(v515)
			v_u_381({
				["kind"] = "ball",
				["t"] = 0,
				["a"] = nil,
				["b"] = nil,
				["nx"] = nil,
				["ny"] = nil,
				["a"] = p508,
				["b"] = v512,
				["nx"] = v516 <= 1e-9 and 1 or v513 / v516,
				["ny"] = v516 <= 1e-9 and 0 or v514 / v516
			})
			local v517 = v_u_245(p508, v512)
			if v517 <= 0 then
				continue
			end
			local v518 = {
				["t"] = nil,
				["type"] = "ballHit",
				["ball"] = nil,
				["other"] = nil,
				["speed"] = nil,
				["t"] = p506.time,
				["ball"] = p508.id,
				["other"] = v512.id,
				["speed"] = v517
			}
			table.insert(p507, v518)
		end
	end,
	["halt"] = function(p519) -- name: halt
		p519.halted = true
	end,
	["emit"] = function(p520, p521, p522, p523, p524, p525, p526, p527) -- name: emit
		local v528 = {
			["t"] = nil,
			["type"] = "ult",
			["ball"] = nil,
			["other"] = nil,
			["speed"] = 0,
			["x"] = nil,
			["y"] = nil,
			["kind"] = nil,
			["value"] = nil,
			["t"] = p520.time,
			["ball"] = p523,
			["other"] = p524,
			["x"] = p525,
			["y"] = p526,
			["kind"] = p522,
			["value"] = p527
		}
		table.insert(p521, v528)
	end
}
v_u_11.Ops = v_u_529
function v_u_11.step(p530, p531, p532) -- name: step
	-- upvalues: (copy) v_u_8, (copy) v_u_498, (copy) v_u_529
	local v533 = p530.overrides
	local v534
	if v533 and v533.Effect then
		v534 = v_u_8[v533.Effect]
	else
		v534 = nil
	end
	if v534 == nil then
		v_u_498(p530, p531, p532, nil, true)
	else
		if p530.fx == nil then
			p530.fx = {}
		end
		if v534.step then
			v534.step(p530, p531)
		end
		if v534.after then
			local v535 = {}
			v_u_498(p530, p531, v535, nil, true)
			v534.after(p530, p531, v535, v_u_529)
			if p532 then
				for _, v536 in v535 do
					table.insert(p532, v536)
				end
				return
			end
		else
			v_u_498(p530, p531, p532, nil, true)
		end
	end
end
function v_u_11.finishShot(p537, p538) -- name: finishShot
	-- upvalues: (copy) v_u_8, (copy) v_u_529
	local v539 = p537.overrides
	local v540
	if v539 and v539.Effect then
		v540 = v_u_8[v539.Effect]
	else
		v540 = nil
	end
	if v540 and v540.finish then
		if p537.fx == nil then
			p537.fx = {}
		end
		v540.finish(p537, p538 or {}, v_u_529)
	end
end
local function v_u_545(p541) -- name: captureFrame
	local v542 = table.create(#p541.balls * 3)
	for v543, v544 in p541.balls do
		v542[v543 * 3 - 2] = v544.x
		v542[v543 * 3 - 1] = v544.y
		v542[v543 * 3] = v544.z
	end
	return {
		["t"] = p541.time,
		["positions"] = v542
	}
end
function v_u_11.checksum(p546) -- name: checksum
	local v547 = 2166136261
	local v548 = v547
	for _, v549 in p546 do
		local v550 = v549.x * 1000 + 0.5
		local v551 = math.floor(v550) % 4294967296
		v547 = bit32.bxor(v548, v551)
		v547 = v547 * 16777619 % 4294967296
		local v552 = v549.y * 1000 + 0.5
		local v553 = math.floor(v552) % 4294967296
		local v554 = v547
		v547 = bit32.bxor(v554, v553)
		v547 = v547 * 16777619 % 4294967296
		local v555 = v549.z * 1000 + 0.5
		local v556 = math.floor(v555) % 4294967296
		local v557 = v547
		v547 = bit32.bxor(v557, v556)
		v547 = v547 * 16777619 % 4294967296
		local v558 = (v549.pocketed and 1 or 0) * 1000 + 0.5
		local v559 = math.floor(v558) % 4294967296
		local v560 = v547
		v547 = bit32.bxor(v560, v559)
		v547 = v547 * 16777619 % 4294967296
		v548 = v547
	end
	return v548
end
function v_u_11.strike(p561, p562) -- name: strike
	-- upvalues: (copy) v_u_11, (copy) v_u_1, (copy) v_u_5
	local v563 = v_u_11.findBall(p561, 0)
	if v563 == nil or v563.pocketed then
		error("Simulation.strike: no cue ball on the table")
	end
	p561.time = 0
	local v564
	if p562.ability then
		v564 = v_u_1.Physics.ShotMaterials[p562.ability]
	else
		v564 = nil
	end
	local v565
	if v564 then
		v565 = table.clone(v564)
	else
		v565 = nil
	end
	p561.overrides = v565
	p561.fx = nil
	p561.halted = nil
	local v566 = p562.power
	p561.power = math.clamp(v566, 0, 1)
	return {
		["t"] = 0,
		["type"] = "cueStrike",
		["ball"] = 0,
		["speed"] = nil,
		["speed"] = v_u_5.strike(v563, p562)
	}
end
function v_u_11.armEffect(p567, p568, p569, p570, p571) -- name: armEffect
	-- upvalues: (copy) v_u_16
	local v572 = not p567.overrides and {} or table.clone(p567.overrides)
	if p571 then
		for v573, v574 in p571 do
			v572[v573] = v_u_16(v574)
		end
	end
	v572.Effect = p568
	v572.Targets = table.clone(p569)
	v572.EightPocket = p570
	v572.ShotPower = p567.power
	p567.overrides = v572
	p567.fx = nil
end
function v_u_11.firstContact(p575) -- name: firstContact
	for _, v576 in p575 do
		if v576.type ~= "ballHit" or v576.ball ~= 0 and v576.other ~= 0 then
			continue
		end
		if v576.ball == 0 then
			return v576.other
		else
			return v576.ball
		end
	end
	return nil
end
function v_u_11.respotCueBall(p577) -- name: respotCueBall
	-- upvalues: (copy) v_u_11, (copy) v_u_2, (copy) v_u_7
	local v578 = v_u_11.findBall(p577, 0)
	if v578 == nil or not v578.pocketed then
		return false
	end
	v578.pocketed = false
	v578.offTable = false
	v578.falling = false
	v578.pocket = nil
	v578.tip = nil
	v578.z = 0
	v_u_2.stop(v578)
	local v579, v580 = v_u_7.headSpot(p577.geometry)
	v578.x = v579
	v578.y = v580
	return true
end
local function v_u_595(p581, p582, p583) -- name: settleInto
	-- upvalues: (copy) v_u_1, (copy) v_u_11, (copy) v_u_2, (copy) v_u_545
	local v584 = v_u_1.Physics
	local v585
	if p581.overrides then
		v585 = table.clone(p581.overrides)
	else
		v585 = nil
	end
	local v586 = v584.MaxShotSeconds / v584.FixedStep
	local v587 = math.floor(v586)
	p581.halted = nil
	local v588 = 0
	local v589 = false
	if not v_u_11.isAtRest(p581) then
		if v587 <= v588 then
			v589 = true
			for _, v590 in p581.balls do
				v_u_2.stop(v590)
				v590.falling = false
				v590.tip = nil
			end
		else
			v_u_11.step(p581, v584.FixedStep, p582)
			if p583 then
				local v591 = v_u_545(p581)
				table.insert(p583, v591)
			end
			v588 = v588 + 1
			if not p581.halted then
				continue
			end
		end
	end
	local v592 = 0
	for _, v593 in p582 do
		if v593.type ~= "ult" or (v593.kind ~= "slow" or not v593.value) then
			continue
		end
		v592 = v592 + v593.value
	end
	if p581.halted and not v589 then
		return {
			["events"] = nil,
			["finalBalls"] = nil,
			["firstContact"] = nil,
			["duration"] = nil,
			["steps"] = nil,
			["capped"] = false,
			["overrides"] = nil,
			["halted"] = true,
			["extraSeconds"] = nil,
			["events"] = p582,
			["finalBalls"] = v_u_2.cloneList(p581.balls),
			["firstContact"] = v_u_11.firstContact(p582),
			["duration"] = p581.time,
			["steps"] = v588,
			["overrides"] = v585,
			["extraSeconds"] = v592
		}
	end
	if not v589 then
		v_u_11.finishShot(p581, p582)
	end
	for _, v594 in p581.balls do
		v594.wz = 0
	end
	p581.overrides = nil
	p581.fx = nil
	p581.halted = nil
	return {
		["events"] = p582,
		["finalBalls"] = v_u_2.cloneList(p581.balls),
		["firstContact"] = v_u_11.firstContact(p582),
		["duration"] = p581.time,
		["steps"] = v588,
		["capped"] = v589,
		["overrides"] = v585,
		["extraSeconds"] = v592
	}
end
function v_u_11.settle(p596, p597) -- name: settle
	-- upvalues: (copy) v_u_595
	return v_u_595(p596, p597 or {}, nil)
end
local function v_u_604(p598, p599, p600) -- name: simulate
	-- upvalues: (copy) v_u_11, (copy) v_u_545, (copy) v_u_595
	local v601 = v_u_11.cloneState(p598)
	local v602 = { v_u_11.strike(v601, p599) }
	if p600 then
		local v603 = v_u_545(v601)
		table.insert(p600, v603)
	end
	return v_u_595(v601, v602, p600)
end
function v_u_11.run(p605, p606) -- name: run
	-- upvalues: (copy) v_u_604
	local v607 = {}
	local v608 = v_u_604(p605, p606, v607)
	return {
		["frames"] = v607,
		["events"] = v608.events,
		["finalBalls"] = v608.finalBalls,
		["firstContact"] = v608.firstContact,
		["duration"] = v608.duration,
		["steps"] = v608.steps,
		["capped"] = v608.capped,
		["overrides"] = v608.overrides
	}
end
function v_u_11.runHeadless(p609, p610) -- name: runHeadless
	-- upvalues: (copy) v_u_11, (copy) v_u_595
	local v611 = v_u_11.cloneState(p609)
	return v_u_595(v611, { v_u_11.strike(v611, p610) }, nil)
end
return v_u_11