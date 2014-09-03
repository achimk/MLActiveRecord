//
//  Artist.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLActiveRecord.h"

@interface Artist : NSManagedObject <MLManagedObjectSerializing>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * playcount;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSSet *images;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addImagesObject:(NSManagedObject *)value;
- (void)removeImagesObject:(NSManagedObject *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
