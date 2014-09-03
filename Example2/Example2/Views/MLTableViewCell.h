//
//  MLTableViewCell.h
//  Example2
//
//  Created by Joachim Kret on 05.08.2014.
//

#import <UIKit/UIKit.h>

@class Artist;

@interface MLTableViewCell : UITableViewCell

- (void)configureWithArtist:(Artist *)artist urlSession:(NSURLSession *)session tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
