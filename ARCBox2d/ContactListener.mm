#import "ContactListener.h"
#import "cocos2d.h"
#import "PhysicsSprite.h"

void ContactListener::BeginContact(b2Contact* contact)
{
    b2Body* bodyA=contact->GetFixtureA()->GetBody();
    b2Body* bodyB=contact->GetFixtureB()->GetBody();
    CCSprite* spriteA=(__bridge CCSprite*)bodyA->GetUserData();
    CCSprite* spriteB=(__bridge CCSprite*)bodyB->GetUserData();
    if ((spriteA.tag == 1 && spriteB.tag==2)||(spriteA.tag == 2 && spriteB.tag==1)) {
        detectballground = false;
    }
   
    
}
void ContactListener::EndContact(b2Contact* contact)
{   
    b2Body* bodyA=contact->GetFixtureA()->GetBody();
    b2Body* bodyB=contact->GetFixtureB()->GetBody();
    CCSprite* spriteA=(__bridge CCSprite*)bodyA->GetUserData();
    CCSprite* spriteB=(__bridge CCSprite*)bodyB->GetUserData();
    if ((spriteA.tag == 1 && spriteB.tag==2)||(spriteA.tag == 2 && spriteB.tag==1)) {
        detectballground = true;
    }
}