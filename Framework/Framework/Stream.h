//
//  Proto.h
//  Intercom
//
//  Created by Dan Kalinin on 3/8/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Helpers/Helpers.h>
#import <Protobuf/GPBProtocolBuffers.h>

@class ProtoMessage, ProtoPair;

typedef void (^GPBMessageErrorBlock)(__kindof GPBMessage *message, NSError *error);
typedef void (^GPBMessageErrorCompletionBlock)(__kindof GPBMessage *message, NSError *error, ErrorBlock completion);










@interface ProtoMessage : HLPStreamMessage

@end










@interface ProtoLoad : HLPStreamLoad

@end










@interface ProtoPair : HLPStreamPair

- (void)call:(GPBMessage *)procedure completion:(GPBMessageErrorBlock)completion;
- (__kindof GPBMessage *)call:(GPBMessage *)procedure error:(NSError **)error;

@end
