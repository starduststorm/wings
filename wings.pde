import SimpleOpenNI.*;

OPC opc;
SimpleOpenNI kinect;
Flyer flyer;

PulsePattern pulsePattern;
BitsPattern bitsPattern;
FadeParityPattern fadeParityPattern;

boolean FAKE_USER = false;

final int kFingerLengths[] = {64, 64, 64, 64, 64, 64, 64, 64};
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

int positionedUserId = -1;
int lastUserSeenMillis = -1;

void setup()
{
  opc = new OPC(this, "127.0.0.1", 7890);
  
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser();
  
  int depthWidth = kinect.depthWidth();
  int depthHeight = kinect.depthHeight();
  
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
  size(wingsRegionWidth + imageWidth, max(wingsRegionHeight, imageHeight), P3D); 
  
  frameRate(60);
  textSize(8);
}

void draw()
{
  int currentMillis = millis();
  
  kinect.update();
  
  // Keep the same positionedUserId if possible
  int[] users = kinect.getUsers();
  if (users != null && users.length > 0) {
    boolean positionedUserStillTracked = false;
    for (int i = 0; i < users.length; ++i) {
      if (users[i] == positionedUserId && kinect.isTrackingSkeleton(users[i]) && userIsInPosition(users[i])) {
        positionedUserStillTracked = true;
        break;
      } 
    }
    if (!positionedUserStillTracked) {
      positionedUserId = -1;
    }
    if (!positionedUserStillTracked) {
      for (int i = 0; i < users.length; ++i) {
        if (kinect.isTrackingSkeleton(users[i]) && userIsInPosition(users[i])) {
          positionedUserId = users[i];
          break;
        }
      }
    }
    if (positionedUserId != -1) {
      lastUserSeenMillis = currentMillis;
    }
  } else {
    positionedUserId = -1;
  }
  
  if (FAKE_USER) {
    positionedUserId = 0;
    lastUserSeenMillis = currentMillis;
  }
  
  // Draw infrared image and skeleton
  PImage depthImage = kinect.depthImage();
  if (depthImage != null) {
    blendMode(BLEND);
    pushMatrix();
    translate(wingsRegionWidth, 0, 0);
    image(kinect.depthImage(), 0, 0);
    
    stroke(color(255,0,0));
    colorMode(HSB, 100);
    
    if (positionedUserId != -1) {
      drawSkeleton(positionedUserId);
    }
    
    popMatrix();
  }
  
  // Fade out the old patterns
  int fadeRate = (positionedUserId == -1 ? 6 : 2);
  colorMode(RGB, 100);
  blendMode(SUBTRACT);
  noStroke();
  fill(fadeRate, fadeRate, fadeRate, 100);
  rect(0, 0, wingsRegionWidth, wingsRegionHeight);
    
  // Draw flyer stuff
  blendMode(BLEND);
  flyer.userID = positionedUserId;
  flyer.update();
  
  // Start patterns a second after we stop tracking someone
  if (currentMillis - lastUserSeenMillis > 1000) {
    if (!pulsePattern.isRunning() && !bitsPattern.isRunning() && !fadeParityPattern.isRunning()) {
      int patternChoice = (int)random(4);
      
      // Twice as likely cause it jankily picks a couple modes
      if (patternChoice == 0 || patternChoice == 1) {
        pulsePattern.startIfNeeded();
      } else if (patternChoice == 2) {
        bitsPattern.startIfNeeded();
      } else if (patternChoice == 3) {
        fadeParityPattern.startIfNeeded();
      }
    }
  }

  pulsePattern.update(positionedUserId); 
  bitsPattern.update(positionedUserId);
  fadeParityPattern.update(positionedUserId);
  
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

boolean userIsInPosition(int userID)
{
  // Hasn't moved in a while? Probably gone.
  // The kinect lib likes to keep a bogus frame around for a while, unmoving, at the edge of the frame.
  
  PVector newLeftHandPos = new PVector();
  PVector newRightHandPos = new PVector();
  kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_LEFT_HAND, newLeftHandPos);
  kinect.getJointPositionSkeleton(userID, SimpleOpenNI.SKEL_RIGHT_HAND, newRightHandPos);
  
  if (newLeftHandPos.x == leftHandPosition.x && newLeftHandPos.y == leftHandPosition.y &&
      newRightHandPos.x == rightHandPosition.x && newRightHandPos.y == rightHandPosition.y) {
    unmovedFrames++;
    if (unmovedFrames > 30) {
      return false;
    }
  }
  leftHandPosition = newLeftHandPos;
  rightHandPosition = newRightHandPos;
  
  PVector centerOfMass = new PVector();
  kinect.getCoM(userID, centerOfMass);
  if (abs(-200 - centerOfMass.x) < 200) {  
    return true;
  }
  return false;
}

void drawSkeleton(int userId)
{
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_TORSO);
  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

void onNewUser(SimpleOpenNI context, int userId)
{
  println("User " + userId + " appeared!");  
  context.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("User " + userId + " disappeared!");
}

