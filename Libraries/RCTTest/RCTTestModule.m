/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "RCTTestModule.h"

#import "FBSnapshotTestController.h"
#import "RCTAssert.h"
#import "RCTEventDispatcher.h"
#import "RCTLog.h"
#import "RCTUIManager.h"

@implementation RCTTestModule
{
  NSMutableDictionary<NSString *, NSString *> *_snapshotCounter;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return _bridge.uiManager.methodQueue;
}

RCT_EXPORT_METHOD(verifySnapshot:(RCTResponseSenderBlock)callback)
{
  RCTAssert(_controller != nil, @"No snapshot controller configured.");

  [_bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {

    NSString *testName = NSStringFromSelector(self->_testSelector);
    if (!self->_snapshotCounter) {
      self->_snapshotCounter = [NSMutableDictionary new];
    }
    self->_snapshotCounter[testName] = (@([self->_snapshotCounter[testName] integerValue] + 1)).stringValue;

    NSError *error = nil;
    BOOL success = [self->_controller compareSnapshotOfView:self->_view
                                             selector:self->_testSelector
                                           identifier:self->_snapshotCounter[testName]
                                                error:&error];
    callback(@[@(success)]);
  }];
}

RCT_EXPORT_METHOD(sendAppEvent:(NSString *)name body:(nullable id)body)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [_bridge.eventDispatcher sendAppEventWithName:name body:body];
#pragma clang diagnostic pop
}

RCT_REMAP_METHOD(shouldResolve, shouldResolve_resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  resolve(@1);
}

RCT_REMAP_METHOD(shouldReject, shouldReject_resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
{
  reject(nil, nil, nil);
}

RCT_EXPORT_METHOD(markTestCompleted)
{
  [self markTestPassed:YES];
}

RCT_EXPORT_METHOD(markTestPassed:(BOOL)success)
{
  [_bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, __unused NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    self->_status = success ? RCTTestStatusPassed : RCTTestStatusFailed;
  }];
}

@end
