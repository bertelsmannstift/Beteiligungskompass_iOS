//
//  RCAddNodeContainerViewController.h
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import <UIKit/UIKit.h>

@interface RCAddNodeContainerViewController : UIViewController {
    BOOL created;
}
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *sectionButtons;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIViewController *currentViewController;
@property (nonatomic, strong) IBOutlet Article *article;

- (void)switchToViewController:(UIViewController *)newViewController;
- (void)closeAndCancel;

+ (UIViewController *)instantiateViewControllerForArticleType:(NSString *)type;
+ (UIViewController *)instantiateViewControllerForDataSet:(Article *)article;

@end


@interface UIViewController (AddNodeController)
@property(readonly, nonatomic) RCAddNodeContainerViewController *addController;
@end

@protocol AddStep <NSObject>

- (void)applyData;

@end