-- run in Garry's Mod (clientside)
-- hold shift to make brush bigger

local grid = Dota_grid or {}
Dota_grid = grid
local grid_map = Dota_grid_map or {}
Dota_grid_map = grid_map

local brush_w, brush_h = 26, 44
local dota_w, dota_h = 60, 50

local menu = vgui.Create("DFrame")
menu:SetSize(ScrW(), ScrH())
menu:Center()
menu:MakePopup()

local copy = menu:Add("DButton")
copy:SetText("Copy")
copy:SizeToContents()
copy:SetWide(copy:GetWide() + 8)
copy:SetTall(18)
copy.y = 3
copy.x = ScrW() - 31 * 4 - 4 - 8
copy.DoClick = function()
	local json = {}
	for _, hero in pairs(grid) do
		json[#json + 1] = util.TableToJSON(hero, true)
	end

	SetClipboardText(table.concat(json, ",\n"))
end

local clear = menu:Add("DButton")
clear:SetText("Clear")
clear:SizeToContents()
clear:SetWide(clear:GetWide() + 8)
clear:SetTall(18)
clear.y = 3
clear.x = copy.x - clear:GetWide()
clear.DoClick = function()
	grid = {}
	grid_map = {}
end

local paint_app = menu:Add("EditablePanel")
paint_app:Dock(FILL)
paint_app.OnMouseReleased = function(me)
	local scale = input.IsKeyDown(KEY_LSHIFT) and 2 or 1

	local x, y = me.cursor.x, me.cursor.y

	grid_map[x] = grid_map[x] or {}
	if grid_map[x][y] then
		grid[grid_map[x][y].index] = nil
		grid_map[x][y] = nil
	else
		grid_map[x][y] = {
			w = brush_w * scale,
			h = brush_h * scale,
			index = table.insert(grid, {
				category_name = "",
				x_position = x,
				y_position = y,
				width = dota_w * scale,
				height = dota_h * scale,
				hero_ids = {14}
			})
		}
	end
end
paint_app.Paint = function(me, w, h)
	for x = 0, math.floor(w / brush_w) * brush_w, brush_w do
		for y = 0, math.floor(h / brush_h) * brush_h, brush_h do
			local hero = (grid_map[x] or {})[y]
			if hero then
				surface.SetDrawColor(0, 200, 0, 60)
				surface.DrawRect(x, y, hero.w, hero.h)
			else
				surface.SetDrawColor(0, 0, 0, 50)
				surface.DrawOutlinedRect(x, y, brush_w, brush_h, 1)
			end
		end
	end

	if me:IsHovered() == false then return end

	local cw, ch = brush_w, brush_h

	if input.IsKeyDown(KEY_LSHIFT) then
		cw, ch = brush_w * 2, brush_h * 2
	end

	local x, y = me:LocalCursorPos()
	x, y = math.floor(x / brush_w) * brush_w, math.floor(y / brush_h) * brush_h

	me.cursor = Vector(x, y)

	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(x, y, cw, ch)
end

--[=[
for x = 5, ScrW() - 5 - w, w do
	for y = 24 + 5, ScrH() - 5 - h, h do
		local btn = menu:Add("EditablePanel")
		btn:SetCursor("hand")
		btn:SetSize(w, h)
		btn:SetPos(x, y)
		btn.check = (grid_map[x] or {})[y] ~= nil
		btn.Paint = function(me, w, h)
			if me.check then
				surface.SetDrawColor(0, 200, 0, 60)
			else
				surface.SetDrawColor(0, 0, 0, 35)
			end

			surface.DrawRect(0, 0, w, h)
		end
		btn.OnMouseReleased = function(me)
			me.check = not me.check
			grid_map[x] = grid_map[x] or {}
			if me.check then
				grid_map[x][y] = table.insert(grid, {
					category_name = "",
					x_position = x,
					y_position = y,
					width = dota_w,
					height = dota_h,
					hero_ids = {14}
				})
			else
				grid[grid_map[x][y]] = nil
				grid_map[x][y] = nil
			end
		end
	end
end
]=]--
