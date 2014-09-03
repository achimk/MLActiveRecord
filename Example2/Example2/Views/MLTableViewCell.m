//
//  MLTableViewCell.m
//  Example2
//
//  Created by Joachim Kret on 05.08.2014.
//

#import "MLTableViewCell.h"

#import "Artist.h"
#import "Image.h"
#import "UIImage+Additions.h"

#pragma mark - MLTableViewCell

@interface MLTableViewCell ()

@property (nonatomic, readwrite, strong) NSURLSessionDownloadTask * downloadTask;

- (void)finishInitialize;

@end

#pragma mark -

@implementation MLTableViewCell

#pragma mark Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self finishInitialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self finishInitialize];
}

- (void)finishInitialize {
    self.accessoryType = UITableViewCellAccessoryNone;

}

#pragma mark View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.layer.cornerRadius = floorf(self.imageView.bounds.size.width * 0.5f);
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imageView.layer.borderWidth = 1.0f;
}

#pragma mark Prepare For Reuse

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.downloadTask = nil;
}

#pragma mark Accessors

- (void)setDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    if (downloadTask != _downloadTask) {
        if (_downloadTask) {
            [_downloadTask cancel];
        }
        
        _downloadTask = downloadTask;
        
        if (downloadTask) {
            [downloadTask resume];
        }
    }
}

#pragma mark Configure Cell

- (void)configureWithArtist:(Artist *)artist urlSession:(NSURLSession *)session tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(artist);
    NSParameterAssert(session);
    
    self.textLabel.text = [NSString stringWithFormat:@"%d. %@", indexPath.row + 1, artist.name];
    self.imageView.image = [UIImage ml_imageWithColor:[UIColor lightGrayColor] size:CGSizeMake(30.0f, 30.0f)];
    
    Image * thumbImage = nil;
    
    for (Image * image in artist.images) {
        if ([image.size isEqualToString:@"medium"]) {
            thumbImage = image;
            break;
        }
    }
    
    if (!thumbImage || !thumbImage.path || !thumbImage.path.length) {
        return;
    }
    
    __weak typeof (self) weakSelf = self;
    NSURL * anURL = [NSURL URLWithString:thumbImage.path];
    NSURLSessionDownloadTask * downloadTask = [session downloadTaskWithURL:anURL completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error) {
        if (error) {
            return;
        }

        UIImage * image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:location]];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = image;
        });
    }];
    
    self.downloadTask = downloadTask;
}

@end
