import java.util.*;

Random rand = new Random();

private int randomSign()
{
  return (rand.nextBoolean() ? 1 : -1);
}

private class Bit
{
  private PVector pos;
  PVector direction;
  private int birthdate;
  
  public Bit(PVector initialPosition)
  {
    birthdate = millis();
    pos = initialPosition;
    if (randomSign() > 0) { // horizontal
      direction = new PVector(randomSign() * 0.01, 0);
    } else { // vertical
      direction = new PVector(0, randomSign() * 0.01);    
    }
  }
  
  public int age()
  {
    return millis() - birthdate;
  }
  
  public float ageAlpha()
  {
    float age = this.age();
    if (age < 500) {
      return 1.0 * age / 500.0;
    } else if (age > 2500) {
      return 1.0 * (3000 - age) / 500;
    }
    return 1.0;
  }
  
  public void drift()
  {
    pos.add(direction);
  }
}

public class BitsPattern extends IdlePattern {
  LinkedList<Bit> bits;
  color bitsColor;
  
  public BitsPattern(int displayWidth, int displayHeight)
  {
    super(displayWidth, displayHeight);
    bits = new LinkedList<Bit>();
  }
  
  public void startPattern()
  {
    super.startPattern();
    colorMode(RGB, 100);
    // bits re-appearing, get a new color
    color[] colors = {color(5,70,5), color(70, 5, 5), color(5, 5, 70)};
    bitsColor = colors[(int)random(colors.length)];
    do {
      bitsColor = color((int)random(100),(int)random(100),(int)random(100));
    } while ((red(bitsColor) > 8 && green(bitsColor) > 8 && blue(bitsColor) > 8)
          || (red(bitsColor) < 20 && green(bitsColor) < 20 && blue(bitsColor) < 20));
  }
  
  public void update()
  {
    if (this.isRunning()) {
      for (int i = 0; i < 3; ++i) {
        Bit newBit = new Bit(new PVector((int)random(0, displayWidth) + 0.5, (int)random(0, displayHeight)));
        bits.add(newBit);
      }
    }
    draw();
  }
  
  public void draw()
  {
    blendMode(BLEND);
    colorMode(RGB, 100);
    noFill();
    
    for (Iterator<Bit> it = bits.iterator(); it.hasNext(); ) {
      Bit bit = it.next();
      float alpha = 100 * bit.ageAlpha();
      stroke(bitsColor, alpha);
      point(bit.pos.x, bit.pos.y, 0);
      
      if (bit.age() > 3000) {
        it.remove();
      } else {
        bit.drift();
      }
    }
    if (this.isStopping() && bits.size() == 0) {
      this.stopCompleted();
    }
  }
}