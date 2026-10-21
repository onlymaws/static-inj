# Static Injector

A simple tool for statically loading dynamic libraries (`.dylib`) into macOS applications

## Usage

Import the header:

```objective-c
#import "DylibLoader.h"
```

Load a library:
```objective-c
DylibLoader *loader = [[DylibLoader alloc] init];
NSError *error = nil;

if ([loader loadLibraryAtPath:@"/path/to/library.dylib"
                        error:&error]) {
    NSLog(@"Library loaded!");
} else {
    NSLog(@"Error: %@", error.localizedDescription);
}
```

Unload the library when finished:
```objective-c
[loader unloadLibrary];
```
