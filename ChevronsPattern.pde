public enum ChevronsPatternType {
  Random,
  Rainbow,
  MixedColor,
  Monochrome,
};

public <T extends Enum<?>> T randomEnum(Class<T> clazz){
  int x = rand.nextInt(clazz.getEnumConstants().length);
  return clazz.getEnumConstants()[x];
}

public color lerpColorMod(color c1, color c2, float amt)
{
  pushStyle();
  colorMode(HSB, 100);
  amt = max(0.0, min(1.0, amt));
  float h1 = hue(c1), h2 = hue(c2);
  float s1 = saturation(c1), s2 = saturation(c2);
  float b1 = brightness(c1), b2 = brightness(c2);
  if (h1 > h2) {
    // loop hue around % 100, so lerpColorMod(color(90, 100, 100), color(0, 100, 100), 0.5) == color(95, 100, 100)
    h2 += 100;
  }
  float h = lerp(h1, h2, amt);
  float s = lerp(s1, s2, amt);
  float b = lerp(b1, b2, amt);
  color c = color(h % 100, s, b);
  popStyle();
  return c;
}

public class ChevronsPattern extends IdlePattern {
  float leadingEdge;
  float leftLeadingValue, rightLeadingValue;
  float leftRotation, rightRotation;
  float leftMagnitude, rightMagnitude;
  
  ChevronsPatternType type;
  ChevronsPatternType initType;
  
  int nonColorHue;
  int secondHue;
  
  public ChevronsPattern(ChevronsPatternType type, int displayWidth, int displayHeight)
  {
    super(displayWidth, displayHeight);
    this.type = type;
    this.initType = type;
  }
  
  public void startPattern()
  {
    super.startPattern();
    
    if (this.initType == ChevronsPatternType.Random) {
      this.type = randomEnum(ChevronsPatternType.class);
    }
    
    leadingEdge = 0;
    leftLeadingValue = (int)random(100);
    rightLeadingValue = leftLeadingValue;
    leftRotation = 0;
    rightRotation = 0;
    leftMagnitude = 1.0;
    rightMagnitude = 1.0;
    
    if (this.type == ChevronsPatternType.MixedColor) {
      nonColorHue = (int)random(100);
      secondHue = nonColorHue + (int)random(-30, 30);
    }
  }
  
  private void lineGradient(float x1, float y1, float x2, float y2, color c1, color c2)
  {
    int mils = millis();
    float alpha = (mils - startMillis < 2000 ? 100 * (mils - startMillis) / 2000 : 100);
    colorMode(HSB, 100);
    
    final int segments = 32;
    
    float lastX = x1;
    float lastY = y1;
    for (int i = 1; i <= segments; ++i) {
      // Draw "segments", not points
      float x = x1 + i * (x2 - x1) / segments;
      float y = y1 + i * (y2 - y1) / segments;
      color c;
      if (this.type == ChevronsPatternType.Rainbow) {
        c = lerpColorMod(c1, c2, i / (float)segments);
      } else {
        // My implementation of lerpColorMod to treat hue as circular is buggy. Not sure what's wrong.
        c = lerpColor(c1, c2, i / (float)segments);
      }
      stroke(c, alpha);
      line(lastX, lastY, x, y);
      lastX = x;
      lastY = y;
    }
  }
  
  public void drawWing(float rotation, float leadingValue, int xOffset, int direction)
  {
    colorMode(HSB, 100);
    float rotationMulti = abs(cos(rotation));
    for (float i = -wingHeight / 2 ; i < wingHeight / 2; i+=0.5) {
      float chevronVertex = i;
      color startColor, endColor;
      if (this.type == ChevronsPatternType.Rainbow) {
        float startHue = leadingValue + (2 + 3 * rotationMulti) * i;
        startColor = color(mod(startHue, 100), 100, 100);
        endColor = color((hue(startColor) + 40) % 100, 100, 30);
      } else if (this.type == ChevronsPatternType.Monochrome) {
        startColor = color(0, 0, 50 * sin(leadingValue + (0.3 + 0.7 * rotationMulti) * i) + 40);
        endColor = color(0, 0, 0);
      } else {
        startColor = color(nonColorHue, 100, 50 * sin(leadingValue + (0.3 + 0.7 * rotationMulti) * i) + 40);
        endColor = color(secondHue, 100, 10);
      }
      
      pushMatrix();
      translate(xOffset + wingWidth / 2.0, displayHeight / 2.0, 0.0);
      rotateZ(rotation);
      translate(-xOffset - wingWidth / 2.0, -displayHeight / 2.0, 0.0);
      lineGradient(wingWidth + direction * chevronVertex, displayHeight / 2.0, 
                   wingWidth + direction * (chevronVertex - 5), 0, 
                   startColor, endColor);
      lineGradient(wingWidth + direction * chevronVertex, displayHeight / 2.0, 
                   wingWidth + direction * (chevronVertex - 5), displayHeight, 
                   startColor, endColor);
      popMatrix();
    }
  }
  
  public void update()
  {
   
    clip(0, 0, wingWidth, displayHeight);
    drawWing(leftRotation, leftLeadingValue, 0, -1);
    noClip();
    clip(wingWidth, 0, wingWidth, displayHeight);
    drawWing(rightRotation, rightLeadingValue, wingWidth, 1);
    noClip();
    
    if (this.type == ChevronsPatternType.Rainbow) {
      float chaos = 1.0;
      if (leftMagnitude == 1 && rightMagnitude == 1) {
        chaos = (0.5 * (sin(0.05 * leadingEdge) + 1.8));
      }
      leftLeadingValue = mod(leftLeadingValue - 1 * leftMagnitude * chaos, 100);
      rightLeadingValue = mod(rightLeadingValue - 1 * rightMagnitude * chaos, 100);
    } else {
      rightLeadingValue -= 0.1 * leftMagnitude;
      leftLeadingValue -= 0.1 * rightMagnitude;
    }
    
    leadingEdge = (leadingEdge + 0.1);
    if (leadingEdge > wingWidth) {
      // FIXME: fade out better?
      if (this.isStopping()) {
        this.stopCompleted();
      }
    }
  }
}