//
//  Proto.h
//  Intercom
//
//  Created by Dan Kalinin on 3/8/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Protobuf/GPBProtocolBuffers.h>
#import "Stream.h"

@class ProtoMessage, ProtoPair;

typedef void (^GPBMessageErrorBlock)(__kindof GPBMessage *message, NSError *error);
typedef void (^GPBMessageErrorCompletionBlock)(__kindof GPBMessage *message, NSError *error, ErrorBlock completion);










@interface ProtoMessage : StreamMessage

@end










@interface ProtoPair : StreamPair

- (void)call:(GPBMessage *)procedure completion:(GPBMessageErrorBlock)completion;

@end
