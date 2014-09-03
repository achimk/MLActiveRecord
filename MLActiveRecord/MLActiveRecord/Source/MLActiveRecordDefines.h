//
//  MLActiveRecordDefines.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 21/07/14.
//

#import <Foundation/Foundation.h>

/*
 *  Simple Logging
 */
#ifdef ML_LOGGING_ENABLED
    #defineMLLog
#else
    #define MLLog(...)
#endif

#define ML_QUEUE_NAME(name) "private.queue.MLActiveRecord."name

/*
 *  Common NSException Macros
 *  from: https://github.com/michalkonturek/MKUnits/blob/master/Source/MKMacros.h
 */
#define METHOD_NOT_IMPLEMENTED METHOD(@"%@: NOT IMPLEMENTED.")
#define METHOD_MUST_BE_OVERRIDDEN METHOD(@"You must override %@ in subclass.")
#define METHOD_USE_DESIGNATED_INIT  METHOD(@"%@: Use designated initializer.")
#define METHOD(MSG) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:MSG, NSStringFromSelector(_cmd)] userInfo:nil];