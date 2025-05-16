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
  
  PImage gradient;
  int gradientTiles = 4;
  
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
    
    gradient = makeGradient(wingWidth, wingHeight / 2, gradientTiles);
  }
  
  public PGraphics makeGradient(int gradWidth, int gradHeight, int widthRepetitions)
  {
    int slant = 2+(int)random(5);
    
    PGraphics img = createGraphics(gradWidth * widthRepetitions, gradHeight);
    img.beginDraw();
    
    float step = 0.5;
    img.colorMode(HSB, 100);
    colorMode(HSB, 100);
    for (int r = 0; r < widthRepetitions; r++) {
      for (float x = 0 ; x < gradWidth; x += step) {
        color startColor, endColor;
        float progress = sin(2*PI * x / (gradWidth - step));
        if (this.type == ChevronsPatternType.Rainbow) {
          // hack: cheat a little on 'repetitions' cause the rainbow needs to take up two slots
          float hueOffset = map((x + r * gradWidth)%(gradWidth*2), 0, gradWidth*2, 0, 100);
          startColor = color(hueOffset, 100, 100);
          endColor = color((40 + hueOffset) % 100, 100, 30);
        } else if (this.type == ChevronsPatternType.Monochrome) {
          startColor = color(0, 0, 50 * progress + 40);
          endColor = color(0, 0, 0);
        } else {
          startColor = color(nonColorHue, 100, 50 * progress + 40);
          endColor = color(secondHue, 100, 10);
        }
        
        lineGradient(img, 
                     r * gradWidth + x, gradHeight, 
                     r * gradWidth + x - slant, 0, 
                     startColor, endColor, 100);
      }
    }
    img.endDraw();
    return img;
  }
  
  public void drawWingSlow(float rotation, float leadingValue, int xOffset, int direction)
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
      
      lineGradient(null, 
                   wingWidth + direction * chevronVertex, displayHeight / 2.0, 
                   wingWidth + direction * (chevronVertex - 5), 0, 
                   startColor, endColor, alpha);
      lineGradient(null,
                   wingWidth + direction * chevronVertex, displayHeight / 2.0, 
                   wingWidth + direction * (chevronVertex - 5), displayHeight, 
                   startColor, endColor, alpha);
      popMatrix();
    }
  }
  
  public void drawWing(float leadingEdge, float xOffset, boolean mirror)
  {
    pushMatrix();
    translate(xOffset, 0);
    if (mirror) {
      scale(-1, 1);
      translate(-wingWidth, 0.0);
    }
    clip(0, 0, wingWidth, wingHeight);
    translate(leadingEdge % (2*wingWidth) - wingWidth, 0);
    image(gradient, -wingWidth, 0);
    translate(0, wingHeight / 2);
    scale(1, -1);
    translate(0, -wingHeight / 2);
    image(gradient, -wingWidth, 0);
    noClip();
    popMatrix();
  }
  
  public void update()
  {
    int mils = millis();
    float alpha = (mils - startMillis < 2000 ? 100 * (mils - startMillis) / 2000 : 100);
    tint(100, alpha);
    drawWing(leadingEdge, 0, true);
    drawWing(leadingEdge, wingWidth, false);
    noTint();
    
    //translate(0, wingHeight + 10);
    //clip(0, 0, wingWidth, displayHeight);
    //drawWingSlow(leftRotation, leftLeadingValue, 0, -1);
    //noClip();
    //clip(wingWidth, 0, wingWidth, displayHeight);
    //drawWingSlow(rightRotation, rightLeadingValue, wingWidth, 1);
    //noClip();
    
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