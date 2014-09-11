//
//  HelloWorldLayer.h
//  ARCBox2d
//
//  Created by Ankit Samarthya on 16/06/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    CCSprite *ball;
    ContactListener *contactlistener;
    CCSprite *level1;
    CCSprite *level2;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void) scroll:(ccTime)dt;
-(int)getRandomNumberBetween:(int)from to:(int)to;

@end
