import SimpleOpenNI.*;

OPC opc;
SimpleOpenNI kinect;
Flyer flyer;

final int strandWidth = 8;
final int strandHeight = 64;

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
  
  background(0,0,0);
  size(strandWidth + imageWidth, max(strandHeight, imageHeight), P3D); 
  
  frameRate(20);
}

void draw()
{
  kinect.update();
  
  // Draw infrared image and skeleton
  blendMode(BLEND);
  pushMatrix();
  translate(strandWidth, 0, 0);
  image(kinect.depthImage(), 0, 0);
  
  
  stroke(color(255,0,0));
  colorMode(HSB, 100);
  int positionedUserId = -1;
  int[] users = kinect.getUsers();
  for (int i = 0; i < users.length; ++i) {
    if (kinect.isTrackingSkeleton(users[i])) {
      if (userIsInPosition(users[i])) {
        positionedUserId = users[i];
        drawSkeleton(users[i]);
        break;
      }
    }
  }
  popMatrix();
  
  // Fade out the old patterns
  int fadeRate = 2;
  colorMode(RGB, 100);
  blendMode(SUBTRACT);
  noStroke();
  fill(fadeRate, fadeRate, fadeRate, 100);
  rect(0, 0, strandWidth, strandHeight);
  
  // Draw flyer stuff
  blendMode(BLEND);
  flyer.userID = positionedUserId;
  flyer.update(); 
  
  // Write pixels
  for (int x = 0; x < strandWidth; ++x) {
    for (int y = 0; y < strandHeight; ++y) {
      color c = get(x, y);
      opc.setPixel(y + strandHeight * x, c);      
    }
  }
  opc.writePixels();
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

