//
//  LevelTestRevolute.m
//  MachineMash
//
//  Created by Schell Scivally on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LevelTestRevolute.h"

class Revolute
{
public:
	Revolute(b2World* world)
	{
        m_world = world;
		b2Body* ground = NULL;
		{
			b2BodyDef bd;
			ground = m_world->CreateBody(&bd);
            
			b2PolygonShape shape;
			shape.SetAsEdge(b2Vec2(-40.0f, 0.0f), b2Vec2(40.0f, 0.0f));
			ground->CreateFixture(&shape, 0.0f);
		}
        
		{
			b2CircleShape shape;
			shape.m_radius = 0.5f;
            
			b2BodyDef bd;
			bd.type = b2_dynamicBody;
            
			b2RevoluteJointDef rjd;
            
			bd.position.Set(0.0f, 20.0f);
			b2Body* body = m_world->CreateBody(&bd);
			body->CreateFixture(&shape, 5.0f);
            
			float32 w = 100.0f;
			body->SetAngularVelocity(w);
			body->SetLinearVelocity(b2Vec2(-8.0f * w, 0.0f));
            
			rjd.Initialize(ground, body, b2Vec2(0.0f, 12.0f));
			rjd.motorSpeed = 1.0f * b2_pi;
			rjd.maxMotorTorque = 10000.0f;
			rjd.enableMotor = false;
			rjd.lowerAngle = -0.25f * b2_pi;
			rjd.upperAngle = 0.5f * b2_pi;
			rjd.enableLimit = false;
			rjd.collideConnected = true;
            
			m_joint = (b2RevoluteJoint*)m_world->CreateJoint(&rjd);
		}
	}
    
	void Keyboard(unsigned char key)
	{
		switch (key)
		{
            case 'l':
                m_joint->EnableLimit(m_joint->IsLimitEnabled());
                break;
                
            case 's':
                m_joint->EnableMotor(false);
                break;
		}
	}
    
    b2World* m_world;
	b2RevoluteJoint* m_joint;
};

@implementation LevelTestRevolute

- (void)setup {
    test = new Revolute(world);
}

- (void)touchesMoved:(NSSet *)touches {
    if ([touches count] < 2) {
        test->Keyboard('s');
    }
}

@end
