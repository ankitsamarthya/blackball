//
//  HelloWorldLayer.mm
//  ARCBox2d
//
//  Created by Ankit Samarthya on 16/06/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"
#import "GB2ShapeCache.h"
// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#include "Background.h"
#import "PhysicsSprite.h"

enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

@implementation HelloWorldLayer

b2Body* ballBody;
int checkstart=0;
b2BodyDef groundBodyDef;
b2BodyDef groundBodyDef2;
b2BodyDef enemybody;
float counter;
int firstrand,secondrand;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	Background *back = [Background node];
	// add layer as a child to scene
    [scene addChild: back z:-1];
	[scene addChild: layer z:1];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
        self.isTouchEnabled = YES;
		//CGSize s = [CCDirector sharedDirector].winSize;
		
        
		// init physics
		[self initPhysics];
		
		// create reset button
		
		//Set up sprite
		
		[self scheduleUpdate];
	}
	return self;
}

-(void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
    delete contactlistener;
    contactlistener = NULL;
	
}	

-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]];
	}];
	
	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
		achivementViewController.achievementDelegate = self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:achivementViewController animated:YES];
		
	}];
	
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
		
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, reset, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
	[self addChild: menu z:-1];	
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
    
    counter=2.0;
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);

	contactlistener = new ContactListener();
    world->SetContactListener(contactlistener);
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
    
    [[GB2ShapeCache sharedShapeCache]addShapesWithFile:@"level.plist"];
    

    firstrand = [self getRandomNumberBetween:1 to:4];
    secondrand = [self getRandomNumberBetween:1 to:4];
    level1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"level%d.png",firstrand]];

    [self addChild:level1 z:3 tag:1];
    
    level2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"level%d.png",secondrand]];

    [self addChild:level2 z:4 tag:1];

    
    ball = [CCSprite spriteWithFile:@"ball.png"];
    [self addChild:ball z:5 tag:2];
    
   
    
    
	
	//m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	//world->SetDebugDraw(m_debugDraw);
	
	//uint32 flags = 0;
	//flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	//m_debugDraw->SetFlags(flags);
	
	
	// Define the ground body.
	//b2BodyDef groundBodyDef;
    groundBodyDef.type = b2_staticBody;
    CGPoint p1=CGPointMake(0, 0);
	groundBodyDef.position=[self toMeters:p1]; // bottom-left corner
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
    groundBody->SetUserData((__bridge void*)level1);
    
    //b2BodyDef groundBodyDef2;
    groundBodyDef2.type = b2_staticBody;
    CGPoint p2=CGPointMake([level1 boundingBox].size.width-1, 0);
	groundBodyDef2.position=[self toMeters:p2];
	//groundBodyDef2.position.Set([level1 boundingBox].size.width-1,0); // bottom-left corner
	b2Body* groundBody2 = world->CreateBody(&groundBodyDef2);
    groundBody2->SetUserData((__bridge void*)level2);
    
    
    b2BodyDef ballDef;
    ballDef.type = b2_dynamicBody;
    CGPoint point=CGPointMake(50, 200);
    ballDef.position=[self toMeters:point];
	ballBody = world->CreateBody(&ballDef);
    ballBody->SetUserData((__bridge void*)ball);
    
    [[GB2ShapeCache sharedShapeCache]addFixturesToBody:groundBody forShapeName:[NSString stringWithFormat:@"level%d",firstrand]];
	[level1 setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:[NSString stringWithFormat:@"level%d",firstrand]]];
    
    [[GB2ShapeCache sharedShapeCache]addFixturesToBody:groundBody2 forShapeName:[NSString stringWithFormat:@"level%d",secondrand]];
	[level2 setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:[NSString stringWithFormat:@"level%d",secondrand]]];

    
    [[GB2ShapeCache sharedShapeCache]addFixturesToBody:ballBody forShapeName:@"ball"];
	[ball setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"ball"]];
    
    CGRect worldFollowBoundary = CGRectMake(0, 0, s.width*2, s.height);
    [self runAction:[CCFollow actionWithTarget:ball worldBoundary:worldFollowBoundary]];
    
    
    
    [self schedule: @selector(tick:)];
    [self schedule: @selector(scroll:)];
}

-(void)scroll:(ccTime)dt{
    NSLog(@"%f->%f",counter,ball.position.x);
    if (ball.position.x>((counter-0.5)*[level2 boundingBox].size.width)) {
        
        counter=counter+1.0;
        firstrand=[self getRandomNumberBetween:1 to:4];
/*        if (firstrand == 4) {
            CCSprite *enemy = [CCSprite spriteWithFile:@"enemy-1_final.png"];
            [self addChild:enemy z:4 tag:3];
            
            enemybody.type = b2_staticBody;
            CGPoint p1=CGPointMake(((counter-1.0)*[level2 boundingBox].size.width-1)+[level2 boundingBox].size.width/2, 0);
            enemybody.position=[self toMeters:p1]; 
            b2Body* enemyBody = world->CreateBody(&enemybody);
            enemyBody->SetUserData((__bridge void*)enemy);
            
            [[GB2ShapeCache sharedShapeCache]addFixturesToBody:enemyBody forShapeName:@"enemy-1_final"];
            [enemy setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"enemy-1_final"]];

        }   */
        level1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"level%d.png",firstrand]];
        [self addChild:level1 z:3 tag:1];
        
        groundBodyDef.type = b2_staticBody;
        CGPoint p1=CGPointMake((counter-1.0)*[level2 boundingBox].size.width-1, 0);
        groundBodyDef.position=[self toMeters:p1]; // bottom-left corner
        b2Body* groundBody = world->CreateBody(&groundBodyDef);
        groundBody->SetUserData((__bridge void*)level1);
        
        [[GB2ShapeCache sharedShapeCache]addFixturesToBody:groundBody forShapeName:[NSString stringWithFormat:@"level%d",firstrand]];
        [level1 setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:[NSString stringWithFormat:@"level%d",firstrand]]];
        
        CGSize s = [[CCDirector sharedDirector] winSize];
        CGRect worldFollowBoundary = CGRectMake(0, 0, s.width*counter, s.height);
        [self runAction:[CCFollow actionWithTarget:ball worldBoundary:worldFollowBoundary]];
    }
   
    
}

-(void) tick: (ccTime) dt
{
    int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	    
    if(checkstart==1){
        ballBody->SetLinearVelocity(b2Vec2(2.9,ballBody->GetLinearVelocity().y));
    }
    
	world->Step(dt, velocityIterations, positionIterations);
    for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
    {
        if (b->GetUserData() != NULL)
        {
            //ballBody->SetLinearVelocity(b2Vec2(1.0,0.0));
            CCSprite *myActor = (__bridge CCSprite*)b->GetUserData();
            myActor.position = CGPointMake(
                                           b->GetPosition().x * PTM_RATIO,
                                           b->GetPosition().y * PTM_RATIO );
            //myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }
    }
    
}

-(b2Vec2) toMeters:(CGPoint)point
{
    return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}
-(CGPoint) toPixels:(b2Vec2)vec
{
    return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

-(void) draw
{
	
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
}

-(void) addNewSpriteAtPosition:(CGPoint)p
{
	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCNode *parent = [self getChildByTag:kTagParentNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];						
	[parent addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
	
	[sprite setPhysicsBody:body];
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);	
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}


-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog(@"hello");
    if(contactlistener->detectballground == false){
    ballBody->ApplyLinearImpulse(b2Vec2(0.0, 30.0), ballBody->GetWorldCenter());
    checkstart=1;
    }
    return YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		[self addNewSpriteAtPosition: location];
	}
   
}

- (void) registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
