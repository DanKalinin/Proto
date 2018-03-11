// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: api.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30002
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30002 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

@class PB3Person;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - PB3ApiRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
@interface PB3ApiRoot : GPBRootObject
@end

#pragma mark - PB3Divide

typedef GPB_ENUM(PB3Divide_FieldNumber) {
  PB3Divide_FieldNumber_A = 1,
  PB3Divide_FieldNumber_B = 2,
  PB3Divide_FieldNumber_Ret = 3,
};

@interface PB3Divide : GPBMessage

@property(nonatomic, readwrite) int32_t a;

@property(nonatomic, readwrite) int32_t b;

@property(nonatomic, readwrite) double ret;

@end

#pragma mark - PB3Person

typedef GPB_ENUM(PB3Person_FieldNumber) {
  PB3Person_FieldNumber_Name = 1,
  PB3Person_FieldNumber_Age = 2,
  PB3Person_FieldNumber_ChildrenArray = 3,
};

@interface PB3Person : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *name;

@property(nonatomic, readwrite) uint32_t age;

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<PB3Person*> *childrenArray;
/** The number of items in @c childrenArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger childrenArray_Count;

@end

#pragma mark - PB3GetParent

typedef GPB_ENUM(PB3GetParent_FieldNumber) {
  PB3GetParent_FieldNumber_Person = 1,
  PB3GetParent_FieldNumber_Ret = 2,
};

@interface PB3GetParent : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) PB3Person *person;
/** Test to see if @c person has been set. */
@property(nonatomic, readwrite) BOOL hasPerson;

@property(nonatomic, readwrite, strong, null_resettable) PB3Person *ret;
/** Test to see if @c ret has been set. */
@property(nonatomic, readwrite) BOOL hasRet;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
