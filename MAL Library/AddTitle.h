//
//  AddTitle.h
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindow;
@interface AddTitle : NSViewController{
    IBOutlet MainWindow * mw;
    int selectededitid;
    bool selectedaired;
    bool selectedaircompleted;
    NSDictionary * selecteditem;
}

@property (strong) IBOutlet NSPopover *addpopover;
-(void)showAddPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge;
@end
