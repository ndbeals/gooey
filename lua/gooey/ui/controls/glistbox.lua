local PANEL = {}

--[[
	Events:
		SelectionChanged (item)
			Fired when the selected item has changed.
		SelectionCleared ()
			Fired when the selection has been cleared.
]]

function PANEL:Init ()
	self.SelectionController = Gooey.SelectionController (self)

	self.pnlCanvas.OnMouseReleased = function (self, mouseCode)
		self:GetParent ():OnMouseReleased (mouseCode)
	end
	
	self.ItemsByID = {}
	self.Sorted = {}
	self.Comparator = nil

	self.Menu = nil
	
	self.LastRebuildTime = 0
	
	self.SelectionController:AddEventListener ("SelectionChanged",
		function (_, item)
			self:DispatchEvent ("SelectionChanged", item)
		end
	)
	
	self.SelectionController:AddEventListener ("SelectionCleared",
		function (_, item)
			self:DispatchEvent ("SelectionCleared", item)
		end
	)
end

function PANEL:AddItem (text, id)
    local item = vgui.Create ("GListBoxItem", self)
	
	-- inline expansion of SetMother and SetID
    item.ListBox = self
	item.m_pMother = self
	item.ID = id
    item:SetText (text)
	if id then
		self.ItemsByID [id] = item
	end

    -- inline expansion of DPanelList.AddItem (self, item)
	item:SetVisible (true)
	item:SetParent (self.pnlCanvas)
	self.Items [#self.Items + 1] = item
	
	self.Sorted [#self.Sorted + 1] = item
	self.LastRebuildTime = 0
	
	self:InvalidateLayout ()
	
    return item
end

function PANEL:Clear ()
	self.Sorted = {}

	DListBox.Clear (self)
	
	self:ClearSelection ()
end

function PANEL:ClearSelection ()
	self.SelectionController:ClearSelection ()
end

function PANEL.DefaultComparator (a, b)
	return a:GetText () < b:GetText ()
end

function PANEL:GetContentBounds ()
	return 1, 1, self:GetWide () - 1, self:GetTall () - 1
end

function PANEL:GetFirstItem ()
	return self:GetItems () [next (self:GetItems ())]
end

function PANEL:GetItemByID (id)
	local item = self.ItemsByID [id]
	if item and not item:IsValid () then
		self.ItemsByID [id] = nil
		item = nil
	end
	return nil
end

function PANEL:GetItemEnumerator ()
	local next, tbl, key = pairs (self:GetItems ())
	return function ()
		key = next (tbl, key)
		return tbl [key]
	end
end

function PANEL:GetSelectedItems ()
	return self.SelectionController:GetSelectedItems ()
end

function PANEL:GetSelectedItem ()
	return self.SelectionController:GetSelectedItem ()
end

function PANEL:GetSelectionEnumerator ()
	return self.SelectionController:GetSelectionEnumerator ()
end

function PANEL:GetSelectionMode ()
	return self.SelectionController:GetSelectionMode ()
end

function PANEL:HasFocus ()
	if debug.getregistry ().Panel.HasFocus (self) then
		return true
	end
	return self.VBar:HasFocus () or self.VBar.btnUp:HasFocus () or self.VBar.btnDown:HasFocus () or self.VBar.btnGrip:HasFocus ()
end

function PANEL:IsHovered ()
	if self.Hovered then
		return true
	end
	if not self:IsVisible () then
		return false
	end
	local mx, my = gui.MouseX (), gui.MouseY ()
	mx, my = self:ScreenToLocal (mx, my)
	if mx >= 0 and my >= 0 and mx <= self:GetWide () and my <= self:GetTall () then
		return true
	end
	return false
end

function PANEL:ItemFromPoint (x, y)
	x, y = self:LocalToScreen (x, y)
	for _, item in pairs (self:GetItems ()) do
		local px, py = item:GetPos ()
		px, py = item:GetParent ():LocalToScreen (px, py)
		local w, h = item:GetSize ()
		if px <= x and x < px + w and
			py <= y and y < py + h then
			return item
		end
	end
	return nil
end

function PANEL:PaintOver ()
	self.SelectionController:PaintOver (self)
end

function PANEL:Rebuild ()
	if CurTime () - self.LastRebuildTime == 0 then
		return
	end
	local offset = 0
	
	local padding = self.Padding
	local spacing = self.Spacing
	
	local canvasWidth = self.pnlCanvas:GetWide ()
	local y = padding
	local h = 0
	for _, panel in ipairs (self.Sorted) do
		h = panel:GetTall ()
		if panel:IsVisible () then
			panel:SetPos (padding, y)
			panel:SetWide (canvasWidth - padding * 2)
			
			y = y + h + spacing
		end
	end
	if h ~= 0 then
		offset = y + h + spacing
	end
	
	self.pnlCanvas:SetTall (offset + padding * 2 - spacing)
	
	self.LastRebuildTime = CurTime ()
end

function PANEL:RemoveID (id)
	local item = self:GetItemByID (id)
	item:SetID (nil)
	self:RemoveItem (item)
end

function PANEL:RemoveItem (item)
	for k, v in pairs (self.Sorted) do
		if v == item then
			table.remove (self.Sorted, k)
			break
		end
	end
	
	if self.SelectionController:IsSelected (item) then
		self.SelectionController:RemoveFromSelection (item)
	end

	DPanelList.RemoveItem (self, item)
end

function PANEL:SetComparator (comparator)
	self.Comparator = comparator
end

function PANEL:SetItemID (item, id)
	if self.ItemsByID [item:GetID ()] and self.ItemsByID [item:GetID ()] == item then
		self.ItemsByID [item:GetID ()] = nil
	end
	if self.ItemsByID [id] == item then
		return
	end
	if id ~= nil then
		self.ItemsByID [id] = item
	end
	item:SetID (id)
end

function PANEL:SetSelectionMode (selectionMode)
	self.SelectionController:SetSelectionMode (selectionMode)
end

function PANEL:Sort (comparator)
	comparator = comparator or self.Comparator or self.DefaultComparator
	table.sort (self.Sorted,
		function (a, b)
			if a == nil then return false end
			if b == nil then return true end
			return comparator (a, b)
		end
	)
	
	self:InvalidateLayout ()
end

-- Event handlers
function PANEL:DoClick (item)
	self:DispatchEvent ("Click", item)
end

function PANEL:DoRightClick (item)
	self:DispatchEvent ("RightClick", item)
end

function PANEL:OnCursorMoved (x, y)
	self:DispatchEvent ("MouseMove", 0, x, y)
end

function PANEL:OnMousePressed (mouseCode)
	self:DispatchEvent ("MouseDown", mouseCode, self:CursorPos ())
end

function PANEL:OnMouseReleased (mouseCode)
	self:DispatchEvent ("MouseUp", mouseCode, self:CursorPos ())
	if mouseCode == MOUSE_LEFT then
		self:DoClick (self:ItemFromPoint (self:CursorPos ()))
	elseif mouseCode == MOUSE_RIGHT then
		self:DoRightClick (self:ItemFromPoint (self:CursorPos ()))
		if self:GetSelectionMode () == Gooey.SelectionMode.Multiple then
			if self.Menu then self.Menu:Open (self:GetSelectedItems ()) end
		else
			if self.Menu then self.Menu:Open (self:GetSelectedItem ()) end
		end
	end
end

Gooey.Register ("GListBox", PANEL, "DListBox")