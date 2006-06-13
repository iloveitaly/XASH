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

#import "ASBookFilterController.h"
#import "ASHelpOutlineDataSource.h"
#import "ASHelpNode.h"

static ASBookFilterController *_sharedFilter;

@implementation ASBookFilterController

+(ASBookFilterController *) sharedFilter {
	extern ASBookFilterController *_sharedFilter;
	return _sharedFilter;
}

- (id) init {
	if (self = [super init]) {
		extern ASBookFilterController *_sharedFilter;
		_sharedFilter = self;
	}
	
	return self;
}


-(void) reloadData {
	NSMutableArray *books = [[[[ASHelpOutlineDataSource sharedSource] rootNode] children] mutableCopy];
	[books insertObject:[ASHelpNode nodeWithName:@"All Books"
									 andHelpPage:nil] atIndex:0];
	[self setFilterArray:books];
}

-(IBAction) setFilteredBook:(id)sender {
	[self setFilterIndex:[sender indexOfSelectedItem]];
}

//----------------------------
//		Getters & Setters
//----------------------------
-(NSMutableArray *) filterArray {
	return _filterArray;
}

-(void) setFilterArray:(NSMutableArray *) a {
	[a retain];
	[_filterArray release];
	_filterArray = a;
}

-(void) setFilterIndex:(int) index {
	_filterIndex = index;
}

-(int) filterIndex {
	return _filterIndex;	
}

@end
