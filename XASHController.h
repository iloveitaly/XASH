/*
 Application: XASH, Flash Help for Xcode
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

#define DEBUG 1

#define XASH_FLASH_PATH_8 @"/Users/Shared/Library/Application Support/Macromedia/Flash 8/en/Configuration/HelpPanel/Help/"
#define XASH_FLASH_PATH_7 @"/Users/Shared/Library/Application Support/Macromedia/Flash MX2004/en/Configuration/HelpPanel/Help/"

#define XASH_FLASH_INDEX_8 @"file:///Users/Shared/Library/Application%20Support/Macromedia/Flash%208/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"
#define XASH_FLASH_INDEX_7 @"file:///Users/Shared/Library/Application%20Support/Macromedia/Flash%20MX2004/en/Configuration/HelpPanel/Help/Welcome/Welcome_help.html"

@class WebView, WebFrame;

@interface XASHController : NSWindowController {
	BOOL _flash8;
	NSString *_helpPath, *_helpIndex;
	
	IBOutlet NSOutlineView *oHelpTree;
	IBOutlet WebView *oWebView;
	
	NSArray *_allHelpPages;
}

//----------------------------
//		Class Methods
//----------------------------
+(XASHController *) sharedController;
+(void) install;

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
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;
@end
