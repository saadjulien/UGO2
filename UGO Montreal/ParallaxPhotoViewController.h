//
//  ParallaxPhotoViewController.h
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 07.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "QMBParallaxScrollViewController.h"
#import "Venue.h"

@interface ParallaxPhotoViewController : QMBParallaxScrollViewController<QMBParallaxScrollViewControllerDelegate>

- (IBAction) dismiss:(id)sender;

@property Venue *venue;
@end
