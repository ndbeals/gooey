local PANEL = {}function PANEL:Init ()	self.ParentMenu = nil	self.Icon = nil		Gooey.EventProvider (self)endfunction PANEL:DoClick ()	self:DispatchEvent ("Click")endfunction PANEL:GetIcon ()	return self.Icon and self.Icon.ImageName or nilendfunction PANEL:GetParentMenu ()	return self.ParentMenuendfunction PANEL:Paint ()	derma.SkinHook ("Paint", "MenuOption", self)	if self:GetDisabled () then		surface.SetTextColor (128, 128, 128, 255)		surface.SetTextPos (20, 3)		surface.DrawText (self:GetText ())		return true	end	return falseendfunction PANEL:SetIcon (icon)	if not icon then		self.Icon:Remove ()		self.Icon = nil		return	end	if not self.Icon then		self.Icon = vgui.Create ("GImage", self)		self.Icon:SetPos (2, 1)		self.Icon:SetSize (16, 16)	end		Gooey.AddResource ("materials/" .. icon .. ".vmt")	self.Icon:SetImage (icon)		return selfendfunction PANEL:SetParentMenu (menu)	self.ParentMenu = menuendfunction PANEL:OnMouseReleased (mouseCode)	if self:GetDisabled () then		return false	end	DButton.OnMouseReleased (self, mouseCode)	if self.m_MenuClicking then		self.m_MenuClicking = false		self.ParentMenu:CloseMenus ()	endendvgui.Register ("GMenuItem", PANEL, "DMenuOption")