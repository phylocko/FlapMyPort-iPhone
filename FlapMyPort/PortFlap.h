//
//  PortFlap.h
//  TabBarTest-2
//
//  Created by Владислав Павкин on 15.07.15.
//  Copyright (c) 2015 Владислав Павкин. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PortFlap : NSObject

@property NSString *port;
@property NSString *descr;
@property NSString *time;
@property NSString *type;
@property NSString *state;

- (id)initWithPort: (NSString *) port
          andDescr: (NSString *) descr
           andTime: (NSString *) time
           andType: (NSString *) type
          andState: (NSString *) state;


@end
