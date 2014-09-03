//
//  MLCoreDataStack+ML_Errors.m
//  MLActiveRecord
//
//  Created by Joachim Kret on 15.08.2014.
//

#import "MLCoreDataStack+ML_Errors.h"

#import "MLActiveRecordDefines.h"

__weak static id errorHandlerTarget = nil;
static SEL errorHandlerAction = nil;

#pragma mark -

@implementation MLCoreDataStack (ML_Errors)

+ (void)cleanUpErrorHanding; {
    errorHandlerTarget = nil;
    errorHandlerAction = nil;
}

+ (void)defaultErrorHandler:(NSError *)error {
    NSDictionary * userInfo = error.userInfo;
    
    for (NSArray * detailedError in [userInfo allValues]) {
        if ([detailedError isKindOfClass:[NSArray class]]) {
            for (NSError *e in detailedError) {
                if ([e respondsToSelector:@selector(userInfo)]) {
                    MLLog(@"Error Details: %@", [e userInfo]);
                }
                else {
                    MLLog(@"Error Details: %@", e);
                }
            }
        }
        else {
            MLLog(@"Error: %@", detailedError);
        }
    }
    
    MLLog(@"Error Message: %@", [error localizedDescription]);
    MLLog(@"Error Domain: %@", [error domain]);
    MLLog(@"Recovery Suggestion: %@", [error localizedRecoverySuggestion]);
}

+ (void)handleErrors:(NSError *)error {
	if (error) {
        // If a custom error handler is set, call that
        if (errorHandlerTarget != nil && errorHandlerAction != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [errorHandlerTarget performSelector:errorHandlerAction withObject:error];
#pragma clang diagnostic pop
        }
		else {
	        // Otherwise, fall back to the default error handling
	        [self defaultErrorHandler:error];
		}
    }
}

+ (id)errorHandlerTarget {
    return errorHandlerTarget;
}

+ (SEL)errorHandlerAction {
    return errorHandlerAction;
}

+ (void)setErrorHandlerTarget:(id)target action:(SEL)action {
    errorHandlerTarget = target;    /* Deliberately don't retain to avoid potential retain cycles */
    errorHandlerAction = action;
}

- (void)handleErrors:(NSError *)error {
	[[self class] handleErrors:error];
}


@end
