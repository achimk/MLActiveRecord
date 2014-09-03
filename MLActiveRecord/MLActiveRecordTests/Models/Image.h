//
//  Image.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLActiveRecord.h"

@class Artist;

@interface Image : NSManagedObject <MLManagedObjectSerializing>

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * size;
@property (nonatomic, retain) Artist *artist;

@end
