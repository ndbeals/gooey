local PANEL = {}

function PANEL:Init ()
	self.Populated = false
	self.ExpandOnPopulate = false
	
	self.ShouldSuppressLayout = false
	self:SetIcon ("gui/g_silkicons/folder")
end

function PANEL:AddNode (name)
	self:CreateChildNodes()
	
	local node = vgui.Create ("GTreeViewNode", self)
	node:SetText (name)
	node:SetParentNode (self)
	node:SetRoot (self:GetRoot ())
	
	self.ChildNodes:AddItem (node)
	self:InvalidateLayout ()
	
	if self.ExpandOnPopulate then
		self.ExpandOnPopulate = false
		self:SetExpanded (true)
	end
	
	self:LayoutRecursive ()
	
	return node
end

function PANEL:FindChild (text)
	if not self.ChildNodes then
		return nil
	end
	for _, Item in pairs (self.ChildNodes:GetItems ()) do
		if Item:GetText () == text then
			return Item
		end
	end
	return nil
end

function PANEL:GetChildCount ()
	return self.ChildNodes and #self.ChildNodes:GetItems () or 0
end

function PANEL:GetIcon ()
	return self.Icon and self.Icon.ImageName or nil
end

function PANEL:GetText ()
	return self.Label:GetValue ()
end

function PANEL:IsExpandable ()
	return self:HasChildren () or self:GetForceShowExpander ()
end

function PANEL:LayoutRecursive ()
	if not self.ShouldSuppressLayout then
		if self.ChildNodes then
			self.ChildNodes:InvalidateLayout (true)
		end
		self:InvalidateLayout (true)
		self:GetParentNode ():LayoutRecursive ()
	end
end

function PANEL:MarkUnpopulated ()
	self.Populated = false
end

function PANEL:Populate ()
	self.Populated = true
	if self:GetRoot ():GetPopulator () then
		self:GetRoot ():GetPopulator () (self)
	end
end

function PANEL:Remove ()
	if self.Label:GetSelected () then
		self:GetRoot ():SetSelectedItem (nil)
	end
	self:GetParentNode ():RemoveNode (self)
	_R.Panel.Remove (self)
end

function PANEL:RemoveNode (node)
	if not self.ChildNodes then
		return
	end
	self.ChildNodes:RemoveItem (node)
	if #self.ChildNodes:GetItems () == 0 then
		self:SetExpandable (false)
	end
	
	self:LayoutRecursive ()
end

function PANEL:Select ()
	self:GetRoot ():SetSelectedItem (self)
	self:SetSelected (true)
end

function PANEL:SetExpandable (expandable)
	self:SetForceShowExpander (expandable)
	self.Expander:SetVisible (self:HasChildren () or expandable)
end

function PANEL:SetExpanded (expanded, suppressAnimation)
	if expanded and
		not self.Populated and
		self:IsExpandable () then
		self:SetExpandOnPopulate (true)
		self:Populate ()
	end
	DTree_Node.SetExpanded (self, expanded, suppressAnimation)
end

function PANEL:SetExpandOnPopulate (expand)
	self.ExpandOnPopulate = expand
end

function PANEL:SetIcon (icon)
	Gooey.AddResource ("materials/" .. icon .. ".vmt")
	self.Icon:SetImage (icon)
end

function PANEL:SortChildren (sorter)
	if not self.ChildNodes then
		return
	end
	table.sort (self.ChildNodes:GetItems (), sorter or function (a, b)
		return a:GetText ():lower () < b:GetText ():lower ()
	end)
	self.ChildNodes:InvalidateLayout ()
end

function PANEL:SuppressLayout (suppress)
	self.ShouldSuppressLayout = suppress
end

-- Events
function PANEL:DoRightClick ()
	self:GetRoot ():SetSelectedItem (self)
end

vgui.Register ("GTreeViewNode", PANEL, "DTree_Node") 