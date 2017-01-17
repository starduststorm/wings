public enum ChevronsPatternType {
  Random,
  Rainbow,
  MixedColor,
  Monochrome,
};

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
  
  public void drawWing(float rotation, float leadingValue, int xOffset, int direction)
  {
    colorMode(HSB, 100);
    float rotationMulti = abs(cos(rotation));
    int mils = millis();
    float alpha = (mils - startMillis < 2000 ? 100 * (mils - startMillis) / 2000 : 100);
    
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
                   startColor, endColor, alpha);
      lineGradient(wingWidth + direction * chevronVertex, displayHeight / 2.0, 
                   wingWidth + direction * (chevronVertex - 5), displayHeight, 
                   startColor, endColor, alpha);
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