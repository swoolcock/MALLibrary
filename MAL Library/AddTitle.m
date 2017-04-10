//
//  AddTitle.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "AddTitle.h"
#import "MainWindow.h"
#import <AFNetworking/AFNetworking.h>
#import "Keychain.h"

@interface AddTitle ()
@property (strong) IBOutlet NSView *popoveraddtitleexistsview;
// Anime
@property (strong) IBOutlet NSView *addtitleview;
@property (strong) IBOutlet NSTextField *addepifield;
@property (strong) IBOutlet NSNumberFormatter *addnumformat;
@property (strong) IBOutlet NSTextField *addtotalepisodes;
@property (strong) IBOutlet NSPopUpButton *addscorefiled;
@property (strong) IBOutlet NSPopUpButton *addstatusfield;
@property (strong) IBOutlet NSButton *addfield;
@property (strong) IBOutlet NSStepper *addepstepper;

// Manga
@property (strong) IBOutlet NSView *addmangaview;
@property (strong) IBOutlet NSTextField *addchapfield;
@property (strong) IBOutlet NSNumberFormatter *addchapnumformat;
@property (strong) IBOutlet NSTextField *addvolfield;
@property (strong) IBOutlet NSNumberFormatter *addvolnumformat;
@property (strong) IBOutlet NSTextField *addtotalchap;
@property (strong) IBOutlet NSTextField *addtotalvol;
@property (strong) IBOutlet NSPopUpButton *addmangascorefiled;
@property (strong) IBOutlet NSPopUpButton *addmangastatusfield;
@property (strong) IBOutlet NSButton *addmangabtn;
@property (strong) IBOutlet NSStepper *addchapstepper;
@property (strong) IBOutlet NSStepper *addvolstepper;

@end

@implementation AddTitle

- (instancetype)init
{
    return [super initWithNibName:@"AddTitle" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view addSubview:[NSView new]];
}

- (void)showAddPopover:(NSDictionary *)d showRelativeToRec:(NSRect)rect ofView:(NSView *)view preferredEdge:(NSRectEdge)rectedge type:(int)type{
    [self view];
    NSNumber *idnum = d[@"id"];
    if (type == 0){
        if (![mw checkiftitleisonlist:idnum.intValue type:0]){
            [self.view replaceSubview:(self.view.subviews)[0] with:_addtitleview];
            selecteditem = d;
            if (((NSNumber *)d[@"episodes"]).intValue > 0){
                _addnumformat.maximum = d[@"episodes"];
            }
            else {
                [_addnumformat setMaximum:nil];
            }
            NSString *airingstatus = d[@"status"];
            if ([airingstatus isEqualToString:@"finished airing"] || d[@"end_date"]){
                selectedaircompleted = true;
            }
            else{
                selectedaircompleted = false;
            }
            if ([airingstatus isEqualToString:@"finished airing"]||[airingstatus isEqualToString:@"currently airing"] || d[@"start_date"]){
                selectedaired = true;
            }
            else{
                selectedaired = false;
            }
            _addepifield.intValue = 0;
            _addepstepper.intValue = 0;
            _addtotalepisodes.intValue = ((NSNumber *)d[@"episodes"]).intValue;
            [_addstatusfield selectItemWithTitle:@"watching"];
            [_addscorefiled selectItemAtIndex:0];
            selectededitid = ((NSNumber *)d[@"id"]).intValue;
        }
        else {
            [self.view replaceSubview:(self.view.subviews)[0] with:_popoveraddtitleexistsview];
        }
        if (view.window == nil) {
            return;
        }
        [_addpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        selectedtype = type;
    }
    else {
        if (![mw checkiftitleisonlist:idnum.intValue type:1]){
            [self.view replaceSubview:(self.view.subviews)[0] with:_addmangaview];
            selecteditem = d;
            if (((NSNumber *)d[@"chapters"]).intValue > 0){
                _addchapnumformat.maximum = d[@"chapters"];
            }
            else {
                [_addchapnumformat setMaximum:nil];
            }
            if (((NSNumber *)d[@"volumes"]).intValue > 0){
                _addvolnumformat.maximum = d[@"chapters"];
            }
            else {
                [_addvolnumformat setMaximum:nil];
            }
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            [manager GET:[NSString stringWithFormat:@"%@/2.1/manga/%i",[[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"],idnum.intValue] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                selecteditem = responseObject;
                NSString *publishtatus = selecteditem[@"status"];
                if ([publishtatus isEqualToString:@"finished"]){
                    selectedfinished = true;
                }
                else{
                    selectedfinished = false;
                }
                if ([publishtatus isEqualToString:@"finished"]||[publishtatus isEqualToString:@"publishing"]){
                    selectedpublished = true;
                }
                else{
                    selectedpublished = false;
                }

            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            _addchapfield.intValue = 0;
            _addchapstepper.intValue = 0;
            _addtotalchap.intValue = ((NSNumber *)d[@"chapters"]).intValue;
            _addvolfield.intValue = 0;
            _addvolstepper.intValue = 0;
            _addtotalvol.intValue = ((NSNumber *)d[@"volumes"]).intValue;
            [_addmangastatusfield selectItemWithTitle:@"reading"];
            [_addmangascorefiled  selectItemAtIndex:0];
            selectededitid = ((NSNumber *)d[@"id"]).intValue;
        }
        else {
            [self.view replaceSubview:(self.view.subviews)[0] with:_popoveraddtitleexistsview];
        }
        [_addpopover showRelativeToRect:rect ofView:view preferredEdge:rectedge];
        selectedtype = type;
    }
    
}

- (IBAction)PerformAddTitle:(id)sender {
    [self addtitletolist];
}

- (void)addtitletolist{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",[Keychain getBase64]] forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if (selectedtype == 0){
        [_addfield setEnabled:false];
        if(![_addstatusfield.title isEqual:@"completed"] && _addepifield.intValue == _addtotalepisodes.intValue && selectedaircompleted){
            [_addstatusfield selectItemWithTitle:@"completed"];
        }
        if(!selectedaired && (![_addstatusfield.title isEqual:@"plan to watch"] ||_addepifield.intValue > 0)){
            // Invalid input, mark it as such
            [_addfield setEnabled:true];
            _addpopover.behavior = NSPopoverBehaviorTransient;
            return;
        }
        if (_addepifield.intValue == _addtotalepisodes.intValue && _addtotalepisodes.intValue != 0 && selectedaircompleted && selectedaired){
            [_addstatusfield selectItemWithTitle:@"completed"];
            _addepifield.stringValue = _addtotalepisodes.stringValue;
        }
        if([_addstatusfield.title isEqual:@"completed"] && _addtotalepisodes.intValue != 0 && _addepifield.intValue != _addtotalepisodes.intValue && selectedaircompleted){
            _addepifield.stringValue = _addtotalepisodes.stringValue;
        }
        _addpopover.behavior = NSPopoverBehaviorApplicationDefined;
        [manager POST:[NSString stringWithFormat:@"%@/2.1/animelist/anime", [[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"]] parameters:@{@"anime_id":@(selectededitid), @"status":_addstatusfield.title, @"score":@(_addscorefiled.selectedTag), @"episodes":@(_addepifield.intValue)} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [mw loadlist:@(true) type:0];
            [mw loadlist:@(true) type:2];
            [_addfield setEnabled:true];
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_addpopover close];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@",error);
            NSData *errordata = error.userInfo [@"com.alamofire.serialization.response.error.data" ];
            NSLog(@"%@",[[NSString alloc] initWithData:errordata encoding:NSUTF8StringEncoding]);
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_addfield setEnabled:true];
        }];
    }
    else {
        [_addmangabtn setEnabled:false];
        if(![_addstatusfield.title isEqual:@"completed"] && _addchapfield.intValue == _addtotalchap.intValue && _addvolfield.intValue == _addtotalvol.intValue && selectedfinished){
            [_addstatusfield selectItemWithTitle:@"completed"];
        }
        if(!selectedpublished && (![_addstatusfield.title isEqual:@"plan to read"] ||_addchapfield.intValue > 0 || _addvolfield.intValue > 0)){
            // Invalid input, mark it as such
            [_addmangabtn setEnabled:true];
            _addpopover.behavior = NSPopoverBehaviorTransient;
            return;
        }
        if (((_addchapfield.intValue == _addtotalchap.intValue && _addchapfield.intValue != 0) || (_addvolfield.intValue == _addtotalvol.intValue && _addtotalvol.intValue != 0)) && selectedfinished && selectedpublished){
            [_addmangastatusfield selectItemWithTitle:@"completed"];
            _addchapfield.stringValue = _addtotalchap.stringValue;
            _addvolfield.stringValue = _addtotalvol.stringValue;
        }
        if([_addstatusfield.title isEqual:@"completed"] && ((_addchapfield.intValue != _addtotalchap.intValue && _addchapfield.intValue != 0)|| (_addvolfield.intValue != _addtotalvol.intValue && _addtotalvol.intValue != 0)) && selectedfinished){
            _addchapfield.stringValue = _addtotalchap.stringValue;
            _addvolfield.stringValue = _addtotalvol.stringValue;
        }
        _addpopover.behavior = NSPopoverBehaviorApplicationDefined;
        [manager POST:[NSString stringWithFormat:@"%@/2.1/mangalist/manga", [[NSUserDefaults standardUserDefaults] valueForKey:@"malapiurl"]] parameters:@{@"manga_id":@(selectededitid), @"status":_addmangastatusfield.title, @"score":@(_addmangascorefiled.selectedTag), @"chapters":@(_addchapfield.intValue), @"volumes":@(_addvolfield.intValue)} progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            [mw loadlist:@(true) type:1];
            [mw loadlist:@(true) type:2];
            [_addmangabtn setEnabled:true];
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_addpopover close];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@",error);
            NSData *errordata = error.userInfo [@"com.alamofire.serialization.response.error.data" ];
            NSLog(@"%@",[[NSString alloc] initWithData:errordata encoding:NSUTF8StringEncoding]);
            _addpopover.behavior = NSPopoverBehaviorTransient;
            [_addmangabtn setEnabled:true];
        }];
    }
}
- (IBAction)segmentstepclick:(id)sender {
    int segment = 0;
    int totalsegment = 0;
    NSStepper * stepper = (NSStepper *)sender;
    if (selectedtype == 0){
        if ([_addepifield.stringValue length] > 0) {
            segment = [_addepifield.stringValue intValue];
        }
        totalsegment = [_addtotalepisodes.stringValue intValue];
        segment = stepper.intValue;
        if ((segment <= totalsegment || totalsegment == 0) && segment >= 0){
            _addepifield.stringValue = [NSString stringWithFormat:@"%i",segment];
        }
    }
    else {
        NSString * segmenttype;
        if ([stepper.identifier isEqualToString:@"chapterstepper"]) {
            segmenttype = @"chapters";
            if ([_addchapfield.stringValue length] > 0) {
                segment = [_addchapfield.stringValue intValue];
            }
            totalsegment = [_addtotalchap.stringValue intValue];
        }
        else {
            // Volumes
            segmenttype = @"volumes";
            if ([_addvolfield.stringValue length] > 0) {
                segment = [_addvolfield.stringValue intValue];
            }
            totalsegment = [_addtotalvol.stringValue intValue];
        }
        
        segment = stepper.intValue;
        if ((segment <= totalsegment || totalsegment == 0) && segment >= 0){
            if ([segmenttype isEqualToString:@"chapters"]){
                _addchapfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
            else {
                _addvolfield.stringValue = [NSString stringWithFormat:@"%i",segment];
            }
        }
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if ([[aNotification name] isEqualToString:@"NSControlTextDidChangeNotification"]) {
        
        if ( [aNotification object] == _addepifield ) {
            _addepstepper.intValue = _addepifield.intValue;
        }
        else if ( [aNotification object] == _addchapfield ) {
            _addchapstepper.intValue = _addchapfield.intValue;
        }
        else if ( [aNotification object] == _addvolfield ) {
            _addvolstepper.intValue = _addvolfield.intValue;
        }
    }
}

@end
