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

#import "ASHelpOutlineDataSource.h"
#import "ASBookFilterController.h"

#define DATA_SOURCE_CHECK_NIL \
if(item == nil) { \
	item = _rootNode; \
	if(_lastIndex != 0) {/* then we have to filter some books */ \
		item = [[_rootNode children] objectAtIndex:_lastIndex - 1 /* -1 for the 'all books' filtering menu item */]; \
	} \
}

static ASHelpOutlineDataSource *_sharedSource;

@implementation ASHelpOutlineDataSource
//----------------------------
//		Class Methods
//----------------------------
+(ASHelpOutlineDataSource *) sharedSource {
	extern ASHelpOutlineDataSource *_sharedSource;
	return _sharedSource;
}

//----------------------------
//		Superclass Overides
//----------------------------
- (id) init {
	if (self = [super init]) {
		extern ASHelpOutlineDataSource *_sharedSource;
		_sharedSource = self; //only one instance of this ob, so set the shared ob to itself
		
		_rootNode = [ASHelpNode new];
	}
	return self;
}

-(void) awakeFromNib {
	//register observers to objects that are stored in a nib after the nib is loaded
	[[ASBookFilterController sharedFilter] addObserver:self
											forKeyPath:@"filterIndex"
											   options:NSKeyValueObservingOptionOld
											   context:nil];
}

//----------------------------
//		KVO Methods
//----------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	int tempIndex = [[ASBookFilterController sharedFilter] filterIndex];
	if(tempIndex == _lastIndex) return;
	
	_lastIndex = tempIndex;
	[oHelpTree reloadData];
}

//----------------------------
//		Getter & Setter
//----------------------------
-(ASHelpNode *) rootNode {
	return _rootNode;
}

//----------------------------
//		Data Source Methods
//----------------------------

//if item  == nil then we are starting at the root, this goes for all datasource methods

-(id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	DATA_SOURCE_CHECK_NIL;
	
	return [[item children] objectAtIndex:index];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	DATA_SOURCE_CHECK_NIL;	
	
	return [[item children] count] != 0;
}

-(int) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	DATA_SOURCE_CHECK_NIL;
	
	return [[(ASHelpNode*)item children] count]; 
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	return [item name];
}
@end