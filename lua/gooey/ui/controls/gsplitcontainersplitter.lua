local PANEL = {}function PANEL:Init ()	self:SetOrientation (Gooey.Orientation.Vertical)		self.DragController = Gooey.DragController (self)endfunction PANEL:Paint (w, h)endfunction PANEL:SetOrientation (orientation)	if self.Orientation == orientation then return end		self.Orientation = orientation	if self.Orientation == Gooey.Orientation.Vertical then		self:SetCursor ("sizewe")	else		self:SetCursor ("sizens")	endendGooey.Register ("GSplitContainerSplitter", PANEL, "GPanel")