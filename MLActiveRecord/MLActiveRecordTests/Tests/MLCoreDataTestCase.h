//
//  MLCoreDataTestCase.h
//  MLActiveRecord
//
//  Created by Joachim Kret on 30/07/14.
//

#import "MLTestCase.h"

#import "MLActiveRecord.h"
#import "Artist.h"
#import "Image.h"

@interface MLCoreDataTestCase : MLTestCase

@property (nonatomic, readonly, strong) MLCoreDataStack * stack;

- (void)importArtist;
- (void)importArtistsList;

@end
