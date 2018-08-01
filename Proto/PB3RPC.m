//
//  PB3RPC.m
//  Proto
//
//  Created by Dan Kalinin on 7/26/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "PB3RPC.h"










@interface PB3RPCPayloadReading ()

@property HLPStreamReading *lengthReading;
@property HLPStreamReading *payloadReading;

@end



@implementation PB3RPCPayloadReading

- (void)main {
    self.progress.totalUnitCount = 2;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    // 1 - Reading
    
    NSMutableData *lengthData = NSMutableData.data;

    self.operation = self.lengthReading = [self.parent.streams.input readData:lengthData minLength:4 maxLength:4 timeout:self.parent.timeout];
    [self.lengthReading waitUntilFinished];
    if (self.lengthReading.cancelled) {
    } else if (self.lengthReading.errors.count > 0) {
        [self.errors addObjectsFromArray:self.lengthReading.errors];
    } else {
        [self updateProgress:1];

        NSMutableData *payloadData = NSMutableData.data;
        uint32_t length = *(uint32_t *)lengthData.bytes;

        self.operation = self.payloadReading = [self.parent.streams.input readData:payloadData minLength:length maxLength:length timeout:self.parent.timeout];
        [self.payloadReading waitUntilFinished];
        if (self.payloadReading.cancelled) {
        } else if (self.payloadReading.errors.count > 0) {
            [self.errors addObjectsFromArray:self.payloadReading.errors];
        } else {
            [self updateProgress:2];
            
            // 2 - Unpacking
            
            NSError *error = nil;
            PB3Payload *payload = [PB3Payload parseFromData:payloadData error:&error];
            if (error) {
                [self.errors addObject:error];
            } else {
                
                // Type
                
                self.payload.type = payload.type;
                
                // Serial
                
                self.payload.serial = payload.serial;
                
                // Response serial
                
                if (payload.type == HLPRPCPayloadTypeReturn) {
                    self.payload.responseSerial = payload.responseSerial;
                }
                
                // Message, Response
                
                
                //    @interface HLPRPCPayload : HLPObject
                //
                //    @property HLPRPCPayloadType type;
                //    @property NSInteger serial;
                //    @property NSInteger responseSerial;
                //    @property id message;
                //    @property id response;
                //    @property NSError *error;
                //
                //    @end
            }

//            NSError *error = nil;
//            PB3Payload *payload = [PB3Payload parseFromData:payloadData error:&error];
//            if (error) {
//                [self.errors addObject:error];
//            } else {
//                self.payload.serial = payload.serial;
//                if (payload.responseSerial.length > 0) {
//                    self.payload.responseSerial = payload.responseSerial;
//                    if (payload.error.length > 0) {
//                        NSArray<NSString *> *components = [payload.error componentsSeparatedByString:@":"];
//                        NSErrorDomain domain = components.firstObject;
//                        NSInteger code = components.lastObject.integerValue;
//                        self.payload.error = [NSError errorWithDomain:domain code:code userInfo:nil];
//                    } else {
//                        NSError *error = nil;
//                        self.payload.response = [payload.message unpackMessageClass:NSClassFromString([payload.message.typeURL.lastPathComponent stringByReplacingOccurrencesOfString:@"." withString:@""]) error:&error];
//                        if (error) {
//                            [self.errors addObject:error];
//                        }
//                    }
//                } else {
//                    NSError *error = nil;
//                    self.payload.message = [payload.message unpackMessageClass:NSClassFromString([payload.message.typeURL.lastPathComponent stringByReplacingOccurrencesOfString:@"." withString:@""]) error:&error];
//                    if (error) {
//                        [self.errors addObject:error];
//                    } else {
//                        self.payload.needsResponse = payload.needsResponse;
//                    }
//                }
//            }
        }
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface PB3RPCPayloadWriting ()

@property HLPStreamWriting *lengthWriting;
@property HLPStreamWriting *payloadWriting;

@end



@implementation PB3RPCPayloadWriting

- (void)main {
    self.progress.totalUnitCount = 2;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    // 1 - Packing
    
    PB3Payload *payload = PB3Payload.message;
    
    // Message, Response
    
    GPBMessage *message = nil;
    if (self.payload.message) {
        message = self.payload.message;
    } else if (self.payload.response) {
        message = self.payload.response;
    }
    
    if (message) {
        NSError *error = nil;
        [payload.message packWithMessage:message error:&error];
        if (error) {
            [self.errors addObject:error];
        }
    }
    
    if (self.errors.count == 0) {
        
        // Type
        
        if (self.payload.message) {
            GPBMessage *message = self.payload.message;
            GPBFieldDescriptor *ret = [message.descriptor fieldWithNumber:15];
            if (ret) {
                self.payload.type = HLPRPCPayloadTypeCall;
            } else {
                self.payload.type = HLPRPCPayloadTypeSignal;
            }
        } else {
            self.payload.type = HLPRPCPayloadTypeReturn;
        }
        
        payload.type = self.payload.type;
        
        // Serial
        
        payload.serial = (int32_t)self.payload.serial;
        
        // Response serial
        
        if (self.payload.type == HLPRPCPayloadTypeReturn) {
            payload.responseSerial = (int32_t)self.payload.responseSerial;
        }
        
        // Error
        
        if (self.payload.error) {
            payload.error = [NSString stringWithFormat:@"%@:%i", self.payload.error.domain, (int)self.payload.error.code];
        }
        
        // 2 - Writing
        
        NSMutableData *payloadData = payload.data.mutableCopy;

        uint32_t length = (uint32_t)payloadData.length;
        NSMutableData *lengthData = [NSMutableData dataWithBytes:&length length:4];

        self.operation = self.lengthWriting = [self.parent.streams.output writeData:lengthData timeout:self.parent.timeout];
        [self.lengthWriting waitUntilFinished];
        if (self.lengthWriting.cancelled) {
        } else if (self.lengthWriting.errors.count > 0) {
            [self.errors addObjectsFromArray:self.lengthWriting.errors];
        } else {
            [self updateProgress:1];

            self.operation = self.payloadWriting = [self.parent.streams.output writeData:payloadData timeout:self.parent.timeout];
            [self.payloadWriting waitUntilFinished];
            if (self.payloadWriting.cancelled) {
            } else if (self.payloadWriting.errors.count > 0) {
                [self.errors addObjectsFromArray:self.payloadWriting.errors];
            } else {
                [self updateProgress:2];
            }
        }
    }
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface PB3RPC ()

@end



@implementation PB3RPC

- (instancetype)initWithStreams:(HLPStreams *)streams {
    self = [super initWithStreams:streams];
    if (self) {
        self.payloadReadingClass = PB3RPCPayloadReading.class;
        self.payloadWritingClass = PB3RPCPayloadWriting.class;
    }
    return self;
}

@end
