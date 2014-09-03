//
//  MLTableViewController.m
//  Example
//
//  Created by Joachim Kret on 25/07/14.
//

#import "MLTableViewController.h"

#import "MLEventEntity.h"

#pragma mark - MLTableViewController

@interface MLTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, readwrite, strong) NSFetchedResultsController * fetchedResultsController;

- (void)finishInitialize;

- (IBAction)addEvent:(id)sender;
- (IBAction)removeAll:(id)sender;

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
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeAll:)];
    
    NSManagedObjectContext * context = [[MLCoreDataStack defaultStack] managedObjectContext];
    NSAssert(NSMainQueueConcurrencyType == context.concurrencyType, @"FetchedResultsController must be created on main context");
    
    NSFetchRequest * fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [MLEventEntity ml_entityDescription];
    fetchRequest.predicate = nil;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    fetchRequest.fetchBatchSize = 20;
    NSFetchedResultsController * controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    controller.delegate = self;
    self.fetchedResultsController = controller;
    
    NSError * error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"-> Error during performFetch: %@, %@", error, error.userInfo);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark Actions

- (IBAction)addEvent:(id)sender {
    [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext * context) {
        [context ml_performBlockAndWait:^{
            MLEventEntity *eventEntity = [MLEventEntity ml_create];
            eventEntity.identifier = @([MLEventEntity ml_count]);
            eventEntity.name = @"test name";
            eventEntity.timestamp = [NSDate date];
        }];
    } completion:^(BOOL isSuccess, NSError * error) {
        if (error) {
            NSLog(@"-> save context failure: %@, %@", error, error.userInfo);
        }
    }];
}

- (IBAction)removeAll:(id)sender {
    [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext * context) {
        [context ml_performBlockAndWait:^{
            [MLEventEntity ml_deleteAll];
        }];
    } completion:^(BOOL isSuccess, NSError * error) {
        if (error) {
            NSLog(@"-> save context failure: %@, %@", error, error.userInfo);
        }
    }];
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    MLEventEntity * eventEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", eventEntity.name, eventEntity.identifier];
    cell.detailTextLabel.text = eventEntity.timestamp.description;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectID * deleteID = [[self.fetchedResultsController objectAtIndexPath:indexPath] objectID];
        
        [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext * context) {
            [context ml_performBlockAndWait:^{
                NSManagedObject *managedObject = [context objectWithID:deleteID];
                [context deleteObject:managedObject];
            }];
        } completion:^(BOOL isSuccess, NSError * error) {
            if (error) {
                NSLog(@"-> save context failure: %@, %@", error, error.userInfo);
            }
        }];
    }
}

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
