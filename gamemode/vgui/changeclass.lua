
// create
local PANEL = {};


/*------------------------------------
	Init
------------------------------------*/
function PANEL:Init( )

	// setup
	self:SetSize( 800, 400 );
	
	// create button
	self.ClassA = vgui.Create( "DImageButton", self );
	self.ClassA:SetImage( "zahmbeez/selectclass/leatherneck" );
	self.ClassA.DoClick = function( button )
	
		RunConsoleCommand( "selectclass", 1 );
		self.Cancel:DoClick();
		
	end
	self.ClassALabel = vgui.Create( "DLabel", self );
	self.ClassALabel:SetText( "Leatherneck" );
	self.ClassALabel:SetFont( "ZahmbeezTarget" );
	self.ClassALabel:SizeToContents();
	
	// create button
	self.ClassB = vgui.Create( "DImageButton", self );
	self.ClassB:SetImage( "zahmbeez/selectclass/macgyver" );
	self.ClassB.DoClick = function( button )
	
		RunConsoleCommand( "selectclass", 2 );
		self.Cancel:DoClick();
		
	end
	self.ClassBLabel = vgui.Create( "DLabel", self );
	self.ClassBLabel:SetText( "MacGyver" );
	self.ClassBLabel:SetFont( "ZahmbeezTarget" );
	self.ClassBLabel:SizeToContents();
	
	// create button
	self.ClassC = vgui.Create( "DImageButton", self );
	self.ClassC:SetImage( "zahmbeez/selectclass/errandboy" );
/*	self.ClassC.DoClick = function( button )
	
		RunConsoleCommand( "selectclass", 3 );
		self.Cancel:DoClick();
		
	end*/
	self.ClassCLabel = vgui.Create( "DLabel", self );
	self.ClassCLabel:SetText( "Errand Boy" );
	self.ClassCLabel:SetFont( "ZahmbeezTarget" );
	self.ClassCLabel:SizeToContents();
	
	// create cancel
	self.Cancel = vgui.Create( "DImageButton", self );
	self.Cancel:SetImage( "zahmbeez/selectclass/cancel" );
	self.Cancel.DoClick = function( button ) self:Remove(); end
	
	// create title
	self.Title = vgui.Create( "DImage", self );
	self.Title:SetMaterial( "zahmbeez/selectclass/title" );

end


/*------------------------------------
	PerformLayout
------------------------------------*/
function PANEL:PerformLayout( )

	self.Title:SetPos( 40, 25 );
	self.Title:SetSize( 320, 40 );
	
	self.ClassA:SetPos( 70, 50 );
	self.ClassA:SetSize( 200, 300 );
	self.ClassALabel:SetPos( 80, 310 );
	
	self.ClassB:SetPos( 300, 50 );
	self.ClassB:SetSize( 200, 300 );
	self.ClassBLabel:SetPos( 310, 310 );
	
	self.ClassC:SetPos( 530, 50 );
	self.ClassC:SetSize( 200, 300 );
	self.ClassCLabel:SetPos( 540, 310 );
	
	self.Cancel:SetPos( 695, 315 );
	self.Cancel:SetSize( 60, 60 );

end


/*------------------------------------
	Paint
------------------------------------*/
function PANEL:Paint( )

	// settings
	local padding = 10;
	local color = Color( 0, 0, 0, 200 );

	// draw
	draw.RoundedBox(
		8,
		self.ClassA.X - padding,
		self.ClassA.Y - padding,
		self.ClassA:GetWide() + ( padding * 2 ),
		self.ClassA:GetTall() + ( padding * 2 ),
		color
	);

	// draw
	draw.RoundedBox(
		8,
		self.ClassB.X - padding,
		self.ClassB.Y - padding,
		self.ClassB:GetWide() + ( padding * 2 ),
		self.ClassB:GetTall() + ( padding * 2 ),
		color
	);
	
	// draw
	draw.RoundedBox(
		8,
		self.ClassC.X - padding,
		self.ClassC.Y - padding,
		self.ClassC:GetWide() + ( padding * 2 ),
		self.ClassC:GetTall() + ( padding * 2 ),
		color
	);

	return true;

end

// register
vgui.Register( "ZahmbeezChangeClass", PANEL, "DPanel" );
