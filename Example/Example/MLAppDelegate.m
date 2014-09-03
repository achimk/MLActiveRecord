//
//  MLAppDelegate.m
//  Example
//
//  Created by Joachim Kret on 17/07/14.
//

#import "MLAppDelegate.h"

#import "MLCustomSQLiteCoreDataStack.h"
#import "MLCustomInMemoryCoreDataStack.h"

@implementation MLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Create stack on app did finish launching
    NSManagedObjectModel * model = [NSManagedObjectModel ml_managedObjectModelNamed:DEFAULT_MODEL_NAME];
    MLCoreDataStack * stack = nil;
    
#if (USE_CUSTOM_STACK && USE_SQLITE_STACK)
    // Create custom sqlite core data stack
    stack = [[MLCustomSQLiteCoreDataStack alloc] initWithStoreNamed:DEFAULT_STORE_NAME model:model];
#elif (USE_CUSTOM_STACK && !USE_SQLITE_STACK)
    // Create custom in memory core data stack
    stack = [[MLCustomInMemoryCoreDataStack alloc] initWithModel:model];
#elif (!USE_CUSTOM_STACK && USE_SQLITE_STACK)
    // Create sqlite core data stack
    stack = [[MLSavingContextSQLCoreDataStack alloc] initWithStoreNamed:DEFAULT_STORE_NAME model:model];
#else
    // Create in memory core data stack
    stack = [[MLSavingContextInMemoryCoreDataStack alloc] initWithModel:model];
#endif
    
    NSParameterAssert(stack);
    [MLCoreDataStack setDefaultStack:stack];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Release stack on will terminate
    [MLCoreDataStack setDefaultStack:nil];
}

@end
