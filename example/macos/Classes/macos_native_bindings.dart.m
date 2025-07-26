#include <stdint.h>
#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <Metal/Metal.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

typedef struct {
  int64_t version;
  void* (*newWaiter)(void);
  void (*awaitWaiter)(void*);
  void* (*currentIsolate)(void);
  void (*enterIsolate)(void*);
  void (*exitIsolate)(void);
  int64_t (*getMainPortId)(void);
  bool (*getCurrentThreadOwnsIsolate)(int64_t);
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, BLOCK_SIG, INVOKE_DIRECT, INVOKE_LISTENER)    \
  assert(ctx->version >= 1);                                                   \
  void* targetIsolate = ctx->currentIsolate();                                 \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();  \
  return BLOCK_SIG {                                                           \
    void* currentIsolate = ctx->currentIsolate();                              \
    bool mayEnterIsolate =                                                     \
        currentIsolate == NULL &&                                              \
        ctx->getCurrentThreadOwnsIsolate != NULL &&                            \
        ctx->getCurrentThreadOwnsIsolate(targetPort);                          \
    if (currentIsolate == targetIsolate || mayEnterIsolate) {                  \
      if (mayEnterIsolate) {                                                   \
        ctx->enterIsolate(targetIsolate);                                      \
      }                                                                        \
      INVOKE_DIRECT;                                                           \
      if (mayEnterIsolate) {                                                   \
        ctx->exitIsolate();                                                    \
      }                                                                        \
    } else {                                                                   \
      void* waiter = ctx->newWaiter();                                         \
      INVOKE_LISTENER;                                                         \
      ctx->awaitWaiter(waiter);                                                \
    }                                                                          \
  };


typedef id  (^ProtocolTrampoline)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_1mbt9g9(id target, void * sel) {
  return ((ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_NSProgressReporting(void) { return @protocol(NSProgressReporting); }

typedef void  (^ListenerTrampoline)(id arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline _MacosNativeBindings_wrapListenerBlock_1a22wz(ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void(id arg0, struct _NSRange arg1, BOOL * arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline)(void * waiter, id arg0, struct _NSRange arg1, BOOL * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline _MacosNativeBindings_wrapBlockingBlock_1a22wz(
    BlockingTrampoline block, BlockingTrampoline listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, struct _NSRange arg1, BOOL * arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, arg2);
  });
}

typedef BOOL  (^ProtocolTrampoline_1)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_e3qsqz(id target, void * sel) {
  return ((ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^ListenerTrampoline_1)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_1 _MacosNativeBindings_wrapListenerBlock_18v1jvf(ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^BlockingTrampoline_1)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_1 _MacosNativeBindings_wrapBlockingBlock_18v1jvf(
    BlockingTrampoline_1 block, BlockingTrampoline_1 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^ProtocolTrampoline_2)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_18v1jvf(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_3)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_xr62hr(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_4)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_zi5eed(id target, void * sel, id arg1, id arg2) {
  return ((ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_2)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_2 _MacosNativeBindings_wrapListenerBlock_fjrv01(ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^BlockingTrampoline_2)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_2 _MacosNativeBindings_wrapBlockingBlock_fjrv01(
    BlockingTrampoline_2 block, BlockingTrampoline_2 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^ProtocolTrampoline_5)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_fjrv01(id target, void * sel, id arg1, id arg2) {
  return ((ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_3)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_3 _MacosNativeBindings_wrapListenerBlock_1tz5yf(ListenerTrampoline_3 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^BlockingTrampoline_3)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_3 _MacosNativeBindings_wrapBlockingBlock_1tz5yf(
    BlockingTrampoline_3 block, BlockingTrampoline_3 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^ProtocolTrampoline_6)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1tz5yf(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((ProtocolTrampoline_6)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

Protocol* _MacosNativeBindings_NSKeyedArchiverDelegate(void) { return @protocol(NSKeyedArchiverDelegate); }

typedef void  (^ListenerTrampoline_4)();
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_4 _MacosNativeBindings_wrapListenerBlock_1pl9qdv(ListenerTrampoline_4 block) NS_RETURNS_RETAINED {
  return ^void() {
    objc_retainBlock(block);
    block();
  };
}

typedef void  (^BlockingTrampoline_4)(void * waiter);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_4 _MacosNativeBindings_wrapBlockingBlock_1pl9qdv(
    BlockingTrampoline_4 block, BlockingTrampoline_4 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(), {
    objc_retainBlock(block);
    block(nil);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter);
  });
}

Protocol* _MacosNativeBindings_NSURLAuthenticationChallengeSender(void) { return @protocol(NSURLAuthenticationChallengeSender); }

Protocol* _MacosNativeBindings_NSNetServiceDelegate(void) { return @protocol(NSNetServiceDelegate); }

typedef void  (^ListenerTrampoline_5)(NSURLSessionAuthChallengeDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_5 _MacosNativeBindings_wrapListenerBlock_n8yd09(ListenerTrampoline_5 block) NS_RETURNS_RETAINED {
  return ^void(NSURLSessionAuthChallengeDisposition arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^BlockingTrampoline_5)(void * waiter, NSURLSessionAuthChallengeDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_5 _MacosNativeBindings_wrapBlockingBlock_n8yd09(
    BlockingTrampoline_5 block, BlockingTrampoline_5 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(NSURLSessionAuthChallengeDisposition arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^ListenerTrampoline_6)(void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_6 _MacosNativeBindings_wrapListenerBlock_bklti2(ListenerTrampoline_6 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  };
}

typedef void  (^BlockingTrampoline_6)(void * waiter, void * arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_6 _MacosNativeBindings_wrapBlockingBlock_bklti2(
    BlockingTrampoline_6 block, BlockingTrampoline_6 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), objc_retainBlock(arg3));
  });
}

typedef void  (^ProtocolTrampoline_7)(void * sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_bklti2(id target, void * sel, id arg1, id arg2, id arg3) {
  return ((ProtocolTrampoline_7)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

Protocol* _MacosNativeBindings_NSURLSessionDelegate(void) { return @protocol(NSURLSessionDelegate); }

typedef void  (^ListenerTrampoline_7)(id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_7 _MacosNativeBindings_wrapListenerBlock_r8gdi7(ListenerTrampoline_7 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^BlockingTrampoline_7)(void * waiter, id arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_7 _MacosNativeBindings_wrapBlockingBlock_r8gdi7(
    BlockingTrampoline_7 block, BlockingTrampoline_7 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^ListenerTrampoline_8)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_8 _MacosNativeBindings_wrapListenerBlock_xtuoz7(ListenerTrampoline_8 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0));
  };
}

typedef void  (^BlockingTrampoline_8)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_8 _MacosNativeBindings_wrapBlockingBlock_xtuoz7(
    BlockingTrampoline_8 block, BlockingTrampoline_8 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0));
  });
}

typedef void  (^ListenerTrampoline_9)(NSURLSessionDelayedRequestDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_9 _MacosNativeBindings_wrapListenerBlock_1otpo83(ListenerTrampoline_9 block) NS_RETURNS_RETAINED {
  return ^void(NSURLSessionDelayedRequestDisposition arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^BlockingTrampoline_9)(void * waiter, NSURLSessionDelayedRequestDisposition arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_9 _MacosNativeBindings_wrapBlockingBlock_1otpo83(
    BlockingTrampoline_9 block, BlockingTrampoline_9 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(NSURLSessionDelayedRequestDisposition arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef void  (^ListenerTrampoline_10)(void * arg0, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_10 _MacosNativeBindings_wrapListenerBlock_xx612k(ListenerTrampoline_10 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, id arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), objc_retainBlock(arg4));
  };
}

typedef void  (^BlockingTrampoline_10)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_10 _MacosNativeBindings_wrapBlockingBlock_xx612k(
    BlockingTrampoline_10 block, BlockingTrampoline_10 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), objc_retainBlock(arg4));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), objc_retainBlock(arg4));
  });
}

typedef void  (^ProtocolTrampoline_8)(void * sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_xx612k(id target, void * sel, id arg1, id arg2, id arg3, id arg4) {
  return ((ProtocolTrampoline_8)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_11)(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_11 _MacosNativeBindings_wrapListenerBlock_l2g8ke(ListenerTrampoline_11 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), objc_retainBlock(arg5));
  };
}

typedef void  (^BlockingTrampoline_11)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_11 _MacosNativeBindings_wrapBlockingBlock_l2g8ke(
    BlockingTrampoline_11 block, BlockingTrampoline_11 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, id arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), objc_retainBlock(arg5));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), objc_retainBlock(arg5));
  });
}

typedef void  (^ProtocolTrampoline_9)(void * sel, id arg1, id arg2, id arg3, id arg4, id arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_l2g8ke(id target, void * sel, id arg1, id arg2, id arg3, id arg4, id arg5) {
  return ((ProtocolTrampoline_9)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_12)(void * arg0, id arg1, id arg2, int64_t arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_12 _MacosNativeBindings_wrapListenerBlock_jyim80(ListenerTrampoline_12 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, int64_t arg3, id arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, objc_retainBlock(arg4));
  };
}

typedef void  (^BlockingTrampoline_12)(void * waiter, void * arg0, id arg1, id arg2, int64_t arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_12 _MacosNativeBindings_wrapBlockingBlock_jyim80(
    BlockingTrampoline_12 block, BlockingTrampoline_12 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, int64_t arg3, id arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, objc_retainBlock(arg4));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, objc_retainBlock(arg4));
  });
}

typedef void  (^ProtocolTrampoline_10)(void * sel, id arg1, id arg2, int64_t arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_jyim80(id target, void * sel, id arg1, id arg2, int64_t arg3, id arg4) {
  return ((ProtocolTrampoline_10)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_13)(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_13 _MacosNativeBindings_wrapListenerBlock_h68abb(ListenerTrampoline_13 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, arg4, arg5);
  };
}

typedef void  (^BlockingTrampoline_13)(void * waiter, void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_13 _MacosNativeBindings_wrapBlockingBlock_h68abb(
    BlockingTrampoline_13 block, BlockingTrampoline_13 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, arg4, arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, arg4, arg5);
  });
}

typedef void  (^ProtocolTrampoline_11)(void * sel, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_h68abb(id target, void * sel, id arg1, id arg2, int64_t arg3, int64_t arg4, int64_t arg5) {
  return ((ProtocolTrampoline_11)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

Protocol* _MacosNativeBindings_NSURLSessionTaskDelegate(void) { return @protocol(NSURLSessionTaskDelegate); }

typedef void  (^ListenerTrampoline_14)(id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_14 _MacosNativeBindings_wrapListenerBlock_rnu2c5(ListenerTrampoline_14 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, BOOL arg1, id arg2) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  };
}

typedef void  (^BlockingTrampoline_14)(void * waiter, id arg0, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_14 _MacosNativeBindings_wrapBlockingBlock_rnu2c5(
    BlockingTrampoline_14 block, BlockingTrampoline_14 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, BOOL arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1, (__bridge id)(__bridge_retained void*)(arg2));
  });
}

typedef void  (^ListenerTrampoline_15)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_15 _MacosNativeBindings_wrapListenerBlock_pfv6jd(ListenerTrampoline_15 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  };
}

typedef void  (^BlockingTrampoline_15)(void * waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_15 _MacosNativeBindings_wrapBlockingBlock_pfv6jd(
    BlockingTrampoline_15 block, BlockingTrampoline_15 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1));
  });
}

typedef uint64_t  (^ProtocolTrampoline_12)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
uint64_t  _MacosNativeBindings_protocolTrampoline_k3xjiw(id target, void * sel) {
  return ((ProtocolTrampoline_12)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLSize  (^ProtocolTrampoline_13)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLSize  _MacosNativeBindings_protocolTrampoline_8c4zsv(id target, void * sel) {
  return ((ProtocolTrampoline_13)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLReadWriteTextureTier  (^ProtocolTrampoline_14)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLReadWriteTextureTier  _MacosNativeBindings_protocolTrampoline_wmhw8a(id target, void * sel) {
  return ((ProtocolTrampoline_14)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLArgumentBuffersTier  (^ProtocolTrampoline_15)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLArgumentBuffersTier  _MacosNativeBindings_protocolTrampoline_1cth5re(id target, void * sel) {
  return ((ProtocolTrampoline_15)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef unsigned long  (^ProtocolTrampoline_16)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _MacosNativeBindings_protocolTrampoline_1ckyi24(id target, void * sel) {
  return ((ProtocolTrampoline_16)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^ListenerTrampoline_16)(id arg0, id arg1, MTLLogLevel arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_16 _MacosNativeBindings_wrapListenerBlock_xbkiks(ListenerTrampoline_16 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, MTLLogLevel arg2, id arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  };
}

typedef void  (^BlockingTrampoline_16)(void * waiter, id arg0, id arg1, MTLLogLevel arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_16 _MacosNativeBindings_wrapBlockingBlock_xbkiks(
    BlockingTrampoline_16 block, BlockingTrampoline_16 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, id arg1, MTLLogLevel arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3));
  });
}

typedef void  (^ListenerTrampoline_17)(id arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_17 _MacosNativeBindings_wrapListenerBlock_f167m6(ListenerTrampoline_17 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block(objc_retainBlock(arg0));
  };
}

typedef void  (^BlockingTrampoline_17)(void * waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_17 _MacosNativeBindings_wrapBlockingBlock_f167m6(
    BlockingTrampoline_17 block, BlockingTrampoline_17 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0), {
    objc_retainBlock(block);
    block(nil, objc_retainBlock(arg0));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, objc_retainBlock(arg0));
  });
}

typedef void  (^ListenerTrampoline_18)(void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_18 _MacosNativeBindings_wrapListenerBlock_1l4hxwm(ListenerTrampoline_18 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1) {
    objc_retainBlock(block);
    block(arg0, objc_retainBlock(arg1));
  };
}

typedef void  (^BlockingTrampoline_18)(void * waiter, void * arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_18 _MacosNativeBindings_wrapBlockingBlock_1l4hxwm(
    BlockingTrampoline_18 block, BlockingTrampoline_18 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1), {
    objc_retainBlock(block);
    block(nil, arg0, objc_retainBlock(arg1));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, objc_retainBlock(arg1));
  });
}

typedef void  (^ProtocolTrampoline_17)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1l4hxwm(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_17)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLLogState(void) { return @protocol(MTLLogState); }

typedef unsigned long  (^ProtocolTrampoline_18)(void * sel, MTLSize arg1);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _MacosNativeBindings_protocolTrampoline_jof8uq(id target, void * sel, MTLSize arg1) {
  return ((ProtocolTrampoline_18)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef struct MTLResourceID  (^ProtocolTrampoline_19)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct MTLResourceID  _MacosNativeBindings_protocolTrampoline_14kff1y(id target, void * sel) {
  return ((ProtocolTrampoline_19)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLFunctionType  (^ProtocolTrampoline_20)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLFunctionType  _MacosNativeBindings_protocolTrampoline_srgf34(id target, void * sel) {
  return ((ProtocolTrampoline_20)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_MTLFunctionHandle(void) { return @protocol(MTLFunctionHandle); }

typedef MTLPatchType  (^ProtocolTrampoline_21)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLPatchType  _MacosNativeBindings_protocolTrampoline_1xstr86(id target, void * sel) {
  return ((ProtocolTrampoline_21)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef long  (^ProtocolTrampoline_22)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
long  _MacosNativeBindings_protocolTrampoline_fai2e9(id target, void * sel) {
  return ((ProtocolTrampoline_22)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_MTLAllocation(void) { return @protocol(MTLAllocation); }

typedef MTLCPUCacheMode  (^ProtocolTrampoline_23)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLCPUCacheMode  _MacosNativeBindings_protocolTrampoline_zgv4ld(id target, void * sel) {
  return ((ProtocolTrampoline_23)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLStorageMode  (^ProtocolTrampoline_24)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLStorageMode  _MacosNativeBindings_protocolTrampoline_1r5fu12(id target, void * sel) {
  return ((ProtocolTrampoline_24)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLHazardTrackingMode  (^ProtocolTrampoline_25)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLHazardTrackingMode  _MacosNativeBindings_protocolTrampoline_1g8njem(id target, void * sel) {
  return ((ProtocolTrampoline_25)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLResourceOptions  (^ProtocolTrampoline_26)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLResourceOptions  _MacosNativeBindings_protocolTrampoline_18p282y(id target, void * sel) {
  return ((ProtocolTrampoline_26)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLPurgeableState  (^ProtocolTrampoline_27)(void * sel, MTLPurgeableState arg1);
__attribute__((visibility("default"))) __attribute__((used))
MTLPurgeableState  _MacosNativeBindings_protocolTrampoline_eqqb4h(id target, void * sel, MTLPurgeableState arg1) {
  return ((ProtocolTrampoline_27)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef unsigned long  (^ProtocolTrampoline_28)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _MacosNativeBindings_protocolTrampoline_c19g8h(id target, void * sel, unsigned long arg1) {
  return ((ProtocolTrampoline_28)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_29)(void * sel, unsigned long arg1, MTLResourceOptions arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_e344kn(id target, void * sel, unsigned long arg1, MTLResourceOptions arg2) {
  return ((ProtocolTrampoline_29)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef struct __IOSurface *  (^ProtocolTrampoline_30)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
struct __IOSurface *  _MacosNativeBindings_protocolTrampoline_tg5r79(id target, void * sel) {
  return ((ProtocolTrampoline_30)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLTextureType  (^ProtocolTrampoline_31)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLTextureType  _MacosNativeBindings_protocolTrampoline_11q778p(id target, void * sel) {
  return ((ProtocolTrampoline_31)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLPixelFormat  (^ProtocolTrampoline_32)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLPixelFormat  _MacosNativeBindings_protocolTrampoline_1utgvu9(id target, void * sel) {
  return ((ProtocolTrampoline_32)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLTextureUsage  (^ProtocolTrampoline_33)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLTextureUsage  _MacosNativeBindings_protocolTrampoline_1o3k4e2(id target, void * sel) {
  return ((ProtocolTrampoline_33)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLTextureCompressionType  (^ProtocolTrampoline_34)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLTextureCompressionType  _MacosNativeBindings_protocolTrampoline_1nbnwnd(id target, void * sel) {
  return ((ProtocolTrampoline_34)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^ListenerTrampoline_19)(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3, MTLRegion arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_19 _MacosNativeBindings_wrapListenerBlock_q8n2i(ListenerTrampoline_19 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3, MTLRegion arg4, unsigned long arg5, unsigned long arg6) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
  };
}

typedef void  (^BlockingTrampoline_19)(void * waiter, void * arg0, void * arg1, unsigned long arg2, unsigned long arg3, MTLRegion arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_19 _MacosNativeBindings_wrapBlockingBlock_q8n2i(
    BlockingTrampoline_19 block, BlockingTrampoline_19 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3, MTLRegion arg4, unsigned long arg5, unsigned long arg6), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4, arg5, arg6);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4, arg5, arg6);
  });
}

typedef void  (^ProtocolTrampoline_35)(void * sel, void * arg1, unsigned long arg2, unsigned long arg3, MTLRegion arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_q8n2i(id target, void * sel, void * arg1, unsigned long arg2, unsigned long arg3, MTLRegion arg4, unsigned long arg5, unsigned long arg6) {
  return ((ProtocolTrampoline_35)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef void  (^ListenerTrampoline_20)(void * arg0, MTLRegion arg1, unsigned long arg2, unsigned long arg3, void * arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_20 _MacosNativeBindings_wrapListenerBlock_117cvpq(ListenerTrampoline_20 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLRegion arg1, unsigned long arg2, unsigned long arg3, void * arg4, unsigned long arg5, unsigned long arg6) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
  };
}

typedef void  (^BlockingTrampoline_20)(void * waiter, void * arg0, MTLRegion arg1, unsigned long arg2, unsigned long arg3, void * arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_20 _MacosNativeBindings_wrapBlockingBlock_117cvpq(
    BlockingTrampoline_20 block, BlockingTrampoline_20 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLRegion arg1, unsigned long arg2, unsigned long arg3, void * arg4, unsigned long arg5, unsigned long arg6), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4, arg5, arg6);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4, arg5, arg6);
  });
}

typedef void  (^ProtocolTrampoline_36)(void * sel, MTLRegion arg1, unsigned long arg2, unsigned long arg3, void * arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_117cvpq(id target, void * sel, MTLRegion arg1, unsigned long arg2, unsigned long arg3, void * arg4, unsigned long arg5, unsigned long arg6) {
  return ((ProtocolTrampoline_36)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef void  (^ListenerTrampoline_21)(void * arg0, void * arg1, unsigned long arg2, MTLRegion arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_21 _MacosNativeBindings_wrapListenerBlock_1rw9p8k(ListenerTrampoline_21 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, void * arg1, unsigned long arg2, MTLRegion arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_21)(void * waiter, void * arg0, void * arg1, unsigned long arg2, MTLRegion arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_21 _MacosNativeBindings_wrapBlockingBlock_1rw9p8k(
    BlockingTrampoline_21 block, BlockingTrampoline_21 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, void * arg1, unsigned long arg2, MTLRegion arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_37)(void * sel, void * arg1, unsigned long arg2, MTLRegion arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1rw9p8k(id target, void * sel, void * arg1, unsigned long arg2, MTLRegion arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_37)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_22)(void * arg0, MTLRegion arg1, unsigned long arg2, void * arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_22 _MacosNativeBindings_wrapListenerBlock_dku27g(ListenerTrampoline_22 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLRegion arg1, unsigned long arg2, void * arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_22)(void * waiter, void * arg0, MTLRegion arg1, unsigned long arg2, void * arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_22 _MacosNativeBindings_wrapBlockingBlock_dku27g(
    BlockingTrampoline_22 block, BlockingTrampoline_22 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLRegion arg1, unsigned long arg2, void * arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_38)(void * sel, MTLRegion arg1, unsigned long arg2, void * arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_dku27g(id target, void * sel, MTLRegion arg1, unsigned long arg2, void * arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_38)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef id  (^ProtocolTrampoline_39)(void * sel, MTLPixelFormat arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_12woq8r(id target, void * sel, MTLPixelFormat arg1) {
  return ((ProtocolTrampoline_39)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_40)(void * sel, MTLPixelFormat arg1, MTLTextureType arg2, struct _NSRange arg3, struct _NSRange arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_1aoqdpp(id target, void * sel, MTLPixelFormat arg1, MTLTextureType arg2, struct _NSRange arg3, struct _NSRange arg4) {
  return ((ProtocolTrampoline_40)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef MTLTextureSwizzleChannels  (^ProtocolTrampoline_41)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLTextureSwizzleChannels  _MacosNativeBindings_protocolTrampoline_7y1w3d(id target, void * sel) {
  return ((ProtocolTrampoline_41)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^ProtocolTrampoline_42)(void * sel, MTLPixelFormat arg1, MTLTextureType arg2, struct _NSRange arg3, struct _NSRange arg4, MTLTextureSwizzleChannels arg5);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_jipc5v(id target, void * sel, MTLPixelFormat arg1, MTLTextureType arg2, struct _NSRange arg3, struct _NSRange arg4, MTLTextureSwizzleChannels arg5) {
  return ((ProtocolTrampoline_42)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_23)(void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_23 _MacosNativeBindings_wrapListenerBlock_ovsamd(ListenerTrampoline_23 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void  (^BlockingTrampoline_23)(void * waiter, void * arg0);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_23 _MacosNativeBindings_wrapBlockingBlock_ovsamd(
    BlockingTrampoline_23 block, BlockingTrampoline_23 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0), {
    objc_retainBlock(block);
    block(nil, arg0);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0);
  });
}

typedef void  (^ProtocolTrampoline_43)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_ovsamd(id target, void * sel) {
  return ((ProtocolTrampoline_43)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef int  (^ProtocolTrampoline_44)(void * sel, unsigned arg1);
__attribute__((visibility("default"))) __attribute__((used))
int  _MacosNativeBindings_protocolTrampoline_4tbi0v(id target, void * sel, unsigned arg1) {
  return ((ProtocolTrampoline_44)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLTexture(void) { return @protocol(MTLTexture); }

typedef MTLHeapType  (^ProtocolTrampoline_45)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLHeapType  _MacosNativeBindings_protocolTrampoline_4lks1a(id target, void * sel) {
  return ((ProtocolTrampoline_45)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^ProtocolTrampoline_46)(void * sel, unsigned long arg1, MTLResourceOptions arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_1n9czk0(id target, void * sel, unsigned long arg1, MTLResourceOptions arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_46)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^ProtocolTrampoline_47)(void * sel, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_skjqxk(id target, void * sel, id arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_47)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLAccelerationStructure(void) { return @protocol(MTLAccelerationStructure); }

typedef id  (^ProtocolTrampoline_48)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_3nbx5e(id target, void * sel, unsigned long arg1) {
  return ((ProtocolTrampoline_48)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_49)(void * sel, unsigned long arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_9b3h4v(id target, void * sel, unsigned long arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_49)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLHeap(void) { return @protocol(MTLHeap); }

Protocol* _MacosNativeBindings_MTLResource(void) { return @protocol(MTLResource); }

typedef void *  (^ProtocolTrampoline_50)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
void *  _MacosNativeBindings_protocolTrampoline_3fl8pv(id target, void * sel) {
  return ((ProtocolTrampoline_50)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef id  (^ProtocolTrampoline_51)(void * sel, id arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_17gec3x(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_51)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_24)(void * arg0, id arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_24 _MacosNativeBindings_wrapListenerBlock_ayxzy9(ListenerTrampoline_24 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct _NSRange arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^BlockingTrampoline_24)(void * waiter, void * arg0, id arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_24 _MacosNativeBindings_wrapBlockingBlock_ayxzy9(
    BlockingTrampoline_24 block, BlockingTrampoline_24 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct _NSRange arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^ProtocolTrampoline_52)(void * sel, id arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_ayxzy9(id target, void * sel, id arg1, struct _NSRange arg2) {
  return ((ProtocolTrampoline_52)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLBuffer(void) { return @protocol(MTLBuffer); }

typedef void  (^ListenerTrampoline_25)(void * arg0, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_25 _MacosNativeBindings_wrapListenerBlock_wy9lus(ListenerTrampoline_25 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^BlockingTrampoline_25)(void * waiter, void * arg0, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_25 _MacosNativeBindings_wrapBlockingBlock_wy9lus(
    BlockingTrampoline_25 block, BlockingTrampoline_25 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^ProtocolTrampoline_53)(void * sel, id arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_wy9lus(id target, void * sel, id arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_53)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_26)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_26 _MacosNativeBindings_wrapListenerBlock_c2yeeh(ListenerTrampoline_26 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_26)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_26 _MacosNativeBindings_wrapBlockingBlock_c2yeeh(
    BlockingTrampoline_26 block, BlockingTrampoline_26 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_54)(void * sel, id arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_c2yeeh(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_54)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_27)(void * arg0, id * arg1, unsigned long * arg2, struct _NSRange arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_27 _MacosNativeBindings_wrapListenerBlock_1h1icfp(ListenerTrampoline_27 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, unsigned long * arg2, struct _NSRange arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_27)(void * waiter, void * arg0, id * arg1, unsigned long * arg2, struct _NSRange arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_27 _MacosNativeBindings_wrapBlockingBlock_1h1icfp(
    BlockingTrampoline_27 block, BlockingTrampoline_27 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, unsigned long * arg2, struct _NSRange arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_55)(void * sel, id * arg1, unsigned long * arg2, struct _NSRange arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1h1icfp(id target, void * sel, id * arg1, unsigned long * arg2, struct _NSRange arg3) {
  return ((ProtocolTrampoline_55)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_28)(void * arg0, id * arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_28 _MacosNativeBindings_wrapListenerBlock_1shg59k(ListenerTrampoline_28 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, struct _NSRange arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_28)(void * waiter, void * arg0, id * arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_28 _MacosNativeBindings_wrapBlockingBlock_1shg59k(
    BlockingTrampoline_28 block, BlockingTrampoline_28 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, struct _NSRange arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_56)(void * sel, id * arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1shg59k(id target, void * sel, id * arg1, struct _NSRange arg2) {
  return ((ProtocolTrampoline_56)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLSamplerState(void) { return @protocol(MTLSamplerState); }

typedef void *  (^ProtocolTrampoline_57)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
void *  _MacosNativeBindings_protocolTrampoline_1ot4dqk(id target, void * sel, unsigned long arg1) {
  return ((ProtocolTrampoline_57)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id  (^ProtocolTrampoline_58)(void * sel, id arg1, MTLRenderStages arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_mo5hqp(id target, void * sel, id arg1, MTLRenderStages arg2) {
  return ((ProtocolTrampoline_58)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLVisibleFunctionTable(void) { return @protocol(MTLVisibleFunctionTable); }

typedef void  (^ListenerTrampoline_29)(void * arg0, MTLIntersectionFunctionSignature arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_29 _MacosNativeBindings_wrapListenerBlock_10n0yx6(ListenerTrampoline_29 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLIntersectionFunctionSignature arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_29)(void * waiter, void * arg0, MTLIntersectionFunctionSignature arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_29 _MacosNativeBindings_wrapBlockingBlock_10n0yx6(
    BlockingTrampoline_29 block, BlockingTrampoline_29 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLIntersectionFunctionSignature arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_59)(void * sel, MTLIntersectionFunctionSignature arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_10n0yx6(id target, void * sel, MTLIntersectionFunctionSignature arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_59)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_30)(void * arg0, MTLIntersectionFunctionSignature arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_30 _MacosNativeBindings_wrapListenerBlock_10r47xz(ListenerTrampoline_30 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLIntersectionFunctionSignature arg1, struct _NSRange arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_30)(void * waiter, void * arg0, MTLIntersectionFunctionSignature arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_30 _MacosNativeBindings_wrapBlockingBlock_10r47xz(
    BlockingTrampoline_30 block, BlockingTrampoline_30 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLIntersectionFunctionSignature arg1, struct _NSRange arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_60)(void * sel, MTLIntersectionFunctionSignature arg1, struct _NSRange arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_10r47xz(id target, void * sel, MTLIntersectionFunctionSignature arg1, struct _NSRange arg2) {
  return ((ProtocolTrampoline_60)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLIntersectionFunctionTable(void) { return @protocol(MTLIntersectionFunctionTable); }

typedef id  (^ProtocolTrampoline_61)(void * sel, id arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_10s6poe(id target, void * sel, id arg1, id * arg2) {
  return ((ProtocolTrampoline_61)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef MTLShaderValidation  (^ProtocolTrampoline_62)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLShaderValidation  _MacosNativeBindings_protocolTrampoline_toica6(id target, void * sel) {
  return ((ProtocolTrampoline_62)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_MTLRenderPipelineState(void) { return @protocol(MTLRenderPipelineState); }

typedef void  (^ListenerTrampoline_31)(void * arg0, struct _NSRange arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_31 _MacosNativeBindings_wrapListenerBlock_xpqfd7(ListenerTrampoline_31 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, struct _NSRange arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_31)(void * waiter, void * arg0, struct _NSRange arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_31 _MacosNativeBindings_wrapBlockingBlock_xpqfd7(
    BlockingTrampoline_31 block, BlockingTrampoline_31 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, struct _NSRange arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_63)(void * sel, struct _NSRange arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_xpqfd7(id target, void * sel, struct _NSRange arg1) {
  return ((ProtocolTrampoline_63)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_32)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_32 _MacosNativeBindings_wrapListenerBlock_hnwr7m(ListenerTrampoline_32 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_32)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_32 _MacosNativeBindings_wrapBlockingBlock_hnwr7m(
    BlockingTrampoline_32 block, BlockingTrampoline_32 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_64)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_hnwr7m(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_64)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_33)(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, id arg8, unsigned long arg9, unsigned long arg10);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_33 _MacosNativeBindings_wrapListenerBlock_1uu7jhl(ListenerTrampoline_33 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, id arg8, unsigned long arg9, unsigned long arg10) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, (__bridge id)(__bridge_retained void*)(arg8), arg9, arg10);
  };
}

typedef void  (^BlockingTrampoline_33)(void * waiter, void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, id arg8, unsigned long arg9, unsigned long arg10);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_33 _MacosNativeBindings_wrapBlockingBlock_1uu7jhl(
    BlockingTrampoline_33 block, BlockingTrampoline_33 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, id arg8, unsigned long arg9, unsigned long arg10), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, (__bridge id)(__bridge_retained void*)(arg8), arg9, arg10);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, (__bridge id)(__bridge_retained void*)(arg8), arg9, arg10);
  });
}

typedef void  (^ProtocolTrampoline_65)(void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, id arg8, unsigned long arg9, unsigned long arg10);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1uu7jhl(id target, void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, id arg8, unsigned long arg9, unsigned long arg10) {
  return ((ProtocolTrampoline_65)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
}

typedef void  (^ListenerTrampoline_34)(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, id arg10, unsigned long arg11, unsigned long arg12);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_34 _MacosNativeBindings_wrapListenerBlock_zat2vc(ListenerTrampoline_34 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, id arg10, unsigned long arg11, unsigned long arg12) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, (__bridge id)(__bridge_retained void*)(arg10), arg11, arg12);
  };
}

typedef void  (^BlockingTrampoline_34)(void * waiter, void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, id arg10, unsigned long arg11, unsigned long arg12);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_34 _MacosNativeBindings_wrapBlockingBlock_zat2vc(
    BlockingTrampoline_34 block, BlockingTrampoline_34 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, id arg10, unsigned long arg11, unsigned long arg12), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, (__bridge id)(__bridge_retained void*)(arg10), arg11, arg12);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, (__bridge id)(__bridge_retained void*)(arg10), arg11, arg12);
  });
}

typedef void  (^ProtocolTrampoline_66)(void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, id arg10, unsigned long arg11, unsigned long arg12);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_zat2vc(id target, void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, id arg10, unsigned long arg11, unsigned long arg12) {
  return ((ProtocolTrampoline_66)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
}

typedef void  (^ListenerTrampoline_35)(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_35 _MacosNativeBindings_wrapListenerBlock_qtki81(ListenerTrampoline_35 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4, arg5);
  };
}

typedef void  (^BlockingTrampoline_35)(void * waiter, void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_35 _MacosNativeBindings_wrapBlockingBlock_qtki81(
    BlockingTrampoline_35 block, BlockingTrampoline_35 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4, arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4, arg5);
  });
}

typedef void  (^ProtocolTrampoline_67)(void * sel, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_qtki81(id target, void * sel, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, unsigned long arg5) {
  return ((ProtocolTrampoline_67)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_36)(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6, long arg7, unsigned long arg8);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_36 _MacosNativeBindings_wrapListenerBlock_5qa770(ListenerTrampoline_36 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6, long arg7, unsigned long arg8) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, arg8);
  };
}

typedef void  (^BlockingTrampoline_36)(void * waiter, void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6, long arg7, unsigned long arg8);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_36 _MacosNativeBindings_wrapBlockingBlock_5qa770(
    BlockingTrampoline_36 block, BlockingTrampoline_36 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6, long arg7, unsigned long arg8), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, arg8);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, arg8);
  });
}

typedef void  (^ProtocolTrampoline_68)(void * sel, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6, long arg7, unsigned long arg8);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_5qa770(id target, void * sel, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6, long arg7, unsigned long arg8) {
  return ((ProtocolTrampoline_68)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
}

typedef void  (^ListenerTrampoline_37)(void * arg0, unsigned long arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_37 _MacosNativeBindings_wrapListenerBlock_199s8vf(ListenerTrampoline_37 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_37)(void * waiter, void * arg0, unsigned long arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_37 _MacosNativeBindings_wrapBlockingBlock_199s8vf(
    BlockingTrampoline_37 block, BlockingTrampoline_37 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_69)(void * sel, unsigned long arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_199s8vf(id target, void * sel, unsigned long arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_69)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_38)(void * arg0, MTLSize arg1, MTLSize arg2, MTLSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_38 _MacosNativeBindings_wrapListenerBlock_105lrwx(ListenerTrampoline_38 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLSize arg1, MTLSize arg2, MTLSize arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_38)(void * waiter, void * arg0, MTLSize arg1, MTLSize arg2, MTLSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_38 _MacosNativeBindings_wrapBlockingBlock_105lrwx(
    BlockingTrampoline_38 block, BlockingTrampoline_38 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLSize arg1, MTLSize arg2, MTLSize arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_70)(void * sel, MTLSize arg1, MTLSize arg2, MTLSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_105lrwx(id target, void * sel, MTLSize arg1, MTLSize arg2, MTLSize arg3) {
  return ((ProtocolTrampoline_70)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

Protocol* _MacosNativeBindings_MTLIndirectRenderCommand(void) { return @protocol(MTLIndirectRenderCommand); }

typedef void  (^ListenerTrampoline_39)(void * arg0, MTLSize arg1, MTLSize arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_39 _MacosNativeBindings_wrapListenerBlock_c7d6f1(ListenerTrampoline_39 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLSize arg1, MTLSize arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_39)(void * waiter, void * arg0, MTLSize arg1, MTLSize arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_39 _MacosNativeBindings_wrapBlockingBlock_c7d6f1(
    BlockingTrampoline_39 block, BlockingTrampoline_39 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLSize arg1, MTLSize arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_71)(void * sel, MTLSize arg1, MTLSize arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_c7d6f1(id target, void * sel, MTLSize arg1, MTLSize arg2) {
  return ((ProtocolTrampoline_71)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_40)(void * arg0, MTLRegion arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_40 _MacosNativeBindings_wrapListenerBlock_1tph48i(ListenerTrampoline_40 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLRegion arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_40)(void * waiter, void * arg0, MTLRegion arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_40 _MacosNativeBindings_wrapBlockingBlock_1tph48i(
    BlockingTrampoline_40 block, BlockingTrampoline_40 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLRegion arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_72)(void * sel, MTLRegion arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1tph48i(id target, void * sel, MTLRegion arg1) {
  return ((ProtocolTrampoline_72)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLIndirectComputeCommand(void) { return @protocol(MTLIndirectComputeCommand); }

Protocol* _MacosNativeBindings_MTLIndirectCommandBuffer(void) { return @protocol(MTLIndirectCommandBuffer); }

Protocol* _MacosNativeBindings_MTLArgumentEncoder(void) { return @protocol(MTLArgumentEncoder); }

typedef id  (^ProtocolTrampoline_73)(void * sel, unsigned long arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_zxdjzr(id target, void * sel, unsigned long arg1, id * arg2) {
  return ((ProtocolTrampoline_73)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef MTLFunctionOptions  (^ProtocolTrampoline_74)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLFunctionOptions  _MacosNativeBindings_protocolTrampoline_1m1xpni(id target, void * sel) {
  return ((ProtocolTrampoline_74)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_MTLFunction(void) { return @protocol(MTLFunction); }

Protocol* _MacosNativeBindings_MTLComputePipelineState(void) { return @protocol(MTLComputePipelineState); }

typedef MTLCommandBufferErrorOption  (^ProtocolTrampoline_75)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLCommandBufferErrorOption  _MacosNativeBindings_protocolTrampoline_1uxsnii(id target, void * sel) {
  return ((ProtocolTrampoline_75)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef double  (^ProtocolTrampoline_76)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
double  _MacosNativeBindings_protocolTrampoline_tfvuzk(id target, void * sel) {
  return ((ProtocolTrampoline_76)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef unsigned long  (^ProtocolTrampoline_77)(void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _MacosNativeBindings_protocolTrampoline_17ap02x(id target, void * sel, NSFastEnumerationState * arg1, id * arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_77)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

Protocol* _MacosNativeBindings_MTLLogContainer(void) { return @protocol(MTLLogContainer); }

typedef void  (^ListenerTrampoline_41)(void * arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_41 _MacosNativeBindings_wrapListenerBlock_18sfmo2(ListenerTrampoline_41 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, double arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_41)(void * waiter, void * arg0, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_41 _MacosNativeBindings_wrapBlockingBlock_18sfmo2(
    BlockingTrampoline_41 block, BlockingTrampoline_41 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, double arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_78)(void * sel, double arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_18sfmo2(id target, void * sel, double arg1) {
  return ((ProtocolTrampoline_78)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLDrawable(void) { return @protocol(MTLDrawable); }

typedef void  (^ListenerTrampoline_42)(void * arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_42 _MacosNativeBindings_wrapListenerBlock_ve6f9k(ListenerTrampoline_42 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, double arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^BlockingTrampoline_42)(void * waiter, void * arg0, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_42 _MacosNativeBindings_wrapBlockingBlock_ve6f9k(
    BlockingTrampoline_42 block, BlockingTrampoline_42 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, double arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^ProtocolTrampoline_79)(void * sel, id arg1, double arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_ve6f9k(id target, void * sel, id arg1, double arg2) {
  return ((ProtocolTrampoline_79)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef MTLCommandBufferStatus  (^ProtocolTrampoline_80)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLCommandBufferStatus  _MacosNativeBindings_protocolTrampoline_ori513(id target, void * sel) {
  return ((ProtocolTrampoline_80)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^ListenerTrampoline_43)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_43 _MacosNativeBindings_wrapListenerBlock_1f5kuzx(ListenerTrampoline_43 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  };
}

typedef void  (^BlockingTrampoline_43)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_43 _MacosNativeBindings_wrapBlockingBlock_1f5kuzx(
    BlockingTrampoline_43 block, BlockingTrampoline_43 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  });
}

typedef void  (^ProtocolTrampoline_81)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1f5kuzx(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9) {
  return ((ProtocolTrampoline_81)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
}

typedef void  (^ListenerTrampoline_44)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_44 _MacosNativeBindings_wrapListenerBlock_1s77zcf(ListenerTrampoline_44 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  };
}

typedef void  (^BlockingTrampoline_44)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_44 _MacosNativeBindings_wrapBlockingBlock_1s77zcf(
    BlockingTrampoline_44 block, BlockingTrampoline_44 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  });
}

typedef void  (^ProtocolTrampoline_82)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1s77zcf(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9) {
  return ((ProtocolTrampoline_82)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
}

typedef void  (^ListenerTrampoline_45)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9, MTLBlitOption arg10);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_45 _MacosNativeBindings_wrapListenerBlock_1r81b3y(ListenerTrampoline_45 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9, MTLBlitOption arg10) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, arg10);
  };
}

typedef void  (^BlockingTrampoline_45)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9, MTLBlitOption arg10);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_45 _MacosNativeBindings_wrapBlockingBlock_1r81b3y(
    BlockingTrampoline_45 block, BlockingTrampoline_45 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9, MTLBlitOption arg10), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, arg10);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, arg10);
  });
}

typedef void  (^ProtocolTrampoline_83)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9, MTLBlitOption arg10);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1r81b3y(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, MTLOrigin arg9, MTLBlitOption arg10) {
  return ((ProtocolTrampoline_83)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
}

typedef void  (^ListenerTrampoline_46)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_46 _MacosNativeBindings_wrapListenerBlock_7p6m9j(ListenerTrampoline_46 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  };
}

typedef void  (^BlockingTrampoline_46)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_46 _MacosNativeBindings_wrapBlockingBlock_7p6m9j(
    BlockingTrampoline_46 block, BlockingTrampoline_46 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  });
}

typedef void  (^ProtocolTrampoline_84)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_7p6m9j(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9) {
  return ((ProtocolTrampoline_84)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
}

typedef void  (^ListenerTrampoline_47)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, MTLBlitOption arg10);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_47 _MacosNativeBindings_wrapListenerBlock_1i8704m(ListenerTrampoline_47 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, MTLBlitOption arg10) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, arg10);
  };
}

typedef void  (^BlockingTrampoline_47)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, MTLBlitOption arg10);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_47 _MacosNativeBindings_wrapBlockingBlock_1i8704m(
    BlockingTrampoline_47 block, BlockingTrampoline_47 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, MTLBlitOption arg10), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, arg10);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9, arg10);
  });
}

typedef void  (^ProtocolTrampoline_85)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, MTLBlitOption arg10);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1i8704m(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, MTLOrigin arg4, MTLSize arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9, MTLBlitOption arg10) {
  return ((ProtocolTrampoline_85)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10);
}

typedef void  (^ListenerTrampoline_48)(void * arg0, id arg1, struct _NSRange arg2, uint8_t arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_48 _MacosNativeBindings_wrapListenerBlock_gne7ki(ListenerTrampoline_48 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct _NSRange arg2, uint8_t arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_48)(void * waiter, void * arg0, id arg1, struct _NSRange arg2, uint8_t arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_48 _MacosNativeBindings_wrapBlockingBlock_gne7ki(
    BlockingTrampoline_48 block, BlockingTrampoline_48 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct _NSRange arg2, uint8_t arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_86)(void * sel, id arg1, struct _NSRange arg2, uint8_t arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_gne7ki(id target, void * sel, id arg1, struct _NSRange arg2, uint8_t arg3) {
  return ((ProtocolTrampoline_86)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_49)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, unsigned long arg8);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_49 _MacosNativeBindings_wrapListenerBlock_1pfumo3(ListenerTrampoline_49 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, unsigned long arg8) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, arg8);
  };
}

typedef void  (^BlockingTrampoline_49)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, unsigned long arg8);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_49 _MacosNativeBindings_wrapBlockingBlock_1pfumo3(
    BlockingTrampoline_49 block, BlockingTrampoline_49 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, unsigned long arg8), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, arg8);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7, arg8);
  });
}

typedef void  (^ProtocolTrampoline_87)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, unsigned long arg8);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1pfumo3(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7, unsigned long arg8) {
  return ((ProtocolTrampoline_87)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
}

typedef void  (^ListenerTrampoline_50)(void * arg0, id arg1, unsigned long arg2, id arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_50 _MacosNativeBindings_wrapListenerBlock_ld7540(ListenerTrampoline_50 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, id arg3, unsigned long arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4, arg5);
  };
}

typedef void  (^BlockingTrampoline_50)(void * waiter, void * arg0, id arg1, unsigned long arg2, id arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_50 _MacosNativeBindings_wrapBlockingBlock_ld7540(
    BlockingTrampoline_50 block, BlockingTrampoline_50 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, id arg3, unsigned long arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4, arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4, arg5);
  });
}

typedef void  (^ProtocolTrampoline_88)(void * sel, id arg1, unsigned long arg2, id arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_ld7540(id target, void * sel, id arg1, unsigned long arg2, id arg3, unsigned long arg4, unsigned long arg5) {
  return ((ProtocolTrampoline_88)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

Protocol* _MacosNativeBindings_MTLFence(void) { return @protocol(MTLFence); }

typedef void  (^ListenerTrampoline_51)(void * arg0, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4, BOOL arg5, id arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_51 _MacosNativeBindings_wrapListenerBlock_16t0ff9(ListenerTrampoline_51 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4, BOOL arg5, id arg6, unsigned long arg7) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7);
  };
}

typedef void  (^BlockingTrampoline_51)(void * waiter, void * arg0, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4, BOOL arg5, id arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_51 _MacosNativeBindings_wrapBlockingBlock_16t0ff9(
    BlockingTrampoline_51 block, BlockingTrampoline_51 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4, BOOL arg5, id arg6, unsigned long arg7), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7);
  });
}

typedef void  (^ProtocolTrampoline_89)(void * sel, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4, BOOL arg5, id arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_16t0ff9(id target, void * sel, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4, BOOL arg5, id arg6, unsigned long arg7) {
  return ((ProtocolTrampoline_89)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}

typedef void  (^ListenerTrampoline_52)(void * arg0, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_52 _MacosNativeBindings_wrapListenerBlock_149ux9u(ListenerTrampoline_52 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_52)(void * waiter, void * arg0, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_52 _MacosNativeBindings_wrapBlockingBlock_149ux9u(
    BlockingTrampoline_52 block, BlockingTrampoline_52 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_90)(void * sel, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_149ux9u(id target, void * sel, id arg1, MTLRegion arg2, unsigned long arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_90)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_53)(void * arg0, id arg1, struct _NSRange arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_53 _MacosNativeBindings_wrapListenerBlock_si2isw(ListenerTrampoline_53 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, struct _NSRange arg2, id arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^BlockingTrampoline_53)(void * waiter, void * arg0, id arg1, struct _NSRange arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_53 _MacosNativeBindings_wrapBlockingBlock_si2isw(
    BlockingTrampoline_53 block, BlockingTrampoline_53 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, struct _NSRange arg2, id arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^ProtocolTrampoline_91)(void * sel, id arg1, struct _NSRange arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_si2isw(id target, void * sel, id arg1, struct _NSRange arg2, id arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_91)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef id  (^ProtocolTrampoline_92)(void * sel, struct _NSRange arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_xzy3cf(id target, void * sel, struct _NSRange arg1) {
  return ((ProtocolTrampoline_92)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLCounterSampleBuffer(void) { return @protocol(MTLCounterSampleBuffer); }

typedef void  (^ListenerTrampoline_54)(void * arg0, id arg1, unsigned long arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_54 _MacosNativeBindings_wrapListenerBlock_1nyrrbs(ListenerTrampoline_54 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, BOOL arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_54)(void * waiter, void * arg0, id arg1, unsigned long arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_54 _MacosNativeBindings_wrapBlockingBlock_1nyrrbs(
    BlockingTrampoline_54 block, BlockingTrampoline_54 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, BOOL arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_93)(void * sel, id arg1, unsigned long arg2, BOOL arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1nyrrbs(id target, void * sel, id arg1, unsigned long arg2, BOOL arg3) {
  return ((ProtocolTrampoline_93)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

Protocol* _MacosNativeBindings_MTLBlitCommandEncoder(void) { return @protocol(MTLBlitCommandEncoder); }

typedef void  (^ListenerTrampoline_55)(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_55 _MacosNativeBindings_wrapListenerBlock_e4uq9v(ListenerTrampoline_55 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_55)(void * waiter, void * arg0, void * arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_55 _MacosNativeBindings_wrapBlockingBlock_e4uq9v(
    BlockingTrampoline_55 block, BlockingTrampoline_55 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_94)(void * sel, void * arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_e4uq9v(id target, void * sel, void * arg1, unsigned long arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_94)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_56)(void * arg0, id * arg1, unsigned long * arg2, unsigned long * arg3, struct _NSRange arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_56 _MacosNativeBindings_wrapListenerBlock_1ed8s3e(ListenerTrampoline_56 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, unsigned long * arg2, unsigned long * arg3, struct _NSRange arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_56)(void * waiter, void * arg0, id * arg1, unsigned long * arg2, unsigned long * arg3, struct _NSRange arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_56 _MacosNativeBindings_wrapBlockingBlock_1ed8s3e(
    BlockingTrampoline_56 block, BlockingTrampoline_56 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, unsigned long * arg2, unsigned long * arg3, struct _NSRange arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_95)(void * sel, id * arg1, unsigned long * arg2, unsigned long * arg3, struct _NSRange arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1ed8s3e(id target, void * sel, id * arg1, unsigned long * arg2, unsigned long * arg3, struct _NSRange arg4) {
  return ((ProtocolTrampoline_95)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_57)(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_57 _MacosNativeBindings_wrapListenerBlock_1oog5zo(ListenerTrampoline_57 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_57)(void * waiter, void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_57 _MacosNativeBindings_wrapBlockingBlock_1oog5zo(
    BlockingTrampoline_57 block, BlockingTrampoline_57 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_96)(void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1oog5zo(id target, void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_96)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_58)(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_58 _MacosNativeBindings_wrapListenerBlock_jnydkc(ListenerTrampoline_58 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_58)(void * waiter, void * arg0, void * arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_58 _MacosNativeBindings_wrapBlockingBlock_jnydkc(
    BlockingTrampoline_58 block, BlockingTrampoline_58 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, void * arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_97)(void * sel, void * arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_jnydkc(id target, void * sel, void * arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_97)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_59)(void * arg0, id arg1, float arg2, float arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_59 _MacosNativeBindings_wrapListenerBlock_17z3y9o(ListenerTrampoline_59 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, float arg2, float arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_59)(void * waiter, void * arg0, id arg1, float arg2, float arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_59 _MacosNativeBindings_wrapBlockingBlock_17z3y9o(
    BlockingTrampoline_59 block, BlockingTrampoline_59 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, float arg2, float arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_98)(void * sel, id arg1, float arg2, float arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_17z3y9o(id target, void * sel, id arg1, float arg2, float arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_98)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_60)(void * arg0, id * arg1, float * arg2, float * arg3, struct _NSRange arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_60 _MacosNativeBindings_wrapListenerBlock_tx2gfc(ListenerTrampoline_60 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, float * arg2, float * arg3, struct _NSRange arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_60)(void * waiter, void * arg0, id * arg1, float * arg2, float * arg3, struct _NSRange arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_60 _MacosNativeBindings_wrapBlockingBlock_tx2gfc(
    BlockingTrampoline_60 block, BlockingTrampoline_60 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, float * arg2, float * arg3, struct _NSRange arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_99)(void * sel, id * arg1, float * arg2, float * arg3, struct _NSRange arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_tx2gfc(id target, void * sel, id * arg1, float * arg2, float * arg3, struct _NSRange arg4) {
  return ((ProtocolTrampoline_99)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_61)(void * arg0, MTLViewport arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_61 _MacosNativeBindings_wrapListenerBlock_u4fi78(ListenerTrampoline_61 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLViewport arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_61)(void * waiter, void * arg0, MTLViewport arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_61 _MacosNativeBindings_wrapBlockingBlock_u4fi78(
    BlockingTrampoline_61 block, BlockingTrampoline_61 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLViewport arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_100)(void * sel, MTLViewport arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_u4fi78(id target, void * sel, MTLViewport arg1) {
  return ((ProtocolTrampoline_100)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_62)(void * arg0, MTLViewport * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_62 _MacosNativeBindings_wrapListenerBlock_14nbhij(ListenerTrampoline_62 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLViewport * arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_62)(void * waiter, void * arg0, MTLViewport * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_62 _MacosNativeBindings_wrapBlockingBlock_14nbhij(
    BlockingTrampoline_62 block, BlockingTrampoline_62 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLViewport * arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_101)(void * sel, MTLViewport * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_14nbhij(id target, void * sel, MTLViewport * arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_101)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_63)(void * arg0, MTLWinding arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_63 _MacosNativeBindings_wrapListenerBlock_2mr18g(ListenerTrampoline_63 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLWinding arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_63)(void * waiter, void * arg0, MTLWinding arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_63 _MacosNativeBindings_wrapBlockingBlock_2mr18g(
    BlockingTrampoline_63 block, BlockingTrampoline_63 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLWinding arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_102)(void * sel, MTLWinding arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_2mr18g(id target, void * sel, MTLWinding arg1) {
  return ((ProtocolTrampoline_102)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_64)(void * arg0, unsigned long arg1, MTLVertexAmplificationViewMapping * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_64 _MacosNativeBindings_wrapListenerBlock_10qn0pm(ListenerTrampoline_64 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, MTLVertexAmplificationViewMapping * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_64)(void * waiter, void * arg0, unsigned long arg1, MTLVertexAmplificationViewMapping * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_64 _MacosNativeBindings_wrapBlockingBlock_10qn0pm(
    BlockingTrampoline_64 block, BlockingTrampoline_64 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, MTLVertexAmplificationViewMapping * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_103)(void * sel, unsigned long arg1, MTLVertexAmplificationViewMapping * arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_10qn0pm(id target, void * sel, unsigned long arg1, MTLVertexAmplificationViewMapping * arg2) {
  return ((ProtocolTrampoline_103)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_65)(void * arg0, MTLCullMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_65 _MacosNativeBindings_wrapListenerBlock_1vmf5v7(ListenerTrampoline_65 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLCullMode arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_65)(void * waiter, void * arg0, MTLCullMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_65 _MacosNativeBindings_wrapBlockingBlock_1vmf5v7(
    BlockingTrampoline_65 block, BlockingTrampoline_65 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLCullMode arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_104)(void * sel, MTLCullMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1vmf5v7(id target, void * sel, MTLCullMode arg1) {
  return ((ProtocolTrampoline_104)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_66)(void * arg0, MTLDepthClipMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_66 _MacosNativeBindings_wrapListenerBlock_145pifa(ListenerTrampoline_66 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLDepthClipMode arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_66)(void * waiter, void * arg0, MTLDepthClipMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_66 _MacosNativeBindings_wrapBlockingBlock_145pifa(
    BlockingTrampoline_66 block, BlockingTrampoline_66 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLDepthClipMode arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_105)(void * sel, MTLDepthClipMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_145pifa(id target, void * sel, MTLDepthClipMode arg1) {
  return ((ProtocolTrampoline_105)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_67)(void * arg0, float arg1, float arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_67 _MacosNativeBindings_wrapListenerBlock_hb35y5(ListenerTrampoline_67 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, float arg1, float arg2, float arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_67)(void * waiter, void * arg0, float arg1, float arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_67 _MacosNativeBindings_wrapBlockingBlock_hb35y5(
    BlockingTrampoline_67 block, BlockingTrampoline_67 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, float arg1, float arg2, float arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_106)(void * sel, float arg1, float arg2, float arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_hb35y5(id target, void * sel, float arg1, float arg2, float arg3) {
  return ((ProtocolTrampoline_106)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_68)(void * arg0, MTLScissorRect arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_68 _MacosNativeBindings_wrapListenerBlock_1udoslm(ListenerTrampoline_68 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLScissorRect arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_68)(void * waiter, void * arg0, MTLScissorRect arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_68 _MacosNativeBindings_wrapBlockingBlock_1udoslm(
    BlockingTrampoline_68 block, BlockingTrampoline_68 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLScissorRect arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_107)(void * sel, MTLScissorRect arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1udoslm(id target, void * sel, MTLScissorRect arg1) {
  return ((ProtocolTrampoline_107)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_69)(void * arg0, MTLScissorRect * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_69 _MacosNativeBindings_wrapListenerBlock_1onpil1(ListenerTrampoline_69 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLScissorRect * arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_69)(void * waiter, void * arg0, MTLScissorRect * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_69 _MacosNativeBindings_wrapBlockingBlock_1onpil1(
    BlockingTrampoline_69 block, BlockingTrampoline_69 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLScissorRect * arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_108)(void * sel, MTLScissorRect * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1onpil1(id target, void * sel, MTLScissorRect * arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_108)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_70)(void * arg0, MTLTriangleFillMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_70 _MacosNativeBindings_wrapListenerBlock_2ds1co(ListenerTrampoline_70 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLTriangleFillMode arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_70)(void * waiter, void * arg0, MTLTriangleFillMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_70 _MacosNativeBindings_wrapBlockingBlock_2ds1co(
    BlockingTrampoline_70 block, BlockingTrampoline_70 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLTriangleFillMode arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_109)(void * sel, MTLTriangleFillMode arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_2ds1co(id target, void * sel, MTLTriangleFillMode arg1) {
  return ((ProtocolTrampoline_109)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_71)(void * arg0, float arg1, float arg2, float arg3, float arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_71 _MacosNativeBindings_wrapListenerBlock_i67yw5(ListenerTrampoline_71 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, float arg1, float arg2, float arg3, float arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_71)(void * waiter, void * arg0, float arg1, float arg2, float arg3, float arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_71 _MacosNativeBindings_wrapBlockingBlock_i67yw5(
    BlockingTrampoline_71 block, BlockingTrampoline_71 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, float arg1, float arg2, float arg3, float arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_110)(void * sel, float arg1, float arg2, float arg3, float arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_i67yw5(id target, void * sel, float arg1, float arg2, float arg3, float arg4) {
  return ((ProtocolTrampoline_110)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

Protocol* _MacosNativeBindings_MTLDepthStencilState(void) { return @protocol(MTLDepthStencilState); }

typedef void  (^ListenerTrampoline_72)(void * arg0, uint32_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_72 _MacosNativeBindings_wrapListenerBlock_wjoxwn(ListenerTrampoline_72 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, uint32_t arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_72)(void * waiter, void * arg0, uint32_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_72 _MacosNativeBindings_wrapBlockingBlock_wjoxwn(
    BlockingTrampoline_72 block, BlockingTrampoline_72 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, uint32_t arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_111)(void * sel, uint32_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_wjoxwn(id target, void * sel, uint32_t arg1) {
  return ((ProtocolTrampoline_111)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_73)(void * arg0, uint32_t arg1, uint32_t arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_73 _MacosNativeBindings_wrapListenerBlock_1og8d8h(ListenerTrampoline_73 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, uint32_t arg1, uint32_t arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_73)(void * waiter, void * arg0, uint32_t arg1, uint32_t arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_73 _MacosNativeBindings_wrapBlockingBlock_1og8d8h(
    BlockingTrampoline_73 block, BlockingTrampoline_73 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, uint32_t arg1, uint32_t arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_112)(void * sel, uint32_t arg1, uint32_t arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1og8d8h(id target, void * sel, uint32_t arg1, uint32_t arg2) {
  return ((ProtocolTrampoline_112)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_74)(void * arg0, MTLVisibilityResultMode arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_74 _MacosNativeBindings_wrapListenerBlock_1qjbcfl(ListenerTrampoline_74 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLVisibilityResultMode arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_74)(void * waiter, void * arg0, MTLVisibilityResultMode arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_74 _MacosNativeBindings_wrapBlockingBlock_1qjbcfl(
    BlockingTrampoline_74 block, BlockingTrampoline_74 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLVisibilityResultMode arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_113)(void * sel, MTLVisibilityResultMode arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1qjbcfl(id target, void * sel, MTLVisibilityResultMode arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_113)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_75)(void * arg0, MTLStoreAction arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_75 _MacosNativeBindings_wrapListenerBlock_15fd6bo(ListenerTrampoline_75 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLStoreAction arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_75)(void * waiter, void * arg0, MTLStoreAction arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_75 _MacosNativeBindings_wrapBlockingBlock_15fd6bo(
    BlockingTrampoline_75 block, BlockingTrampoline_75 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLStoreAction arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_114)(void * sel, MTLStoreAction arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_15fd6bo(id target, void * sel, MTLStoreAction arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_114)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_76)(void * arg0, MTLStoreAction arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_76 _MacosNativeBindings_wrapListenerBlock_p2yddn(ListenerTrampoline_76 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLStoreAction arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_76)(void * waiter, void * arg0, MTLStoreAction arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_76 _MacosNativeBindings_wrapBlockingBlock_p2yddn(
    BlockingTrampoline_76 block, BlockingTrampoline_76 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLStoreAction arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_115)(void * sel, MTLStoreAction arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_p2yddn(id target, void * sel, MTLStoreAction arg1) {
  return ((ProtocolTrampoline_115)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_77)(void * arg0, MTLStoreActionOptions arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_77 _MacosNativeBindings_wrapListenerBlock_c89s3g(ListenerTrampoline_77 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLStoreActionOptions arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_77)(void * waiter, void * arg0, MTLStoreActionOptions arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_77 _MacosNativeBindings_wrapBlockingBlock_c89s3g(
    BlockingTrampoline_77 block, BlockingTrampoline_77 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLStoreActionOptions arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_116)(void * sel, MTLStoreActionOptions arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_c89s3g(id target, void * sel, MTLStoreActionOptions arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_116)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_78)(void * arg0, MTLStoreActionOptions arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_78 _MacosNativeBindings_wrapListenerBlock_19ca9v7(ListenerTrampoline_78 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLStoreActionOptions arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_78)(void * waiter, void * arg0, MTLStoreActionOptions arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_78 _MacosNativeBindings_wrapBlockingBlock_19ca9v7(
    BlockingTrampoline_78 block, BlockingTrampoline_78 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLStoreActionOptions arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_117)(void * sel, MTLStoreActionOptions arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_19ca9v7(id target, void * sel, MTLStoreActionOptions arg1) {
  return ((ProtocolTrampoline_117)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_79)(void * arg0, id arg1, unsigned long arg2, MTLSize arg3, MTLSize arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_79 _MacosNativeBindings_wrapListenerBlock_mdjwdg(ListenerTrampoline_79 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, MTLSize arg3, MTLSize arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_79)(void * waiter, void * arg0, id arg1, unsigned long arg2, MTLSize arg3, MTLSize arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_79 _MacosNativeBindings_wrapBlockingBlock_mdjwdg(
    BlockingTrampoline_79 block, BlockingTrampoline_79 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, MTLSize arg3, MTLSize arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_118)(void * sel, id arg1, unsigned long arg2, MTLSize arg3, MTLSize arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_mdjwdg(id target, void * sel, id arg1, unsigned long arg2, MTLSize arg3, MTLSize arg4) {
  return ((ProtocolTrampoline_118)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_80)(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_80 _MacosNativeBindings_wrapListenerBlock_1n7kxlo(ListenerTrampoline_80 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_80)(void * waiter, void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_80 _MacosNativeBindings_wrapBlockingBlock_1n7kxlo(
    BlockingTrampoline_80 block, BlockingTrampoline_80 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_119)(void * sel, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1n7kxlo(id target, void * sel, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_119)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_81)(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_81 _MacosNativeBindings_wrapListenerBlock_eyddsj(ListenerTrampoline_81 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_81)(void * waiter, void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_81 _MacosNativeBindings_wrapBlockingBlock_eyddsj(
    BlockingTrampoline_81 block, BlockingTrampoline_81 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_120)(void * sel, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_eyddsj(id target, void * sel, MTLPrimitiveType arg1, unsigned long arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_120)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_82)(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_82 _MacosNativeBindings_wrapListenerBlock_17ahrkx(ListenerTrampoline_82 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6);
  };
}

typedef void  (^BlockingTrampoline_82)(void * waiter, void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_82 _MacosNativeBindings_wrapBlockingBlock_17ahrkx(
    BlockingTrampoline_82 block, BlockingTrampoline_82 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6);
  });
}

typedef void  (^ProtocolTrampoline_121)(void * sel, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_17ahrkx(id target, void * sel, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5, unsigned long arg6) {
  return ((ProtocolTrampoline_121)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef void  (^ListenerTrampoline_83)(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_83 _MacosNativeBindings_wrapListenerBlock_iw3rgc(ListenerTrampoline_83 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  };
}

typedef void  (^BlockingTrampoline_83)(void * waiter, void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_83 _MacosNativeBindings_wrapBlockingBlock_iw3rgc(
    BlockingTrampoline_83 block, BlockingTrampoline_83 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  });
}

typedef void  (^ProtocolTrampoline_122)(void * sel, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_iw3rgc(id target, void * sel, MTLPrimitiveType arg1, unsigned long arg2, MTLIndexType arg3, id arg4, unsigned long arg5) {
  return ((ProtocolTrampoline_122)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_84)(void * arg0, MTLPrimitiveType arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_84 _MacosNativeBindings_wrapListenerBlock_ib7igs(ListenerTrampoline_84 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLPrimitiveType arg1, id arg2, unsigned long arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^BlockingTrampoline_84)(void * waiter, void * arg0, MTLPrimitiveType arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_84 _MacosNativeBindings_wrapBlockingBlock_ib7igs(
    BlockingTrampoline_84 block, BlockingTrampoline_84 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLPrimitiveType arg1, id arg2, unsigned long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^ProtocolTrampoline_123)(void * sel, MTLPrimitiveType arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_ib7igs(id target, void * sel, MTLPrimitiveType arg1, id arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_123)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_85)(void * arg0, MTLPrimitiveType arg1, MTLIndexType arg2, id arg3, unsigned long arg4, id arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_85 _MacosNativeBindings_wrapListenerBlock_8o2638(ListenerTrampoline_85 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLPrimitiveType arg1, MTLIndexType arg2, id arg3, unsigned long arg4, id arg5, unsigned long arg6) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4, (__bridge id)(__bridge_retained void*)(arg5), arg6);
  };
}

typedef void  (^BlockingTrampoline_85)(void * waiter, void * arg0, MTLPrimitiveType arg1, MTLIndexType arg2, id arg3, unsigned long arg4, id arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_85 _MacosNativeBindings_wrapBlockingBlock_8o2638(
    BlockingTrampoline_85 block, BlockingTrampoline_85 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLPrimitiveType arg1, MTLIndexType arg2, id arg3, unsigned long arg4, id arg5, unsigned long arg6), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4, (__bridge id)(__bridge_retained void*)(arg5), arg6);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4, (__bridge id)(__bridge_retained void*)(arg5), arg6);
  });
}

typedef void  (^ProtocolTrampoline_124)(void * sel, MTLPrimitiveType arg1, MTLIndexType arg2, id arg3, unsigned long arg4, id arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_8o2638(id target, void * sel, MTLPrimitiveType arg1, MTLIndexType arg2, id arg3, unsigned long arg4, id arg5, unsigned long arg6) {
  return ((ProtocolTrampoline_124)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef void  (^ListenerTrampoline_86)(void * arg0, id arg1, MTLRenderStages arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_86 _MacosNativeBindings_wrapListenerBlock_1baco99(ListenerTrampoline_86 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLRenderStages arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^BlockingTrampoline_86)(void * waiter, void * arg0, id arg1, MTLRenderStages arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_86 _MacosNativeBindings_wrapBlockingBlock_1baco99(
    BlockingTrampoline_86 block, BlockingTrampoline_86 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLRenderStages arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^ProtocolTrampoline_125)(void * sel, id arg1, MTLRenderStages arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1baco99(id target, void * sel, id arg1, MTLRenderStages arg2) {
  return ((ProtocolTrampoline_125)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_87)(void * arg0, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_87 _MacosNativeBindings_wrapListenerBlock_1fcaigd(ListenerTrampoline_87 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, float arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_87)(void * waiter, void * arg0, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_87 _MacosNativeBindings_wrapBlockingBlock_1fcaigd(
    BlockingTrampoline_87 block, BlockingTrampoline_87 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, float arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_126)(void * sel, float arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1fcaigd(id target, void * sel, float arg1) {
  return ((ProtocolTrampoline_126)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_88)(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_88 _MacosNativeBindings_wrapListenerBlock_mbxyo5(ListenerTrampoline_88 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7);
  };
}

typedef void  (^BlockingTrampoline_88)(void * waiter, void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_88 _MacosNativeBindings_wrapBlockingBlock_mbxyo5(
    BlockingTrampoline_88 block, BlockingTrampoline_88 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6, arg7);
  });
}

typedef void  (^ProtocolTrampoline_127)(void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_mbxyo5(id target, void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7) {
  return ((ProtocolTrampoline_127)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}

typedef void  (^ListenerTrampoline_89)(void * arg0, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_89 _MacosNativeBindings_wrapListenerBlock_1dwhg9c(ListenerTrampoline_89 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  };
}

typedef void  (^BlockingTrampoline_89)(void * waiter, void * arg0, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_89 _MacosNativeBindings_wrapBlockingBlock_1dwhg9c(
    BlockingTrampoline_89 block, BlockingTrampoline_89 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  });
}

typedef void  (^ProtocolTrampoline_128)(void * sel, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1dwhg9c(id target, void * sel, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5) {
  return ((ProtocolTrampoline_128)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_90)(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_90 _MacosNativeBindings_wrapListenerBlock_1dmhn7g(ListenerTrampoline_90 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  };
}

typedef void  (^BlockingTrampoline_90)(void * waiter, void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_90 _MacosNativeBindings_wrapBlockingBlock_1dmhn7g(
    BlockingTrampoline_90 block, BlockingTrampoline_90 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7, arg8, arg9);
  });
}

typedef void  (^ProtocolTrampoline_129)(void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1dmhn7g(id target, void * sel, unsigned long arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7, unsigned long arg8, unsigned long arg9) {
  return ((ProtocolTrampoline_129)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
}

typedef void  (^ListenerTrampoline_91)(void * arg0, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_91 _MacosNativeBindings_wrapListenerBlock_14lphdv(ListenerTrampoline_91 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7) {
    objc_retainBlock(block);
    block(arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7);
  };
}

typedef void  (^BlockingTrampoline_91)(void * waiter, void * arg0, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_91 _MacosNativeBindings_wrapBlockingBlock_14lphdv(
    BlockingTrampoline_91 block, BlockingTrampoline_91 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, (__bridge id)(__bridge_retained void*)(arg2), arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5, (__bridge id)(__bridge_retained void*)(arg6), arg7);
  });
}

typedef void  (^ProtocolTrampoline_130)(void * sel, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_14lphdv(id target, void * sel, unsigned long arg1, id arg2, unsigned long arg3, id arg4, unsigned long arg5, id arg6, unsigned long arg7) {
  return ((ProtocolTrampoline_130)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}

typedef void  (^ListenerTrampoline_92)(void * arg0, MTLSize arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_92 _MacosNativeBindings_wrapListenerBlock_q1bpy1(ListenerTrampoline_92 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLSize arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_92)(void * waiter, void * arg0, MTLSize arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_92 _MacosNativeBindings_wrapBlockingBlock_q1bpy1(
    BlockingTrampoline_92 block, BlockingTrampoline_92 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLSize arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_131)(void * sel, MTLSize arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_q1bpy1(id target, void * sel, MTLSize arg1) {
  return ((ProtocolTrampoline_131)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_93)(void * arg0, id arg1, MTLResourceUsage arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_93 _MacosNativeBindings_wrapListenerBlock_2ehcc9(ListenerTrampoline_93 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLResourceUsage arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^BlockingTrampoline_93)(void * waiter, void * arg0, id arg1, MTLResourceUsage arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_93 _MacosNativeBindings_wrapBlockingBlock_2ehcc9(
    BlockingTrampoline_93 block, BlockingTrampoline_93 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLResourceUsage arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^ProtocolTrampoline_132)(void * sel, id arg1, MTLResourceUsage arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_2ehcc9(id target, void * sel, id arg1, MTLResourceUsage arg2) {
  return ((ProtocolTrampoline_132)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_94)(void * arg0, id * arg1, unsigned long arg2, MTLResourceUsage arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_94 _MacosNativeBindings_wrapListenerBlock_13hogjj(ListenerTrampoline_94 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, unsigned long arg2, MTLResourceUsage arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_94)(void * waiter, void * arg0, id * arg1, unsigned long arg2, MTLResourceUsage arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_94 _MacosNativeBindings_wrapBlockingBlock_13hogjj(
    BlockingTrampoline_94 block, BlockingTrampoline_94 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, unsigned long arg2, MTLResourceUsage arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_133)(void * sel, id * arg1, unsigned long arg2, MTLResourceUsage arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_13hogjj(id target, void * sel, id * arg1, unsigned long arg2, MTLResourceUsage arg3) {
  return ((ProtocolTrampoline_133)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_95)(void * arg0, id arg1, MTLResourceUsage arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_95 _MacosNativeBindings_wrapListenerBlock_48hp1z(ListenerTrampoline_95 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLResourceUsage arg2, MTLRenderStages arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_95)(void * waiter, void * arg0, id arg1, MTLResourceUsage arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_95 _MacosNativeBindings_wrapBlockingBlock_48hp1z(
    BlockingTrampoline_95 block, BlockingTrampoline_95 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLResourceUsage arg2, MTLRenderStages arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_134)(void * sel, id arg1, MTLResourceUsage arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_48hp1z(id target, void * sel, id arg1, MTLResourceUsage arg2, MTLRenderStages arg3) {
  return ((ProtocolTrampoline_134)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_96)(void * arg0, id * arg1, unsigned long arg2, MTLResourceUsage arg3, MTLRenderStages arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_96 _MacosNativeBindings_wrapListenerBlock_k165m9(ListenerTrampoline_96 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, unsigned long arg2, MTLResourceUsage arg3, MTLRenderStages arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_96)(void * waiter, void * arg0, id * arg1, unsigned long arg2, MTLResourceUsage arg3, MTLRenderStages arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_96 _MacosNativeBindings_wrapBlockingBlock_k165m9(
    BlockingTrampoline_96 block, BlockingTrampoline_96 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, unsigned long arg2, MTLResourceUsage arg3, MTLRenderStages arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_135)(void * sel, id * arg1, unsigned long arg2, MTLResourceUsage arg3, MTLRenderStages arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_k165m9(id target, void * sel, id * arg1, unsigned long arg2, MTLResourceUsage arg3, MTLRenderStages arg4) {
  return ((ProtocolTrampoline_135)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_97)(void * arg0, id * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_97 _MacosNativeBindings_wrapListenerBlock_1050wct(ListenerTrampoline_97 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_97)(void * waiter, void * arg0, id * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_97 _MacosNativeBindings_wrapBlockingBlock_1050wct(
    BlockingTrampoline_97 block, BlockingTrampoline_97 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_136)(void * sel, id * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1050wct(id target, void * sel, id * arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_136)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_98)(void * arg0, id * arg1, unsigned long arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_98 _MacosNativeBindings_wrapListenerBlock_1vnvqqj(ListenerTrampoline_98 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, unsigned long arg2, MTLRenderStages arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_98)(void * waiter, void * arg0, id * arg1, unsigned long arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_98 _MacosNativeBindings_wrapBlockingBlock_1vnvqqj(
    BlockingTrampoline_98 block, BlockingTrampoline_98 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, unsigned long arg2, MTLRenderStages arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_137)(void * sel, id * arg1, unsigned long arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1vnvqqj(id target, void * sel, id * arg1, unsigned long arg2, MTLRenderStages arg3) {
  return ((ProtocolTrampoline_137)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_99)(void * arg0, id arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_99 _MacosNativeBindings_wrapListenerBlock_2xx4dm(ListenerTrampoline_99 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, unsigned long arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  };
}

typedef void  (^BlockingTrampoline_99)(void * waiter, void * arg0, id arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_99 _MacosNativeBindings_wrapBlockingBlock_2xx4dm(
    BlockingTrampoline_99 block, BlockingTrampoline_99 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, unsigned long arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3);
  });
}

typedef void  (^ProtocolTrampoline_138)(void * sel, id arg1, id arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_2xx4dm(id target, void * sel, id arg1, id arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_138)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_100)(void * arg0, MTLBarrierScope arg1, MTLRenderStages arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_100 _MacosNativeBindings_wrapListenerBlock_1dwjah9(ListenerTrampoline_100 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLBarrierScope arg1, MTLRenderStages arg2, MTLRenderStages arg3) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_100)(void * waiter, void * arg0, MTLBarrierScope arg1, MTLRenderStages arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_100 _MacosNativeBindings_wrapBlockingBlock_1dwjah9(
    BlockingTrampoline_100 block, BlockingTrampoline_100 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLBarrierScope arg1, MTLRenderStages arg2, MTLRenderStages arg3), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_139)(void * sel, MTLBarrierScope arg1, MTLRenderStages arg2, MTLRenderStages arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1dwjah9(id target, void * sel, MTLBarrierScope arg1, MTLRenderStages arg2, MTLRenderStages arg3) {
  return ((ProtocolTrampoline_139)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_101)(void * arg0, id * arg1, unsigned long arg2, MTLRenderStages arg3, MTLRenderStages arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_101 _MacosNativeBindings_wrapListenerBlock_1pzwcgd(ListenerTrampoline_101 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id * arg1, unsigned long arg2, MTLRenderStages arg3, MTLRenderStages arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_101)(void * waiter, void * arg0, id * arg1, unsigned long arg2, MTLRenderStages arg3, MTLRenderStages arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_101 _MacosNativeBindings_wrapBlockingBlock_1pzwcgd(
    BlockingTrampoline_101 block, BlockingTrampoline_101 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id * arg1, unsigned long arg2, MTLRenderStages arg3, MTLRenderStages arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_140)(void * sel, id * arg1, unsigned long arg2, MTLRenderStages arg3, MTLRenderStages arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1pzwcgd(id target, void * sel, id * arg1, unsigned long arg2, MTLRenderStages arg3, MTLRenderStages arg4) {
  return ((ProtocolTrampoline_140)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

Protocol* _MacosNativeBindings_MTLRenderCommandEncoder(void) { return @protocol(MTLRenderCommandEncoder); }

typedef MTLSizeAndAlign  (^ProtocolTrampoline_141)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLSizeAndAlign  _MacosNativeBindings_protocolTrampoline_nplw35(id target, void * sel) {
  return ((ProtocolTrampoline_141)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLSize  (^ProtocolTrampoline_142)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
MTLSize  _MacosNativeBindings_protocolTrampoline_1phsu60(id target, void * sel, unsigned long arg1) {
  return ((ProtocolTrampoline_142)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef MTLSamplePosition  (^ProtocolTrampoline_143)(void * sel, MTLSamplePosition arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
MTLSamplePosition  _MacosNativeBindings_protocolTrampoline_1wv7urk(id target, void * sel, MTLSamplePosition arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_143)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLRasterizationRateMap(void) { return @protocol(MTLRasterizationRateMap); }

typedef MTLDispatchType  (^ProtocolTrampoline_144)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLDispatchType  _MacosNativeBindings_protocolTrampoline_1n4cnoy(id target, void * sel) {
  return ((ProtocolTrampoline_144)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef void  (^ListenerTrampoline_102)(void * arg0, id arg1, unsigned long arg2, MTLSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_102 _MacosNativeBindings_wrapListenerBlock_pvhrnu(ListenerTrampoline_102 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, MTLSize arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  };
}

typedef void  (^BlockingTrampoline_102)(void * waiter, void * arg0, id arg1, unsigned long arg2, MTLSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_102 _MacosNativeBindings_wrapBlockingBlock_pvhrnu(
    BlockingTrampoline_102 block, BlockingTrampoline_102 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, MTLSize arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3);
  });
}

typedef void  (^ProtocolTrampoline_145)(void * sel, id arg1, unsigned long arg2, MTLSize arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_pvhrnu(id target, void * sel, id arg1, unsigned long arg2, MTLSize arg3) {
  return ((ProtocolTrampoline_145)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_103)(void * arg0, MTLBarrierScope arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_103 _MacosNativeBindings_wrapListenerBlock_uhmkct(ListenerTrampoline_103 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLBarrierScope arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_103)(void * waiter, void * arg0, MTLBarrierScope arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_103 _MacosNativeBindings_wrapBlockingBlock_uhmkct(
    BlockingTrampoline_103 block, BlockingTrampoline_103 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLBarrierScope arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_146)(void * sel, MTLBarrierScope arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_uhmkct(id target, void * sel, MTLBarrierScope arg1) {
  return ((ProtocolTrampoline_146)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLComputeCommandEncoder(void) { return @protocol(MTLComputeCommandEncoder); }

typedef id  (^ProtocolTrampoline_147)(void * sel, MTLDispatchType arg1);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_1vuldgw(id target, void * sel, MTLDispatchType arg1) {
  return ((ProtocolTrampoline_147)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLEvent(void) { return @protocol(MTLEvent); }

typedef void  (^ListenerTrampoline_104)(void * arg0, id arg1, uint64_t arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_104 _MacosNativeBindings_wrapListenerBlock_10o24io(ListenerTrampoline_104 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, uint64_t arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  };
}

typedef void  (^BlockingTrampoline_104)(void * waiter, void * arg0, id arg1, uint64_t arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_104 _MacosNativeBindings_wrapBlockingBlock_10o24io(
    BlockingTrampoline_104 block, BlockingTrampoline_104 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, uint64_t arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2);
  });
}

typedef void  (^ProtocolTrampoline_148)(void * sel, id arg1, uint64_t arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_10o24io(id target, void * sel, id arg1, uint64_t arg2) {
  return ((ProtocolTrampoline_148)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLParallelRenderCommandEncoder(void) { return @protocol(MTLParallelRenderCommandEncoder); }

typedef void  (^ListenerTrampoline_105)(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion * arg3, unsigned long * arg4, unsigned long * arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_105 _MacosNativeBindings_wrapListenerBlock_1oqxone(ListenerTrampoline_105 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion * arg3, unsigned long * arg4, unsigned long * arg5, unsigned long arg6) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, arg6);
  };
}

typedef void  (^BlockingTrampoline_105)(void * waiter, void * arg0, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion * arg3, unsigned long * arg4, unsigned long * arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_105 _MacosNativeBindings_wrapBlockingBlock_1oqxone(
    BlockingTrampoline_105 block, BlockingTrampoline_105 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion * arg3, unsigned long * arg4, unsigned long * arg5, unsigned long arg6), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, arg6);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, arg6);
  });
}

typedef void  (^ProtocolTrampoline_149)(void * sel, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion * arg3, unsigned long * arg4, unsigned long * arg5, unsigned long arg6);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1oqxone(id target, void * sel, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion * arg3, unsigned long * arg4, unsigned long * arg5, unsigned long arg6) {
  return ((ProtocolTrampoline_149)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef void  (^ListenerTrampoline_106)(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_106 _MacosNativeBindings_wrapListenerBlock_kfbtuv(ListenerTrampoline_106 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion arg3, unsigned long arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5);
  };
}

typedef void  (^BlockingTrampoline_106)(void * waiter, void * arg0, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_106 _MacosNativeBindings_wrapBlockingBlock_kfbtuv(
    BlockingTrampoline_106 block, BlockingTrampoline_106 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion arg3, unsigned long arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5);
  });
}

typedef void  (^ProtocolTrampoline_150)(void * sel, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion arg3, unsigned long arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_kfbtuv(id target, void * sel, id arg1, MTLSparseTextureMappingMode arg2, MTLRegion arg3, unsigned long arg4, unsigned long arg5) {
  return ((ProtocolTrampoline_150)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_107)(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_107 _MacosNativeBindings_wrapListenerBlock_1owq0hf(ListenerTrampoline_107 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, id arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^BlockingTrampoline_107)(void * waiter, void * arg0, id arg1, MTLSparseTextureMappingMode arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_107 _MacosNativeBindings_wrapBlockingBlock_1owq0hf(
    BlockingTrampoline_107 block, BlockingTrampoline_107 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLSparseTextureMappingMode arg2, id arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^ProtocolTrampoline_151)(void * sel, id arg1, MTLSparseTextureMappingMode arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1owq0hf(id target, void * sel, id arg1, MTLSparseTextureMappingMode arg2, id arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_151)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

Protocol* _MacosNativeBindings_MTLResourceStateCommandEncoder(void) { return @protocol(MTLResourceStateCommandEncoder); }

typedef void  (^ListenerTrampoline_108)(void * arg0, id arg1, id arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_108 _MacosNativeBindings_wrapListenerBlock_1oxtwsg(ListenerTrampoline_108 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^BlockingTrampoline_108)(void * waiter, void * arg0, id arg1, id arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_108 _MacosNativeBindings_wrapBlockingBlock_1oxtwsg(
    BlockingTrampoline_108 block, BlockingTrampoline_108 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^ProtocolTrampoline_152)(void * sel, id arg1, id arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1oxtwsg(id target, void * sel, id arg1, id arg2, id arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_152)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_109)(void * arg0, id arg1, id arg2, id arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_109 _MacosNativeBindings_wrapListenerBlock_7j0gnq(ListenerTrampoline_109 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5);
  };
}

typedef void  (^BlockingTrampoline_109)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_109 _MacosNativeBindings_wrapBlockingBlock_7j0gnq(
    BlockingTrampoline_109 block, BlockingTrampoline_109 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5);
  });
}

typedef void  (^ProtocolTrampoline_153)(void * sel, id arg1, id arg2, id arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_7j0gnq(id target, void * sel, id arg1, id arg2, id arg3, id arg4, unsigned long arg5) {
  return ((ProtocolTrampoline_153)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_110)(void * arg0, id arg1, id arg2, id arg3, id arg4, unsigned long arg5, MTLAccelerationStructureRefitOptions arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_110 _MacosNativeBindings_wrapListenerBlock_1xwbdv4(ListenerTrampoline_110 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, unsigned long arg5, MTLAccelerationStructureRefitOptions arg6) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6);
  };
}

typedef void  (^BlockingTrampoline_110)(void * waiter, void * arg0, id arg1, id arg2, id arg3, id arg4, unsigned long arg5, MTLAccelerationStructureRefitOptions arg6);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_110 _MacosNativeBindings_wrapBlockingBlock_1xwbdv4(
    BlockingTrampoline_110 block, BlockingTrampoline_110 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, id arg3, id arg4, unsigned long arg5, MTLAccelerationStructureRefitOptions arg6), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), (__bridge id)(__bridge_retained void*)(arg3), (__bridge id)(__bridge_retained void*)(arg4), arg5, arg6);
  });
}

typedef void  (^ProtocolTrampoline_154)(void * sel, id arg1, id arg2, id arg3, id arg4, unsigned long arg5, MTLAccelerationStructureRefitOptions arg6);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1xwbdv4(id target, void * sel, id arg1, id arg2, id arg3, id arg4, unsigned long arg5, MTLAccelerationStructureRefitOptions arg6) {
  return ((ProtocolTrampoline_154)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6);
}

typedef void  (^ListenerTrampoline_111)(void * arg0, id arg1, id arg2, unsigned long arg3, MTLDataType arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_111 _MacosNativeBindings_wrapListenerBlock_qoprjb(ListenerTrampoline_111 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2, unsigned long arg3, MTLDataType arg4) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_111)(void * waiter, void * arg0, id arg1, id arg2, unsigned long arg3, MTLDataType arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_111 _MacosNativeBindings_wrapBlockingBlock_qoprjb(
    BlockingTrampoline_111 block, BlockingTrampoline_111 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2, unsigned long arg3, MTLDataType arg4), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), (__bridge id)(__bridge_retained void*)(arg2), arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_155)(void * sel, id arg1, id arg2, unsigned long arg3, MTLDataType arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_qoprjb(id target, void * sel, id arg1, id arg2, unsigned long arg3, MTLDataType arg4) {
  return ((ProtocolTrampoline_155)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

Protocol* _MacosNativeBindings_MTLAccelerationStructureCommandEncoder(void) { return @protocol(MTLAccelerationStructureCommandEncoder); }

typedef BOOL  (^ProtocolTrampoline_156)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_3su7tt(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_156)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLResidencySet(void) { return @protocol(MTLResidencySet); }

Protocol* _MacosNativeBindings_MTLCommandBuffer(void) { return @protocol(MTLCommandBuffer); }

Protocol* _MacosNativeBindings_MTLCommandQueue(void) { return @protocol(MTLCommandQueue); }

typedef MTLSizeAndAlign  (^ProtocolTrampoline_157)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
MTLSizeAndAlign  _MacosNativeBindings_protocolTrampoline_1jrpy3r(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_157)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef MTLSizeAndAlign  (^ProtocolTrampoline_158)(void * sel, unsigned long arg1, MTLResourceOptions arg2);
__attribute__((visibility("default"))) __attribute__((used))
MTLSizeAndAlign  _MacosNativeBindings_protocolTrampoline_1x5wkbj(id target, void * sel, unsigned long arg1, MTLResourceOptions arg2) {
  return ((ProtocolTrampoline_158)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^ProtocolTrampoline_159)(void * sel, void * arg1, unsigned long arg2, MTLResourceOptions arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_1wsspof(id target, void * sel, void * arg1, unsigned long arg2, MTLResourceOptions arg3) {
  return ((ProtocolTrampoline_159)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_112)(void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_112 _MacosNativeBindings_wrapListenerBlock_zuf90e(ListenerTrampoline_112 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, unsigned long arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_112)(void * waiter, void * arg0, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_112 _MacosNativeBindings_wrapBlockingBlock_zuf90e(
    BlockingTrampoline_112 block, BlockingTrampoline_112 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, unsigned long arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef id  (^ProtocolTrampoline_160)(void * sel, void * arg1, unsigned long arg2, MTLResourceOptions arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_qvsazo(id target, void * sel, void * arg1, unsigned long arg2, MTLResourceOptions arg3, id arg4) {
  return ((ProtocolTrampoline_160)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef id  (^ProtocolTrampoline_161)(void * sel, id arg1, struct __IOSurface * arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_1ynlvay(id target, void * sel, id arg1, struct __IOSurface * arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_161)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef id  (^ProtocolTrampoline_162)(void * sel, id arg1, id arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_10z9f5k(id target, void * sel, id arg1, id arg2, id * arg3) {
  return ((ProtocolTrampoline_162)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_113)(void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_113 _MacosNativeBindings_wrapListenerBlock_jk1ljc(ListenerTrampoline_113 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, id arg2) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  };
}

typedef void  (^BlockingTrampoline_113)(void * waiter, void * arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_113 _MacosNativeBindings_wrapBlockingBlock_jk1ljc(
    BlockingTrampoline_113 block, BlockingTrampoline_113 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, id arg2), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), objc_retainBlock(arg2));
  });
}

typedef void  (^ProtocolTrampoline_163)(void * sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_jk1ljc(id target, void * sel, id arg1, id arg2) {
  return ((ProtocolTrampoline_163)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef MTLLibraryType  (^ProtocolTrampoline_164)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLLibraryType  _MacosNativeBindings_protocolTrampoline_s1qd2h(id target, void * sel) {
  return ((ProtocolTrampoline_164)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_MTLLibrary(void) { return @protocol(MTLLibrary); }

typedef id  (^ProtocolTrampoline_165)(void * sel, id arg1, MTLPipelineOption arg2, id * arg3, id * arg4);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_s8j3g9(id target, void * sel, id arg1, MTLPipelineOption arg2, id * arg3, id * arg4) {
  return ((ProtocolTrampoline_165)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_114)(void * arg0, id arg1, MTLPipelineOption arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_114 _MacosNativeBindings_wrapListenerBlock_1vpepiy(ListenerTrampoline_114 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, MTLPipelineOption arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, objc_retainBlock(arg3));
  };
}

typedef void  (^BlockingTrampoline_114)(void * waiter, void * arg0, id arg1, MTLPipelineOption arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_114 _MacosNativeBindings_wrapBlockingBlock_1vpepiy(
    BlockingTrampoline_114 block, BlockingTrampoline_114 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, MTLPipelineOption arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, objc_retainBlock(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, objc_retainBlock(arg3));
  });
}

typedef void  (^ProtocolTrampoline_166)(void * sel, id arg1, MTLPipelineOption arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1vpepiy(id target, void * sel, id arg1, MTLPipelineOption arg2, id arg3) {
  return ((ProtocolTrampoline_166)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^ProtocolTrampoline_167)(void * sel, MTLFeatureSet arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_9bgrl6(id target, void * sel, MTLFeatureSet arg1) {
  return ((ProtocolTrampoline_167)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^ProtocolTrampoline_168)(void * sel, MTLGPUFamily arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_o3i15y(id target, void * sel, MTLGPUFamily arg1) {
  return ((ProtocolTrampoline_168)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^ProtocolTrampoline_169)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_15ssoz8(id target, void * sel, unsigned long arg1) {
  return ((ProtocolTrampoline_169)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef unsigned long  (^ProtocolTrampoline_170)(void * sel, MTLPixelFormat arg1);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _MacosNativeBindings_protocolTrampoline_10cl8qu(id target, void * sel, MTLPixelFormat arg1) {
  return ((ProtocolTrampoline_170)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef void  (^ListenerTrampoline_115)(void * arg0, MTLSamplePosition * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_115 _MacosNativeBindings_wrapListenerBlock_2klnj8(ListenerTrampoline_115 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLSamplePosition * arg1, unsigned long arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_115)(void * waiter, void * arg0, MTLSamplePosition * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_115 _MacosNativeBindings_wrapBlockingBlock_2klnj8(
    BlockingTrampoline_115 block, BlockingTrampoline_115 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLSamplePosition * arg1, unsigned long arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_171)(void * sel, MTLSamplePosition * arg1, unsigned long arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_2klnj8(id target, void * sel, MTLSamplePosition * arg1, unsigned long arg2) {
  return ((ProtocolTrampoline_171)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id  (^ProtocolTrampoline_172)(void * sel, id arg1, unsigned long arg2, MTLResourceOptions arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_1pwmu1(id target, void * sel, id arg1, unsigned long arg2, MTLResourceOptions arg3) {
  return ((ProtocolTrampoline_172)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_116)(id arg0, uint64_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_116 _MacosNativeBindings_wrapListenerBlock_dzdejc(ListenerTrampoline_116 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, uint64_t arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void*)(arg0), arg1);
  };
}

typedef void  (^BlockingTrampoline_116)(void * waiter, id arg0, uint64_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_116 _MacosNativeBindings_wrapBlockingBlock_dzdejc(
    BlockingTrampoline_116 block, BlockingTrampoline_116 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(id arg0, uint64_t arg1), {
    objc_retainBlock(block);
    block(nil, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, (__bridge id)(__bridge_retained void*)(arg0), arg1);
  });
}

typedef void  (^ListenerTrampoline_117)(void * arg0, id arg1, uint64_t arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_117 _MacosNativeBindings_wrapListenerBlock_10udern(ListenerTrampoline_117 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, uint64_t arg2, id arg3) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, objc_retainBlock(arg3));
  };
}

typedef void  (^BlockingTrampoline_117)(void * waiter, void * arg0, id arg1, uint64_t arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_117 _MacosNativeBindings_wrapBlockingBlock_10udern(
    BlockingTrampoline_117 block, BlockingTrampoline_117 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, uint64_t arg2, id arg3), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, objc_retainBlock(arg3));
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, objc_retainBlock(arg3));
  });
}

typedef void  (^ProtocolTrampoline_173)(void * sel, id arg1, uint64_t arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_10udern(id target, void * sel, id arg1, uint64_t arg2, id arg3) {
  return ((ProtocolTrampoline_173)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef BOOL  (^ProtocolTrampoline_174)(void * sel, uint64_t arg1, uint64_t arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_19jrxa7(id target, void * sel, uint64_t arg1, uint64_t arg2) {
  return ((ProtocolTrampoline_174)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void  (^ListenerTrampoline_118)(void * arg0, uint64_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_118 _MacosNativeBindings_wrapListenerBlock_1d4g4wu(ListenerTrampoline_118 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, uint64_t arg1) {
    objc_retainBlock(block);
    block(arg0, arg1);
  };
}

typedef void  (^BlockingTrampoline_118)(void * waiter, void * arg0, uint64_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_118 _MacosNativeBindings_wrapBlockingBlock_1d4g4wu(
    BlockingTrampoline_118 block, BlockingTrampoline_118 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, uint64_t arg1), {
    objc_retainBlock(block);
    block(nil, arg0, arg1);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1);
  });
}

typedef void  (^ProtocolTrampoline_175)(void * sel, uint64_t arg1);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1d4g4wu(id target, void * sel, uint64_t arg1) {
  return ((ProtocolTrampoline_175)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLSharedEvent(void) { return @protocol(MTLSharedEvent); }

Protocol* _MacosNativeBindings_MTLIOFileHandle(void) { return @protocol(MTLIOFileHandle); }

typedef void  (^ListenerTrampoline_119)(void * arg0, void * arg1, unsigned long arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_119 _MacosNativeBindings_wrapListenerBlock_jpad1l(ListenerTrampoline_119 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, void * arg1, unsigned long arg2, id arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  };
}

typedef void  (^BlockingTrampoline_119)(void * waiter, void * arg0, void * arg1, unsigned long arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_119 _MacosNativeBindings_wrapBlockingBlock_jpad1l(
    BlockingTrampoline_119 block, BlockingTrampoline_119 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, void * arg1, unsigned long arg2, id arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, (__bridge id)(__bridge_retained void*)(arg3), arg4);
  });
}

typedef void  (^ProtocolTrampoline_176)(void * sel, void * arg1, unsigned long arg2, id arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_jpad1l(id target, void * sel, void * arg1, unsigned long arg2, id arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_176)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef void  (^ListenerTrampoline_120)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_120 _MacosNativeBindings_wrapListenerBlock_1klfs94(ListenerTrampoline_120 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  };
}

typedef void  (^BlockingTrampoline_120)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_120 _MacosNativeBindings_wrapBlockingBlock_1klfs94(
    BlockingTrampoline_120 block, BlockingTrampoline_120 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, (__bridge id)(__bridge_retained void*)(arg4), arg5);
  });
}

typedef void  (^ProtocolTrampoline_177)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_1klfs94(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, id arg4, unsigned long arg5) {
  return ((ProtocolTrampoline_177)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_121)(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLSize arg4, unsigned long arg5, unsigned long arg6, MTLOrigin arg7, id arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_121 _MacosNativeBindings_wrapListenerBlock_psk36x(ListenerTrampoline_121 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLSize arg4, unsigned long arg5, unsigned long arg6, MTLOrigin arg7, id arg8, unsigned long arg9) {
    objc_retainBlock(block);
    block(arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, arg6, arg7, (__bridge id)(__bridge_retained void*)(arg8), arg9);
  };
}

typedef void  (^BlockingTrampoline_121)(void * waiter, void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLSize arg4, unsigned long arg5, unsigned long arg6, MTLOrigin arg7, id arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_121 _MacosNativeBindings_wrapBlockingBlock_psk36x(
    BlockingTrampoline_121 block, BlockingTrampoline_121 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, id arg1, unsigned long arg2, unsigned long arg3, MTLSize arg4, unsigned long arg5, unsigned long arg6, MTLOrigin arg7, id arg8, unsigned long arg9), {
    objc_retainBlock(block);
    block(nil, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, arg6, arg7, (__bridge id)(__bridge_retained void*)(arg8), arg9);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, (__bridge id)(__bridge_retained void*)(arg1), arg2, arg3, arg4, arg5, arg6, arg7, (__bridge id)(__bridge_retained void*)(arg8), arg9);
  });
}

typedef void  (^ProtocolTrampoline_178)(void * sel, id arg1, unsigned long arg2, unsigned long arg3, MTLSize arg4, unsigned long arg5, unsigned long arg6, MTLOrigin arg7, id arg8, unsigned long arg9);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_psk36x(id target, void * sel, id arg1, unsigned long arg2, unsigned long arg3, MTLSize arg4, unsigned long arg5, unsigned long arg6, MTLOrigin arg7, id arg8, unsigned long arg9) {
  return ((ProtocolTrampoline_178)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9);
}

typedef MTLIOStatus  (^ProtocolTrampoline_179)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLIOStatus  _MacosNativeBindings_protocolTrampoline_1hwx3bi(id target, void * sel) {
  return ((ProtocolTrampoline_179)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_MTLIOCommandBuffer(void) { return @protocol(MTLIOCommandBuffer); }

Protocol* _MacosNativeBindings_MTLIOCommandQueue(void) { return @protocol(MTLIOCommandQueue); }

Protocol* _MacosNativeBindings_MTLIOScratchBuffer(void) { return @protocol(MTLIOScratchBuffer); }

Protocol* _MacosNativeBindings_MTLIOScratchBufferAllocator(void) { return @protocol(MTLIOScratchBufferAllocator); }

typedef id  (^ProtocolTrampoline_180)(void * sel, id arg1, MTLIOCompressionMethod arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
id  _MacosNativeBindings_protocolTrampoline_ttdcgo(id target, void * sel, id arg1, MTLIOCompressionMethod arg2, id * arg3) {
  return ((ProtocolTrampoline_180)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef MTLSize  (^ProtocolTrampoline_181)(void * sel, MTLTextureType arg1, MTLPixelFormat arg2, unsigned long arg3);
__attribute__((visibility("default"))) __attribute__((used))
MTLSize  _MacosNativeBindings_protocolTrampoline_1oj3nt4(id target, void * sel, MTLTextureType arg1, MTLPixelFormat arg2, unsigned long arg3) {
  return ((ProtocolTrampoline_181)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

typedef void  (^ListenerTrampoline_122)(void * arg0, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, MTLSparseTextureRegionAlignmentMode arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_122 _MacosNativeBindings_wrapListenerBlock_2b3bq6(ListenerTrampoline_122 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, MTLSparseTextureRegionAlignmentMode arg4, unsigned long arg5) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4, arg5);
  };
}

typedef void  (^BlockingTrampoline_122)(void * waiter, void * arg0, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, MTLSparseTextureRegionAlignmentMode arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_122 _MacosNativeBindings_wrapBlockingBlock_2b3bq6(
    BlockingTrampoline_122 block, BlockingTrampoline_122 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, MTLSparseTextureRegionAlignmentMode arg4, unsigned long arg5), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4, arg5);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4, arg5);
  });
}

typedef void  (^ProtocolTrampoline_182)(void * sel, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, MTLSparseTextureRegionAlignmentMode arg4, unsigned long arg5);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_2b3bq6(id target, void * sel, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, MTLSparseTextureRegionAlignmentMode arg4, unsigned long arg5) {
  return ((ProtocolTrampoline_182)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4, arg5);
}

typedef void  (^ListenerTrampoline_123)(void * arg0, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_123 _MacosNativeBindings_wrapListenerBlock_mtqqh0(ListenerTrampoline_123 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, unsigned long arg4) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2, arg3, arg4);
  };
}

typedef void  (^BlockingTrampoline_123)(void * waiter, void * arg0, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_123 _MacosNativeBindings_wrapBlockingBlock_mtqqh0(
    BlockingTrampoline_123 block, BlockingTrampoline_123 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, unsigned long arg4), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2, arg3, arg4);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2, arg3, arg4);
  });
}

typedef void  (^ProtocolTrampoline_183)(void * sel, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, unsigned long arg4);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_mtqqh0(id target, void * sel, MTLRegion * arg1, MTLRegion * arg2, MTLSize arg3, unsigned long arg4) {
  return ((ProtocolTrampoline_183)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef unsigned long  (^ProtocolTrampoline_184)(void * sel, MTLSparsePageSize arg1);
__attribute__((visibility("default"))) __attribute__((used))
unsigned long  _MacosNativeBindings_protocolTrampoline_p2u2t7(id target, void * sel, MTLSparsePageSize arg1) {
  return ((ProtocolTrampoline_184)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef MTLSize  (^ProtocolTrampoline_185)(void * sel, MTLTextureType arg1, MTLPixelFormat arg2, unsigned long arg3, MTLSparsePageSize arg4);
__attribute__((visibility("default"))) __attribute__((used))
MTLSize  _MacosNativeBindings_protocolTrampoline_mzj6v3(id target, void * sel, MTLTextureType arg1, MTLPixelFormat arg2, unsigned long arg3, MTLSparsePageSize arg4) {
  return ((ProtocolTrampoline_185)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

Protocol* _MacosNativeBindings_MTLCounterSet(void) { return @protocol(MTLCounterSet); }

typedef void  (^ListenerTrampoline_124)(void * arg0, uint64_t * arg1, uint64_t * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_124 _MacosNativeBindings_wrapListenerBlock_oyxpvl(ListenerTrampoline_124 block) NS_RETURNS_RETAINED {
  return ^void(void * arg0, uint64_t * arg1, uint64_t * arg2) {
    objc_retainBlock(block);
    block(arg0, arg1, arg2);
  };
}

typedef void  (^BlockingTrampoline_124)(void * waiter, void * arg0, uint64_t * arg1, uint64_t * arg2);
__attribute__((visibility("default"))) __attribute__((used))
ListenerTrampoline_124 _MacosNativeBindings_wrapBlockingBlock_oyxpvl(
    BlockingTrampoline_124 block, BlockingTrampoline_124 listenerBlock,
    DOBJC_Context* ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(ctx, ^void(void * arg0, uint64_t * arg1, uint64_t * arg2), {
    objc_retainBlock(block);
    block(nil, arg0, arg1, arg2);
  }, {
    objc_retainBlock(listenerBlock);
    listenerBlock(waiter, arg0, arg1, arg2);
  });
}

typedef void  (^ProtocolTrampoline_186)(void * sel, uint64_t * arg1, uint64_t * arg2);
__attribute__((visibility("default"))) __attribute__((used))
void  _MacosNativeBindings_protocolTrampoline_oyxpvl(id target, void * sel, uint64_t * arg1, uint64_t * arg2) {
  return ((ProtocolTrampoline_186)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef MTLBindingType  (^ProtocolTrampoline_187)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLBindingType  _MacosNativeBindings_protocolTrampoline_o0wqtj(id target, void * sel) {
  return ((ProtocolTrampoline_187)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef MTLBindingAccess  (^ProtocolTrampoline_188)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLBindingAccess  _MacosNativeBindings_protocolTrampoline_vbnp4d(id target, void * sel) {
  return ((ProtocolTrampoline_188)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_MTLBinding(void) { return @protocol(MTLBinding); }

typedef MTLDataType  (^ProtocolTrampoline_189)(void * sel);
__attribute__((visibility("default"))) __attribute__((used))
MTLDataType  _MacosNativeBindings_protocolTrampoline_1yat1y8(id target, void * sel) {
  return ((ProtocolTrampoline_189)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

Protocol* _MacosNativeBindings_MTLBufferBinding(void) { return @protocol(MTLBufferBinding); }

typedef BOOL  (^ProtocolTrampoline_190)(void * sel, MTLCounterSamplingPoint arg1);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_1tv8jr(id target, void * sel, MTLCounterSamplingPoint arg1) {
  return ((ProtocolTrampoline_190)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL  (^ProtocolTrampoline_191)(void * sel, id arg1, id * arg2);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_joosg4(id target, void * sel, id arg1, id * arg2) {
  return ((ProtocolTrampoline_191)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

Protocol* _MacosNativeBindings_MTLDynamicLibrary(void) { return @protocol(MTLDynamicLibrary); }

typedef BOOL  (^ProtocolTrampoline_192)(void * sel, id arg1, id arg2, id * arg3);
__attribute__((visibility("default"))) __attribute__((used))
BOOL  _MacosNativeBindings_protocolTrampoline_oqebfq(id target, void * sel, id arg1, id arg2, id * arg3) {
  return ((ProtocolTrampoline_192)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

Protocol* _MacosNativeBindings_MTLBinaryArchive(void) { return @protocol(MTLBinaryArchive); }

typedef MTLAccelerationStructureSizes  (^ProtocolTrampoline_193)(void * sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used))
MTLAccelerationStructureSizes  _MacosNativeBindings_protocolTrampoline_2e8w9h(id target, void * sel, id arg1) {
  return ((ProtocolTrampoline_193)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef MTLSizeAndAlign  (^ProtocolTrampoline_194)(void * sel, unsigned long arg1);
__attribute__((visibility("default"))) __attribute__((used))
MTLSizeAndAlign  _MacosNativeBindings_protocolTrampoline_3kzaei(id target, void * sel, unsigned long arg1) {
  return ((ProtocolTrampoline_194)((id (*)(id, SEL, SEL))objc_msgSend)(target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

Protocol* _MacosNativeBindings_MTLDevice(void) { return @protocol(MTLDevice); }

Protocol* _MacosNativeBindings_MTLCommandEncoder(void) { return @protocol(MTLCommandEncoder); }

Protocol* _MacosNativeBindings_MTLCaptureScope(void) { return @protocol(MTLCaptureScope); }
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
