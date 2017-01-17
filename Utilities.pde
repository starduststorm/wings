Random rand = new Random();

private int randomSign()
{
  return (rand.nextBoolean() ? 1 : -1);
}

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

public void lineGradient(float x1, float y1, float x2, float y2, color c1, color c2, float alpha)
{
  colorMode(HSB, 100);
  
  final int segments = 32;
  
  float lastX = x1;
  float lastY = y1;
  for (int i = 1; i <= segments; ++i) {
    // Draw "segments", not points
    float x = x1 + i * (x2 - x1) / segments;
    float y = y1 + i * (y2 - y1) / segments;
    color c;
    if (hue(c1) != hue(c2)) {
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