#import "Selection.h"
#import "RenderingState.h"


@implementation Selection

/* Rendering state represents opening (left) cap */
- (id)initWithStartState:(RenderingState *)state
{
	if ((self = [super init]))
	{
		initialState = [state copy];
	}
	return self;
}

/* Rendering state represents closing (right) cap */
- (void)finalizeWithState:(RenderingState *)state
{
	// Concatenate CTM onto text matrix
	transform = CGAffineTransformConcat([initialState textMatrix], [initialState ctm]);

	Font *openingFont = [initialState font];
	Font *closingFont = [state font];
	
	// Width (difference between caps) with text transformation removed
	CGFloat width = [state textMatrix].tx - [initialState textMatrix].tx;	
	width /= [state textMatrix].a;

	// Use tallest cap for entire selection
	CGFloat startHeight = [openingFont maxY] - [openingFont minY];
	CGFloat finishHeight = [closingFont maxY] - [closingFont minY];
	RenderingState *s = (startHeight > finishHeight) ? initialState : state;

	Font *font = [s font];
	FontDescriptor *descriptor = [font fontDescriptor];
	
	// Height is ascent plus (negative) descent
	CGFloat height = [s convertToUserSpace:(font.maxY - font.minY)];

	// Descent
	CGFloat descent = [s convertToUserSpace:descriptor.descent];

	// Selection frame in text space
	frame = CGRectMake(0, descent, width, height);
	
//	[initialState release]; initialState = nil;
}


#pragma mark - Memory Management


- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"<Selection frame:%@ transform:%@>", NSStringFromCGRect(frame), NSStringFromCGAffineTransform(transform)];
    return description;
}

@synthesize frame, transform;
@end
