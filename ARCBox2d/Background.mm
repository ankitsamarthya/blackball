//
//  Background.m
//  ARCBox2d
//
//  Created by Ankit Samarthya on 10/08/13.
//
//

#import "Background.h"

@implementation Background

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
        self.isTouchEnabled = YES;
		//CGSize s = [CCDirector sharedDirector].winSize;
		
		background = [CCSprite spriteWithFile:@"back.png"];
        background.position = ccp(0,0);
        background.anchorPoint=ccp(0,0);
        [self addChild:background z:-1];
		
		// create reset button
		
		//Set up sprite
		
		//[self scheduleUpdate];
	}
	return self;
}

@end
