//
//  MLTableViewController.m
//  Example2
//
//  Created by Joachim Kret on 05.08.2014.
//

#import "MLTableViewController.h"

#import "Artist.h"
#import "Image.h"
#import "MLTableViewCell.h"

#pragma mark - MLTableViewController

@interface MLTableViewController () <NSFetchedResultsControllerDelegate, NSURLSessionDelegate>

@property (nonatomic, readwrite, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, readwrite, strong) NSURLSession * session;
@property (nonatomic, readwrite, strong) NSURLSessionTask * artistListTask;

- (void)finishInitialize;

- (IBAction)refresh:(id)sender;

@end

#pragma mark -

@implementation MLTableViewController

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)finishInitialize {
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSManagedObjectContext * context = [[MLCoreDataStack defaultStack] managedObjectContext];
    NSAssert(NSMainQueueConcurrencyType == context.concurrencyType, @"FetchedResultsController must be created on main context");
    
    NSFetchRequest * fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [Artist ml_entityDescription];
    fetchRequest.predicate = nil;
    fetchRequest.sortDescriptors = [NSSortDescriptor ml_descriptors:@"rank"];
    fetchRequest.fetchBatchSize = 20;
    NSFetchedResultsController * controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    self.fetchedResultsController = controller;
    
    NSError * error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"-> Error during performFetch: %@, %@", error, error.userInfo);
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    [self refresh:nil];
}

#pragma mark Accessors

- (void)setArtistListTask:(NSURLSessionTask *)artistListTask {
    if (artistListTask != _artistListTask) {
        if (_artistListTask) {
            [_artistListTask cancel];
        }
        
        _artistListTask = artistListTask;
        
        if (artistListTask) {
            [artistListTask resume];
        }
    }
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
    NSString * urlString = [NSString stringWithFormat:@"http://ws.audioscrobbler.com/2.0/?method=group.getweeklyartistchart&group=mnml&api_key=%@&format=json", LASTFM_API_KEY];
    NSURL * anURL = [NSURL URLWithString:urlString];
    
    __weak typeof (self) weakSekf = self;
    NSURLSessionTask * jsonTask = [self.session dataTaskWithURL:anURL completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        if (weakSekf) {
            __strong typeof (weakSekf) strongSelf = weakSekf;
            
            if (error) {
                [strongSelf handleFailureWithError:error];
            }
            else {
                [strongSelf handleSuccessWithData:data];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.refreshControl endRefreshing];
            });
        }
    }];
    
    self.artistListTask = jsonTask;
}

- (void)handleSuccessWithData:(NSData *)data {
    NSAssert(![NSThread isMainThread], @"Must be called out of main thread");
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    NSManagedObjectContext * context = [[MLCoreDataStack defaultStack] managedObjectContext];
    [context ml_performBlock:^{
        NSArray *artists = [[jsonObject objectForKey:@"weeklyartistchart"] objectForKey:@"artist"];

        NSMutableArray *objects = [NSMutableArray array];
        for (NSDictionary *dictionary in artists) {
            NSManagedObject *managedObject = [Artist ml_objectWithDictionary:dictionary inContext:context];

            if (managedObject) {
                [objects addObject:managedObject];
            }
        }

        if (objects.count) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", objects];
            [Artist ml_deleteWithPredicate:predicate inContext:context];
        }

        [context obtainPermanentIDsForObjects:context.insertedObjects.allObjects error:nil];
        [context ml_saveStackWithCompletion:nil];
    }];
    
}

- (void)handleFailureWithError:(NSError *)error {
    NSAssert(![NSThread isMainThread], @"Must be called out of main thread");

    if (NSURLErrorCancelled == error.code) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:error.userInfo[NSLocalizedDescriptionKey]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    });
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MLTableViewCell class])];
    
    if (!cell) {
        cell = [[MLTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([MLTableViewCell class])];
    }
    
    Artist * artist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureWithArtist:artist urlSession:self.session tableView:tableView indexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark NSURLSessionDelegate

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    UITableViewRowAnimation animation = UITableViewRowAnimationFade;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:animation];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:animation];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableViewRowAnimation animation = UITableViewRowAnimationFade;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
