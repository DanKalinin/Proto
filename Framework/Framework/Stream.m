//
//  Proto.m
//  Intercom
//
//  Created by Dan Kalinin on 3/8/18.
//  Copyright © 2018 Dan Kalinin. All rights reserved.
//

#import "Stream.h"
#import "Message.pbobjc.h"
#import "Api.pbobjc.h"










@interface ProtoMessage ()

@property PB3Message *message;

@end



@implementation ProtoMessage

- (instancetype)init {
    self = super.init;
    if (self) {
        self.message = PB3Message.message;
    }
    return self;
}

- (NSInteger)readFromStream:(NSInputStream *)inputStream {
    NSMutableData *lengthData = NSMutableData.data;
    NSInteger result = [inputStream read:lengthData exactly:4];
    if (result <= 0) return result;
    uint32_t length = *(uint32_t *)lengthData.bytes;
    
    NSMutableData *messageData = NSMutableData.data;
    result = [inputStream read:messageData exactly:length];
    if (result <= 0) return result;
    [self.message mergeFromData:messageData extensionRegistry:nil];
    
    self.reply = self.message.reply;
    self.serial = self.message.serial;
    self.replySerial = self.message.replySerial;
    return result;
}

- (NSInteger)writeToStream:(NSOutputStream *)outputStream {
    self.message.reply = self.reply;
    self.message.serial = self.serial;
    self.message.replySerial = self.replySerial;
    
    NSMutableData *messageData = self.message.data.mutableCopy;
    uint32_t length = (uint32_t)messageData.length;
    NSMutableData *lengthData = [NSMutableData dataWithBytes:&length length:4];
    
    NSInteger result = [outputStream writeAll:lengthData];
    if (result <= 0) return result;
    result = [outputStream writeAll:messageData];
    return result;
}

@end










@interface ProtoLoad ()

@end



@implementation ProtoLoad

- (void)main {
    [self updateState:OperationStateDidBegin];
    
    int32_t handle = (int32_t)self.parent.loadSequence.value;
    [self.parent.loadSequence increment];
    
    if (self.operation == StreamLoadOperationUp) {
        PB3Load *upload = PB3Load.message;
        upload.operation = PB3Load_Operation_OperationUp;
        upload.command = PB3Load_Command_CommandBegin;
        upload.handle = handle;
        upload.digest = [self.data digest:DigestMD5];
        NSError *error;
        [self.parent call:upload error:&error];
        if (error) {
            [self.errors addObject:error];
        } else {
            while (!self.cancelled) {
                if (self.data.length > self.parent.loadChunk) {
                    // TODO: pop range
                } else {
                    break;
                }
            }
        }
    } else {
        
    }
    
    [self updateState:OperationStateDidEnd];
    
    
    
    
//    PB3Authorize *authorize = PB3Authorize.message;
//    authorize.code = self.ac.textFields[0].text;
//    HUDController *hud = [HUDController.alloc initWithProgressHUD:self.hudIndeterminate errorHUD:self.hudText];
//    [self.pair call:authorize completion:^(PB3Authorize *message, NSError *error) {
//        [hud completeWithError:error];
//        NSLog(@"result - %@ - %@", message, error);
//    }];
}

#pragma mark - Proto

@end










@interface ProtoPair ()

@end



@implementation ProtoPair

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    self = [super initWithInputStream:inputStream outputStream:outputStream];
    if (self) {
        self.messageClass = ProtoMessage.class;
        self.loadClass = ProtoLoad.class;
    }
    return self;
}

- (void)call:(GPBMessage *)procedure completion:(GPBMessageErrorBlock)completion {
    ProtoMessage *message = self.messageClass.new;
    message.reply = [procedure.descriptor fieldWithName:KeyRet];
    [message.message.message packWithMessage:procedure error:nil];
    [self writeMessage:message completion:^(ProtoMessage *msg, NSError *error) {
        if (error) {
            [self invokeHandler:completion object:nil object:error];
        } else if (message.reply) {
            if (msg.message.error.length > 0) {
                NSError *error = [NSError errorWithDomain:msg.message.error code:0 userInfo:nil];
                [self invokeHandler:completion object:nil object:error];
            } else {
                GPBMessage *result = [msg.message.message unpackMessageClass:procedure.class error:nil];
                [self invokeHandler:completion object:result object:nil];
            }
        } else {
            [self invokeHandler:completion object:procedure object:nil];
        }
    }];
}

- (GPBMessage *)call:(GPBMessage *)procedure error:(NSError **)error {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    __block GPBMessage *msg;
    __block NSError *err;
    [self call:procedure completion:^(GPBMessage *message, NSError *error) {
        msg = message;
        err = error;
        dispatch_group_leave(group);
    }];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    *error = err;
    return msg;
}

#pragma mark - Pair

- (void)pair:(ProtoPair *)pair didReceiveMessage:(ProtoMessage *)message {
    [super pair:pair didReceiveMessage:message];
    
    NSString *name = [NSString stringWithFormat:@"%@%@", message.message.descriptor.file.objcPrefix, message.message.message.typeURL.lastPathComponent];
    Class class = NSClassFromString(name);
    if (class) {
        GPBMessage *procedure = [message.message.message unpackMessageClass:class error:nil];
        NSString *signature = [NSString stringWithFormat:@"%@:%@:%@:", KeyPair, name, KeyCompletion];
        SEL selector = NSSelectorFromString(signature);
        [self.delegates performSelector:selector withObject:self withObject:procedure withObject:^(GPBMessage *result, NSError *error, ErrorBlock completion) {
            if (message.reply) {
                ProtoMessage *msg = self.messageClass.new;
                msg.replySerial = message.serial;
                if (result) {
                    [msg.message.message packWithMessage:result error:nil];
                } else {
                    msg.message.error = error.domain;
                }
                [self writeMessage:msg completion:^(ProtoMessage *message, NSError *error) {
                    [self invokeHandler:completion object:error];
                }];
            } else {
                [self invokeHandler:completion object:nil];
            }
        }];
    }
}

@end
