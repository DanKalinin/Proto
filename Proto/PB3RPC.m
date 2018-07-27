//
//  PB3RPC.m
//  Proto
//
//  Created by Dan Kalinin on 7/26/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "PB3RPC.h"










@interface PB3RPCPayloadReading ()

@end



@implementation PB3RPCPayloadReading

- (void)main {
    [self updateState:HLPOperationStateDidBegin];
    
//    self.reading = [self.parent.streams.input readData:NSMutableData.data minLength:4 maxLength:4 timeout:self.parent.timeout];
//    [self.reading waitUntilFinished];
//    if (self.reading.cancelled) {
//    } else if (self.reading.errors.count > 0) {
//    } else {
//        uint32_t length = *(uint32_t *)self.reading.data.bytes;
//        self.reading = [self.parent.streams.input readData:NSMutableData.data minLength:length maxLength:length timeout:self.parent.timeout];
//        [self.reading waitUntilFinished];
//        if (self.reading.cancelled) {
//        } else if (self.reading.errors.count > 0) {
//        } else {
//            NSError *error = nil;
//            PB3Payload *payload = [PB3Payload parseFromData:self.reading.data error:&error];
//            if (error) {
//                [self.errors addObject:error];
//            } else {
//                self.payload.serial = payload.serial;
//                if (payload.responseSerial.length > 0) {
//                    self.payload.responseSerial = payload.responseSerial;
//                    if (payload.error.length > 0) {
//
//                    } else {
//
//                    }
//                } else {
//                    self.payload.needsResponse = payload.needsResponse;
//                    self.payload.message = payload.message;
//                }
//            }
//        }
//    }
//
//    [self.errors addObjectsFromArray:self.reading.errors];
    
    [self updateState:HLPOperationStateDidEnd];
}

@end










@interface PB3RPCPayloadWriting ()

@end



@implementation PB3RPCPayloadWriting

- (void)main {
    self.progress.totalUnitCount = 2;
    
    [self updateState:HLPOperationStateDidBegin];
    [self updateProgress:0];
    
    PB3Payload *payload = PB3Payload.message;
    payload.serial = self.payload.serial;
    if (self.payload.message) {
        GPBMessage *message = self.payload.message;
        GPBFieldDescriptor *ret = [message.descriptor fieldWithNumber:15];
        self.payload.needsResponse = (ret != nil);
        
        payload.needsResponse = self.payload.needsResponse;
        [payload.message mergeFrom:self.payload.message];
    } else {
        payload.responseSerial = self.payload.responseSerial;
        if (self.payload.response) {
            [payload.message mergeFrom:self.payload.response];
        } else {
            payload.error = [NSString stringWithFormat:@"%@:%i", self.payload.error.domain, (int)self.payload.error.code];
        }
    }
    
    NSMutableData *payloadData = payload.data.mutableCopy;
    
    uint32_t length = (uint32_t)payloadData.length;
    NSMutableData *lengthData = [NSMutableData dataWithBytes:&length length:4];
    
    self.operation = [self.parent.streams.output writeData:lengthData timeout:self.parent.timeout];
    [self.operation waitUntilFinished];
    if (self.operation.cancelled) {
    } else if (self.operation.errors.count > 0) {
    } else {
        [self updateProgress:1];
        
        self.operation = [self.parent.streams.output writeData:payloadData timeout:self.parent.timeout];
        [self.operation waitUntilFinished];
        if (self.operation.cancelled) {
        } else if (self.operation.errors.count > 0) {
        } else {
            [self updateProgress:2];
        }
    }
    
    [self.errors addObjectsFromArray:self.operation.errors];
    
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
