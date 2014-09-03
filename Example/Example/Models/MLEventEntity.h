//
//  MLEventEntity.h
//  Example
//
//  Created by Joachim Kret on 25/07/14.
//

#import <CoreData/CoreData.h>

@interface MLEventEntity : NSManagedObject

@property (nonatomic, strong) NSNumber * identifier;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSDate * timestamp;

@end
