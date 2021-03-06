//
//  SearchView.m
//  MAL Library
//
//  Created by 天々座理世 on 2017/03/29.
//  Copyright © 2017 Atelier Shiori. All rights reserved. Licensed under 3-clause BSD License
//

#import "SearchView.h"
#import "MainWindow.h"
#import "MyAnimeList.h"

@interface SearchView ()

@end

@implementation SearchView

- (instancetype)init
{
    return [super initWithNibName:@"SearchView" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [_addtitleitem setEnabled:NO];
    [self view];
    // Set Resizing Mask
    _animesearch.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    _mangasearch.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    // Add Placeholder Subview
    [self.view addSubview:_animesearch];
    AnimeSearchTerm = @"";
    MangaSearchTerm = @"";
}
- (void)loadsearchView:(int)type{
    switch (type){
        case AnimeSearch:
            MangaSearchTerm = _searchtitlefield.stringValue;
            _searchtitlefield.stringValue = AnimeSearchTerm;
            currentsearch = type;
            [self.view replaceSubview:(self.view).subviews[0] with:_animesearch];
            [self setToolbarButtonStatus];
            break;
        case MangaSearch:
            AnimeSearchTerm = _searchtitlefield.stringValue;
            _searchtitlefield.stringValue = MangaSearchTerm;
            currentsearch = type;
            [self.view replaceSubview:(self.view).subviews[0] with:_mangasearch];
            [self setToolbarButtonStatus];
            break;
    }
}

- (IBAction)performsearch:(id)sender {
    if ((_searchtitlefield.stringValue).length > 0){
        [MyAnimeList searchTitle:_searchtitlefield.stringValue withType:currentsearch completion:^(id responseObject){
            [mw populatesearchtb:responseObject type:currentsearch];
        }error:^(NSError *error){
            NSLog(@"Error: %@", error);
        }];
    }
    else{
        [self clearsearchtb];
    }
}

- (IBAction)searchtbdoubleclick:(id)sender {
    if (currentsearch == AnimeSearch){
        if (_searchtb.selectedRow >=0){
            if (_searchtb.selectedRow >-1){
                NSDictionary *d = _searcharraycontroller.selectedObjects[0];
                NSNumber *idnum = d[@"id"];
                [mw loadinfo:idnum type:AnimeSearch];
            }
        }
    }
    else{
        if (_mangasearchtb.selectedRow >=0){
            if (_mangasearchtb.selectedRow >-1){
                NSDictionary *d = _mangasearcharraycontroller.selectedObjects[0];
                NSNumber *idnum = d[@"id"];
                [mw loadinfo:idnum type:MangaSearch];
            }
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self setToolbarButtonStatus];
}
- (void)setToolbarButtonStatus{
    if (currentsearch == AnimeSearch){
        if (_searcharraycontroller.selectedObjects.count > 0){
            [_addtitleitem setEnabled:YES];
        }
        else {
            [_addtitleitem setEnabled:NO];
        }
    }
    else if (currentsearch == MangaSearch){
        if (_mangasearcharraycontroller.selectedObjects.count > 0){
            [_addtitleitem setEnabled:YES];
        }
        else {
            [_addtitleitem setEnabled:NO];
        }
    }
}
- (void)clearsearchtb{
    if (currentsearch == AnimeSearch){
        [[_searcharraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
        [_searchtb reloadData];
        [_searchtb deselectAll:self];
    }
    else{
        [[_mangasearcharraycontroller mutableArrayValueForKey:@"content"] removeAllObjects];
        [_mangasearchtb reloadData];
        [_mangasearchtb deselectAll:self];
    }
}
@end
