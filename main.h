#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DylibLoader : NSObject

@property (nonatomic, assign, readonly, getter=isLoaded) BOOL loaded;

/// load it
- (BOOL)loadLibraryAtPath:(NSString *)path
                    error:(NSError * _Nullable * _Nullable)error;

- (nullable void *)symbolNamed:(NSString *)name
                         error:(NSError * _Nullable * _Nullable)error;

/// unload it
- (void)unloadLibrary;

@end

NS_ASSUME_NONNULL_END
