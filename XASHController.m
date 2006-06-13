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

#import <WebKit/WebKit.h>

#import "XASHController.h"
#import "ASHelpXMLParser.h"
#import "ASHelpOutlineDataSource.h"
#import "ASHelpNode.h"

static XASHController *_sharedController;

@implementation XASHController
//----------------------------
//		Class Methods
//----------------------------
+(XASHController *) sharedController {
	if(!_sharedController) {
		_sharedController = [XASHController new];
	}
	
	return _sharedController;
}

+(void) install {
	NSLog(@"[XASH] Installing Plug-in");
	[self sharedController];
}

//----------------------------
//		Misc Methods
//----------------------------
-(void) configFlashVersion {
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if([manager fileExistsAtPath:XASH_FLASH_PATH_8]) {
		_helpPath = XASH_FLASH_PATH_8;
		_helpIndex = XASH_FLASH_INDEX_8;
		_flash8 = YES;
	} else if([manager fileExistsAtPath:XASH_FLASH_PATH_7]) {
		_helpPath = XASH_FLASH_PATH_7;
		_helpIndex = XASH_FLASH_INDEX_7;
		_flash8 = NO;		
	} else {//no flash help path found
		_helpPath = nil;
	}
}

//----------------------------
//		Superclass Overides
//----------------------------
- (id) init {
	if (self = [self initWithWindowNibName:@"XASHPanel"]) {
		NSLog(@"[XASH] Window Controller Inited");
	}
	return self;
}

-(void) windowDidLoad {
	[super windowDidLoad];
	
	[self configFlashVersion];
	if(_helpPath == nil) {//then no valid help files were found
		return;
	}

	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *helpTopics = [manager directoryContentsAtPath:_helpPath];
	BOOL isDir;
	int l = [helpTopics count];
	NSString *tempDir;
	
	while(l--) {
		[manager fileExistsAtPath:tempDir = [helpTopics objectAtIndex:l] isDirectory:&isDir];
		if(isDir) {
			NSString *helpDirIndex = [NSString stringWithFormat:@"%@%@%@", _helpPath, tempDir, @"/help_toc.xml"];
			if([manager fileExistsAtPath:helpDirIndex]) {//check to make sure the directory exists first
				[[[ASHelpXMLParser alloc] initWithASXMLFile:helpDirIndex
						 withRootNode:[[ASHelpOutlineDataSource sharedSource] rootNode]] autorelease];
			}
		}
	}
	
	//get all the help pages
	_allHelpPages = [[[[ASHelpOutlineDataSource sharedSource] rootNode] allChildren] retain];

	//add a menu item to the help menu, if a help menu can be found
	NSMenuItem *helpMenu = [[NSApp mainMenu] itemWithTitle:@"Help"];
	if(helpMenu != nil) {
		NSLog(@"[XASH]: Adding help menu item");
		NSMenuItem *XASHItem = [NSMenuItem new];
		[XASHItem setTitle:@"Flash Help..."];
		[XASHItem setKeyEquivalent:@"F"];
		[XASHItem setKeyEquivalentModifierMask:NSCommandKeyMask|NSShiftKeyMask];
		[XASHItem setAction:@selector(showWindow:)];
		[XASHItem setTarget:[XASHController sharedController]];
		[[helpMenu submenu] addItem:XASHItem];
	} else {
		NSLog(@"[XASH]: Help menu item could not be found");
	}
	
	//load the index page and the tree data
	[[oWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_helpIndex]]];
	[oHelpTree reloadData];
}

//----------------------------
//		Action Methods
//----------------------------
-(IBAction) setHelpPage:(id)sender {
	[[oWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[(ASHelpNode*)[oHelpTree itemAtRow:[oHelpTree selectedRow]] helpPage]]]];
}

//----------------------------
//		Delegate Methods
//----------------------------
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
	//check for a null URL
	NSString *currURL;
	if([currURL = [[[[frame provisionalDataSource] request] URL] absoluteString] isEqualToString:@"file://(null)"]) {
#if DEBUG >= 1
		NSLog(@"A file://(null) URL was loaded into a web-view");
#endif
		return;
	}
	
	//get rid of an anchor if theres one in the string
	NSRange tempRange;
	if((tempRange = [currURL rangeOfString:@"#"]).location != NSNotFound && tempRange.location > [currURL rangeOfString:@"/" options:NSBackwardsSearch].location) {
		currURL = [currURL substringToIndex:tempRange.location];
	}
	
	//check to make sure the object is found
	int index = [_allHelpPages indexOfObject:currURL];
	if(index == NSNotFound) {
#if DEBUG >= 1
		NSLog(@"%@, not found in help page array", currURL);
#endif
		return;
	}
	
	ASHelpNode *targetNode, *tempNode;
	tempNode = targetNode = [_allHelpPages objectAtIndex:index];
	
	if(!targetNode) {
#if DEBUG >= 1
		NSLog(@"No model object found for: %@", [[[[frame provisionalDataSource] request] URL] absoluteString]);
#endif
		return; //check to make sure we found the model object
	}

	while(tempNode = [tempNode parent]) {
		[oHelpTree expandItem:tempNode];
	}
	
	[oHelpTree selectRow:[oHelpTree rowForItem:targetNode] byExtendingSelection:NO];
}
@end
