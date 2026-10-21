#import "DylibLoader.h"
#import <dlfcn.h>

static NSString * const DylibLoaderErrorDomain =
    @"com.example.DylibLoader";

typedef NS_ENUM(NSInteger, DylibLoaderErrorCode) {
    DylibLoaderErrorInvalidPath = 1,
    DylibLoaderErrorLoadFailed,
    DylibLoaderErrorNotLoaded,
    DylibLoaderErrorSymbolNotFound
};

@interface DylibLoader ()

@property (nonatomic, assign) void *handle;

@end

@implementation DylibLoader

- (BOOL)isLoaded {
    return self.handle != NULL;
}

- (BOOL)loadLibraryAtPath:(NSString *)path
                    error:(NSError **)error {
    if (path.length == 0 || !path.isAbsolutePath) {
        if (error) {
            *error = [NSError
                errorWithDomain:DylibLoaderErrorDomain
                code:DylibLoaderErrorInvalidPath
                userInfo:@{
                    NSLocalizedDescriptionKey:
                        @"provide an actual library path."
                }];
        }
        return NO;
    }

    if (self.handle != NULL) {
        [self unloadLibrary];
    }

    dlerror();

    self.handle = dlopen(
        path.fileSystemRepresentation,
        RTLD_NOW | RTLD_LOCAL
    );

    if (self.handle == NULL) {
        const char *message = dlerror();

        if (error) {
            *error = [NSError
                errorWithDomain:DylibLoaderErrorDomain
                code:DylibLoaderErrorLoadFailed
                userInfo:@{
                    NSLocalizedDescriptionKey:
                        message
                            ? [NSString stringWithUTF8String:message]
                            : @"unable to load the .dylib"
                }];
        }

        return NO;
    }

    return YES;
}

- (void *)symbolNamed:(NSString *)name
                error:(NSError **)error {
    if (self.handle == NULL) {
        if (error) {
            *error = [NSError
                errorWithDomain:DylibLoaderErrorDomain
                code:DylibLoaderErrorNotLoaded
                userInfo:@{
                    NSLocalizedDescriptionKey:
                        @"no .dylib is currently loaded"
                }];
        }
        return NULL;
    }

    if (name.length == 0) {
        if (error) {
            *error = [NSError
                errorWithDomain:DylibLoaderErrorDomain
                code:DylibLoaderErrorSymbolNotFound
                userInfo:@{
                    NSLocalizedDescriptionKey:
                        @"the symbol name cannot be empty."
                }];
        }
        return NULL;
    }

    dlerror();

    void *symbol = dlsym(self.handle, name.UTF8String);
    const char *message = dlerror();

    if (message != NULL) {
        if (error) {
            *error = [NSError
                errorWithDomain:DylibLoaderErrorDomain
                code:DylibLoaderErrorSymbolNotFound
                userInfo:@{
                    NSLocalizedDescriptionKey:
                        [NSString stringWithUTF8String:message]
                }];
        }
        return NULL;
    }

    return symbol;
}

- (void)unloadLibrary {
    if (self.handle != NULL) {
        dlclose(self.handle);
        self.handle = NULL;
    }
}

- (void)dealloc {
    [self unloadLibrary];
}

@end
