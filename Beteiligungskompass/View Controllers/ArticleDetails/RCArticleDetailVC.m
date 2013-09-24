//
//  RCArticleDetailVC.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//
//

#import "RCArticleDetailVC.h"
#import "RCArticleCriteriaList.h"
#import "RCArticleSideVC.h"
#import "RCImageVC.h"

#import "RCSharingController.h"
#import <QuartzCore/QuartzCore.h>

static BOOL notificationShown=NO;

@interface RCArticleDetailVC ()

@end

@implementation RCArticleDetailVC {
    UIPopoverController *notificationPopover;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.firstColumn.scrollView.scrollsToTop=NO;
    self.secondColumn.scrollView.scrollsToTop=NO;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateContent];
    if(UI_USER_INTERFACE_IDIOM()!=UIUserInterfaceIdiomPad)
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            self.toolBar.frame=CGRectMake(0, -1, [UIScreen mainScreen].bounds.size.height, 33);
            self.container.frame=CGRectMake(0, 32, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.height-32);
        }
        else
        {
            self.toolBar.frame=CGRectMake(0, -1, 320, 45);
            self.container.frame=CGRectMake(0, 44, 320, self.view.frame.size.height-44);
        }
    }
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated: animated];
    [super viewWillAppear:animated];
    if(self.articles==nil)
    {
        self.leftButton.hidden=YES;
        self.rightButton.hidden=YES;
    }
    
    UINavigationController *container=(UINavigationController*)self.slideViewController.sideViewController;
    RCArticleSideVC *sideCtrl=[container.viewControllers objectAtIndex:0];
    [sideCtrl setArticles:self.articles forType:self.article.type];
    //now: render the template
    hideOnNextDisappear=NO;
    [self updateContent];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        if(!self.tabBarController.tabBar.hidden)
        {
            [self.tabBarController.tabBar setHidden:YES];
            for(UIView *view in self.tabBarController.view.subviews)
            {
                if(view!=self.tabBarController.tabBar)
                {
                    CGRect frame=view.frame;
                    frame.size.height+=self.tabBarController.tabBar.frame.size.height;
                    view.frame=frame;
                }
            }
        }
    }
    else
    {
        if(!notificationShown)
        {
            notificationShown=YES;
            UIViewController *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"buttonnotification"];
            UIPopoverController *ctrl=[[UIPopoverController alloc] initWithContentViewController:controller];
            [ctrl presentPopoverFromBarButtonItem:self.toolBar.items[0] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            notificationPopover=ctrl;
        }
    }
    [super viewDidAppear:animated];
    
    // This hack needed somewhere else?!
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(hideOnNextDisappear)
    {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
        {
            self.refBackup.tabBar.hidden=NO;
            for(UIView *view in self.refBackup.view.subviews)
            {
                if(view!=self.refBackup.tabBar)
                {
                    CGRect frame=view.frame;
                    frame.size.height-=self.refBackup.tabBar.frame.size.height;
                    view.frame=frame;
                }
            }
        }
    }
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(notificationPopover.isPopoverVisible)
    {
        [notificationPopover dismissPopoverAnimated:NO];
    }
    UINavigationController *container=(UINavigationController*)self.slideViewController.sideViewController;
    RCArticleSideVC *sideCtrl=[container.viewControllers objectAtIndex:0];
    if(hideOnNextDisappear)
    {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
        [sideCtrl setArticles:nil forType:nil];
        self.refBackup=self.tabBarController;
        
    }
    [super viewWillDisappear:animated];
}

- (void)onBack:(id)sender
{
    hideOnNextDisappear=YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)slide:(id)sender
{
    if(self.slideViewController.isSideViewControllerVisible)
        [self.slideViewController slideOut];
    else
        [self.slideViewController slideIn];
}

- (IBAction)onLeft:(id)sender
{
    int idx=[self.articles indexOfObject:self.article];
    idx--;
    if(idx<0)return;
    self.article=[self.articles objectAtIndex:idx];
    [self updateContent];
    
    [self viewWillAppear: YES];
}

- (IBAction)onRight:(id)sender
{
    int idx=[self.articles indexOfObject:self.article];
    idx++;
    if(idx>=self.articles.count)
        return;
    self.article=[self.articles objectAtIndex:idx];
    [self updateContent];
    
    [self viewWillAppear: YES];
}

- (IBAction)onShare:(id)sender
{
    [[RCSharingController instance] shareURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@article/show/%@", baseurl, self.article.id_from_import]] from:sender];
}

- (NSArray *)fieldsForFirstColumn
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"projectfacts",@"type",@"plain",@"output", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"images",@"type",@"plain",@"output", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"short_description",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Kurzbeschreibung",@"label.short_description"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"videos",@"type",@"full",@"output",RCLocalizedString(@"Videos", @"label.videos"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"background",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Hintergrund", @"label.background"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"aim",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Ziel", @"label.aim"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"process",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Prozess", @"label.process"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"results",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Ergebnisse", @"label.results"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"more_information",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Weitere Informationen", @"label.more_information"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"external_links",@"type",@"full",@"output",RCLocalizedString(@"Externe Links", @"label.external_links"),@"title", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"contact",@"key",@"string",@"type",@"full",@"output",RCLocalizedString(@"Kontakt", @"label.contact"),@"title", nil],
            nil];
}

- (NSArray *)fieldsForSecondColumn
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"files",@"type",@"full",@"output",RCLocalizedString(@"Downloads", @"label.downloads"),@"title",nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"linked_articles",@"type",@"full",@"output",RCLocalizedString(@"Zugeordnete Artikel", @"global.linked_articles"),@"title",nil],
            nil];
}

- (NSString*)fetchValueForFieldWithType:(NSString*)type key:(NSString *)key
{
    if([type isEqualToString:@"string"])
    {
        NSString *value=[self.article valueForKey:key];
        if(value==nil || value.length==0)return nil;
        return value;
    }
    else if([type isEqualToString:@"projectfacts"])
    {
        NSMutableString *content=[NSMutableString string];
        BOOL needsSeparator=NO;
        if(self.article.city!=nil && self.article.city.length>0)
        {
            [content appendString:self.article.city];
            needsSeparator=YES;
        }
        CriteriaOption *option=nil;
        NSArray *items=[[self.article.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.discriminator=%@",@"country"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],nil]];
        if(items.count>0)
            option=[items objectAtIndex:0];
        if(option!=nil)
        {
            if(needsSeparator)
                [content appendString:@" | "];
            [content appendString:option.title];
            needsSeparator=YES;
        }
        if(self.article.projectduration!=nil && self.article.projectduration.length>0)
        {
            if(needsSeparator)
            {
                [content appendString:@" | "];
            }
            [content appendString:self.article.projectduration];
            needsSeparator=YES;
        }
        option=nil;
        items=[[self.article.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.discriminator=%@",@"projectstatus"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES], nil]];
        if(items.count>0)
            option=[items objectAtIndex:0];
        if(option!=nil)
        {
            if(needsSeparator)
            {
                [content appendString:@" | "];
            }
            [content appendString:option.title];
            needsSeparator=YES;
        }
        if(content.length==0) return nil;
        return content;
    }
    else if([type isEqualToString:@"projectduration"])
    {
        return self.article.projectduration;
    }
    else if([type isEqualToString:@"projectstatus"])
    {
        CriteriaOption *option;
        NSArray *items=[[self.article.options filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"criterion.discriminator=%@",@"projectstatus"]] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"orderindex" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES], nil]];
        if(items.count>0)
            option=[items objectAtIndex:0];
        if(option!=nil)
        {
            return option.title;
        }
    }
    else if([type isEqualToString:@"external_links"])
    {
        NSArray *links=[self.article.external_links sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
        if(links.count==0)return nil;
        NSMutableString *string=[NSMutableString string];
        [string appendString:@"<ul id='external-links'>"];
        for(External_Link *link in links)
        {
            [string appendString:@"<li>"];
            if([link.show_link boolValue])
            {
                [string appendFormat:@"<a href=\"%@\">",link.url];
            }
            [string appendString:link.url];
            if([link.show_link boolValue])
            {
                [string appendFormat:@"</a>"];
            }
            [string appendString:@"</li>"];
        }
        [string appendString:@"</ul>"];
        return string;
    }
    else if([type isEqualToString:@"videos"])
    {
        NSArray *videos=[self.article.videos sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES], nil]];
        if(videos.count==0)return nil;
        NSMutableString *string=[NSMutableString string];
        Video *first=[videos objectAtIndex:0];
        
        NSString *(^getProvider)(Video *video)=^(Video *video){
            NSURL *url=[NSURL URLWithString:video.url];
            NSString *server=url.host;
            if([server isEqualToString:@"www.youtube.com"])
                return @"youtube";
            else
                return @"vimeo";
        };
        
        NSString *(^getVideoId)(Video *video)=^(Video *video){
            NSURL *url=[NSURL URLWithString:video.url];
            NSString *server=url.host;
            if([server isEqualToString:@"www.youtube.com"])
            {
                NSString *query=[url query];
                NSArray *elems=[query componentsSeparatedByString:@"&"];
                for(NSString *elem in elems)
                {
                    NSArray *parts=[elem componentsSeparatedByString:@"="];
                    if([[parts objectAtIndex:0] isEqualToString:@"v"])
                    {
                        return (NSString *)[parts objectAtIndex:1];
                    }
                }
                return @"";
            }
            else
            {
                return [url.path lastPathComponent];
            }
        };
        NSString *(^getFileName)(Video *video)=^(Video *video)
        {
            return [NSString stringWithFormat:@"%@_%@.jpg",getVideoId(video),getProvider(video)];
        };
        
        NSString *filename=getFileName(first);
        NSString *type=getProvider(first);
        NSString *videoid=getVideoId(first);
        NSString *embedurl;
        if([type isEqualToString:@"youtube"])
        {
            embedurl=[NSString stringWithFormat:@"http://www.youtube.com/embed/%@",videoid];
        }
        else if([type isEqualToString:@"vimeo"])
        {
            embedurl=[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",videoid];
        }
        NSString *thumbnail=[[[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:filename];
        [string appendFormat:@"<div id='videoPlayer'><img id=\"videoThumbnail\" src=\"%@\"><iframe id=\"videoFrame\" src=\"%@\"></iframe></div>",thumbnail,embedurl];
        [string appendString:@"<div id='videos'>"];
        [string appendString:@"<ul>"];
        NSMutableString *javascript=[NSMutableString string];
        [javascript appendString:@"$(function(){\n"];
        for(Video *video in videos)
        {
            filename=getFileName(video);
            videoid=getVideoId(video);
            type=getProvider(video);
            if([type isEqualToString:@"youtube"])
            {
                embedurl=[NSString stringWithFormat:@"http://www.youtube.com/embed/%@",videoid];
            }
            else if([type isEqualToString:@"vimeo"])
            {
                embedurl=[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",videoid];
            }

            thumbnail=[[[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:filename];
            NSString *display = [videos indexOfObject: video] == 0 ? @"none" : @"inline";
            [string appendFormat:@"<li><img class=\"vid\" style=\"display: %@;\"id=\"%@\" width=\"89\" height=\"89\" src=\"%@\"></li>",display,videoid,thumbnail];
            [javascript appendFormat:@"$('#%@').click(function(){\n",videoid];
            [javascript appendFormat:@"    $('#videoFrame').hide();\n"];
            [javascript appendFormat:@"    $('#videoThumbnail').show();\n"];
            [javascript appendFormat:@"    $('#videoThumbnail').attr('src',$('#%@').src);\n",videoid];
            [javascript appendFormat:@"    $('#videoFrame').attr('src','%@');\n",embedurl];
            [javascript appendFormat:@"    $('.vid').show();\n"];
            [javascript appendFormat:@"    $('#%@').hide();\n",videoid];
            [javascript appendFormat:@"});\n"];
        }
        [javascript appendFormat:@"$('#videoFrame').load(function(){\n"];
        [javascript appendFormat:@"    $('#videoThumbnail').hide();\n"];
        [javascript appendFormat:@"    $('#videoFrame').show();\n"];
        [javascript appendFormat:@"});\n"];
        [javascript appendFormat:@"$('#videoFrame').hide();\n"];
        [javascript appendString:@"});\n"];
        [string appendString:@"</ul>"];
        [string appendFormat:@"<script>%@</script>",javascript];
        [string appendString:@"</div>"];
        return string;
    }
    else if([type isEqualToString:@"images"])
    {
        NSArray *images=[self.article.images sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES], nil]];
        if(images.count==0)return nil;
        NSMutableString *string=[NSMutableString string];
        
        [string appendString:@"<ul id='images'>"];
        for(Image *image in images)
        {
            NSString *path=[[[[NSString cacheDirectory] stringByAppendingPathComponent:@"thumbnails"] stringByAppendingPathComponent:@"200x"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@",image.file.id_from_import,image.file.filename]];
            NSURL *url=[NSURL fileURLWithPath:path];
            [string appendFormat:@"<li><a href=\"x-image://%@/\"><img src=\"%@\"></a></li>",image.file.id_from_import,url];
        }
        [string appendString:@"</ul>"];
        return string;
    }
    else if([type isEqualToString:@"files"])
    {
        NSArray *files=[self.article.files sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES], nil]];
        if(files.count==0) return nil;
        NSMutableString *string=[NSMutableString string];
        
        [string appendString:@"<ul id='downloads'>"];
        
        for(Linked_file *file in files)
        {
            [string appendFormat:@"<li><a href=\"x-file://%@/\">%@</a></li>", file.file.id_from_import, file.file.filename];
        }
        
        [string appendString:@"</ul>"];
        
        return string;
    }
    else if([type isEqualToString:@"linked_articles"])
    {
        NSArray *objects=[NSArray arrayWithObjects:@"study",@"method",@"qa",@"expert",@"event",@"news", nil];
        NSArray *names=[NSArray arrayWithObjects:RCLocalizedString(@"Projekte", @"module.studies.title"),RCLocalizedString(@"Methoden", @"module.methods.title"),RCLocalizedString(@"Praxiswissen", @"module.qa.title"),RCLocalizedString(@"Experten", @"module.experts.title"),RCLocalizedString(@"Veranstaltungen", @"module.events.title"),RCLocalizedString(@"News", @"module.news.title"), nil];
        NSComparator cmp=^(id objA, id objB){
            int idxA=[objects indexOfObject:objA];
            int idxB=[objects indexOfObject:objB];
            if(idxA<idxB) return NSOrderedAscending;
            if(idxA==idxB) return NSOrderedSame;
            if(idxA>idxB) return NSOrderedDescending;
            return NSOrderedSame;
        };
        NSArray *articles=[self.article.linked_articles sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES comparator:cmp],[NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:YES], nil]];
        if(articles.count==0)
            return nil;
        NSMutableString *string=[NSMutableString string];
        NSString *lastType=nil;
        
        [string appendString:@"<ul id='linked-articles'>"];
        for(Article *article in articles)
        {
            if(![article.type isEqual:lastType])
            {
                if(lastType!=nil)
                    [string appendString:@"</ul>"];
                [string appendFormat:@"<h2>%@</h2><ul>",[names objectAtIndex:[objects indexOfObject:article.type]]];
                lastType=article.type;
            }
            NSString *finalTitle=article.title;
            if([article.type isEqualToString:@"expert"])
            {
                NSMutableString *title=[NSMutableString string];
                BOOL separatorNeeded=NO;
                if(article.firstname!=nil && article.firstname.length>0)
                {
                    [title appendString:article.firstname];
                    [title appendString:@" "];
                    [title appendString:article.lastname];
                    separatorNeeded=YES;
                }
                if(article.institution!=nil && article.institution.length>0)
                {
                    if(separatorNeeded)
                        [title appendString:@", "];
                    [title appendString:article.institution];
                }
                finalTitle=title;
            }
            [string appendFormat:@"<li><a href=\"x-article://%@\">%@</a></li>",article.id_from_import,finalTitle];
        }
        [string appendString:@"</ul>"];
        return string;
    }
    else if([type isEqualToString:@"dummy"])
    {
        return @"";
    }
    return nil;
}

- (NSString *)renderField:(NSDictionary*)field
{
    NSString *type=[field objectForKey:@"type"];
    /*
     type can be: string, projectduration,projectstatus,external_links
     */
    NSString *key=[field objectForKey:@"key"];
    NSString *output=[field objectForKey:@"output"];
    NSString *title=[field objectForKey:@"title"];
    NSString *value=[self fetchValueForFieldWithType:type key:key];
    
    
    if(value==nil)return nil;
    if([output isEqualToString:@"full"])
    {
        NSString *addClass = @"";
        NSString *preTag = @"";
        
        if([title isEqualToString: RCLocalizedString(@"Kurzbeschreibung",@"label.short_description")] ||
           [title isEqualToString: RCLocalizedString(@"Fragestellung",@"label.question")])
            addClass = @"short-description";
        
        if([title isEqualToString: RCLocalizedString(@"Videos",@"label.videos")])
            preTag = @"<div class=\"clear\"></div>";
        
        
        return [NSString stringWithFormat:@"%@<div class=\"datafield headline %@\"><h2>%@</h2><div class=\"textcontent\">%@</div></div><div class=\"clear\"></div>",preTag, addClass,title,value];
    }
    else if([output isEqualToString:@"labeled"])
    {
        return [NSString stringWithFormat:@"<div class=\"datafield labeled\"><label>%@:</label><span>%@</span></div><div class=\"clear\"></div>",title,value];
    }
    else if([output isEqualToString:@"plain"])
    {
        BOOL isImage = value && [value rangeOfString: @"<ul id='images'>"].location != NSNotFound;
        
        if(isImage)
            return [NSString stringWithFormat:@"<div class=\"image-floating\">%@</div>",value];
            
        return [NSString stringWithFormat:@"<div style='margin-bottom: 15px;'>%@</div>%@",value, isImage ? @"" : @"<div class=\"clear\"></div>"];
    }
    
    return nil;
}

- (NSString *)buildContentForFirstColumn
{
    NSMutableString *content=[NSMutableString string];
    [content appendFormat:@"<html><head><link rel=\"stylesheet\" href=\"%@\" type=\"text/css\" /></head><body style='width:320px;padding:0;margin:0;'><div id='left-column' class='container %@ %@ %@'>",[[NSBundle mainBundle] URLForResource:@"articledetails" withExtension:@"css"],(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? @"ipad" : @"iphone"),(UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? @"landscape" : @"portrait"), [[UIScreen mainScreen] isLongScreen] ? @"iphone-large" : @""];
    [content appendFormat:@"<script src=\"%@\"></script>",[[NSBundle mainBundle] URLForResource:@"jquery" withExtension:@"js"]];
    NSArray *fields=[self fieldsForFirstColumn];
    
    for(id elem in fields)
    {
        NSString *fieldcontent=[self renderField:elem];
        
        if(fieldcontent!=nil)
            [content appendString:fieldcontent];
    }
    [content appendString:@"<script>$(function(){window.location='x-ready://firstColumn';});</script>"];
    [content appendString:@"</div></body></html>"];
    return content;
}

- (NSString *)buildContentForSecondColumn
{
    NSMutableString *content=[NSMutableString string];
    [content appendFormat:@"<html><head><link rel=\"stylesheet\" href=\"%@\" type=\"text/css\" /></head><body style='width:320px;padding:0;margin:0;'><div id='right-column' class='container %@ %@ %@'>",[[NSBundle mainBundle] URLForResource:@"articledetails" withExtension:@"css"],(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad? @"ipad" : @"iphone"),(UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? @"landscape" : @"portrait"), [[UIScreen mainScreen] isLongScreen] ? @"iphone-large" : @""];
    [content appendFormat:@"<script src=\"%@\"></script>",[[NSBundle mainBundle] URLForResource:@"jquery" withExtension:@"js"]];
    NSArray *fields=[self fieldsForSecondColumn];
    for(id elem in fields)
    {
        NSString *fieldcontent=[self renderField:elem];
        if(fieldcontent!=nil)
            [content appendString:fieldcontent];
    }
    [content appendString:@"<script>$(function(){window.location='x-ready://secondColumn';});</script>"];
    [content appendString:@"</div></body></html>"];
    return content;
}




- (void)updateContent
{
    if(self.article.favorites.count>0)
    {
        [self.starBtn setImage:[UIImage imageNamed:@"icon_tapbar_fav_oranje.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.starBtn setImage:[UIImage imageNamed:@"icon_tapbar_fav_blue.png"] forState:UIControlStateNormal];
        
    }

    self.firstColumn.scrollView.scrollEnabled=YES;
    CGRect frame=self.firstColumn.frame;
    frame.size.height=10;
    self.firstColumn.frame=frame;
    self.secondColumn.scrollView.scrollEnabled=YES;
    frame=self.secondColumn.frame;
    frame.size.height=10;
    self.secondColumn.frame=frame;

    self.titleLabel.text=self.article.title;
    UINavigationController *container=(UINavigationController*)self.slideViewController.sideViewController;
    RCArticleSideVC *ctrl=[container.viewControllers objectAtIndex:0];
    ctrl.currentArticle=self.article;
    
    
    NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
    [fmt setDateStyle:NSDateFormatterShortStyle];
    [fmt setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *prefix = RCLocalizedString(@"Autor", @"label.author");
    
    if(self.article.originating_user.first_name!=nil && self.article.originating_user.last_name!=nil)
        self.authorLabel.text = [NSString stringWithFormat:@"%@: %@ %@",prefix,self.article.originating_user.first_name,self.article.originating_user.last_name];
    else if(self.article.author && ![self.article.author isEqualToString: @""])
        self.authorLabel.text = [NSString stringWithFormat: @"%@: %@", prefix, self.article.author];
    else
        self.authorLabel.text= @"";
    
    self.dateLabel.text=[fmt stringForObjectValue:self.article.updated];
    if(self.dateLabel.text==nil)
    {
        self.authorLabel.text=[self.authorLabel.text stringByAppendingFormat:@" | %@",[fmt stringFromDate:self.article.updated]];
    }
    
    NSString *html=[self buildContentForFirstColumn];
    [self.firstColumn loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    [self.firstColumn setNeedsLayout];
    
    html=[self buildContentForSecondColumn];
    [self.secondColumn loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    [self.secondColumn setNeedsLayout];
    
    if(self.articles==nil)
    {
        self.leftButton.hidden=YES;
        self.rightButton.hidden=YES;
    }
    else
    {
        int idx=[self.articles indexOfObject:self.article];
        if(idx==0)
            self.leftButton.hidden=YES;
        else
            self.leftButton.hidden=NO;
        if(idx==self.articles.count-1)
            self.rightButton.hidden=YES;
        else
            self.rightButton.hidden=NO;
    }
}


- (CGSize)sizeOfWebView:(UIWebView*)webView
{
//    return webView.scrollView.contentSize;
    return CGSizeMake([[webView stringByEvaluatingJavaScriptFromString:@"$(document).width()"] floatValue],
                      [[webView stringByEvaluatingJavaScriptFromString:@"$(document).height()"] floatValue]);
}

- (void)sizeWebView:(UIWebView *)webView
{
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        if(webView==self.firstColumn)
        {
            CGSize content=[self sizeOfWebView:self.firstColumn];
            CGRect frame=self.firstColumn.frame;
            frame.size=content;
            self.firstColumn.frame=frame;
            self.firstColumn.scrollView.scrollEnabled=NO;
        }
        else if(webView==self.secondColumn)
        {
            CGSize content=[self sizeOfWebView:self.secondColumn];
            CGRect frame=self.secondColumn.frame;
            frame.size=content;
            self.secondColumn.frame=frame;
            self.secondColumn.scrollView.scrollEnabled=NO;
        }
        self.container.contentSize=CGSizeMake(self.container.frame.size.width, MAX(CGRectGetMaxY(self.secondColumn.frame),CGRectGetMaxY(self.firstColumn.frame)));

    }
    else
    {
        if(webView==self.firstColumn)
        {
            CGSize content=[self sizeOfWebView:self.firstColumn];
            CGRect frame=self.firstColumn.frame;
            frame.size=content;
            self.firstColumn.frame=frame;
            frame=self.secondColumn.frame;
            frame.origin.y=CGRectGetMaxY(self.firstColumn.frame);
            self.secondColumn.frame=frame;
            self.container.contentSize=CGSizeMake(self.container.frame.size.width, CGRectGetMaxY(self.secondColumn.frame));
            self.firstColumn.scrollView.scrollEnabled=NO;
        }
        else if(webView==self.secondColumn)
        {
            CGSize content=[self sizeOfWebView:self.secondColumn];
            CGRect frame=self.secondColumn.frame;
            frame.size=content;
            self.secondColumn.frame=frame;
            self.container.contentSize=CGSizeMake(self.container.frame.size.width, CGRectGetMaxY(self.secondColumn.frame));
            self.secondColumn.scrollView.scrollEnabled=NO;
        }
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url=request.URL;
    if([url.scheme isEqualToString:@"x-article"])
    {
        Article *article=[[Article fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"id_from_import=%@",[NSNumber numberWithLongLong:[url.host longLongValue]]] inContext:self.appDelegate.managedObjectContext] lastObject];
        @try {
            RCArticleDetailVC *ctrl=[self.storyboard instantiateViewControllerWithIdentifier:article.type];
            ctrl.article=article;
            [self.navigationController pushViewController:ctrl animated:YES];

        }
        @catch (NSException *exception) {
        }
        return NO;
    }
    else if([url.scheme isEqualToString:@"x-image"])
    {
        File *file=[[File fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"id_from_import=%ld",[url.host longLongValue]] inContext:self.appDelegate.managedObjectContext] lastObject];
        [self performSegueWithIdentifier:@"images" sender:file];
        return NO;
    }
    else if([url.scheme isEqualToString:@"x-file"])
    {
        File *file=[[File fetchObjectsWithPredicate:[NSPredicate predicateWithFormat:@"id_from_import=%ld",[url.host longLongValue]] inContext:self.appDelegate.managedObjectContext] lastObject];
        NSString *url=[NSString stringWithFormat:@"%@media/%@-%@",baseurl,file.id_from_import,file.filename];
        NSURL *encapsulated=[NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:encapsulated];
        return NO;
    }
    else if([url.scheme isEqualToString:@"x-ready"])
    {
        [self sizeWebView:webView];
        return NO;
    }
    
    if(navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSString *uri = [request.URL absoluteString];
        
        if([[uri lowercaseString] rangeOfString: @"applewebdata://"].location != NSNotFound)
        {
            uri = [uri stringByReplacingOccurrencesOfString: @"applewebdata://" withString: @""];
            NSRange rangeOfFirstSlash = [uri rangeOfString: @"/"];
            uri = [uri stringByReplacingCharactersInRange: NSMakeRange(0, rangeOfFirstSlash.location + 1) withString: @"http://"];
        }
        
        NSURL *url = [NSURL URLWithString: uri];
        [[UIApplication sharedApplication] openURL: url];
        
		return NO;
    }
    
    return YES;
}

-(void)webViewDidFinishLoad: (UIWebView *)webView
{
    [self sizeWebView: webView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[RCArticleCriteriaList class]])
    {
        RCArticleCriteriaList *destination=segue.destinationViewController;
        destination.article=self.article;
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            self.popOver=((UIStoryboardPopoverSegue*)segue).popoverController;
            hideOnNextDisappear=YES;
        }
    }
    else if([segue.destinationViewController isKindOfClass:[RCImageVC class]])
    {
        RCImageVC *ctrl=segue.destinationViewController;
        File *file=sender;
        NSArray *images=[self.article.images sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
        ctrl.images=images;
        Image *image=[[images filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"file=%@",file]] lastObject];
        ctrl.currentImage=[images indexOfObject:image];
        hideOnNextDisappear=YES;
    }
}

- (void)onFilterCats:(id)sender
{
    if(self.popOver==nil)
    {
        [self performSegueWithIdentifier:@"showFilterCats" sender:sender];
        
    }
    else
    {
        [self.popOver dismissPopoverAnimated:YES];
        self.popOver=nil;
    }
}

- (void)onSwipeLeft:(UISwipeGestureRecognizer *)sender
{
    if(sender.state==UIGestureRecognizerStateEnded)
    {
        [self onRight:nil];
    }
}

- (void)onSwipeRight:(UISwipeGestureRecognizer *)sender
{
    if(sender.state==UIGestureRecognizerStateEnded)
    {
        [self onLeft:nil];
    }
}

- (IBAction)onStar:(id)sender
{
    if(self.appDelegate.comm.isAuthenticated)
    {
        if(self.article.favorites.count>0)
        {
            [self.appDelegate.comm removeFavorite:self.article.id_from_import andCall:^(id response){
                BOOL success=[[[response objectForKey:@"response"] objectForKey:@"success"] boolValue];
                if(success)
                {
                    for(NSManagedObject *obj in [self.article.favorites copy])
                    {
                        [self.appDelegate.managedObjectContext deleteObject:obj];
                    }
                    [self.appDelegate.managedObjectContext save:nil];
                    [self updateContent];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Entfernen nicht möglich", @"label.error_delete_not_possible")
                                                                  message:RCLocalizedString(@"Es gab einen Fehler bei der Kommunikation. Bitte versuchen Sie es später erneut", @"label.error_communication")
                                                                 delegate:nil cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok") otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        else
        {
            [self.appDelegate.comm addFavorite:self.article.id_from_import andCall:^(id response){
                BOOL success=[[[response objectForKey:@"response"] objectForKey:@"success"] boolValue];
                if(success)
                {
                    Favorite_Entry *entry=[Favorite_Entry createObjectInContext:self.appDelegate.managedObjectContext];
                    [self.appDelegate.managedObjectContext assignObject:entry toPersistentStore:self.appDelegate.globalStore];
                    entry.article=self.article;
                    [self.appDelegate.managedObjectContext save:nil];
                    [self updateContent];
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:RCLocalizedString(@"Hinzufügen nicht möglich", @"label.error_add_not_possible")
                                                                  message:RCLocalizedString(@"Es gab einen Fehler bei der Kommunikation. Bitte versuchen Sie es später erneut", @"label.error_communication")
                                                                 delegate:nil cancelButtonTitle:RCLocalizedString(@"OK", @"label.ok") otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
    }
    else
    {
        UIViewController *ctrl=[self.appDelegate.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"login"];
        [self.appDelegate.window.rootViewController presentViewController:ctrl animated:YES completion:nil];
    }
}

@end
