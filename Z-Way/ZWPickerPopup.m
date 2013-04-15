//
//  PickerInputTableViewCell.m
//  ShootStudio
//
//  Created by Tom Fewster on 18/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZWPickerPopup.h"

@implementation ZWPickerPopup

@synthesize picker;

- (void)initalizeInputView
{
	self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	self.picker.showsSelectionIndicator = YES;
	//self.picker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		UIViewController *popoverContent = [[UIViewController alloc] init];
		[popoverContent.view addSubview:self.picker];
		_popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
		_popoverController.delegate = self;
	}
    else
    {
        _backgroundTint = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundTint.backgroundColor = [UIColor blackColor];
        _backgroundTint.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
}


- (id)initWithParent:(UIView *)parent
{
    self = [super init];
    if (self)
    {
        _parent = parent;
		[self initalizeInputView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
		[self initalizeInputView];
    }
    return self;
}

- (UIView *)inputView
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		return nil;
	}
    else
    {
		return self.picker;
	}
}

- (UIView *)inputAccessoryView
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
		return nil;
	}
    else
    {
		if (_inputAccessoryView == nil)
        {
			_inputAccessoryView = [[UIToolbar alloc] init];
			_inputAccessoryView.barStyle = UIBarStyleBlackTranslucent;
			_inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			[_inputAccessoryView sizeToFit];
			CGRect frame = _inputAccessoryView.frame;
			frame.size.height = 44.0f;
			_inputAccessoryView.frame = frame;
			
			UIBarButtonItem *doneBtn =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
			UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			
			_inputAccessoryView.items = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
		}
		return _inputAccessoryView;
	}
}

- (void)done:(id)sender
{
	[self resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.picker sizeToFit];
        CGSize pickerSize = self.picker.frame.size;
        _popoverController.popoverContentSize = pickerSize;
        
        CGRect frame = _parent.bounds;
        frame = [self convertRect:frame fromView:_parent];
        
		[_popoverController presentPopoverFromRect:frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		// resign the current first responder
		for (UIView *subview in self.superview.subviews)
        {
			if ([subview isFirstResponder])
            {
				[subview resignFirstResponder];
			}
		}
		return NO;
	}
    else
    {
		[self.picker setNeedsLayout];
        
        UIView *superview = self.superview;
        
        _backgroundTint.frame = superview.bounds;
        _backgroundTint.alpha = 0;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        [superview addSubview:_backgroundTint];
        _backgroundTint.alpha = 0.3;
        
        [UIView commitAnimations];
	}
    
	return [super becomeFirstResponder];
}

- (void)resignAnimationEnded
{
    [_backgroundTint removeFromSuperview];
}

- (BOOL)resignFirstResponder
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(resignAnimationEnded)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        _backgroundTint.alpha = 0;
        
        [UIView commitAnimations];
    }
    
    [self performSelector:@selector(valueChanged) withObject:nil afterDelay:0.1];
    
	return [super resignFirstResponder];
}

- (void)deviceDidRotate:(NSNotification*)notification
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        CGRect frame = _parent.bounds;
        frame = [self convertRect:frame fromView:_parent];
        
		// we should only get this call if the popover is visible
		[_popoverController presentPopoverFromRect:frame inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
    else
    {
		[self.picker setNeedsLayout];
	}
}

- (void)valueChanged
{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark -
#pragma mark Respond to touch and become first responder.

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

#pragma mark -
#pragma mark UIKeyInput Protocol Methods

- (BOOL)hasText
{
	return YES;
}

- (void)insertText:(NSString *)theText
{
}

- (void)deleteBackward
{
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate Protocol Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self resignFirstResponder];
}

@end
