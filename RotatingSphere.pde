// === Rotating 3D Sphere with PURE 2D Circles ===
// Controls:
//   + / -        -> add/remove circles
//   UP / DOWN    -> increase/decrease circle size
//   LEFT / RIGHT -> control rotation speed
// Mouse repels circles (2D plane reaction)

int numCircles = 200;
float circleRadius = 8;       // size of small circles
float sphereRadius = 250;     // radius of invisible 3D sphere

float[] x, y, z;   // circle positions in 3D
float[] vx, vy, vz; // velocities

float rotationAngle = 0;
float rotationSpeed = 0.01;

void setup() {
  size(900, 700, P3D);
  noStroke();
  initCircles();
}

void draw() {
  background(0);

  // Apply rotation and projection
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateY(rotationAngle);
  rotationAngle += rotationSpeed;

  // Store projected screen positions
  float[] sx = new float[numCircles];
  float[] sy = new float[numCircles];

  float mx = mouseX - width/2;
  float my = mouseY - height/2;

  for (int i = 0; i < numCircles; i++) {
    // Update motion
    x[i] += vx[i];
    y[i] += vy[i];
    z[i] += vz[i];

    // Keep inside sphere
    float distFromCenter = dist(0, 0, 0, x[i], y[i], z[i]);
    float limit = sphereRadius - circleRadius;
    if (distFromCenter > limit) {
      float a = atan2(y[i], x[i]);
      float e = acos(z[i] / distFromCenter);
      x[i] = cos(a) * sin(e) * limit;
      y[i] = sin(a) * sin(e) * limit;
      z[i] = cos(e) * limit;
      vx[i] *= -0.8;
      vy[i] *= -0.8;
      vz[i] *= -0.8;
    }

    // Repulsion (XY plane)
    float d = dist(mx, my, x[i], y[i]);
    if (d < 100) {
      float repelForce = (100 - d) * 0.01;
      float angle = atan2(y[i] - my, x[i] - mx);
      vx[i] += cos(angle) * repelForce;
      vy[i] += sin(angle) * repelForce;
    }

    // Friction
    vx[i] *= 0.95;
    vy[i] *= 0.95;
    vz[i] *= 0.95;

    // Project into 2D screen coords
    sx[i] = screenX(x[i], y[i], z[i]);
    sy[i] = screenY(x[i], y[i], z[i]);
  }

  popMatrix(); // leave 3D mode

  // === Draw circles in flat 2D ===
  fill(255);
  for (int i = 0; i < numCircles; i++) {
    ellipse(sx[i], sy[i], circleRadius*2, circleRadius*2);
  }

  // HUD
  hint(DISABLE_DEPTH_TEST);
  fill(200);
  textAlign(LEFT, TOP);
  text("Circles: " + numCircles +
       "\nSize: " + circleRadius +
       "\nRotation speed: " + nf(rotationSpeed, 0, 3), 10, 10);
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {
  if (key == '+' || key == '=') {
    numCircles += 20;
    initCircles();
  } else if (key == '-') {
    numCircles = max(20, numCircles - 20);
    initCircles();
  } else if (keyCode == UP) {
    circleRadius += 2;
  } else if (keyCode == DOWN) {
    circleRadius = max(2, circleRadius - 2);
  } else if (keyCode == LEFT) {
    rotationSpeed -= 0.005;
    rotationSpeed = constrain(rotationSpeed, -0.2, 0.2);
  } else if (keyCode == RIGHT) {
    rotationSpeed += 0.005;
    rotationSpeed = constrain(rotationSpeed, -0.2, 0.2);
  }
}

void initCircles() {
  x = new float[numCircles];
  y = new float[numCircles];
  z = new float[numCircles];
  vx = new float[numCircles];
  vy = new float[numCircles];
  vz = new float[numCircles];

  for (int i = 0; i < numCircles; i++) {
    float a = random(TWO_PI);
    float e = random(PI);
    float r = random(sphereRadius - circleRadius);
    x[i] = cos(a) * sin(e) * r;
    y[i] = sin(a) * sin(e) * r;
    z[i] = cos(e) * r;
    vx[i] = random(-1, 1);
    vy[i] = random(-1, 1);
    vz[i] = random(-1, 1);
  }
}
