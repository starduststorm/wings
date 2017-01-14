import KinectPV2.*;

OPC opc;
KinectPV2 kinect;
Flyer flyer;

PulsePattern pulsePattern;
BitsPattern bitsPattern;
FadeParityPattern fadeParityPattern;

boolean FAKE_USER = false;

final int kFingerTopCounts[] = {0, 6, 6, 8, 13, 16, 9, 9};

final int wingWidth = 8;
final int wingHeight = 64;
final int wingsRegionWidth = 16;
final int wingsRegionHeight = wingHeight;

PVector leftHandPosition = new PVector(0, 0);
PVector rightHandPosition = new PVector(0, 0);
int unmovedFrames = 0;

int imageWidth;
int imageHeight;

int lastUserSeenMillis = -1;

void setup()
{
  opc = new OPC(this, "127.0.0.1", 7890);
  
  kinect = new KinectPV2(this);   
  kinect.enableDepthImg(true);   
  kinect.enableSkeletonDepthMap(true);
  //kinect.enableSkeleton3DMap(true);
  kinect.enableBodyTrackImg(true);
  //kinect.enableInfraredImg(true);
  kinect.init();
  
  int depthWidth = 512;
  int depthHeight = 424;
  
  if (depthWidth == 0 || depthWidth > 1000 || depthHeight == 0 || depthHeight > 1000) {
    imageWidth = 0;
    imageHeight = wingsRegionHeight + 20; // + 20 for fps
  } else {
    imageWidth = max(depthWidth, wingsRegionWidth);
    imageHeight = max(depthHeight, wingsRegionHeight);
  }
  
  flyer = new Flyer();
  flyer.kinect = kinect;
  flyer.opc = opc;
  
  pulsePattern = new PulsePattern(wingsRegionWidth, wingsRegionHeight);
  bitsPattern = new BitsPattern(wingsRegionWidth, wingsRegionHeight);
  fadeParityPattern = new FadeParityPattern(wingsRegionWidth, wingsRegionHeight);
  
  background(0,0,0);
  //size(wingsRegionWidth + imageWidth, max(wingsRegionHeight, imageHeight), P3D); 
  size(528, 424, P3D);
  
  frameRate(60);
  textSize(8);
}

public PVector coordsForJoint(KJoint joint)
{
  return new PVector(joint.getX() / 512.0 * width, joint.getY() / 424 * height);
}

void draw()
{
  int currentMillis = millis();
  
    // Draw infrared image and skeleton
  PImage depthImage = kinect.getDepthImage();
  if (depthImage != null) {
    blendMode(BLEND);
    pushMatrix();
    translate(wingsRegionWidth, 0, 0);
    image(depthImage, 0, 0);
    
    stroke(color(255,0,0));
    colorMode(HSB, 100);
    
    popMatrix();
  }
  
  
  ArrayList<KSkeleton> skeletons = kinect.getSkeletonDepthMap();
  
  boolean trackingPerson = false;
  KSkeleton trackingSkeleton = null;
  
  for (KSkeleton skeleton : skeletons) {
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      KJoint head = joints[KinectPV2.JointType_Head];
      
      PVector p = coordsForJoint(head);
      if (!Float.isFinite(p.x) || !Float.isFinite(p.y)) {
        // Tends to happen as bodies move out of the frame?
        continue;
      }
      if (userIsInPosition(skeleton)) {
        trackingPerson = true;
        lastUserSeenMillis = currentMillis;
        
        translate(wingsRegionWidth, 0, 0);
        drawSkeleton(skeleton);
        translate(-wingsRegionWidth, 0, 0);
        trackingSkeleton = skeleton;
        break;
      }
    }
  }
  
  // Fade out the old patterns
  int fadeRate = (trackingPerson ? 1 : 6);
  
  // Start patterns a second after we stop tracking someone
  if (currentMillis - lastUserSeenMillis > 1000) {
    if (!pulsePattern.isRunning() && !bitsPattern.isRunning() && !fadeParityPattern.isRunning()) {
      int patternChoice = (int)random(5);
      
      // Twice as likely cause it jankily picks a couple modes
      if (patternChoice == 0 || patternChoice == 1 || patternChoice == 2) {
        pulsePattern.startIfNeeded();
      } else if (patternChoice == 3) {
        bitsPattern.startIfNeeded();
      } else if (patternChoice == 4) {
        fadeParityPattern.startIfNeeded();
      }
    }
  }

  
  colorMode(RGB, 100);
  blendMode(SUBTRACT);
  noStroke();
  fill(fadeRate, fadeRate, fadeRate, 100);
  //rect(0, 0, wingsRegionWidth, wingsRegionHeight);
  rect(0, 0, width, height);

  blendMode(BLEND);
  flyer.skeleton = trackingSkeleton;
  flyer.update();

    
  if (FAKE_USER) {
    trackingPerson = true;
    lastUserSeenMillis = currentMillis;
  }
    
  pulsePattern.update(trackingPerson); 
  bitsPattern.update(trackingPerson);
  fadeParityPattern.update(trackingPerson);
  
  // Write pixels
  for (int x = 0; x < wingsRegionWidth; ++x) {
    for (int y = 0; y < wingsRegionHeight; ++y) {
      color c = get(x, y);
      opc.setPixel(y + wingsRegionHeight * x, c);
    }
  }
  opc.writePixels();
  
  colorMode(RGB, 100);
  noStroke();
  fill(#000000);
  rect(0, height - 20, 24, 20);
  fill(#FFFFFF);
  stroke(#FFFFFF);
  text(String.format("%.1f", frameRate), 0, height - 10);
}

boolean userIsInPosition(KSkeleton skel)
{
  //PVector newLeftHandPos = new PVector();
  //PVector newRightHandPos = new PVector();
  //kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HAND, newLeftHandPos);
  //kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_HAND, newRightHandPos);
  
  //if (newLeftHandPos.x == leftHandPosition.x && newLeftHandPos.y == leftHandPosition.y &&
  //    newRightHandPos.x == rightHandPosition.x && newRightHandPos.y == rightHandPosition.y) {
  //  unmovedFrames++;
  //  if (unmovedFrames > 30) {
  //    return false;
  //  }
  //}
  //leftHandPosition = newLeftHandPos;
  //rightHandPosition = newRightHandPos;
  
  KJoint[] joints = skel.getJoints();
  KJoint head = joints[KinectPV2.JointType_Head];
  PVector p = coordsForJoint(head);
  //println("Head pos = " + p);
  if (abs(p.x - 260) < 60) {  
    return true;
  }
  return false;
}

void drawSkeleton(KSkeleton skel)
{
  KJoint joints[] = skel.getJoints();
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  //drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  //drawJoint(joints, KinectPV2.JointType_HandTipRight);
  //drawJoint(joints, KinectPV2.JointType_FootLeft);
  //drawJoint(joints, KinectPV2.JointType_FootRight);

  //drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  //drawJoint(joints, KinectPV2.JointType_ThumbRight);

  //drawJoint(joints, KinectPV2.JointType_Head);
}

////draw joint
//void drawJoint(KJoint[] joints, int jointType)
//{
//  pushMatrix();
//  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
//  ellipse(0, 0, 25, 25);
//  popMatrix();
//}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2)
{
  //pushMatrix();
  //translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  //ellipse(0, 0, 25, 25);
  //popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}