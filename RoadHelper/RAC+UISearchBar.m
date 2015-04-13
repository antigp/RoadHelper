//
//  RAC+UISearchBar.m
//  RoadHelper
//
//  Created by Eugene on 13/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

#import "RAC+UISearchBar.h"

#import <objc/runtime.h>

@implementation UISearchBar (RAC)

- (RACSignal *)rac_textSignal {
    self.delegate = self;
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    
    /* Create signal from selector */
    signal = [[self rac_signalForSelector:@selector(searchBar:textDidChange:)
                             fromProtocol:@protocol(UISearchBarDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
    
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}
@end