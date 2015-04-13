//
//  ViewController.m
//  HW_CoreData
//
//  Created by Alexander on 30.03.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "ViewController.h"

@interface ViewController () {
    NSMutableArray *sites;
    NSIndexPath *updateIdxPath;
    UIAlertController *addSite;
    NSNotificationCenter *nCenter;
    NSManagedObjectContext *moc;
    CoreDataManager *manager;
    NetManager *nManager;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property(nonatomic,retain) UIPopoverPresentationController *popover;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    nCenter = [NSNotificationCenter defaultCenter];
    manager = [CoreDataManager shared];
    nManager =[NetManager sharedInstance];
    [self reloadData];
    //    [nCenter addObserver:self
    //                selector:@selector(didEnterBackground:)
    //                    name:UIApplicationDidEnterBackgroundNotification
    //                  object:nil];
}

-(void)addSiteWithTitle:(NSString *)title AndUrl:(NSString *)url{
    moc = manager.managedObjectContext;
    Site *page = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:moc];
    page.title = title;
    page.url = url;
    [nManager downloadSite:page :^(Site *site) {
        [sites addObject:site];
        NSLog(@"%@", site.title);
        NSLog(@"%@", site.data);
        NSLog(@"%@", site.preview);
        [manager save];
        [self.tableView reloadData];
        
    }];
    
}
-(void)reloadData{
    [manager getSites:^(NSArray *sitesArr) {
        sites = [NSMutableArray arrayWithArray:sitesArr];
        [self.tableView reloadData];
    }];
}

- (IBAction)addSite:(id)sender {
    //__weak ViewController *weakSelf = self;
    NSLog(@"%@", @"tapped");
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        addSite = [UIAlertController alertControllerWithTitle:@"" message:@"Введите название" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction
                                   actionWithTitle:@"Отмена"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                                        object:nil];
                                       [addSite dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        UIAlertAction *yesAction = [UIAlertAction
                                    actionWithTitle:@"Добавить"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        UITextField *nameTextField = addSite.textFields.firstObject;
                                        UITextField *urlTextField = addSite.textFields.lastObject;
                                        
                                        [self addSiteWithTitle:nameTextField.text AndUrl:urlTextField.text];
                                        
                                        [nCenter removeObserver:self                                                                                               name:UITextFieldTextDidChangeNotification
                                                         object:nil];
                                        [addSite dismissViewControllerAnimated:YES completion:nil];
                                    }];
        [addSite addTextFieldWithConfigurationHandler:^(UITextField *nameTextField) {
            nameTextField.placeholder = @"Пример: Прочитать!";
            [nCenter addObserver:self
                        selector:@selector(alertTextFieldDidChange:)
                            name:UITextFieldTextDidChangeNotification
                          object:nameTextField];
        }];
        [addSite addTextFieldWithConfigurationHandler:^(UITextField *urlTextField) {
            urlTextField.placeholder = @"http://www....";
            [nCenter addObserver:self
                        selector:@selector(alertTextFieldDidChange:)
                            name:UITextFieldTextDidChangeNotification
                          object:urlTextField];
        }];
        yesAction.enabled = NO;
        [addSite addAction:noAction];
        [addSite addAction:yesAction];
        UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:addSite];
        destNav.modalPresentationStyle = UIModalPresentationPopover;
        _popover = destNav.popoverPresentationController;
        _popover.delegate = self;
        if (sender) {
            _popover.barButtonItem = sender;
        } else  _popover.barButtonItem = _addButton;
        destNav.modalPresentationStyle = UIModalPresentationPopover;
        destNav.navigationBarHidden = YES;
        [self presentViewController:destNav animated:YES completion:nil];
    }
}

- (void)alertTextFieldDidChange:(NSNotification *)notification
{
    UINavigationController *nav = self.presentedViewController;
    UIAlertController *alertController = (UIAlertController *)[nav visibleViewController];
    if (alertController)
    {
        UITextField *name = alertController.textFields.firstObject;
        UITextField *url = alertController.textFields.lastObject;
        UIAlertAction *yesAction = alertController.actions.lastObject;
        NSString *urlRegEx =
        @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
        NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
        yesAction.enabled = (name.text.length>2)&&[urlTest evaluateWithObject:url.text];
    }
}

//- (void)didEnterBackground:(NSNotification *)notification
//{
//    [nCenter removeObserver:self
//                       name:UITextFieldTextDidChangeNotification
//                     object:nil];
//    [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
//}

- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}


#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (sites) {
        return sites.count;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SiteCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SiteCell" forIndexPath:indexPath];
    Site *site = sites[indexPath.row];
    if (site) {
        cell.title.text = site.title;
        cell.thumb.image = site.preview;
    }
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((editingStyle==UITableViewCellEditingStyleDelete)&&(sites[indexPath.row])) {
        [manager deleteSite:sites[indexPath.row]];
        [manager save];
        [sites removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqual:@"showPage"] && path) {
        WebViewController *webView = [segue destinationViewController];
        if (sites[path.row]) {
            Site *s = sites[path.row];
            webView.data = s.data;
            webView.url = [NSURL URLWithString:s.url];
        }
    }

}


@end
