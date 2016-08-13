import SimpleOpenNI.*;

OPC opc;
SimpleOpenNI kinect;
Flyer flyer;
PulsePattern pulsePattern;

final int kFingerLengths[] = {64, 64, 64, 64, 64, 64, 64, 64};

final int wingWidth = 8;
final int wingHeight = 64;
final int wingsRegionWidth = 16;
final int wingsRegionHeight = wingHeight;

int imageWidth;
int imageHeight;

void setup()
{
  opc = new OPC(this, "127.0.0.1", 7890);
  
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser();
  
  imageWidth = kinect.depthWidth();
  imageHeight = kinect.depthHeight();
    
  flyer = new Flyer();
  flyer.kinect = kinect;
  flyer.opc = opc;
  
  pulsePattern = new PulsePattern(0, 0, wingsRegionWidth, wingsRegionHeight);
  
  background(0,0,0);
  size(wingsRegionWidth + imageWidth, max(wingsRegionHeight, imageHeight), P3D); 
  
  frameRate(30);
  textSize(8);
}

void draw()
{
  kinect.update();
  
  // Draw infrared image and skeleton
  blendMode(BLEND);
  pushMatrix();
  translate(wingsRegionWidth, 0, 0);
  image(kinect.depthImage(), 0, 0);
  
  
  stroke(color(255,0,0));
  colorMode(HSB, 100);
  int positionedUserId = -1;
  int[] users = kinect.getUsers();
  for (int i = 0; i < users.length; ++i) {
    if (kinect.isTrackingSkeleton(users[i]) && userIsInPosition(users[i])) {
      positionedUserId = users[i];
      drawSkeleton(users[i]);
      break;
    }
  }
  popMatrix();
  
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
   
  pulsePattern.update(positionedUserId); 
  
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

boolean userIsInPosition(int userId)
{
  PVector centerOfMass = new PVector();
  kinect.getCoM(userId, centerOfMass);
//  println(centerOfMass); 
  return true;
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

