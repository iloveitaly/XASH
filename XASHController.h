/*
 Application: XASH, Xcode-like Flash Help File Viewer
 Copyright (C) 2005 Michael Bianco <software@mabwebdesign.com>
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import <Cocoa/Cocoa.h>

#define DEBUG 0

#define XASH_FLASH_PATH_8 @"/Users/Shared/Library/Application Support/Macromedia/Flash 8/en/Configuration/HelpPanel/Help/"
#define XASH_FLASH_PATH_7 @"/Users/Shared/Library/Application Support/Macromedia/Flash MX 2004/en/Configuration/HelpPanel/Help/"

#define XASH_FLASH_INDEX_8 @"file:///Users/Shared/Library/Application%20Support/Macromedia/Flash%208/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"
#define XASH_FLASH_INDEX_7 @"file:///Users/Shared/Library/Application%20Support/Macromedia/Flash%20MX2004/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"

#define TOC_PATH @"/help_toc.xml"

#define MIN_LEFT_PANEL_W 200.0

#define BASE_WIN_TITLE @"Flash Help"

#define ADD_XML_FILE(x) \
[[[ASHelpXMLParser alloc] initWithASXMLFile:x withRootNode:[[ASHelpOutlineDataSource sharedSource] rootNode]] autorelease]


//pref keys, move to the preference controller when we actually have a preference controller
#define GET_PREF_KEY(k) [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:k]
#define XASH_FLASH_PATH_8_KEY @"f8Path"
#define XASH_FLASH_PATH_7_KEY @"f7Path"
#define XASH_FLASH_INDEX_7_KEY @"f7Index"
#define XASH_FLASH_INDEX_8_KEY @"f8Index"
#define XASH_ADDITIONAL_SEARCH_PATHS @"additionalSearchPaths"

@class WebView, WebFrame;

@interface XASHController : NSObject {
	NSString *_helpPath, *_helpIndex;
	
	IBOutlet NSOutlineView *oHelpTree;
	IBOutlet WebView *oWebView;
	IBOutlet NSWindow *oHelpWindow;
	
	NSArray *_allHelpPages;
}

//----------------------------
//		Class Methods
//----------------------------
+(XASHController *) sharedController;

//----------------------------
//		Misc Methods
//----------------------------
-(void) configFlashVersion;

//----------------------------
//		Action Methods
//----------------------------
-(IBAction) setHelpPage:(id)sender;

//----------------------------
//		Delegate Methods
//----------------------------

//delegate methods for the webview
//make sure the instance of the class is wired to be the webframeload delegate of the webview
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame;

//delegate methods for the splitview
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset;
//- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize;
@end
