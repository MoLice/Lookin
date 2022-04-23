//
//  LookinDocument.m
//  Lookin
//
//  Created by Li Kai on 2019/6/26.
//  https://lookin.work
//

#import "LookinDocument.h"
#import "LookinHierarchyFile.h"
#import "LKReadWindowController.h"
#import "LKNavigationManager.h"

// 点击 menu 里的 “打开文件” 会走到这里的一系列方法
@implementation LookinDocument

- (void)makeWindowControllers {
    LKReadWindowController *wc = [[LKReadWindowController alloc] initWithFile:self.hierarchyFile];
    [self addWindowController:wc];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    if (!self.hierarchyFile) {
        NSAssert(NO, @"");
        if (outError) {
            *outError = LookinErr_Inner;
        }
        return nil;
    }
    
    if ([typeName isEqualToString:@"com.lookin.lookin"]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.hierarchyFile requiringSecureCoding:YES error:outError];
        return data;
    }
    
    if (outError) {
        *outError = LookinErr_Inner;
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {    
    NSError *unarchiveError = nil;
    LookinHierarchyFile *hierarchyFile = [NSKeyedUnarchiver unarchivedObjectOfClass:LookinHierarchyFile.class fromData:data error:&unarchiveError];
    
    if (unarchiveError) {
        NSLog(@"%@", unarchiveError);
        NSAssert(NO, @"存在没列到 unarchivedClasses 里的 Class，解码失败，请查看 Xcode 控制台输出的信息。");
        if (outError) {
            *outError = unarchiveError;
        }
        return NO;
    }
    
    NSError *verifyError = [LookinHierarchyFile verifyHierarchyFile:hierarchyFile];
    if (verifyError) {
        if (outError) {
            *outError = verifyError;
        }
        return NO;
    }

    self.hierarchyFile = hierarchyFile;
    return YES;
}

@end
