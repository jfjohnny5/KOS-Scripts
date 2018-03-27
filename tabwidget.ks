// tabwidget.ks
// John Fallara

// NOT COMPLETE OR EVEN CLOSE TO FUNCTIONAL

local gui is GUI(500).
local tabwidget is AddTabWidget(gui).

local page is AddTab(tabwidget,"One").
page:ADDLABEL("This is page 1").
page:ADDLABEL("Put stuff here").

local page is AddTab(tabwidget,"Two").
page:ADDLABEL("This is page 2").
page:ADDLABEL("Put more stuff here").

local page is AddTab(tabwidget,"Three").
page:ADDLABEL("This is page 3").
page:ADDLABEL("Put even more stuff here").

declare function AddTabWidget {
	//any box is allowed
	declare parameter box.
	
	//See if styles for the TabWidget components (tabs and panels) have already been defined elsewhere. If not, define one.
	
	if not box:GUI:SKIN:HAS("TabWidgetTab") {
	
		// The style for tabs is like a button, but it should smoothly connect to the panel below it, especially if it is the current selected tab.
		local style is box:GUI:SKIN:ADD("TabWidgetTab", box:GUI:SKIN:BUTTON).
	}
	

}