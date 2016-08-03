//
//  PortFlap.m
//  TabBarTest-2
//
//  Created by Владислав Павкин on 15.07.15.
//  Copyright (c) 2015 Владислав Павкин. All rights reserved.
//

#import "PortFlap.h"

@implementation PortFlap

- (id)initWithPort: (NSString *) port
          andDescr: (NSString *) descr
           andTime: (NSString *) time
           andType: (NSString *) type
          andState: (NSString *) state
{
    self = [super init];
    
    if (self)
    {
        _port = port;
        _descr = descr;
        _time = time;
        _type = type;
        _state = state;
        
    }
    return self;
}

@end
