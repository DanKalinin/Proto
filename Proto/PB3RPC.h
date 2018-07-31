//
//  PB3RPC.h
//  Proto
//
//  Created by Dan Kalinin on 7/26/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import <Helpers/Helpers.h>
#import "Payload.pbobjc.h"

@class PB3RPCPayloadReading, PB3RPCPayloadWriting, PB3RPC;










@interface PB3RPCPayloadReading : HLPRPCPayloadReading

@property (readonly) HLPStreamReading *lengthReading;
@property (readonly) HLPStreamReading *payloadReading;

@end










@interface PB3RPCPayloadWriting : HLPRPCPayloadWriting

@property (readonly) HLPStreamWriting *lengthWriting;
@property (readonly) HLPStreamWriting *payloadWriting;

@end










@interface PB3RPC : HLPRPC

@end
