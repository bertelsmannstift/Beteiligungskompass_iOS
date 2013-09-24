//
//  RCActionSheetController.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import <Foundation/Foundation.h>

@interface RCActionSheetItem : NSObject {
    NSString *_text;
    void (^_onPressed)();
}
@property (nonatomic, retain) NSString *text;
@property (nonatomic, copy) void (^onPressed)();

@end

@interface RCActionSheetController : NSObject<UIActionSheetDelegate> {
    NSMutableArray *_items;
    UIActionSheet *_sheet;
}
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) IBOutlet UIActionSheet *sheet;
@property (nonatomic, copy) void (^onCancel)();

- (void)addItemWithTitle:(NSString *)title callback:(void (^)())callback;
- (void)prepareSheet;


@end
