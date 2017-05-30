//
//  VoipInputTextFieldBar.m
//  TouchPalDialer
//
//  Created by game3108 on 14-11-5.
//
//

#import "VoipInputTextFieldBar.h"
#import "CustomInputTextFiled.h"
#import "TPDialerResourceManager.h"
@interface VoipInputTextFieldBar() <UITextFieldDelegate>{
    CustomInputTextFiled *inputField;
    UIButton *textFiledButton;
    UIView *_middleLine;
}

@end

@implementation VoipInputTextFieldBar

- (id) initWithFrame:(CGRect)frame
         andLeftIcon:(UIImage*)leftIcon
      andPlaceHolder:(NSString*)placeHolder
               andID:(id)object{
    self = [super initWithFrame:frame];
    
    if (self){
        
        float y = leftIcon.size.height / leftIcon.size.width;
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(16, (56 - 26*y)/2, 26, 26*y)];
        iconView.image = leftIcon;
        [self addSubview:iconView];
        
        inputField = [[CustomInputTextFiled alloc] initWithFrame:CGRectMake( 60, 0, frame.size.width - 76, frame.size.height)
                                                  andPlaceHolder:placeHolder
                                                           andID:object];
        inputField.delegate = self;
        _middleLine = inputField.middleLine;
        [self addSubview:inputField];

        if ([object isKindOfClass:[NSString class]]){
            textFiledButton = [UIButton buttonWithType:UIButtonTypeCustom];
            textFiledButton.frame = CGRectMake( 0 , 0, 108, frame.size.height);
            [textFiledButton setTitle:(NSString *) object forState:UIControlStateNormal];
            textFiledButton.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3_5];
            [textFiledButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_normalbutton_normal_color"] forState:UIControlStateNormal];
            [textFiledButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_normalbutton_disable_color"] forState:UIControlStateDisabled];
            inputField.rightViewMode = UITextFieldViewModeAlways;
            inputField.rightView = textFiledButton;
            [textFiledButton addTarget:self action:@selector(onButtonAction) forControlEvents:UIControlEventTouchUpInside];
        }else if ([object isKindOfClass:[UIImage class]]){
            textFiledButton = [UIButton buttonWithType:UIButtonTypeCustom];
            textFiledButton.frame = CGRectMake( 0 , 0 , 72, frame.size.height);
            [textFiledButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_normalbutton_normal_color"] forState:UIControlStateNormal];
            [textFiledButton setTitleColor:[TPDialerResourceManager getColorForStyle:@"voip_normalbutton_disable_color"] forState:UIControlStateDisabled];
            [textFiledButton setBackgroundImage:(UIImage*)object forState:UIControlStateNormal];
            inputField.rightViewMode = UITextFieldViewModeAlways;
            inputField.rightView = textFiledButton;
            [textFiledButton addTarget:self action:@selector(onButtonAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        
    }
    
    return self;
}

- (void) onButtonAction{
    [_delegate onButtonAction];
}

- (UITextField *)getTextField{
    return inputField;
}

- (UIButton *) getTextFieldButton{
    return textFiledButton;
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    int MAX_CHARS = 14;
    
    NSMutableString *newtxt = [NSMutableString stringWithString:inputField.text];
    [newtxt replaceCharactersInRange:range withString:string];
    
    if (newtxt.length > MAX_CHARS){
        inputField.text = [newtxt substringToIndex:MAX_CHARS];
        return NO;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark keyboardShownObserverSelecter


- (void) keyboardWillBeShown:(NSNotification *) notification
{
    if ([inputField isFirstResponder]){
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        if (kbSize.height <= 0){
            return;
        }
        NSInteger contentOffset = _hostView.contentSize.height - _hostView.frame.size.height;
        [_hostView setContentOffset:CGPointMake(0, contentOffset)];
        CGRect oldFrame = _hostView.frame;
        if (kbSize.height > (TPScreenHeight() - _moveY + contentOffset) ){
            NSNumber *animationDurationNumber = (NSNumber *)[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
            CGFloat animationDuration = 0.0f;
            animationDuration = [animationDurationNumber floatValue];
            [UIView animateWithDuration:animationDuration animations:^{
                _hostView.frame = CGRectMake(oldFrame.origin.x,(TPScreenHeight() - _moveY + contentOffset) - kbSize.height, oldFrame.size.width , oldFrame.size.height);
            }];
            _hostView.scrollEnabled = NO;
        }
    }
}

- (void) keyboardWillBeHidden:(NSNotification *) notification
{
    if ([inputField isFirstResponder]){
        NSDictionary *userInfo = [notification userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        if (kbSize.height <= 0){
            return;
        }
        CGRect oldFrame = _hostView.frame;
        NSNumber *animationDurationNumber = (NSNumber *)[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
        [_hostView setContentOffset:CGPointMake(0, 0)];
        if (kbSize.height > (TPScreenHeight() - _moveY) ){
            CGFloat animationDuration = 0.0f;
            animationDuration = [animationDurationNumber floatValue];
            [UIView animateWithDuration:animationDuration animations:^{
                _hostView.frame = CGRectMake(oldFrame.origin.x, 0, oldFrame.size.width, oldFrame.size.height);
            }];
            _hostView.scrollEnabled = YES;
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
