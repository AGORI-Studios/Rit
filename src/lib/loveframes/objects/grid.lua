--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- grid object
local newobject = loveframes.NewObject("grid", "loveframes_object_grid", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()
	self.type = "grid"
	self.width = 100
	self.height = 100
	self.prevwidth = 100
	self.prevheight = 100
	self.rows = 0
	self.columns = 0
	self.cellwidth = 25
	self.cellheight = 25
	self.cellpadding = 5
	self.itemautosize = false
	self.children = {}
	self.OnSizeChanged = nil
      self.rowspans = {}
	self.colspans = {}

	self:SetDrawFunc()
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	self:CheckHover()
	
	local parent = self.parent
	local children = self.children
	local base = loveframes.base
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx - (parent.offsetx or 0)
		self.y = self.parent.y + self.staticy - (parent.offsety or 0)
	end
	
	local prevwidth = self.prevwidth
	local prevheight = self.prevheight

	self:CalculateSize()	

	if self.width ~= prevwidth or self.height ~= prevheight then
		local onsizechanged = self.OnSizeChanged
		self.prevwidth = self.width
		self.prevheight = self.height
		self:_update_children_position()
		if onsizechanged then
			onsizechanged(self)
		end
	end
	
	for k, v in ipairs(children) do
		v:update(dt)
	end

	local update = self.Update
	if update then update(self, dt) end

end

--[[---------------------------------------------------------
	- func: CalculateSize()
	- desc: calculate the object size
--]]---------------------------------------------------------
function newobject:CalculateSize()
	self.width = (self.columns * self.cellwidth) + (self.columns * (self.cellpadding * 2))
	self.height = (self.rows * self.cellheight) + (self.rows * (self.cellpadding * 2))
end

function newobject:_update_children_position()
	for k, v in ipairs(self.children) do
		local rs, cs = self:GetCellSpanSize(v.gridrow, v.gridcolumn)
		local csw = cs * self.cellwidth + (cs * self.cellpadding * 2)
		local csh = rs * self.cellheight + (rs * self.cellpadding * 2)

		local cw = self.cellwidth + (self.cellpadding * 2)
		local ch = self.cellheight + (self.cellpadding * 2)

		local x
		local y = ((ch * v.gridrow) - ch) + (csh/2 - v.height/2)

		if
		v.align == 'center' then
			x = (cw * (v.gridcolumn - 1)) + (csw/2 - v.width/2)
		elseif
		v.align == 'right' then
			x = (cw * (v.gridcolumn - 1)) + (csw - v.width) - self.cellpadding
		elseif
		v.align == 'left' then
			x = self.cellpadding + (cw * (v.gridcolumn - 1))
		end

		v.staticx = x
		v.staticy = y
	end
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local children = self.children
	local hover = self.hover
	
	if hover and button == 1 then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
	end
	
	for k, v in ipairs(children) do
		v:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible  = self.visible
	local children = self.children
	
	if not visible then
		return
	end
	
	for k, v in ipairs(children) do
		v:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: RowSpanAt(row, col, size)
	- desc: expands the size of the row at position
--]]---------------------------------------------------------
function newobject:RowSpanAt(row, col, size)

	self.colspans[col] = self.colspans[col] or {}
	local colsize = self.colspans[col][row]
	local s = colsize or 1

	for i = col, col + s - 1 do
		for j = row, row + size - 1 do
			self.rowspans[i] = self.rowspans[i] or {}
			self.colspans[i] = self.colspans[i] or {}

			self.rowspans[i][j] = -1
			self.colspans[i][j] = -1
		end
	end

	self.rowspans[col][row] = size
	self.colspans[col][row] = colsize
	return self

end

--[[---------------------------------------------------------
	- func: ColSpanAt(row, col, size)
	- desc: expands the size of the column at position
--]]---------------------------------------------------------
function newobject:ColSpanAt(row, col, size)

	self.rowspans[col] = self.rowspans[col] or {}
	local rowsize = self.rowspans[col][row]
	local s = rowsize or 1

	for i = col, col + size - 1 do
		for j = row, row + s - 1 do
			self.rowspans[i] = self.rowspans[i] or {}
			self.colspans[i] = self.colspans[i] or {}

			self.rowspans[i][j] = -1
			self.colspans[i][j] = -1
		end
	end

	self.rowspans[col][row] = rowsize
	self.colspans[col][row] = size
	return self

end

--[[---------------------------------------------------------
	- func: GetCellSpanSize(row, col, size)
	- desc: get span size of cell
--]]---------------------------------------------------------
function newobject:GetCellSpanSize(row, col)

	self.rowspans[col] = self.rowspans[col] or {}
	local rs = self.rowspans[col][row] or 1
	self.colspans[col] = self.colspans[col] or {}
	local cs = self.colspans[col][row] or 1
	return rs, cs

end

--[[---------------------------------------------------------
	- func: AddItem(object, row, column)
	- desc: adds and item to the object
--]]---------------------------------------------------------
function newobject:AddItem(object, row, col, align)

	local itemautosize = self.itemautosize
	local children = self.children

	object:Remove()

	table.insert(children, object)
	object.parent = self
	object.gridrow = row
	object.gridcolumn = col
	object.align = align or 'center'

	if itemautosize then
		if object.type == 'text' or object.type == 'checkbox'  then
			return self
		end
		local rs, cs = self:GetCellSpanSize(row, col)
		local cw = cs * self.cellwidth + (self.cellpadding * 2)
		local ch = rs * self.cellheight + (self.cellpadding * 2)
		object.width = cw - (self.cellpadding * 2)
		object.height = ch - (self.cellpadding * 2)

		if object.CalculateSize then object:CalculateSize() end
		if object.RedoLayout then object:RedoLayout() end
	end

	return self

end

--[[---------------------------------------------------------
	- func: GetItem(row, column)
	- desc: gets an item from the object at the specified
			row and column
--]]---------------------------------------------------------
function newobject:GetItem(row, column)

	local children = self.children
	
	for k, v in ipairs(children) do
		if v.gridrow == row and v.gridcolumn == column then
			return v
		end
	end
	
	return false
	
end

--[[---------------------------------------------------------
	- func: SetItemAutoSize(bool)
	- desc: sets whether or not the object should auto-size
			its items
--]]---------------------------------------------------------
function newobject:SetItemAutoSize(bool)

	self.itemautosize = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetItemAutoSize()
	- desc: gets whether or not the object should auto-size
			its items
--]]---------------------------------------------------------
function newobject:GetItemAutoSize()

	return self.itemautosize
	
end

--[[---------------------------------------------------------
	- func: SetRows(rows)
	- desc: sets the number of rows the object should have
--]]---------------------------------------------------------
function newobject:SetRows(rows)

	self.rows = rows
	return self
	
end

--[[---------------------------------------------------------
	- func: SetRows(rows)
	- desc: gets the number of rows the object has
--]]---------------------------------------------------------
function newobject:GetRows()

	return self.rows
	
end

--[[---------------------------------------------------------
	- func: SetColumns(columns)
	- desc: sets the number of columns the object should
			have
--]]---------------------------------------------------------
function newobject:SetColumns(columns)

	self.columns = columns
	return self
	
end

--[[---------------------------------------------------------
	- func: GetColumns()
	- desc: gets the number of columns the object has
--]]---------------------------------------------------------
function newobject:GetColumns()

	return self.columns
	
end

--[[---------------------------------------------------------
	- func: SetCellWidth(width)
	- desc: sets the width of the object's cells
--]]---------------------------------------------------------
function newobject:SetCellWidth(width)

	self.cellwidth = width
	return self
	
end

--[[---------------------------------------------------------
	- func: GetCellWidth()
	- desc: gets the width of the object's cells
--]]---------------------------------------------------------
function newobject:GetCellWidth()

	return self.cellwidth

end

--[[---------------------------------------------------------
	- func: SetCellHeight(height)
	- desc: sets the height of the object's cells
--]]---------------------------------------------------------
function newobject:SetCellHeight(height)

	self.cellheight = height
	return self
	
end

--[[---------------------------------------------------------
	- func: GetCellHeight()
	- desc: gets the height of the object's cells
--]]---------------------------------------------------------
function newobject:GetCellHeight()

	return self.cellheight
	
end

--[[---------------------------------------------------------
	- func: SetCellSize(width, height)
	- desc: sets the size of the object's cells
--]]---------------------------------------------------------
function newobject:SetCellSize(width, height)

	self.cellwidth = width
	self.cellheight = height
	return self
	
end

--[[---------------------------------------------------------
	- func: GetCellSize()
	- desc: gets the size of the object's cells
--]]---------------------------------------------------------
function newobject:GetCellSize()

	return self.cellwidth, self.cellheight
	
end

--[[---------------------------------------------------------
	- func: SetCellPadding(padding)
	- desc: sets the padding of the object's cells
--]]---------------------------------------------------------
function newobject:SetCellPadding(padding)

	self.cellpadding = padding
	return self
	
end

--[[---------------------------------------------------------
	- func: GetCellPadding
	- desc: gets the padding of the object's cells
--]]---------------------------------------------------------
function newobject:GetCellPadding()

	return self.cellpadding
	
end

---------- module end ----------
end
