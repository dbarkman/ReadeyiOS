//
//  RSSItemCell.m
//  Readey
//
//  Created by David Barkman on 4/5/13.
//  Copyright (c) 2013 RealSimpleApps. All rights reserved.
//

#import "RSSItemCell.h"

@implementation RSSItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)share
{
	NSLog(@"Sharring!");
}

@end
