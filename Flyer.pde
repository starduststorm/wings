import java.util.Random;

int modeCount = 1;
final int HandElbowLine = modeCount++;
final int WaveyPatterns = modeCount++;
final int FlyerModeCount = modeCount;

final int TEST_MODE = HandElbowLine;


private class BezierPath {
  PVector p1, p2;
  PVector c1, c2;
}

public class Flyer {
  public int userID;
  public int lastUserID;
  public SimpleOpenNI kinect;
  public OPC opc;
  
  Random random;
  private int mode;
  
  // mode vars
  
  ArrayList<BezierPath> beziers;
  
  //
  
  Flyer()
  {
    random = new Random();
    beziers = new ArrayList<BezierPath>();
  }
  
  private PVector screenPositionForJoint(int joint)
  {
    PVector jointPos3D = new PVector();
    kinect.getJointPositionSkeleton(userID, joint, jointPos3D);
    
    PVector jointPos = new PVector();
    kinect.convertRealWorldToProjective(jointPos3D, jointPos);
    return jointPos;    
  }
  
  private PVector wingPositionForJoint(int joint, boolean isRight)
  {
    PVector jointPx = screenPositionForJoint(joint);
    PVector wingPos = new PVector();
    wingPos.x = (jointPx.x * wingWidth / imageWidth) + (isRight ? wingWidth : 0.0);
    wingPos.y = (jointPx.y * wingHeight / imageHeight); 
    return wingPos;
  }
  
  public void update()
  {
    if (userID == -1 && TEST_MODE == 0) {
      return;
    }
        
    if (TEST_MODE != 0) {
      mode = TEST_MODE;
    } else if (userID != lastUserID) {
      mode = random.nextInt(FlyerModeCount);       
    }
    
    // fuck java's switch statement
    if (mode == HandElbowLine) {
        runModeHandElbowLine();
    } else if (mode ==  WaveyPatterns) {
        runModeWaveyPatterns();
    }
    
    lastUserID = userID;
  }
  
  private void runModeWaveyPatterns()
  {
    final int segmentCount = 20;
    
    if (userID != lastUserID || beziers.size() == 0) {
      for (int i = 0; i < segmentCount; ++i) {
        BezierPath path = new BezierPath();
        path.p1 = new PVector(random.nextInt(wingsRegionWidth), random.nextInt(wingsRegionHeight));
        path.p2 = new PVector(random.nextInt(wingsRegionWidth), random.nextInt(wingsRegionHeight));
        path.c1 = new PVector(path.p1.x + random.nextInt(10) - 5,
                              path.p1.y + random.nextInt(10) - 5);
        path.c2 = new PVector(path.p2.x + random.nextInt(10) - 5,
                              path.p2.y + random.nextInt(10) - 5);
                              
        beziers.add(path);
      }
    }
    
    // bezier(x1, y1, x2, y2, x3, y3, x4, y4)
    // bezierPoint(p1, c1, c2, p2, t)   p == point, c == control
    colorMode(HSB, 100);
    noFill();
    stroke(0, 0, 255);
    
    PVector lastPoint = null;
    for (int i = 0; i < beziers.size(); ++i) {
      BezierPath path = beziers.get(i);
      float x = bezierPoint(path.p1.x, path.c1.x, path.c1.y, path.p1.y, i / (float)segmentCount);
      float y = bezierPoint(path.p2.x, path.c2.x, path.c2.y, path.p2.y, i / (float)segmentCount);
      
      println("x = ", x, ", y = ", y);
      
//      stroke(10, 255, 50);
//      x = random.nextInt(wingsRegionWidth);
//      y = random.nextInt(wingsRegionHeight);
      
      if (lastPoint != null) {
        line(lastPoint.x, lastPoint.y, x, y);
        lastPoint = null;
      } else {
        lastPoint = new PVector(x, y);
      }
    }
  }
  
  private void runModeHandElbowLine()
  {
    PVector leftHandPx = wingPositionForJoint(SimpleOpenNI.SKEL_LEFT_HAND, false);
    PVector leftElbowPx = wingPositionForJoint(SimpleOpenNI.SKEL_LEFT_ELBOW, false);
    PVector rightHandPx = wingPositionForJoint(SimpleOpenNI.SKEL_RIGHT_HAND, true);
    PVector rightElbowPx = wingPositionForJoint(SimpleOpenNI.SKEL_RIGHT_ELBOW, true);
    
    clip(0, 0, wingWidth, wingHeight);
    colorMode(HSB, wingHeight, 100, 100);
    stroke(leftHandPx.y, 100, 100);
    drawLongLineThrough(leftHandPx, leftElbowPx);
//    fill(#0000FF);
//    rect(0, 0, wingsRegionWidth, wingsRegionHeight);
    noClip();
    
    clip(wingWidth, 0, wingWidth, wingHeight);
    stroke(rightHandPx.y, 100, 100);
    drawLongLineThrough(rightHandPx, rightElbowPx);
//    fill(#FF0000);
//    rect(0, 0, wingsRegionWidth, wingsRegionHeight);
    noClip();
  }
  
  private void drawLongLineThrough(PVector p1, PVector p2)
  {
    float slope = (p1.y - p2.y) / (p1.x - p2.x);
    int sign = (slope > 0 ? 1 : -1);
    
    p1.x -= sign * wingsRegionWidth;
    p1.y -= sign * wingsRegionWidth * slope;
    
    p2.x += sign * wingsRegionWidth;
    p2.y += sign * wingsRegionWidth * slope;
        
    line(p2.x, p2.y, p1.x, p1.y);
  }
}

// GESTURE_CLICK, GESTURE_HAND_RAISE, GESTURE_WAVE, IMG_MODE_DEFAULT, 
// IMG_MODE_RGB_FADE, NODE_DEPTH, NODE_GESTURE, NODE_HANDS, NODE_IMAGE, NODE_IR, NODE_NONE, 
// NODE_PLAYER, NODE_RECORDER, NODE_SCENE, NODE_USER, 
// RUN_MODE_DEFAULT, RUN_MODE_MULTI_THREADED, RUN_MODE_SINGLE_THREADED, 

// SKEL_HEAD, SKEL_LEFT_ELBOW, SKEL_LEFT_FINGERTIP, SKEL_LEFT_FOOT, SKEL_LEFT_HAND, SKEL_LEFT_HIP, 
// SKEL_LEFT_KNEE, SKEL_LEFT_SHOULDER, SKEL_NECK, SKEL_RIGHT_ELBOW, SKEL_RIGHT_FINGERTIP, SKEL_RIGHT_FOOT, 
// SKEL_RIGHT_HAND, SKEL_RIGHT_HIP, SKEL_RIGHT_KNEE, SKEL_RIGHT_SHOULDER, SKEL_TORSO
