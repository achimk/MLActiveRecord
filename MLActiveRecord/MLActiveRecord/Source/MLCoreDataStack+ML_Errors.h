//
//  MLCoreDataStack+ML_Errors.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 15.08.2014.
//

#import "MLCoreDataStack.h"

@interface MLCoreDataStack (ML_Errors)

+ (void)handleErrors:(NSError *)error;
- (void)handleErrors:(NSError *)error;

+ (void)setErrorHandlerTarget:(id)target action:(SEL)action;
+ (SEL)errorHandlerAction;
+ (id)errorHandlerTarget;

@end
