//
//  RAC+UISearchBar.h
//  RoadHelper
//
//  Created by Eugene on 13/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface UISearchBar (RAC)

- (RACSignal *)rac_textSignal;

@end