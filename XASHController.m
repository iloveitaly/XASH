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

#import <WebKit/WebKit.h>

#import "XASHController.h"
#import "ASHelpXMLParser.h"
#import "ASHelpOutlineDataSource.h"
#import "ASHelpNode.h"
#import "ASBookFilterController.h"

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

+(void) initialize {
	//register default search paths
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	
	[defaults setValue:XASH_FLASH_PATH_8 forKey:XASH_FLASH_PATH_8_KEY];
	[defaults setValue:XASH_FLASH_PATH_7 forKey:XASH_FLASH_PATH_7_KEY];
	[defaults setValue:XASH_FLASH_INDEX_8 forKey:XASH_FLASH_INDEX_8_KEY];
	[defaults setValue:XASH_FLASH_INDEX_7 forKey:XASH_FLASH_INDEX_7_KEY];
	
	NSArray *searchPaths = [NSArray arrayWithObject:[NSHomeDirectory() stringByAppendingString:@"/Library/Application Support/Macromedia/Flash MX 2004/en/Configuration/HelpPanel/Help/"]];
	[defaults setValue:searchPaths forKey:XASH_ADDITIONAL_SEARCH_PATHS];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

//----------------------------
//		Misc Methods
//----------------------------
-(void) configFlashVersion {
	NSFileManager *manager = [NSFileManager defaultManager];
	NSString *f8Path = GET_PREF_KEY(XASH_FLASH_PATH_8_KEY), *f7Path = GET_PREF_KEY(XASH_FLASH_PATH_7_KEY);

	if([manager fileExistsAtPath:f8Path]) {
		_helpPath = f8Path;
		_helpIndex = GET_PREF_KEY(XASH_FLASH_INDEX_8_KEY);
	} else if([manager fileExistsAtPath:f7Path]) {
		_helpPath = f7Path;
		_helpIndex = GET_PREF_KEY(XASH_FLASH_INDEX_7_KEY);
	} else {//no flash help path found
		_helpPath = nil;
		//_helpIndex = nil;
	}
}

//----------------------------
//		Superclass Overides
//----------------------------
- (id) init {
	if (self = [super init]) {		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appDidBecomeActive:)
													 name:@"NSApplicationDidBecomeActiveNotification"
												   object:NSApp];
	}
	return self;
}

-(void) awakeFromNib {
	[self configFlashVersion];
	
	if(_helpPath == nil) {//then no valid help files were found
		NSLog(@"No valid help files found");
		return;
	}

	NSFileManager *manager = [NSFileManager defaultManager];
	NSArray *helpTopics = [manager directoryContentsAtPath:_helpPath], *helpFolders = GET_PREF_KEY(XASH_ADDITIONAL_SEARCH_PATHS);
	BOOL isDir;
	int l = [helpTopics count], l2;
	NSString *tempDir, *currHelpDir, *helpDirIndex;
	
	while(l--) {//look through all the contents of the flash7/8 help folder
		[manager fileExistsAtPath:[_helpPath stringByAppendingString:tempDir = [helpTopics objectAtIndex:l]] isDirectory:&isDir];
		if(isDir) {
			helpDirIndex = [NSString stringWithFormat:@"%@%@%@", _helpPath, tempDir, TOC_PATH];
			if([manager fileExistsAtPath:helpDirIndex]) {//check to make sure the directory exists first
				ADD_XML_FILE(helpDirIndex);
			}
		}
	}
	
	l = [helpFolders count];
	while(l--) {//loop through all the additional search directorys
		if(![manager fileExistsAtPath:currHelpDir = [helpFolders objectAtIndex:l] isDirectory:&isDir] || !isDir) {
			NSLog(@"File/Folder %@ does not exist, or is not a directory.", currHelpDir);
			continue;
		}
		
		helpTopics = [manager directoryContentsAtPath:currHelpDir];
		l2 = [helpTopics count];
		
		while(l2--) {//loop through all the additional folders in the additional directories
			if([manager fileExistsAtPath:tempDir = [currHelpDir stringByAppendingString:[helpTopics objectAtIndex:l2]] isDirectory:&isDir] && isDir) {
				helpDirIndex = [tempDir stringByAppendingString:TOC_PATH];
				if([manager fileExistsAtPath:helpDirIndex]) {
					ADD_XML_FILE(helpDirIndex);
				} else {
					NSLog(@"Table of contents index file %@ not found", helpDirIndex);
				}
			} else {
				NSLog(@"File/Folder %@ does not exist, or is not a directory.", tempDir);
			}
		}
	}
	
	
	
	//get all the help pages in a linear array
	_allHelpPages = [[[[ASHelpOutlineDataSource sharedSource] rootNode] allChildren] retain];

	//add a menu item to the help menu, if a help menu can be found
	NSMenuItem *helpMenu = [[NSApp mainMenu] itemWithTitle:@"Help"];
	if(helpMenu != nil) {
		NSLog(@"Adding help menu item");
		NSMenuItem *XASHItem = [NSMenuItem new];
		[XASHItem setTitle:@"Flash Help..."];
		[XASHItem setKeyEquivalent:@"F"];
		[XASHItem setKeyEquivalentModifierMask:NSCommandKeyMask|NSShiftKeyMask];
		[XASHItem setAction:@selector(showWindow:)];
		[XASHItem setTarget:[XASHController sharedController]];
		[[helpMenu submenu] addItem:XASHItem];
	} else {
		NSLog(@"Help menu item could not be found");
	}
	
	//load the index page, tree data, and filter information
	[[oWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_helpIndex]]];
	[[ASBookFilterController sharedFilter] reloadData];
	[oHelpTree reloadData];
}

-(void) appDidBecomeActive:(NSNotification *)note {
	[oHelpWindow makeKeyAndOrderFront:self];
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
	NSString *currURL;
	if([currURL = [[[[frame provisionalDataSource] request] URL] absoluteString] isEqualToString:@"file://(null)"]) {//check for a null URL
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

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
	[oHelpWindow setTitle:[NSString stringWithFormat:@"%@ : %@", BASE_WIN_TITLE, title]];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
#if DEBUG >= 1
	NSLog(@"%@", error);
#endif
}

//delegate method for the split view, gives a minimum width to the outline view
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset {
	if(offset == 0) {
		return MIN_LEFT_PANEL_W;
	} else {
		return 0; //this never happens so....
	}
}
@end
