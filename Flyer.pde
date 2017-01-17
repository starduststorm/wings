import java.util.Random;

int modeCount = 0;
final int BigAssCircles = ++modeCount;
final int UpTheStrands = ++modeCount;
final int ChevronPoint = ++modeCount;

final int HandElbowLine = -1;//modeCount++; // doesn't use correct coordinate translation
final int WaveyPatterns = -1;//modeCount++; // not interactive yet
 
final int TEST_MODE = 0;

public float mod(float f, int m)
{
  f = f % m;
  while (f < 0) {
    f += m;
  }
  return f;
}

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
  float leftHue;
  float rightHue;
  
  PVector lastLeftHand = null;
  PVector lastLeftElbow = null;
  PVector lastRightHand = null;
  PVector lastRightElbow = null;
  
  // mode vars
  
  ArrayList<BezierPath> beziers;
  
  ChevronsPattern chevrons;
  
  //
  
  Flyer()
  {
    random = new Random();
    beziers = new ArrayList<BezierPath>();
    this.chevrons = new ChevronsPattern(wingsRegionWidth, wingsRegionHeight, rand.nextBoolean());
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
    wingPos.y = (jointPx.y * wingHeight / (imageHeight * 0.8));
    return wingPos;
  }
  
  public void startFlying()
  {
    if (TEST_MODE != 0) {
      mode = TEST_MODE;
    } else if (this.skeleton != null) {
      mode = random.nextInt(modeCount) + 1;
    }
    println("FLYING WITH MODE " + mode);
    
    lastLeftElbow = null;
    lastLeftHand = null;
    lastRightElbow = null;
    lastRightHand = null;
    
    useColor = (int)random(2) == 0;
    leftHue = (int)random(100);
    rightHue = (int)random(100);
    
    if (mode == ChevronPoint) {
      chevrons.startPattern();
    }
  }
  
  public void stopFlying()
  {
    if (chevrons.isRunning()) {
      chevrons.lazyStop();
    }
  }
  
  public void update()
  {
    // fuck java's switch statement
    if (mode == HandElbowLine) {
      runModeHandElbowLine();
    } else if (mode == BigAssCircles) {
      runModeBigAssCircles();
    } else if (mode == UpTheStrands) {
      runModeUpTheStrands();
    //} else if (mode == WaveyPatterns) {
    //  runModeWaveyPatterns();
    } else if (mode == ChevronPoint) {
      runModeChevronPoint();
    }
  }
  
  private void runModeBigAssCircles()
  {
    KJoint[] joints = this.skeleton.getJoints();
    KJoint leftHand = joints[KinectPV2.JointType_HandLeft];
    KJoint rightHand = joints[KinectPV2.JointType_HandRight];
    
    int leftDirection = (leftHand.getState() == KinectPV2.HandState_Open ? -1 : 1);
    int rightDirection = (rightHand.getState() == KinectPV2.HandState_Open ? -1 : 1);

    PVector leftHandPx = wingPositionForJoint(leftHand, false);
    PVector rightHandPx = wingPositionForJoint(rightHand, true);
    
    colorMode(HSB, 100);
    noFill();
    for (int r = 0; r < 60; ++r) {
      stroke((leftHue + 50 + 1 * r) % 100, 100, 100);
      ellipse(leftHandPx.x, leftHandPx.y, 4, r);
      stroke((rightHue + 1 * r) % 100, 100, 100);
      ellipse(rightHandPx.x, rightHandPx.y, 4, r);
    }
    leftHue = mod(leftHue + leftDirection * 1.0, 100);
    rightHue = mod(rightHue + rightDirection * 1.0, 100);
  }
  
  private void runModeUpTheStrands()
  {
    KJoint[] joints = this.skeleton.getJoints();
    PVector leftHandPx = wingPositionForJoint(joints[KinectPV2.JointType_HandLeft], false);
    PVector rightHandPx = wingPositionForJoint(joints[KinectPV2.JointType_HandRight], false);
    
    colorMode(HSB, 100);
    noStroke();
    if (lastLeftHand != null) {
      float speed = abs(lastLeftHand.x - leftHandPx.x);
      if (useColor) {
        fill(leftHue, 100, 100);
      } else {
        fill(0, 0, 100);
      }
      rect(0, min(leftHandPx.y, lastLeftHand.y), wingWidth, abs(leftHandPx.y - lastLeftHand.y));
    }
    
    if (lastRightHand != null) {
      float speed = abs(lastRightHand.x - rightHandPx.x);
      if (useColor) {
        fill(rightHue, 100, 100);
      } else {
        fill(0, 0, 100);
      }
      rect(wingWidth, min(rightHandPx.y, lastRightHand.y), wingWidth, abs(rightHandPx.y - lastRightHand.y));
    }
    
    lastLeftHand = leftHandPx;
    lastRightHand = rightHandPx; 
    
    leftHue = (leftHue + 1) % 100;
    rightHue = (rightHue + 1) % 100;
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
  
  private void runModeChevronPoint()
  {
    KJoint[] joints = skeleton.getJoints();
    KJoint leftHand = joints[KinectPV2.JointType_HandLeft];
    PVector vLeftHand = coordsForJoint(leftHand);
    PVector vLeftShoulder = coordsForJoint(joints[KinectPV2.JointType_ShoulderLeft]);
    KJoint rightHand = joints[KinectPV2.JointType_HandRight];
    PVector vRightHand = coordsForJoint(rightHand);
    PVector vRightShoulder = coordsForJoint(joints[KinectPV2.JointType_ShoulderRight]);
    
    PVector negativeUnit = new PVector(-1.0, 0.0, 0.0);
    PVector leftArm = vLeftHand.sub(vLeftShoulder);
    chevrons.leftRotation = PVector.angleBetween(negativeUnit, leftArm);
    // frakking angleBetween always returns an angle < pi.
    if (leftArm.y > 0) {
      chevrons.leftRotation = 2 * PI - chevrons.leftRotation;
    }
    // Mag ranges from around 10 to around 120.
    chevrons.leftMagnitude = max(10, min(120, leftArm.mag())) / 30.0;
    
    PVector unit = new PVector(1.0, 0.0, 0.0);
    PVector rightArm = vRightHand.sub(vRightShoulder);
    chevrons.rightRotation = PVector.angleBetween(unit, rightArm);
    if (rightArm.y < 0) {
      chevrons.rightRotation = 2 * PI - chevrons.rightRotation;
    }
    chevrons.rightMagnitude = max(10, min(120, rightArm.mag())) / 30.0;
    
    chevrons.update();
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