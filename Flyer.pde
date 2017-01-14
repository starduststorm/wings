import java.util.Random;

int modeCount = 0;
final int HandElbowLine = modeCount++; // doesn't use correct coordinate translation
final int BigAssCircles = modeCount++; // doesn't use correct coordinate translation
final int UpTheStrands = modeCount++;  // FIXME: this is the only mode that doesn't suck.
final int WaveyPatterns = modeCount++; // not interactive yet

final int FlyerModeCount = 2;
 
final int TEST_MODE = BigAssCircles;

private class BezierPath {
  PVector p1, p2;
  PVector c1, c2;
  color col;
}

public class Flyer {
  public KinectPV2 kinect;
  public KSkeleton skeleton;
  public OPC opc;
  
  Random random;
  private int mode;
  boolean useColor;
  
  PVector lastLeftHand = null;
  PVector lastLeftElbow = null;
  PVector lastRightHand = null;
  PVector lastRightElbow = null;
  
  // mode vars
  
  ArrayList<BezierPath> beziers;
  
  //
  
  Flyer()
  {
    random = new Random();
    beziers = new ArrayList<BezierPath>();
  }
  
  //private PVector screenPositionForJoint(int joint)
  //{
  //  PVector jointPos3D = new PVector();
  //  kinect.getJointPositionSkeleton(userID, joint, jointPos3D);
    
  //  PVector jointPos = new PVector();
  //  kinect.convertRealWorldToProjective(jointPos3D, jointPos);
  //  return jointPos;    
  //}
  
  public PVector coordsForJoint(KJoint joint)
  {
    return new PVector(joint.getX() / 512.0 * width, joint.getY() / 424 * height);
  }
  
  private PVector wingPositionForJoint(KJoint joint, boolean isRight)
  {
    PVector jointPx = this.coordsForJoint(joint);
    PVector wingPos = new PVector();
    wingPos.x = (jointPx.x * wingWidth / imageWidth) + (isRight ? wingWidth : 0.0);
    wingPos.y = (jointPx.y * wingHeight / imageHeight);
    return wingPos;
  }
  
  public void update()
  {
    if (this.skeleton == null) {
      lastLeftElbow = null;
      lastLeftHand = null;
      lastRightElbow = null;
      lastRightHand = null;
      
      useColor = (int)random(2) == 0;
      return;
    }
      
    if (TEST_MODE != 0) {
      mode = TEST_MODE;
    } else if (this.skeleton != null) {
      mode = random.nextInt(FlyerModeCount);
    }
    
    // fuck java's switch statement
    if (mode == HandElbowLine) {
      runModeHandElbowLine();
    } else if (mode == BigAssCircles) {
      runModeBigAssCircles();
    } else if (mode == UpTheStrands) {
      runModeUpTheStrands();
    //} else if (mode == WaveyPatterns) {
    //  runModeWaveyPatterns();
    }
  }
  
  private void runModeBigAssCircles()
  {
    KJoint[] joints = this.skeleton.getJoints();
    PVector leftHandPx = wingPositionForJoint(joints[KinectPV2.JointType_HandLeft], false);
    PVector rightHandPx = wingPositionForJoint(joints[KinectPV2.JointType_HandRight], true);
    
    colorMode(HSB, 100);
    fill(50, 0, 100);
    noStroke();
    ellipse(leftHandPx.x, leftHandPx.y, 4, 20);
    ellipse(rightHandPx.x, rightHandPx.y, 4, 20);
  }
  
  private void runModeUpTheStrands()
  {
    KJoint[] joints = this.skeleton.getJoints();
    PVector leftHandPx = wingPositionForJoint(joints[KinectPV2.JointType_HandLeft], false);
    PVector rightHandPx = wingPositionForJoint(joints[KinectPV2.JointType_HandRight], true);
    
    colorMode(HSB, 100);
    noStroke();
    if (lastLeftHand != null) {
      float speed = abs(lastLeftHand.x - leftHandPx.x);
      int hue = (int)(200 * speed);
      if (useColor) {
        hue = min(90, hue);
        fill(hue, 100, 100);
      } else {
        fill(0, 0, 100);
      }
      rect(0, min(leftHandPx.y, lastLeftHand.y), wingWidth, abs(leftHandPx.y - lastLeftHand.y));
    }
    
    lastLeftHand = leftHandPx;
    lastRightHand = rightHandPx;    
  }
  
  private float contain(float f, float theMax)
  {
    if (f < 0) {
      return 0;
    }
    if (f > theMax) { 
      return theMax;
    }
    return f;
  }
  
  //private void runModeWaveyPatterns()
  //{
  //  final int segmentCount = 30;
    
  //  colorMode(HSB, 100);
    
  //  if (userID != lastUserID || beziers.size() == 0) {
  //    for (int i = 0; i < segmentCount; ++i) {
  //      BezierPath path = new BezierPath();
  //      path.p1 = new PVector(random.nextInt(wingsRegionWidth), random.nextInt(wingsRegionHeight));
  //      path.p2 = new PVector(random.nextInt(wingsRegionWidth), random.nextInt(wingsRegionHeight));
  //      path.c1 = new PVector(path.p1.x + random.nextInt(10) - 5,
  //                            path.p1.y + random.nextInt(10) - 5);
  //      path.c2 = new PVector(path.p2.x + random.nextInt(10) - 5,
  //                            path.p2.y + random.nextInt(10) - 5);

  //      path.col = color(random(100), random(30) + 70, 100);                               
  //      beziers.add(path);
  //    }
  //  }
    
  //  for (int i = 0; i < beziers.size(); ++i) {
  //    BezierPath path = beziers.get(i);
  //    path.p1.x = contain(path.p1.x + random(2) - 1.0, wingsRegionWidth);
  //    path.p1.y = contain(path.p1.y + random(2) - 1.0, wingsRegionHeight);
  //    path.p2.x = contain(path.p2.x + random(2) - 1.0, wingsRegionWidth);
  //    path.p2.y = contain(path.p2.y + random(2) - 1.0, wingsRegionHeight);
  //    path.c1.x = path.c1.x + random(4) - 2.0;
  //    path.c1.y = path.c1.y + random(4) - 2.0;
  //    path.c2.x = path.c2.x + random(4) - 2.0;
  //    path.c2.y = path.c2.y + random(4) - 2.0;
  //  }
    
  //  // bezier(x1, y1, x2, y2, x3, y3, x4, y4)
  //  // bezierPoint(p1, c1, c2, p2, t)   p == point, c == control
    
  //  noFill();
    
  //  PVector lastPoint = null;
  //  for (int i = 0; i < beziers.size(); ++i) {
  //    BezierPath path = beziers.get(i);
  //    stroke(path.col);
  //    float x = bezierPoint(path.p1.x, path.c1.x, path.c1.y, path.p1.y, i / (float)segmentCount);
  //    float y = bezierPoint(path.p2.x, path.c2.x, path.c2.y, path.p2.y, i / (float)segmentCount);
      
  //    println("x = ", x, ", y = ", y);
      
////      stroke(10, 255, 50);
////      x = random.nextInt(wingsRegionWidth);
////      y = random.nextInt(wingsRegionHeight);
      
  //    if (lastPoint != null) {
  //      line(lastPoint.x, lastPoint.y, x, y);
  //      lastPoint = null;
  //    } else {
  //      lastPoint = new PVector(x, y);
  //    }
  //  }
  //}
  
  private void runModeHandElbowLine()
  {
    KJoint[] joints = skeleton.getJoints();
    PVector leftHandPx = wingPositionForJoint(joints[KinectPV2.JointType_HandLeft], false);
    PVector leftElbowPx = wingPositionForJoint(joints[KinectPV2.JointType_ElbowLeft], false);
    PVector rightHandPx = wingPositionForJoint(joints[KinectPV2.JointType_HandRight], true);
    PVector rightElbowPx = wingPositionForJoint(joints[KinectPV2.JointType_ElbowRight], true);
    
    leftHandPx.x += wingWidth;
    leftElbowPx.x += wingWidth;
    rightHandPx.x -= wingWidth;
    rightElbowPx.x -= wingWidth;
    
    clip(0, 0, wingWidth, wingHeight);
    colorMode(HSB, wingHeight, 100, 100);
    
    drawLongLineThrough(leftHandPx, leftElbowPx, lastLeftHand, lastLeftElbow);
//    fill(#0000FF);
//    rect(0, 0, wingsRegionWidth, wingsRegionHeight);
    noClip();
    
    clip(wingWidth, 0, wingWidth, wingHeight);
    stroke(rightHandPx.y, 100, 100);
    drawLongLineThrough(rightHandPx, rightElbowPx, lastRightHand, lastRightElbow);
//    fill(#FF0000);
//    rect(0, 0, wingsRegionWidth, wingsRegionHeight);
    noClip();
    
    lastLeftHand = leftHandPx;
    lastLeftElbow = leftElbowPx;
    lastRightHand = rightHandPx;
    lastRightElbow = rightElbowPx;
  }
  
  private void drawLongLineThrough(PVector p1, PVector p2, PVector lastP1, PVector lastP2)
  {
    {
      float slope = (p1.y - p2.y) / (p1.x - p2.x);
      int sign = (slope > 0 ? 1 : -1);
      
      p1.x -= sign * wingsRegionWidth;
      p1.y -= sign * wingsRegionWidth * slope;
      
      p2.x += sign * wingsRegionWidth;
      p2.y += sign * wingsRegionWidth * slope;
    }
        
    
    if (lastP1 != null && lastP2 != null) {
      noStroke();
      fill(p1.y, 100, 100);
      
      float slope = (lastP1.y - lastP2.y) / (lastP1.x - lastP2.x);
      int sign = (slope > 0 ? 1 : -1);
      
      lastP1.x -= sign * wingsRegionWidth;
      lastP1.y -= sign * wingsRegionWidth * slope;
      
      lastP2.x += sign * wingsRegionWidth;
      lastP2.y += sign * wingsRegionWidth * slope;

      
      triangle(p2.x, p2.y, p1.x, p1.y, lastP2.x, lastP2.y);
      triangle(lastP2.x, lastP2.y, lastP1.x, lastP1.y, p1.x, p1.y);
    } else {
      stroke(p1.y, 100, 100);
      line(p2.x, p2.y, p1.x, p1.y);
    }
  }
}

// GESTURE_CLICK, GESTURE_HAND_RAISE, GESTURE_WAVE, IMG_MODE_DEFAULT, 
// IMG_MODE_RGB_FADE, NODE_DEPTH, NODE_GESTURE, NODE_HANDS, NODE_IMAGE, NODE_IR, NODE_NONE, 
// NODE_PLAYER, NODE_RECORDER, NODE_SCENE, NODE_USER, 
// RUN_MODE_DEFAULT, RUN_MODE_MULTI_THREADED, RUN_MODE_SINGLE_THREADED, 

// SKEL_HEAD, SKEL_LEFT_ELBOW, SKEL_LEFT_FINGERTIP, SKEL_LEFT_FOOT, SKEL_LEFT_HAND, SKEL_LEFT_HIP, 
// SKEL_LEFT_KNEE, SKEL_LEFT_SHOULDER, SKEL_NECK, SKEL_RIGHT_ELBOW, SKEL_RIGHT_FINGERTIP, SKEL_RIGHT_FOOT, 
// SKEL_RIGHT_HAND, SKEL_RIGHT_HIP, SKEL_RIGHT_KNEE, SKEL_RIGHT_SHOULDER, SKEL_TORSO